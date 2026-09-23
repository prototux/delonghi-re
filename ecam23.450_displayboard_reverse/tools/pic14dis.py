#!/usr/bin/env python3
"""
Bank-aware PIC14 (mid-range, PIC16F916) disassembler for the display board firmware.

Unlike the Ghidra export (displayboard.asm), this tracks RP0/RP1/IRP and PCLATH
through the control flow graph, so every file register is printed with the
name it really has in the selected bank (e.g. 0x0C is PIE1 when RP0=1, not PIR1)
and every CALL/GOTO resolves to its real page.

Usage:
    pic14dis.py firmware.bin                 # full listing
    pic14dis.py firmware.bin -f name|0xaddr  # a single function
    pic14dis.py firmware.bin --xref 0x4f     # who touches bank0:0x4f
"""
import argparse
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from symbols import FUNCTIONS, LABELS, RAM, DATA_RANGES, OLD_NAMES  # noqa: E402

# ---------------------------------------------------------------------------
# SFRs of the PIC16F916 (linear 9-bit address -> name)
SFR = {
    0x00: "INDF", 0x01: "TMR0", 0x02: "PCL", 0x03: "STATUS", 0x04: "FSR",
    0x05: "PORTA", 0x06: "PORTB", 0x07: "PORTC", 0x09: "PORTE", 0x0A: "PCLATH",
    0x0B: "INTCON", 0x0C: "PIR1", 0x0D: "PIR2", 0x0E: "TMR1L", 0x0F: "TMR1H",
    0x10: "T1CON", 0x11: "TMR2", 0x12: "T2CON", 0x13: "SSPBUF", 0x14: "SSPCON",
    0x15: "CCPR1L", 0x16: "CCPR1H", 0x17: "CCP1CON", 0x18: "RCSTA", 0x19: "TXREG",
    0x1A: "RCREG", 0x1E: "ADRESH", 0x1F: "ADCON0",
    0x81: "OPTION_REG", 0x85: "TRISA", 0x86: "TRISB", 0x87: "TRISC", 0x89: "TRISE",
    0x8C: "PIE1", 0x8D: "PIE2", 0x8E: "PCON", 0x8F: "OSCCON", 0x90: "OSCTUNE",
    0x91: "ANSEL", 0x92: "PR2", 0x93: "SSPADD", 0x94: "SSPSTAT", 0x95: "WPUB",
    0x96: "IOCB", 0x97: "CMCON1", 0x98: "TXSTA", 0x99: "SPBRG", 0x9C: "CMCON0",
    0x9D: "VRCON", 0x9E: "ADRESL", 0x9F: "ADCON1",
    0x105: "WDTCON", 0x106: "PORTB", 0x107: "LCDCON", 0x108: "LCDPS", 0x109: "LVDCON",
    0x10C: "EEDATL", 0x10D: "EEADRL", 0x10E: "EEDATH", 0x10F: "EEADRH",
    0x11C: "LCDSE0", 0x11D: "LCDSE1", 0x11E: "LCDSE2",
    0x181: "OPTION_REG", 0x186: "TRISB", 0x18C: "EECON1", 0x18D: "EECON2",
}
MIRRORED = {0x00, 0x02, 0x03, 0x04, 0x0A, 0x0B}  # same in every bank

BITS = {
    "STATUS": ["C", "DC", "Z", "nPD", "nTO", "RP0", "RP1", "IRP"],
    "INTCON": ["RBIF", "INTF", "T0IF", "RBIE", "INTE", "T0IE", "PEIE", "GIE"],
    "PIR1": ["TMR1IF", "TMR2IF", "CCP1IF", "SSPIF", "TXIF", "RCIF", "ADIF", "EEIF"],
    "PIE1": ["TMR1IE", "TMR2IE", "CCP1IE", "SSPIE", "TXIE", "RCIE", "ADIE", "EEIE"],
    "RCSTA": ["RX9D", "OERR", "FERR", "ADDEN", "CREN", "SREN", "RX9", "SPEN"],
    "TXSTA": ["TX9D", "TRMT", "BRGH", "-", "SYNC", "TXEN", "TX9", "CSRC"],
    "T2CON": ["T2CKPS0", "T2CKPS1", "TMR2ON", "TOUTPS0", "TOUTPS1", "TOUTPS2", "TOUTPS3", "-"],
    "SSPCON": ["SSPM0", "SSPM1", "SSPM2", "SSPM3", "CKP", "SSPEN", "SSPOV", "WCOL"],
    "SSPSTAT": ["BF", "UA", "R_nW", "S", "P", "D_nA", "CKE", "SMP"],
}


