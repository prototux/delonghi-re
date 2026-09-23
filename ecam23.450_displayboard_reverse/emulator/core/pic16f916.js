// PIC16F916 instruction set simulator with the peripherals the display
// board firmware uses: TMR0 (+ prescaler), WDT, TMR1, TMR2 + CCP1 PWM,
// SSP in SPI master mode, USART (async), ports A/B/C/E, interrupts.
//
// The core knows nothing about the board: port inputs, SPI slave and UART
// peer are callbacks (see board.js).
//
// Time: `cycles` counts instruction cycles; `time` is in seconds and
// follows the oscillator selected by OSCCON (4 MHz at reset, 8 MHz once
// the firmware sets IRCF=111).

// Opcode numbers for the pre-decoded program
const OP = {
  NOP: 0, RETURN: 1, RETFIE: 2, SLEEP: 3, CLRWDT: 4, MOVWF: 5, CLRW: 6, CLRF: 7,
  SUBWF: 8, DECF: 9, IORWF: 10, ANDWF: 11, XORWF: 12, ADDWF: 13, MOVF: 14, COMF: 15,
  INCF: 16, DECFSZ: 17, RRF: 18, RLF: 19, SWAPF: 20, INCFSZ: 21,
  BCF: 22, BSF: 23, BTFSC: 24, BTFSS: 25, CALL: 26, GOTO: 27,
  MOVLW: 28, RETLW: 29, IORLW: 30, ANDLW: 31, XORLW: 32, SUBLW: 33, ADDLW: 34, BAD: 35,
};

function decode(w) {
  // returns [op, a, b]: a = f or k, b = d or bit
  const top = (w >> 12) & 3;
  if (top === 0) {
    if ((w & 0x3f9f) === 0) return [OP.NOP, 0, 0];
    if (w === 0x0008) return [OP.RETURN, 0, 0];
    if (w === 0x0009) return [OP.RETFIE, 0, 0];
    if (w === 0x0063) return [OP.SLEEP, 0, 0];
    if (w === 0x0064) return [OP.CLRWDT, 0, 0];
    const hi = w >> 7;
    if (hi === 0x01) return [OP.MOVWF, w & 0x7f, 1];
    if (hi === 0x02) return [OP.CLRW, 0, 0];
    if (hi === 0x03) return [OP.CLRF, w & 0x7f, 1];
    const o = (w >> 8) & 0xf;
    const map = [OP.BAD, OP.BAD, OP.SUBWF, OP.DECF, OP.IORWF, OP.ANDWF, OP.XORWF, OP.ADDWF,
      OP.MOVF, OP.COMF, OP.INCF, OP.DECFSZ, OP.RRF, OP.RLF, OP.SWAPF, OP.INCFSZ];
    return [map[o], w & 0x7f, (w >> 7) & 1];
  }
  if (top === 1) return [[OP.BCF, OP.BSF, OP.BTFSC, OP.BTFSS][(w >> 10) & 3], w & 0x7f, (w >> 7) & 7];
  if (top === 2) return [(w & 0x800) ? OP.GOTO : OP.CALL, w & 0x7ff, 0];
  const k = w & 0xff;
  const o = (w >> 8) & 0xf;
  if (o < 4) return [OP.MOVLW, k, 0];
  if (o < 8) return [OP.RETLW, k, 0];
  if (o === 8) return [OP.IORLW, k, 0];
  if (o === 9) return [OP.ANDLW, k, 0];
  if (o === 0xa) return [OP.XORLW, k, 0];
  if (o === 0xc || o === 0xd) return [OP.SUBLW, k, 0];
  if (o === 0xe || o === 0xf) return [OP.ADDLW, k, 0];
  return [OP.BAD, 0, 0];
}

