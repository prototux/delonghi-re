#!/usr/bin/env python3
"""
PIC18 (PIC18F2525/4525, non-extended instruction set) disassembler for the
ECAM 23.450 power board firmware.

The input is the programmer image in files/ (flash at 0x000000, ID at
0x200000, config at 0x300000, data EEPROM at 0xF00000).

Features: function discovery (CALL/RCALL targets + vectors), labels, BSR
tracking so banked accesses show the real address, symbol names from
pb_symbols.py, call graph and cross references.

Usage:
    pic18dis.py image.bin                    full listing
    pic18dis.py image.bin -f name|0xaddr     one function
    pic18dis.py image.bin --calls            call graph
    pic18dis.py image.bin --xref 0x123       accesses to a RAM/SFR address
"""
import argparse
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
try:
    import pb_symbols as SYM
except ImportError:
    SYM = None

FLASH = 0xC000

# PIC18F2525/4525 SFRs (0xF80..0xFFF)
SFR = {
    0xF80: 'PORTA', 0xF81: 'PORTB', 0xF82: 'PORTC', 0xF83: 'PORTD', 0xF84: 'PORTE',
    0xF89: 'LATA', 0xF8A: 'LATB', 0xF8B: 'LATC', 0xF8C: 'LATD', 0xF8D: 'LATE',
    0xF92: 'TRISA', 0xF93: 'TRISB', 0xF94: 'TRISC', 0xF95: 'TRISD', 0xF96: 'TRISE',
    0xF9B: 'OSCTUNE', 0xF9D: 'PIE1', 0xF9E: 'PIR1', 0xF9F: 'IPR1', 0xFA0: 'PIE2',
    0xFA1: 'PIR2', 0xFA2: 'IPR2', 0xFA6: 'EECON1', 0xFA7: 'EECON2', 0xFA8: 'EEDATA',
    0xFA9: 'EEADR', 0xFAA: 'EEADRH', 0xFAB: 'RCSTA', 0xFAC: 'TXSTA', 0xFAD: 'TXREG',
    0xFAE: 'RCREG', 0xFAF: 'SPBRG', 0xFB0: 'SPBRGH', 0xFB1: 'T3CON', 0xFB2: 'TMR3L',
    0xFB3: 'TMR3H', 0xFB4: 'CMCON', 0xFB5: 'CVRCON', 0xFB6: 'ECCP1AS', 0xFB7: 'PWM1CON',
    0xFB8: 'BAUDCON', 0xFBA: 'CCP2CON', 0xFBB: 'CCPR2L', 0xFBC: 'CCPR2H', 0xFBD: 'CCP1CON',
    0xFBE: 'CCPR1L', 0xFBF: 'CCPR1H', 0xFC0: 'ADCON2', 0xFC1: 'ADCON1', 0xFC2: 'ADCON0',
    0xFC3: 'ADRESL', 0xFC4: 'ADRESH', 0xFC5: 'SSPCON2', 0xFC6: 'SSPCON1', 0xFC7: 'SSPSTAT',
    0xFC8: 'SSPADD', 0xFC9: 'SSPBUF', 0xFCA: 'T2CON', 0xFCB: 'PR2', 0xFCC: 'TMR2',
    0xFCD: 'T1CON', 0xFCE: 'TMR1L', 0xFCF: 'TMR1H', 0xFD0: 'RCON', 0xFD1: 'WDTCON',
    0xFD2: 'HLVDCON', 0xFD3: 'OSCCON', 0xFD5: 'T0CON', 0xFD6: 'TMR0L', 0xFD7: 'TMR0H',
    0xFD8: 'STATUS', 0xFD9: 'FSR2L', 0xFDA: 'FSR2H', 0xFDB: 'PLUSW2', 0xFDC: 'PREINC2',
    0xFDD: 'POSTDEC2', 0xFDE: 'POSTINC2', 0xFDF: 'INDF2', 0xFE0: 'BSR', 0xFE1: 'FSR1L',
    0xFE2: 'FSR1H', 0xFE3: 'PLUSW1', 0xFE4: 'PREINC1', 0xFE5: 'POSTDEC1', 0xFE6: 'POSTINC1',
    0xFE7: 'INDF1', 0xFE8: 'WREG', 0xFE9: 'FSR0L', 0xFEA: 'FSR0H', 0xFEB: 'PLUSW0',
    0xFEC: 'PREINC0', 0xFED: 'POSTDEC0', 0xFEE: 'POSTINC0', 0xFEF: 'INDF0', 0xFF0: 'INTCON3',
    0xFF1: 'INTCON2', 0xFF2: 'INTCON', 0xFF3: 'PRODL', 0xFF4: 'PRODH', 0xFF5: 'TABLAT',
    0xFF6: 'TBLPTRL', 0xFF7: 'TBLPTRH', 0xFF8: 'TBLPTRU', 0xFF9: 'PCL', 0xFFA: 'PCLATH',
    0xFFB: 'PCLATU', 0xFFC: 'STKPTR', 0xFFD: 'TOSL', 0xFFE: 'TOSH', 0xFFF: 'TOSU',
}
BITS = {
    'STATUS': ['C', 'DC', 'Z', 'OV', 'N', '5', '6', '7'],
    'INTCON': ['RBIF', 'INT0IF', 'TMR0IF', 'RBIE', 'INT0IE', 'TMR0IE', 'PEIE', 'GIE'],
    'PIR1': ['TMR1IF', 'TMR2IF', 'CCP1IF', 'SSPIF', 'TXIF', 'RCIF', 'ADIF', 'PSPIF'],
    'PIE1': ['TMR1IE', 'TMR2IE', 'CCP1IE', 'SSPIE', 'TXIE', 'RCIE', 'ADIE', 'PSPIE'],
    'PIR2': ['CCP2IF', 'TMR3IF', 'HLVDIF', 'BCLIF', 'EEIF', '5', 'CMIF', 'OSCFIF'],
    'PIE2': ['CCP2IE', 'TMR3IE', 'HLVDIE', 'BCLIE', 'EEIE', '5', 'CMIE', 'OSCFIE'],
    'SSPSTAT': ['BF', 'UA', 'R_W', 'S', 'P', 'D_A', 'CKE', 'SMP'],
    'SSPCON1': ['SSPM0', 'SSPM1', 'SSPM2', 'SSPM3', 'CKP', 'SSPEN', 'SSPOV', 'WCOL'],
    'ADCON0': ['ADON', 'GO', 'CHS0', 'CHS1', 'CHS2', 'CHS3', '6', '7'],
    'EECON1': ['RD', 'WR', 'WREN', 'WRERR', 'FREE', '5', 'CFGS', 'EEPGD'],
    'RCSTA': ['RX9D', 'OERR', 'FERR', 'ADDEN', 'CREN', 'SREN', 'RX9', 'SPEN'],
    'TXSTA': ['TX9D', 'TRMT', 'BRGH', 'SENDB', 'SYNC', 'TXEN', 'TX9', 'CSRC'],
    'T0CON': ['T0PS0', 'T0PS1', 'T0PS2', 'PSA', 'T0SE', 'T0CS', 'T08BIT', 'TMR0ON'],
    'T1CON': ['TMR1ON', 'TMR1CS', 'T1SYNC', 'T1OSCEN', 'T1CKPS0', 'T1CKPS1', 'T1RUN', 'RD16'],
    'RCON': ['BOR', 'POR', 'PD', 'TO', 'RI', '5', 'SBOREN', 'IPEN'],
}