def fmt_bit(reg, b):
    names = BITS.get(reg)
    if names and names[b] != "-":
        return names[b]
    return str(b)


# ---------------------------------------------------------------------------
def load(path):
    data = open(path, "rb").read()
    words = [data[i] | (data[i + 1] << 8) for i in range(0, min(len(data), 0x2000 * 2), 2)]
    return words


class Insn:
    __slots__ = ("addr", "word", "mn", "f", "d", "b", "k", "kind")

    def __init__(self, addr, w):
        self.addr, self.word = addr, w
        self.f = self.d = self.b = self.k = None
        self.kind = "op"
        top2 = (w >> 12) & 3
        if top2 == 0:
            if w & 0x3F9F == 0:
                self.mn = "NOP"
            elif w == 0x0008:
                self.mn, self.kind = "RETURN", "ret"
            elif w == 0x0009:
                self.mn, self.kind = "RETFIE", "ret"
            elif w == 0x0063:
                self.mn = "SLEEP"
            elif w == 0x0064:
                self.mn = "CLRWDT"
            elif (w >> 7) == 0x01:
                self.mn, self.f = "MOVWF", w & 0x7F
            elif (w >> 7) == 0x02:
                self.mn = "CLRW"
            elif (w >> 7) == 0x03:
                self.mn, self.f = "CLRF", w & 0x7F
            else:
                op = (w >> 8) & 0xF
                self.mn = ["?", "?", "SUBWF", "DECF", "IORWF", "ANDWF", "XORWF", "ADDWF",
                           "MOVF", "COMF", "INCF", "DECFSZ", "RRF", "RLF", "SWAPF", "INCFSZ"][op]
                self.f, self.d = w & 0x7F, (w >> 7) & 1
                if self.mn in ("DECFSZ", "INCFSZ"):
                    self.kind = "skip"
        elif top2 == 1:
            op = (w >> 10) & 3
            self.mn = ["BCF", "BSF", "BTFSC", "BTFSS"][op]
            self.f, self.b = w & 0x7F, (w >> 7) & 7
            if op >= 2:
                self.kind = "skip"
        elif top2 == 2:
            self.k = w & 0x7FF
            if w & 0x800:
                self.mn, self.kind = "GOTO", "goto"
            else:
                self.mn, self.kind = "CALL", "call"
        else:
            k = w & 0xFF
            self.k = k
            o = (w >> 8) & 0xF
            if o < 4:
                self.mn = "MOVLW"
            elif o < 8:
                self.mn, self.kind = "RETLW", "ret"
            elif o == 8:
                self.mn = "IORLW"
            elif o == 9:
                self.mn = "ANDLW"
            elif o == 0xA:
                self.mn = "XORLW"
            elif o in (0xC, 0xD):
                self.mn = "SUBLW"
            elif o in (0xE, 0xF):
                self.mn = "ADDLW"
            else:
                self.mn = "?"


# Analysis state: tuple (RP0, RP1, IRP, PCLATH3, PCLATH4), each 0/1 or None (unknown)
UNK = None
RP0, RP1, IRP, P3, P4 = range(5)
ALL_UNK = (UNK,) * 5


def join(a, b):
    if a is None:
        return b
    if b is None:
        return a
    return tuple(x if x == y else UNK for x, y in zip(a, b))