// Canonical SFR addresses (bank 0 address for mirrored registers)
const R = {
  INDF: 0x00, TMR0: 0x01, PCL: 0x02, STATUS: 0x03, FSR: 0x04, PORTA: 0x05, PORTB: 0x06,
  PORTC: 0x07, PORTE: 0x09, PCLATH: 0x0a, INTCON: 0x0b, PIR1: 0x0c, PIR2: 0x0d,
  TMR1L: 0x0e, TMR1H: 0x0f, T1CON: 0x10, TMR2: 0x11, T2CON: 0x12, SSPBUF: 0x13,
  SSPCON: 0x14, CCPR1L: 0x15, CCPR1H: 0x16, CCP1CON: 0x17, RCSTA: 0x18, TXREG: 0x19,
  RCREG: 0x1a, OPTION: 0x81, TRISA: 0x85, TRISB: 0x86, TRISC: 0x87, TRISE: 0x89,
  PIE1: 0x8c, PIE2: 0x8d, PCON: 0x8e, OSCCON: 0x8f, ANSEL: 0x91, PR2: 0x92,
  SSPSTAT: 0x94, TXSTA: 0x98, SPBRG: 0x99, WDTCON: 0x105,
};

const UNIMPL = -10000;

// Build the 9 bit address -> storage map. >= 0: RAM index, < 0: -(sfr+1)
function buildMap() {
  const map = new Int32Array(512);
  const sfrBank = [
    // bank 0
    [0x01, 0x05, 0x06, 0x07, 0x09, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14,
      0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1e, 0x1f],
    // bank 1
    [0x81, 0x85, 0x86, 0x87, 0x89, 0x8c, 0x8d, 0x8e, 0x8f, 0x90, 0x91, 0x92, 0x93, 0x94,
      0x95, 0x96, 0x97, 0x98, 0x99, 0x9c, 0x9d, 0x9e, 0x9f],
    // bank 2
    [0x101, 0x105, 0x106, 0x107, 0x108, 0x109, 0x10c, 0x10d, 0x10e, 0x10f,
      0x110, 0x111, 0x112, 0x113, 0x114, 0x115, 0x116, 0x117, 0x118, 0x119, 0x11a, 0x11b,
      0x11c, 0x11d, 0x11e],
    // bank 3
    [0x181, 0x186, 0x18c, 0x18d],
  ];
  const canon = { 0x101: 0x01, 0x181: 0x81, 0x106: 0x06, 0x186: 0x86 };
  for (let a = 0; a < 512; a++) {
    const low = a & 0x7f, bank = a >> 7;
    if (low >= 0x70) { map[a] = 0x70 + (low - 0x70); continue; }
    if ([0x00, 0x02, 0x03, 0x04, 0x0a, 0x0b].includes(low)) { map[a] = -(low + 1); continue; }
    const gpr = (bank === 3) ? (low >= 0x10) : (low >= 0x20);
    if (gpr) { map[a] = a; continue; }
    if (sfrBank[bank].includes(a)) { map[a] = -((canon[a] ?? a) + 1); continue; }
    map[a] = UNIMPL;
  }
  return map;
}

export class PIC16F916 {
  constructor() {
    this.prog = new Uint16Array(0x2000).fill(0x3fff);
    this.config = 0x3fff;
    this.op = new Uint8Array(0x2000);
    this.argA = new Uint16Array(0x2000);
    this.argB = new Uint8Array(0x2000);
    this.map = buildMap();
    this.ram = new Uint8Array(512);
    this.sfr = new Uint8Array(512);
    this.stack = new Uint16Array(8);

    // board hooks
    this.readPins = () => 0;        // (port 'A'|'B'|'C') -> external level of input pins
    this.onPortWrite = () => {};    // (port) after a PORTx/TRISx write
    this.spiExchange = () => 0xff;  // (txByte) -> rxByte, called when a transfer starts
    this.uartTx = () => {};         // (byte) when a character has left the TSR

    this.stats = { wdtResets: 0, badOps: 0, stackOverflows: 0 };
    this.reset(false);
  }

  load(words, config) {
    this.prog.fill(0x3fff);
    for (let i = 0; i < Math.min(words.length, 0x2000); i++) this.prog[i] = words[i] & 0x3fff;
    if (config !== undefined) this.config = config;
    for (let a = 0; a < 0x2000; a++) {
      const [o, x, y] = decode(this.prog[a]);
      this.op[a] = o; this.argA[a] = x; this.argB[a] = y;
    }
    this.reset(false);
  }