BRANCH_OPS = {0xE0: 'BZ', 0xE1: 'BNZ', 0xE2: 'BC', 0xE3: 'BNC', 0xE4: 'BOV', 0xE5: 'BNOV',
              0xE6: 'BN', 0xE7: 'BNN'}
BYTE_OPS = {  # top 6 bits -> mnemonic
    0x01: 'DECF', 0x04: 'IORWF', 0x05: 'ANDWF', 0x06: 'XORWF', 0x07: 'COMF',
    0x08: 'ADDWFC', 0x09: 'ADDWF', 0x0A: 'INCF', 0x0B: 'DECFSZ', 0x0C: 'RRCF', 0x0D: 'RLCF',
    0x0E: 'SWAPF', 0x0F: 'INCFSZ', 0x10: 'RRNCF', 0x11: 'RLNCF', 0x12: 'INFSNZ', 0x13: 'DCFSNZ',
    0x14: 'MOVF', 0x15: 'SUBFWB', 0x16: 'SUBWFB', 0x17: 'SUBWF',
}
FA_OPS = {0x60: 'CPFSLT', 0x62: 'CPFSEQ', 0x64: 'CPFSGT', 0x66: 'TSTFSZ', 0x68: 'SETF',
          0x6A: 'CLRF', 0x6C: 'NEGF', 0x6E: 'MOVWF', 0x02: 'MULWF'}