class Disasm:
    def __init__(self, words):
        self.words = words
        self.n = 0x2000
        self.ins = {a: Insn(a, words[a]) for a in range(self.n)}
        self.data = set()
        for lo, hi, _ in DATA_RANGES:
            self.data.update(range(lo, hi + 1))
        self.state = {}      # addr -> state on entry
        self.ret_state = {}  # function addr -> state on return
        self.funcs = dict(FUNCTIONS)
        self.labels = dict(LABELS)
        self.callers = {}
        self.tail = {}       # function -> set(functions it tail-jumps into)
        self.pcl_writes = []

    # --- helpers ---------------------------------------------------------
    def reg_addr(self, f, st):
        """Resolve a 7-bit f into a 9-bit linear address (or None)."""
        if f in MIRRORED or f >= 0x70:
            return f
        if not st or st[RP0] is None or st[RP1] is None:
            return None
        return (st[RP1] << 8) | (st[RP0] << 7) | f

    def reg_name(self, f, st):
        a = self.reg_addr(f, st)
        if a is None:
            banks = [0, 1, 2, 3]
            if st and st[RP0] is not None:
                banks = [b for b in banks if (b & 1) == st[RP0]]
            if st and st[RP1] is not None:
                banks = [b for b in banks if (b >> 1) == st[RP1]]
            cands = list(dict.fromkeys(self.name_of((b << 7) | f) for b in banks))
            return "{" + "|".join(cands) + "}"
        return self.name_of(a)

    def name_of(self, a):
        if a in SFR:
            return SFR[a]
        if (a & 0x7F) >= 0x70:
            return RAM.get(0x70 | (a & 0x0F), "r%03x" % (0x70 | (a & 0x0F)))
        if a in RAM:
            return RAM[a]
        return "r%03x" % a

    def target(self, i, st):
        if not st or st[P3] is None or st[P4] is None:
            return None
        return (st[P4] << 12) | (st[P3] << 11) | i.k

    # --- dataflow ------------------------------------------------------------
    @staticmethod
    def step(i, st, w):
        s = list(st)
        if i.mn in ("BSF", "BCF") and i.f == 0x03 and i.b in (5, 6, 7):
            s[{5: RP0, 6: RP1, 7: IRP}[i.b]] = 1 if i.mn == "BSF" else 0
        elif i.mn in ("BSF", "BCF") and i.f == 0x0A and i.b in (3, 4):
            s[{3: P3, 4: P4}[i.b]] = 1 if i.mn == "BSF" else 0
        elif i.mn == "CLRF" and i.f == 0x03:
            s[RP0] = s[RP1] = s[IRP] = 0
        elif i.mn == "CLRF" and i.f == 0x0A:
            s[P3] = s[P4] = 0
        elif i.mn == "MOVWF" and i.f == 0x0A:
            s[P3] = (w >> 3) & 1 if w is not None else UNK
            s[P4] = (w >> 4) & 1 if w is not None else UNK
        elif i.mn == "MOVWF" and i.f == 0x03:
            s[RP0] = s[RP1] = s[IRP] = UNK
        elif i.f == 0x03 and i.d == 1:
            s[RP0] = s[RP1] = s[IRP] = UNK
        elif i.f == 0x0A and i.d == 1:
            s[P3] = s[P4] = UNK
        return tuple(s)

    def func_of(self, a):
        best = None
        for f in self.funcs:
            if f <= a and (best is None or f > best):
                best = f
        return best

    def analyse(self):
        # entry states
        self.state[0] = (0, 0, 0, 0, 0)
        self.state[4] = (UNK, UNK, UNK, UNK, UNK)
        work = [0, 4]
        callsites = {}   # callee -> set(return addresses)
        self.w_at = {}   # addr -> W constant known on entry (from MOVLW just before)

        def push(t, st):
            old = self.state.get(t)
            new = join(old, st)
            if old != new or t not in self.state:
                self.state[t] = new
                work.append(t)

        def set_ret(f, st, seen=None):
            seen = seen or set()
            if f in seen:
                return
            seen.add(f)
            old = self.ret_state.get(f)
            new = join(old, st)
            if old != new:
                self.ret_state[f] = new
                for r in callsites.get(f, ()):
                    cst = self.state.get(r - 1)
                    if cst is not None:
                        push(r, self.after_call(cst, new))
                for g, tails in self.tail.items():
                    if f in tails:
                        set_ret(g, new, seen)

        guard = 0
        while guard < 500000:
            if not work:
                # seed functions nobody calls (dead code) with their own page
                dead = [f for f in self.funcs if f not in self.state and f not in self.data]
                for f in dead:
                    self.state[f] = (UNK, UNK, UNK, (f >> 11) & 1, (f >> 12) & 1)
                    work.append(f)
                if not work:
                    break
            guard += 1
            a = work.pop()
            if a in self.data or a >= self.n:
                continue
            st = self.state[a]
            i = self.ins[a]
            prev = self.ins.get(a - 1)
            w = prev.k if prev is not None and prev.mn == "MOVLW" and a not in self.labels else None
            nst = self.step(i, st, w)
            if i.kind == "ret":
                f = self.func_of(a)
                if f is not None:
                    set_ret(f, nst)
                continue
            if i.kind == "goto":
                t = self.target(i, st)
                if t is None:
                    continue
                if t in self.funcs and t != self.func_of(a):
                    f = self.func_of(a)
                    self.tail.setdefault(f, set()).add(t)
                    if t in self.ret_state:
                        set_ret(f, self.ret_state[t])
                else:
                    self.labels.setdefault(t, "L_%04x" % t)
                push(t, nst)
                continue
            if i.kind == "call":
                t = self.target(i, st)
                if t is None:
                    continue
                if t not in self.funcs:
                    self.funcs[t] = "sub_%04x" % t
                self.callers.setdefault(t, set()).add(a)
                callsites.setdefault(t, set()).add(a + 1)
                push(t, nst)
                if t in self.ret_state:
                    push(a + 1, self.after_call(nst, self.ret_state[t]))
                continue
            if i.f == 0x02 and (i.mn == "MOVWF" or (i.mn == "ADDWF" and i.d == 1)):
                # computed jump: follow a GOTO table if one follows
                self.pcl_writes.append(a)
                if self.ins[a + 1].kind != "goto" or a + 1 in self.data:
                    # jump into a RETLW table: behaves like a return
                    f = self.func_of(a)
                    if f is not None:
                        set_ret(f, nst)
                    continue
                b = a + 1
                while b < self.n and self.ins[b].kind == "goto" and b not in self.funcs \
                        and b not in self.data:
                    self.labels.setdefault(b, "T_%04x" % b)
                    push(b, (nst[RP0], nst[RP1], nst[IRP], (b >> 11) & 1, (b >> 12) & 1))
                    b += 1
                continue
            if i.kind == "skip":
                push(a + 2, nst)
            if a + 1 in self.funcs:
                # falls through into the next function: acts like a tail call
                f, t = self.func_of(a), a + 1
                self.tail.setdefault(f, set()).add(t)
                if t in self.ret_state:
                    set_ret(f, self.ret_state[t])
            push(a + 1, nst)

    @staticmethod
    def after_call(caller_st, ret_st):
        # bank bits and PCLATH are whatever the callee left behind
        return tuple(ret_st)


    # --- output --------------------------------------------------------------
    def fmt(self, i):
        st = self.state.get(i.addr)
        m = i.mn
        if i.kind in ("goto", "call"):
            t = self.target(i, st)
            if t is None:
                return "%-7s ?page:0x%03x" % (m, i.k)
            name = self.funcs.get(t) or self.labels.get(t) or "0x%04x" % t
            return "%-7s %s" % (m, name)
        if m in ("MOVLW", "RETLW", "IORLW", "ANDLW", "XORLW", "SUBLW", "ADDLW"):
            c = chr(i.k) if 0x20 <= i.k < 0x7F else ""
            return "%-7s 0x%02x%s" % (m, i.k, ("   ; '%s'" % c) if c and m == "RETLW" else "")
        if i.b is not None:
            rn = self.reg_name(i.f, st)
            return "%-7s %s,%s" % (m, rn, fmt_bit(rn, i.b))
        if i.f is not None:
            rn = self.reg_name(i.f, st)
            if i.d is None:
                return "%-7s %s" % (m, rn)
            return "%-7s %s,%s" % (m, rn, "f" if i.d else "w")
        return m

    def listing(self, lo=0, hi=None, out=sys.stdout):
        hi = hi if hi is not None else self.n - 1
        data_names = {lo_: n for lo_, _, n in DATA_RANGES}
        a = lo
        while a <= hi:
            if a in self.funcs:
                was = OLD_NAMES.get(a)
                out.write("\n;%s\n%s:   ; 0x%04x%s  callers: %s\n" % (
                    "-" * 70, self.funcs[a], a, " (was %s)" % was if was else "",
                    ", ".join(self.funcs.get(self.func_of(c), "?") + "@%04x" % c
                              for c in sorted(self.callers.get(a, ())))))
            elif a in self.labels:
                out.write("%s:\n" % self.labels[a])
            if a in data_names:
                out.write("; ---- data: %s\n" % data_names[a])
            if a in self.data:
                w = self.words[a]
                i = self.ins[a]
                extra = ""
                if i.mn == "RETLW":
                    extra = "RETLW 0x%02x %s" % (i.k, repr(chr(i.k)) if 0x20 <= i.k < 0x7f else "")
                out.write("  %04x  %04x   .dw 0x%04x   %s\n" % (a, w, w, extra))
                a += 1
                continue
            i = self.ins[a]
            st = self.state.get(a)
            bank = "?" if not st or st[RP0] is None or st[RP1] is None else str(st[RP1] * 2 + st[RP0])
            if a not in self.state:
                bank = "-"  # never reached by the analysis
            out.write("  %04x  %04x  b%s  %s\n" % (a, i.word, bank, self.fmt(i)))
            a += 1

    def func_range(self, f):
        nxt = min([g for g in self.funcs if g > f] + [lo for lo, _, _ in DATA_RANGES if lo > f]
                  + [self.n])
        return f, nxt - 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("bin")
    ap.add_argument("-f", "--func", action="append")
    ap.add_argument("--xref", help="linear RAM address (e.g. 0x4f, 0xa5, 0x120)")
    ap.add_argument("--calls", action="store_true", help="print call graph")
    a = ap.parse_args()
    d = Disasm(load(a.bin))
    d.analyse()
    if a.xref:
        tgt = int(a.xref, 16)
        for addr in range(d.n):
            i = d.ins[addr]
            if addr in d.data or i.f is None:
                continue
            ra = d.reg_addr(i.f, d.state.get(addr))
            if ra == tgt or (ra is None and (i.f == tgt & 0x7F)):
                print("%04x  %-22s %s%s" % (addr, d.funcs.get(d.func_of(addr)), d.fmt(i),
                                           "" if ra is not None else "   (bank unknown)"))
        return
    if a.calls:
        for f in sorted(d.funcs):
            lo, hi = d.func_range(f)
            callees = []
            for x in range(lo, hi + 1):
                if x in d.data:
                    continue
                i = d.ins[x]
                if i.kind == "call":
                    t = d.target(i, d.state.get(x))
                    callees.append(d.funcs.get(t, "?%s" % t))
            print("%-28s -> %s" % (d.funcs[f], ", ".join(dict.fromkeys(callees))))
        return
    if a.func:
        for fn in a.func:
            if re.match(r"^(0x)?[0-9a-fA-F]+$", fn) and fn not in d.funcs.values():
                f = int(fn, 16)
            else:
                f = [k for k, v in d.funcs.items() if v == fn][0]
            lo, hi = d.func_range(f)
            d.listing(lo, hi)
        return
    d.listing()


if __name__ == "__main__":
    main()