  reset(fromWdt) {
    this.pc = 0; this.sp = 0; this.w = 0;
    this.status = fromWdt ? 0x08 : 0x18;          // /TO, /PD
    this.fsr = 0; this.pclath = 0; this.intcon = 0;
    const s = this.sfr;
    s.fill(0);
    s[R.OPTION] = 0xff; s[R.TRISA] = 0xff; s[R.TRISB] = 0xff; s[R.TRISC] = 0xff; s[R.TRISE] = 0x08;
    s[R.PR2] = 0xff; s[R.ANSEL] = 0xff; s[R.TXSTA] = 0x02; s[R.OSCCON] = 0x60; s[R.WDTCON] = 0x08;
    this.lat = { A: 0, B: 0, C: 0 };
    this.tmr0 = 0; this.t0presc = 0; this.t0inhibit = 0;
    this.tmr1 = 0; this.t1presc = 0;
    this.tmr2 = 0; this.t2presc = 0; this.t2post = 0;
    this.sspBusy = false; this.sspRemain = 0; this.sspRx = 0xff; this.sspbuf = 0;
    this.txReg = 0; this.txRegFull = false; this.tsrBusy = false; this.tsrRemain = 0; this.tsr = 0;
    this.rxFifo = []; this.rxQueue = this.rxQueue || [];
    this.wdt = 0;
    this.sleeping = false;
    this.setClock();
    if (this.cycles === undefined) { this.cycles = 0; this.time = 0; }
    if (fromWdt) this.stats.wdtResets++;
  }

  setClock() {
    const ircf = (this.sfr[R.OSCCON] >> 4) & 7;
    const fosc = [31e3, 125e3, 250e3, 500e3, 1e6, 2e6, 4e6, 8e6][ircf];
    this.fosc = fosc;
    this.tcy = 4 / fosc;
  }

  // ---------------------------------------------------------------- memory
  bankAddr(f) { return ((this.status & 0x60) << 2) | f; }

  portPins(p) {
    const tris = this.sfr[p === 'A' ? R.TRISA : p === 'B' ? R.TRISB : R.TRISC];
    let ext = this.readPins(p);
    if (p === 'A' || p === 'B') {
      // analog selected pins read 0 (ANSEL covers RA0-3,RA5,RE0-2 on the 916)
      if (p === 'A') ext &= ~(this.sfr[R.ANSEL] & 0x2f);
    }
    return ((this.lat[p] & ~tris) | (ext & tris)) & 0xff;
  }

  read(a) {
    const c = this.map[a];
    if (c >= 0) return this.ram[c];
    if (c === UNIMPL) return 0;
    const r = -c - 1;
    switch (r) {
      case R.INDF: {
        const ia = ((this.status & 0x80) << 1) | this.fsr;
        return (ia & 0x7f) === 0 ? 0 : this.read(ia);
      }
      case R.TMR0: return this.tmr0;
      case R.PCL: return this.pc & 0xff;
      case R.STATUS: return this.status;
      case R.FSR: return this.fsr;
      case R.PORTA: return this.portPins('A');
      case R.PORTB: return this.portPins('B');
      case R.PORTC: return this.portPins('C');
      case R.PORTE: return 0x08;
      case R.PCLATH: return this.pclath;
      case R.INTCON: return this.intcon;
      case R.PIR1: return this.pir1();
      case R.TMR1L: return this.tmr1 & 0xff;
      case R.TMR1H: return this.tmr1 >> 8;
      case R.TMR2: return this.tmr2;
      case R.SSPBUF: this.sfr[R.SSPSTAT] &= ~1; return this.sspbuf;
      case R.RCREG: {
        const v = this.rxFifo.length ? this.rxFifo.shift() : 0;
        this.stats.rcregReads = (this.stats.rcregReads || 0) + 1;
        return v;
      }
      case R.TXSTA: return (this.sfr[R.TXSTA] & ~2) | (this.tsrBusy ? 0 : 2);
      default: return this.sfr[r];
    }
  }