LIT_OPS = {0x08: 'SUBLW', 0x09: 'IORLW', 0x0A: 'XORLW', 0x0B: 'ANDLW', 0x0C: 'RETLW',
           0x0D: 'MULLW', 0x0E: 'MOVLW', 0x0F: 'ADDLW'}
SKIPS = {'DECFSZ', 'INCFSZ', 'INFSNZ', 'DCFSNZ', 'CPFSLT', 'CPFSEQ', 'CPFSGT', 'TSTFSZ',
         'BTFSS', 'BTFSC'}


def sext(v, bits):
    return v - (1 << bits) if v & (1 << (bits - 1)) else v


class Ins:
    __slots__ = ('addr', 'size', 'mn', 'f', 'd', 'a', 'b', 'k', 'target', 'kind', 'f2', 's')

    def __init__(self, addr, w, w2):
        self.addr, self.size = addr, 2
        self.f = self.d = self.a = self.b = self.k = self.target = self.f2 = self.s = None
        self.kind = 'op'
        hi = w >> 8
        if w == 0x0000: self.mn = 'NOP'
        elif w == 0x0003: self.mn = 'SLEEP'
        elif w == 0x0004: self.mn = 'CLRWDT'
        elif w == 0x0005: self.mn = 'PUSH'
        elif w == 0x0006: self.mn = 'POP'
        elif w == 0x0007: self.mn = 'DAW'
        elif 0x0008 <= w <= 0x000F:
            self.mn = ['TBLRD*', 'TBLRD*+', 'TBLRD*-', 'TBLRD+*', 'TBLWT*', 'TBLWT*+', 'TBLWT*-', 'TBLWT+*'][w - 8]
        elif w in (0x0010, 0x0011): self.mn, self.s, self.kind = 'RETFIE', w & 1, 'ret'
        elif w in (0x0012, 0x0013): self.mn, self.s, self.kind = 'RETURN', w & 1, 'ret'
        elif w == 0x00FF: self.mn, self.kind = 'RESET', 'ret'
        elif (w & 0xFFF0) == 0x0100: self.mn, self.k = 'MOVLB', w & 0xF
        elif hi in LIT_OPS:
            self.mn, self.k = LIT_OPS[hi], w & 0xFF
            if hi == 0x0C: self.kind = 'ret'
        elif (w >> 9) == 0x01: self.mn, self.f, self.a = 'MULWF', w & 0xFF, (w >> 8) & 1
        elif (w >> 10) in BYTE_OPS:
            self.mn = BYTE_OPS[w >> 10]
            self.f, self.a, self.d = w & 0xFF, (w >> 8) & 1, (w >> 9) & 1
            if self.mn in SKIPS: self.kind = 'skip'
        elif (w >> 12) == 0x6:
            op = (w >> 8) & 0xFE
            self.mn, self.f, self.a = FA_OPS[0x60 | (op & 0x0E)], w & 0xFF, (w >> 8) & 1
            if self.mn in SKIPS: self.kind = 'skip'
        elif (w >> 12) in (0x7, 0x8, 0x9, 0xA, 0xB):
            self.mn = {0x7: 'BTG', 0x8: 'BSF', 0x9: 'BCF', 0xA: 'BTFSS', 0xB: 'BTFSC'}[w >> 12]
            self.f, self.a, self.b = w & 0xFF, (w >> 8) & 1, (w >> 9) & 7
            if self.mn in SKIPS: self.kind = 'skip'
        elif (w >> 12) == 0xC:
            self.mn, self.size = 'MOVFF', 4
            self.f, self.f2 = w & 0xFFF, w2 & 0xFFF
        elif (w >> 11) == 0x1A:
            self.mn, self.kind = 'BRA', 'goto'
            self.target = addr + 2 + 2 * sext(w & 0x7FF, 11)
        elif (w >> 11) == 0x1B:
            self.mn, self.kind = 'RCALL', 'call'
            self.target = addr + 2 + 2 * sext(w & 0x7FF, 11)
        elif hi in BRANCH_OPS:
            self.mn, self.kind = BRANCH_OPS[hi], 'cond'
            self.target = addr + 2 + 2 * sext(w & 0xFF, 8)
        elif hi in (0xEC, 0xED):
            self.mn, self.kind, self.size, self.s = 'CALL', 'call', 4, hi & 1
            self.target = ((w2 & 0xFFF) << 8 | (w & 0xFF)) * 2
        elif hi == 0xEF:
            self.mn, self.kind, self.size = 'GOTO', 'goto', 4
            self.target = ((w2 & 0xFFF) << 8 | (w & 0xFF)) * 2
        elif hi == 0xEE and (w & 0xC0) == 0:
            self.mn, self.size = 'LFSR', 4
            self.f, self.k = (w >> 4) & 3, ((w & 0xF) << 8) | (w2 & 0xFF)
        elif (w >> 12) == 0xF: self.mn = 'NOP2'
        else: self.mn = '???'