  write(a, v) {
    v &= 0xff;
    const c = this.map[a];
    if (c >= 0) { this.ram[c] = v; return; }
    if (c === UNIMPL) return;
    const r = -c - 1;
    switch (r) {
      case R.INDF: {
        const ia = ((this.status & 0x80) << 1) | this.fsr;
        if ((ia & 0x7f) !== 0) this.write(ia, v);
        return;
      }
      case R.TMR0: this.tmr0 = v; this.t0presc = 0; this.t0inhibit = 2; return;
      case R.PCL: this.pc = ((this.pclath & 0x1f) << 8) | v; this.pclWritten = true; return;
      case R.STATUS: this.status = (this.status & 0x18) | (v & ~0x18); return;
      case R.FSR: this.fsr = v; return;
      case R.PORTA: this.lat.A = v; this.onPortWrite('A'); return;
      case R.PORTB: this.lat.B = v; this.onPortWrite('B'); return;
      case R.PORTC: this.lat.C = v; this.onPortWrite('C'); return;
      case R.TRISA: this.sfr[r] = v; this.onPortWrite('A'); return;
      case R.TRISB: this.sfr[r] = v; this.onPortWrite('B'); return;
      case R.TRISC: this.sfr[r] = v; this.onPortWrite('C'); return;
      case R.PCLATH: this.pclath = v & 0x1f; return;
      case R.INTCON: this.intcon = v; return;
      case R.PIR1: this.sfr[R.PIR1] = v & ~0x30; return;
      case R.TMR1L: this.tmr1 = (this.tmr1 & 0xff00) | v; return;
      case R.TMR1H: this.tmr1 = (this.tmr1 & 0x00ff) | (v << 8); return;
      case R.TMR2: this.tmr2 = v; return;
      case R.T2CON: this.sfr[r] = v & 0x7f; return;
      case R.OSCCON: this.sfr[r] = (this.sfr[r] & 0x0e) | (v & 0x71); this.setClock(); return;
      case R.SSPBUF: this.sspWrite(v); return;
      case R.SSPSTAT: this.sfr[r] = (this.sfr[r] & 0x3f) | (v & 0xc0); return;
      case R.TXREG: this.txReg = v; this.txRegFull = true; this.uartLoad(); return;
      case R.RCSTA: {
        const old = this.sfr[r];
        let nv = (v & ~0x06) | (old & 0x06);
        if (!(v & 0x10)) nv &= ~0x02;                 // clearing CREN clears OERR
        if (!(v & 0x80)) this.rxFifo = [];
        this.sfr[r] = nv;
        return;
      }
      case R.TXSTA: this.sfr[r] = v; this.uartLoad(); return;
      default: this.sfr[r] = v;
    }
  }

  pir1() {
    let v = this.sfr[R.PIR1] & ~0x30;
    if (!this.txRegFull) v |= 0x10;
    if (this.rxFifo.length) v |= 0x20;
    return v;
  }

  // ---------------------------------------------------------------- SSP
  sspWrite(v) {
    const con = this.sfr[R.SSPCON];
    this.sspbuf = v;
    if (!(con & 0x20) || (con & 0x0f) > 3) return;     // not SPI master
    if (this.sspBusy) { this.sfr[R.SSPCON] |= 0x80; return; }  // WCOL
    this.sspBusy = true;
    const perBit = [1, 4, 16, 16][con & 3];            // instruction cycles per SCK period
    this.sspRemain = 8 * perBit;
    this.sspRx = this.spiExchange(v) & 0xff;
  }

  // ---------------------------------------------------------------- USART
  uartBitCycles() {
    const brgh = this.sfr[R.TXSTA] & 0x04;
    return (brgh ? 4 : 16) * (this.sfr[R.SPBRG] + 1);
  }

  uartFrameCycles(tx) {
    const nine = tx ? (this.sfr[R.TXSTA] & 0x40) : (this.sfr[R.RCSTA] & 0x40);
    return this.uartBitCycles() * (nine ? 11 : 10);
  }

  uartLoad() {
    const on = (this.sfr[R.RCSTA] & 0x80) && (this.sfr[R.TXSTA] & 0x20);
    if (!on || this.tsrBusy || !this.txRegFull) return;
    this.tsr = this.txReg; this.txRegFull = false;
    this.tsrBusy = true; this.tsrRemain = this.uartFrameCycles(true);
  }

  // Bytes sent to the PIC's RX pin, `gap` seconds apart (min: one frame)
  uartInject(bytes) {
    let t = Math.max(this.time, this.rxQueue.length ? this.rxQueue[this.rxQueue.length - 1].t : 0);
    const frame = this.uartFrameCycles(false) * this.tcy;
    for (const b of bytes) { t += frame; this.rxQueue.push({ t, b }); }
  }

  // ---------------------------------------------------------------- timers
  tick(cyc) {
    this.cycles += cyc;
    this.time += cyc * this.tcy;
    const s = this.sfr;

    // TMR0
    const opt = s[R.OPTION];
    if (!(opt & 0x20)) {
      for (let i = 0; i < cyc; i++) {
        if (this.t0inhibit > 0) { this.t0inhibit--; continue; }
        let inc = true;
        if (!(opt & 0x08)) {
          const rate = 2 << (opt & 7);
          if (++this.t0presc >= rate) this.t0presc = 0; else inc = false;
        }
        if (inc) {
          this.tmr0 = (this.tmr0 + 1) & 0xff;
          if (this.tmr0 === 0) this.intcon |= 0x04;
        }
      }
    }

    // TMR1 (internal clock only)
    const t1 = s[R.T1CON];
    if ((t1 & 1) && !(t1 & 2)) {
      const rate = 1 << ((t1 >> 4) & 3);
      this.t1presc += cyc;
      while (this.t1presc >= rate) {
        this.t1presc -= rate;
        this.tmr1 = (this.tmr1 + 1) & 0xffff;
        if (this.tmr1 === 0) s[R.PIR1] |= 0x01;
      }
    }

    // TMR2
    const t2 = s[R.T2CON];
    if (t2 & 0x04) {
      const rate = [1, 4, 16, 16][t2 & 3];
      this.t2presc += cyc;
      while (this.t2presc >= rate) {
        this.t2presc -= rate;
        if (this.tmr2 === s[R.PR2]) {
          this.tmr2 = 0;
          if (++this.t2post > ((t2 >> 3) & 0xf)) { this.t2post = 0; s[R.PIR1] |= 0x02; }
        } else {
          this.tmr2 = (this.tmr2 + 1) & 0xff;
        }
      }
    }

    // SSP
    if (this.sspBusy) {
      this.sspRemain -= cyc;
      if (this.sspRemain <= 0) {
        this.sspBusy = false;
        if (s[R.SSPSTAT] & 1) s[R.SSPCON] |= 0x40;     // SSPOV
        this.sspbuf = this.sspRx;
        s[R.SSPSTAT] |= 1;
        s[R.PIR1] |= 0x08;
      }
    }

    // USART TX
    if (this.tsrBusy) {
      this.tsrRemain -= cyc;
      if (this.tsrRemain <= 0) {
        this.tsrBusy = false;
        this.uartTx(this.tsr);
        this.uartLoad();
      }
    }
    // USART RX
    if (this.rxQueue.length && this.time >= this.rxQueue[0].t) {
      const { b } = this.rxQueue.shift();
      const rc = s[R.RCSTA];
      if ((rc & 0x80) && (rc & 0x10) && this.rxEnabled()) {
        if (this.rxFifo.length >= 2) s[R.RCSTA] |= 0x02;   // OERR
        else if (!(rc & 0x02)) { this.rxFifo.push(b); this.stats.rxBytes = (this.stats.rxBytes || 0) + 1; }
      } else { this.stats.rxDropped = (this.stats.rxDropped || 0) + 1;
      }
    }

    // WDT (~16.5 ms with WDTCON = 1:512 and the prescaler on TMR0)
    if (this.config & 0x08) {
      this.wdt += cyc * this.tcy;
      const period = (32 << ((s[R.WDTCON] >> 1) & 0xf)) / 31000 *
        ((opt & 0x08) ? (1 << (opt & 7)) : 1);
      if (this.wdt >= period) { this.wdt = 0; this.reset(true); }
    }
  }