class Dis:
    def __init__(self, image):
        self.img = image
        self.flash = image[:FLASH]
        self.ins = {}
        self.funcs = dict(getattr(SYM, 'FUNCTIONS', {}))
        self.funcs.setdefault(0x0000, 'reset_vector')
        self.funcs.setdefault(0x0008, 'isr_high_vector')
        if 0x0018 not in self.funcs:
            self.funcs[0x0018] = 'isr_low_vector'
        self.labels = dict(getattr(SYM, 'LABELS', {}))
        self.ram = dict(getattr(SYM, 'RAM', {}))
        self.data = []
        for lo, hi, name in getattr(SYM, 'DATA_RANGES', []):
            self.data.append((lo, hi, name))
        self.callers = {}
        self.bsr = {}            # addr -> BSR value known on entry (or None)
        self.reached = set()

    def word(self, a):
        return self.flash[a] | (self.flash[a + 1] << 8)

    def decode(self, a):
        if a not in self.ins:
            w = self.word(a)
            w2 = self.word(a + 2) if a + 2 < FLASH else 0xFFFF
            self.ins[a] = Ins(a, w, w2)
        return self.ins[a]

    def is_data(self, a):
        return any(lo <= a <= hi for lo, hi, _ in self.data)

    # ---- control flow + BSR dataflow
    def analyse(self):
        UNK = None
        work = [(a, UNK) for a in self.funcs]
        seen = {}
        while work:
            a, bsr = work.pop()
            while 0 <= a < FLASH:
                if self.is_data(a):
                    break
                key = a
                old = seen.get(key, 'unset')
                if old != 'unset':
                    if old == bsr or old is None:
                        break
                    bsr = None               # conflicting paths: unknown
                seen[key] = bsr
                self.bsr[a] = bsr
                self.reached.add(a)
                i = self.decode(a)
                # BSR effects
                if i.mn == 'MOVLB':
                    bsr = i.k
                elif i.mn in ('MOVWF', 'CLRF', 'SETF', 'INCF', 'DECF') and i.a == 0 and i.f == 0xE0:
                    bsr = self._w if (i.mn == 'MOVWF' and self._w is not None) else (0 if i.mn == 'CLRF' else None)
                elif i.mn == 'MOVFF' and i.f2 == 0xFE0:
                    bsr = None
                self._w = i.k if i.mn == 'MOVLW' else None
                nxt = a + i.size
                if i.kind == 'ret':
                    break
                if i.kind == 'call':
                    if i.target is not None and 0 <= i.target < FLASH:
                        if i.target not in self.funcs:
                            self.funcs[i.target] = 'f_%04x' % i.target
                        self.callers.setdefault(i.target, set()).add(a)
                        work.append((i.target, bsr))
                    bsr = None               # callee may change BSR
                    a = nxt
                    continue
                if i.kind == 'goto':
                    if i.target is not None:
                        if i.target not in self.funcs:
                            self.labels.setdefault(i.target, 'L_%04x' % i.target)
                        work.append((i.target, bsr))
                    # computed jump tables: GOTO right after ADDWF PCL
                    break
                if i.kind == 'cond':
                    self.labels.setdefault(i.target, 'L_%04x' % i.target)
                    work.append((i.target, bsr))
                if i.kind == 'skip':
                    n2 = nxt + self.decode(nxt).size
                    work.append((n2, bsr))
                if i.mn in ('MOVWF', 'ADDWF') and i.a == 0 and i.f == 0xF9 and (i.mn == 'MOVWF' or i.d == 1):
                    # computed goto: follow a table of BRA/GOTO if present
                    b = nxt
                    while self.decode(b).mn in ('BRA', 'GOTO', 'RETLW') and b < FLASH:
                        t = self.decode(b)
                        if t.target is not None:
                            self.labels.setdefault(t.target, 'L_%04x' % t.target)
                            work.append((t.target, bsr))
                        self.reached.add(b)
                        self.labels.setdefault(b, 'T_%04x' % b)
                        b += t.size
                    break
                a = nxt

    def func_of(self, a):
        best = None
        for f in self.funcs:
            if f <= a and (best is None or f > best):
                best = f
        return best

    # ---- names
    def reg(self, f, a_bit, bsr):
        if a_bit == 0:
            addr = f if f < 0x80 else 0xF00 | f
        else:
            if bsr is None:
                return 'b?:0x%02x' % f, None
            addr = (bsr << 8) | f
        return self.name(addr), addr

    def name(self, addr):
        if addr in SFR:
            return SFR[addr]
        if addr in self.ram:
            return self.ram[addr]
        return 'r%03x' % addr

    def fmt(self, i):
        m = i.mn
        bsr = self.bsr.get(i.addr)
        if i.target is not None:
            t = i.target
            name = self.funcs.get(t) or self.labels.get(t) or '0x%04x' % t
            return '%-7s %s' % (m, name)
        if m == 'MOVFF':
            return '%-7s %s, %s' % (m, self.name(i.f), self.name(i.f2))
        if m == 'LFSR':
            return '%-7s FSR%d, %s' % (m, i.f, self.name(i.k) if i.k in self.ram or i.k in SFR else '0x%03x' % i.k)
        if m == 'MOVLB':
            return '%-7s 0x%x' % (m, i.k)
        if i.k is not None:
            return '%-7s 0x%02x' % (m, i.k)
        if i.b is not None:
            n, _ = self.reg(i.f, i.a, bsr)
            bits = BITS.get(n)
            return '%-7s %s,%s' % (m, n, bits[i.b] if bits else i.b)
        if i.f is not None:
            n, _ = self.reg(i.f, i.a, bsr)
            if i.d is None:
                return '%-7s %s' % (m, n)
            return '%-7s %s,%s' % (m, n, 'f' if i.d else 'w')
        if m in ('RETURN', 'RETFIE') and i.s:
            return m + ' FAST'
        return m

    def listing(self, lo, hi, out=sys.stdout):
        a = lo
        while a <= hi and a < FLASH:
            if a in self.funcs:
                cs = sorted(self.callers.get(a, ()))
                out.write('\n;%s\n%s:   ; 0x%04x  callers: %s\n' % ('-' * 60, self.funcs[a], a,
                          ', '.join('%s@%04x' % (self.funcs.get(self.func_of(c), '?'), c) for c in cs[:8])
                          + (' ...' if len(cs) > 8 else '')))
            elif a in self.labels:
                out.write('%s:\n' % self.labels[a])
            for lo_, hi_, name in self.data:
                if a == lo_:
                    out.write('; ---- data %s (0x%04x-0x%04x)\n' % (name, lo_, hi_))
            if self.is_data(a) or a not in self.reached:
                w = self.word(a)
                if a not in self.reached and not self.is_data(a) and w == 0xFFFF:
                    # skip erased runs
                    b = a
                    while b <= hi and b < FLASH and self.word(b) == 0xFFFF and b not in self.reached:
                        b += 2
                    out.write('  %04x  (erased up to %04x)\n' % (a, b - 2))
                    a = b
                    continue
                c = ''.join(chr(x) if 32 <= x < 127 else '.' for x in (w & 0xFF, w >> 8))
                out.write('  %04x  %04x          .dw   %s\n' % (a, w, c))
                a += 2
                continue
            i = self.decode(a)
            raw = '%04x' % self.word(a) + (' %04x' % self.word(a + 2) if i.size == 4 else '     ')
            b = self.bsr.get(a)
            out.write('  %04x  %s  %s  %s\n' % (a, raw, ('b%x' % b) if b is not None else 'b?', self.fmt(i)))
            a += i.size

    def body(self, f):
        """addresses reached from f without entering other functions"""
        seen, work = set(), [f]
        while work:
            a = work.pop()
            while 0 <= a < FLASH and a not in seen and (a == f or a not in self.funcs):
                if self.is_data(a):
                    break
                seen.add(a)
                i = self.decode(a)
                nxt = a + i.size
                if i.kind == 'ret':
                    break
                if i.kind == 'goto':
                    if i.target is not None and i.target not in self.funcs:
                        work.append(i.target)
                    break
                if i.kind == 'cond' and i.target not in self.funcs:
                    work.append(i.target)
                if i.kind == 'skip':
                    work.append(nxt + self.decode(nxt).size)
                if i.mn in ('MOVWF', 'ADDWF') and i.a == 0 and i.f == 0xF9:
                    b = nxt
                    while self.decode(b).mn in ('BRA', 'GOTO', 'RETLW'):
                        t = self.decode(b)
                        seen.add(b)
                        if t.target is not None and t.target not in self.funcs:
                            work.append(t.target)
                        b += t.size
                    break
                a = nxt
        return seen

    def list_func(self, f, out=sys.stdout):
        body = sorted(self.body(f))
        cs = sorted(self.callers.get(f, ()))
        out.write('\n;%s\n%s:   ; 0x%04x  %d instructions  callers: %s\n' % ('-' * 60, self.funcs[f], f, len(body),
                  ', '.join('%s@%04x' % (self.funcs.get(self.owner(c), '?'), c) for c in cs[:10]) + (' ...' if len(cs) > 10 else '')))
        prev = None
        for a in body:
            if prev is not None and a != prev:
                out.write('        ...\n')
            if a != f and a in self.labels:
                out.write('%s:\n' % self.labels[a])
            i = self.decode(a)
            raw = '%04x' % self.word(a) + (' %04x' % self.word(a + 2) if i.size == 4 else '     ')
            b = self.bsr.get(a)
            out.write('  %04x  %s  %s  %s\n' % (a, raw, ('b%x' % b) if b is not None else 'b?', self.fmt(i)))
            prev = a + i.size

    def owner(self, a):
        if not hasattr(self, '_owner'):
            self._owner = {}
            for f in sorted(self.funcs):
                for x in self.body(f):
                    self._owner.setdefault(x, f)
        return self._owner.get(a, self.func_of(a))

    def func_range(self, f):
        nxt = min([g for g in self.funcs if g > f] + [FLASH])
        return f, nxt - 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('image')
    ap.add_argument('-f', '--func', action='append')
    ap.add_argument('--calls', action='store_true')
    ap.add_argument('--xref')
    ap.add_argument('--range')
    a = ap.parse_args()
    img = open(a.image, 'rb').read()
    d = Dis(img)
    d.analyse()
    if a.calls:
        for f in sorted(d.funcs):
            body = d.body(f)
            callees = []
            for x in sorted(body):
                if d.ins[x].kind == 'call':
                    callees.append(d.funcs.get(d.ins[x].target, hex(d.ins[x].target)))
            print('%04x %-28s (%4d ins) -> %s' % (f, d.funcs[f], len(body), ', '.join(dict.fromkeys(callees))))
        return
    if a.xref:
        t = int(a.xref, 16)
        for x in sorted(d.reached):
            i = d.ins[x]
            hit = False
            if i.mn == 'MOVFF':
                hit = t in (i.f, i.f2)
            elif i.f is not None and i.mn != 'LFSR':
                _, addr = d.reg(i.f, i.a, d.bsr.get(x))
                hit = addr == t
            elif i.mn == 'LFSR':
                hit = i.k == t
            if hit:
                print('%04x  %-24s %s' % (x, d.funcs.get(d.owner(x)), d.fmt(i)))
        return
    if a.range:
        lo, hi = (int(v, 16) for v in a.range.split('-'))
        d.listing(lo, hi)
        return
    if a.func:
        for fn in a.func:
            f = int(fn, 16) if re.match(r'^0x', fn) else [k for k, v in d.funcs.items() if v == fn][0]
            d.list_func(f)
        return
    d.listing(0, FLASH - 1)


if __name__ == '__main__':
    main()