  rxEnabled() { return true; }   // overridden by the board (mux)

  // PWM on CCP1 (buzzer)
  pwm() {
    const s = this.sfr;
    const on = ((s[R.CCP1CON] & 0x0c) === 0x0c) && (s[R.T2CON] & 0x04) && !(s[R.TRISC] & 0x20);
    if (!on) return { on: false, freq: 0, duty: 0 };
    const pre = [1, 4, 16, 16][s[R.T2CON] & 3];
    const period = (s[R.PR2] + 1) * pre;              // in instruction cycles
    const duty = ((s[R.CCPR1L] << 2) | ((s[R.CCP1CON] >> 4) & 3)) / (4 * (s[R.PR2] + 1));
    return { on: true, freq: 1 / (period * this.tcy), duty: Math.min(1, duty) };
  }

  // ---------------------------------------------------------------- CPU
  push(v) { this.stack[this.sp] = v; this.sp = (this.sp + 1) & 7; }
  pop() { this.sp = (this.sp - 1) & 7; return this.stack[this.sp]; }

  flagZ(r) { if (r & 0xff) this.status &= ~4; else this.status |= 4; }
  setC(c) { if (c) this.status |= 1; else this.status &= ~1; }
  setDC(c) { if (c) this.status |= 2; else this.status &= ~2; }

  step() {
    // interrupts
    if (this.intcon & 0x80) {
      const pend = (this.intcon & (this.intcon >> 3) & 0x07) ||
        ((this.intcon & 0x40) && (this.pir1() & this.sfr[R.PIE1]));
      if (pend) {
        this.push(this.pc);
        this.pc = 4;
        this.intcon &= ~0x80;
        this.tick(2);
        return;
      }
    }

    const pc = this.pc;
    const op = this.op[pc], a = this.argA[pc], b = this.argB[pc];
    this.pc = (pc + 1) & 0x1fff;
    this.pclWritten = false;
    let cyc = 1;
    let addr, v, r;

    switch (op) {
      case OP.NOP: break;
      case OP.RETURN: this.pc = this.pop(); cyc = 2; break;
      case OP.RETFIE: this.pc = this.pop(); this.intcon |= 0x80; cyc = 2; break;
      case OP.SLEEP: break;
      case OP.CLRWDT: this.wdt = 0; this.t0presc = (this.sfr[R.OPTION] & 0x08) ? 0 : this.t0presc;
        this.status |= 0x18; break;
      case OP.MOVWF: this.write(this.bankAddr(a), this.w); break;
      case OP.CLRW: this.w = 0; this.status |= 4; break;
      case OP.CLRF: this.write(this.bankAddr(a), 0); this.status |= 4; break;

      case OP.SUBWF: addr = this.bankAddr(a); v = this.read(addr); r = v - this.w;
        this.store(addr, b, r & 0xff); this.setC(r >= 0); this.setDC((v & 0xf) >= (this.w & 0xf)); this.flagZ(r); break;
      case OP.ADDWF: addr = this.bankAddr(a); v = this.read(addr); r = v + this.w;
        this.store(addr, b, r & 0xff); this.setC(r > 0xff); this.setDC((v & 0xf) + (this.w & 0xf) > 0xf); this.flagZ(r); break;
      case OP.DECF: addr = this.bankAddr(a); r = (this.read(addr) - 1) & 0xff; this.store(addr, b, r); this.flagZ(r); break;
      case OP.INCF: addr = this.bankAddr(a); r = (this.read(addr) + 1) & 0xff; this.store(addr, b, r); this.flagZ(r); break;
      case OP.IORWF: addr = this.bankAddr(a); r = this.read(addr) | this.w; this.store(addr, b, r); this.flagZ(r); break;
      case OP.ANDWF: addr = this.bankAddr(a); r = this.read(addr) & this.w; this.store(addr, b, r); this.flagZ(r); break;
      case OP.XORWF: addr = this.bankAddr(a); r = this.read(addr) ^ this.w; this.store(addr, b, r); this.flagZ(r); break;
      case OP.MOVF: addr = this.bankAddr(a); r = this.read(addr); this.store(addr, b, r); this.flagZ(r); break;
      case OP.COMF: addr = this.bankAddr(a); r = (~this.read(addr)) & 0xff; this.store(addr, b, r); this.flagZ(r); break;
      case OP.SWAPF: addr = this.bankAddr(a); v = this.read(addr); this.store(addr, b, ((v << 4) | (v >> 4)) & 0xff); break;
      case OP.RLF: addr = this.bankAddr(a); v = this.read(addr); r = ((v << 1) | (this.status & 1)) & 0xff;
        this.store(addr, b, r); this.setC(v & 0x80); break;
      case OP.RRF: addr = this.bankAddr(a); v = this.read(addr); r = (v >> 1) | ((this.status & 1) << 7);
        this.store(addr, b, r); this.setC(v & 1); break;
      case OP.DECFSZ: addr = this.bankAddr(a); r = (this.read(addr) - 1) & 0xff; this.store(addr, b, r);
        if (r === 0) { this.pc = (this.pc + 1) & 0x1fff; cyc = 2; } break;
      case OP.INCFSZ: addr = this.bankAddr(a); r = (this.read(addr) + 1) & 0xff; this.store(addr, b, r);
        if (r === 0) { this.pc = (this.pc + 1) & 0x1fff; cyc = 2; } break;

      case OP.BCF: addr = this.bankAddr(a); this.write(addr, this.read(addr) & ~(1 << b)); break;
      case OP.BSF: addr = this.bankAddr(a); this.write(addr, this.read(addr) | (1 << b)); break;
      case OP.BTFSC: if (!(this.read(this.bankAddr(a)) & (1 << b))) { this.pc = (this.pc + 1) & 0x1fff; cyc = 2; } break;
      case OP.BTFSS: if (this.read(this.bankAddr(a)) & (1 << b)) { this.pc = (this.pc + 1) & 0x1fff; cyc = 2; } break;

      case OP.CALL:
        if (this.sp === 7) this.stats.stackOverflows++;
        this.push(this.pc); this.pc = ((this.pclath & 0x18) << 8) | a; cyc = 2; break;
      case OP.GOTO: this.pc = ((this.pclath & 0x18) << 8) | a; cyc = 2; break;

      case OP.MOVLW: this.w = a; break;
      case OP.RETLW: this.w = a; this.pc = this.pop(); cyc = 2; break;
      case OP.IORLW: this.w |= a; this.flagZ(this.w); break;
      case OP.ANDLW: this.w &= a; this.flagZ(this.w); break;
      case OP.XORLW: this.w ^= a; this.flagZ(this.w); break;
      case OP.SUBLW: r = a - this.w; this.setC(r >= 0); this.setDC((a & 0xf) >= (this.w & 0xf));
        this.w = r & 0xff; this.flagZ(this.w); break;
      case OP.ADDLW: r = a + this.w; this.setC(r > 0xff); this.setDC((a & 0xf) + (this.w & 0xf) > 0xf);
        this.w = r & 0xff; this.flagZ(this.w); break;
      default: this.stats.badOps++; break;
    }
    if (this.pclWritten) cyc = 2;
    this.tick(cyc);
  }

  store(addr, d, v) { if (d) this.write(addr, v); else this.w = v; }

  // run until `time` >= t (seconds)
  runUntil(t) {
    while (this.time < t) this.step();
  }
}

export { R as REG };
