// PIC18F4525 simulator (standard instruction set, XINST=0) with the
// peripherals the power board firmware uses: TMR0/1/2/3, CCP1 capture,
// ADC, MSSP in SPI slave mode, EUSART, data EEPROM, WDT, ports, interrupts
// (non-priority mode) with fast register stack.
//
// Board specific behaviour (analog levels, switch inputs, the SPI master on
// the other side) comes through callbacks, see powerboard_hw.js.

const FLASH_SIZE = 0xC000;

// SFR addresses
const S = {
  PORTA: 0xF80, PORTB: 0xF81, PORTC: 0xF82, PORTD: 0xF83, PORTE: 0xF84,
  LATA: 0xF89, LATB: 0xF8A, LATC: 0xF8B, LATD: 0xF8C, LATE: 0xF8D,
  TRISA: 0xF92, TRISB: 0xF93, TRISC: 0xF94, TRISD: 0xF95, TRISE: 0xF96,
  OSCTUNE: 0xF9B, PIE1: 0xF9D, PIR1: 0xF9E, IPR1: 0xF9F, PIE2: 0xFA0, PIR2: 0xFA1, IPR2: 0xFA2,
  EECON1: 0xFA6, EECON2: 0xFA7, EEDATA: 0xFA8, EEADR: 0xFA9, EEADRH: 0xFAA,
  RCSTA: 0xFAB, TXSTA: 0xFAC, TXREG: 0xFAD, RCREG: 0xFAE, SPBRG: 0xFAF, SPBRGH: 0xFB0,
  T3CON: 0xFB1, TMR3L: 0xFB2, TMR3H: 0xFB3, BAUDCON: 0xFB8,
  CCP2CON: 0xFBA, CCPR2L: 0xFBB, CCPR2H: 0xFBC, CCP1CON: 0xFBD, CCPR1L: 0xFBE, CCPR1H: 0xFBF,
  ADCON2: 0xFC0, ADCON1: 0xFC1, ADCON0: 0xFC2, ADRESL: 0xFC3, ADRESH: 0xFC4,
  SSPCON2: 0xFC5, SSPCON1: 0xFC6, SSPSTAT: 0xFC7, SSPADD: 0xFC8, SSPBUF: 0xFC9,
  T2CON: 0xFCA, PR2: 0xFCB, TMR2: 0xFCC, T1CON: 0xFCD, TMR1L: 0xFCE, TMR1H: 0xFCF,
  RCON: 0xFD0, WDTCON: 0xFD1, OSCCON: 0xFD3, T0CON: 0xFD5, TMR0L: 0xFD6, TMR0H: 0xFD7,
  STATUS: 0xFD8, FSR2L: 0xFD9, FSR2H: 0xFDA, PLUSW2: 0xFDB, PREINC2: 0xFDC, POSTDEC2: 0xFDD,
  POSTINC2: 0xFDE, INDF2: 0xFDF, BSR: 0xFE0, FSR1L: 0xFE1, FSR1H: 0xFE2, PLUSW1: 0xFE3,
  PREINC1: 0xFE4, POSTDEC1: 0xFE5, POSTINC1: 0xFE6, INDF1: 0xFE7, WREG: 0xFE8, FSR0L: 0xFE9,
  FSR0H: 0xFEA, PLUSW0: 0xFEB, PREINC0: 0xFEC, POSTDEC0: 0xFED, POSTINC0: 0xFEE, INDF0: 0xFEF,
  INTCON3: 0xFF0, INTCON2: 0xFF1, INTCON: 0xFF2, PRODL: 0xFF3, PRODH: 0xFF4, TABLAT: 0xFF5,
  TBLPTRL: 0xFF6, TBLPTRH: 0xFF7, TBLPTRU: 0xFF8, PCL: 0xFF9, PCLATH: 0xFFA, PCLATU: 0xFFB,
  STKPTR: 0xFFC, TOSL: 0xFFD, TOSH: 0xFFE, TOSU: 0xFFF,
};
const C = 1, DC = 2, Z = 4, OV = 8, N = 16;
const PORTS = ['A', 'B', 'C', 'D', 'E'];

export class PIC18F4525 {
  constructor() {
    this.flash = new Uint8Array(FLASH_SIZE).fill(0xff);
    this.ram = new Uint8Array(4096);
    this.eeprom = new Uint8Array(1024).fill(0xff);
    this.config = new Uint8Array(14).fill(0xff);
    this.stack = new Uint32Array(32);
    this.readPins = () => 0;         // (port letter) -> external levels of the input pins
    this.onPortWrite = () => {};     // (port letter)
    this.adcRead = () => 0;          // (channel) -> 10 bit result
    this.uartTx = () => {};          // (byte)
    this.stats = { wdtResets: 0, badOps: 0, stackOverflows: 0, eeWrites: 0 };
    this.cycles = 0; this.time = 0;
    this.reset(false);
  }

  // image = programmer dump (flash at 0, EEPROM at 0xF00000, config at 0x300000)
  loadImage(img) {
    this.flash.set(img.subarray(0, FLASH_SIZE));
    if (img.length >= 0xF00400) this.eeprom.set(img.subarray(0xF00000, 0xF00400));
    if (img.length >= 0x30000E) this.config.set(img.subarray(0x300000, 0x30000E));
    this.decodeAll();
    this.reset(false);
  }

  decodeAll() {
    const n = FLASH_SIZE / 2;
    this.w0 = new Uint16Array(n);
    for (let i = 0; i < n; i++) this.w0[i] = this.flash[2 * i] | (this.flash[2 * i + 1] << 8);
  }

  reset(fromWdt) {
    const r = this.ram;
    for (let a = 0xF80; a < 0x1000; a++) r[a] = 0;
    r[S.TRISA] = r[S.TRISB] = r[S.TRISC] = r[S.TRISD] = 0xff; r[S.TRISE] = 0x07;
    r[S.OSCCON] = 0x40; r[S.PR2] = 0xff; r[S.TXSTA] = 0x02; r[S.ADCON1] = 0x00;
    r[S.T0CON] = 0xff; r[S.INTCON2] = 0xf5; r[S.INTCON3] = 0xc0;
    r[S.RCON] = fromWdt ? 0x14 & ~0x08 : 0x1c;
    r[S.IPR1] = 0xff; r[S.IPR2] = 0xff;
    this.pc = 0; this.sp = 0; this.w = 0;
    this.shadow = { w: 0, status: 0, bsr: 0 };
    this.tmr0h = 0; this.t0presc = 0; this.t0inh = 0;
    this.t1presc = 0; this.t2presc = 0; this.t2post = 0; this.t3presc = 0;
    this.adcBusy = 0;
    this.sspTx = 0xff;
    this.txReg = 0; this.txFull = false; this.tsrBusy = false; this.tsrRemain = 0;
    this.rxFifo = []; this.rxQueue = this.rxQueue || [];
    this.eeWriteRemain = 0;
    this.wdt = 0;
    this.eecon2seq = 0;
    this.setClock();
    if (fromWdt) this.stats.wdtResets++;
  }

  setClock() {
    const r = this.ram;
    const ircf = (r[S.OSCCON] >> 4) & 7;
    let f = [31e3, 125e3, 250e3, 500e3, 1e6, 2e6, 4e6, 8e6][ircf];
    if ((r[S.OSCTUNE] & 0x40) && (ircf === 6 || ircf === 7)) f *= 4;  // PLL with INTOSC
    this.fosc = f;
    this.tcy = 4 / f;
  }

  // ---------------------------------------------------------------- memory
  fsr(n) { const b = [S.FSR0L, S.FSR1L, S.FSR2L][n]; return (this.ram[b] | (this.ram[b + 1] << 8)) & 0xfff; }
  setFsr(n, v) { const b = [S.FSR0L, S.FSR1L, S.FSR2L][n]; this.ram[b] = v & 0xff; this.ram[b + 1] = (v >> 8) & 0x0f; }

  // resolve indirect registers; returns the effective address (and applies pre/post modifications)
  indirect(a, write) {
    let n, kind;
    if (a >= S.INDF0 - 4 && a <= S.INDF0) { n = 0; kind = S.INDF0 - a; }
    else if (a >= S.INDF1 - 4 && a <= S.INDF1) { n = 1; kind = S.INDF1 - a; }
    else { n = 2; kind = S.INDF2 - a; }
    // kind: 0 INDF, 1 POSTINC, 2 POSTDEC, 3 PREINC, 4 PLUSW
    let f = this.fsr(n), ea;
    switch (kind) {
      case 0: ea = f; break;
      case 1: ea = f; this.setFsr(n, f + 1); break;
      case 2: ea = f; this.setFsr(n, f - 1); break;
      case 3: f = (f + 1) & 0xfff; this.setFsr(n, f); ea = f; break;
      default: ea = (f + ((this.w << 24) >> 24)) & 0xfff; break;
    }
    void write;
    return ea;
  }

  indirectEA(a) {
    const ea = this.indirect(a, false);
    return this.isIndirect(ea) ? 0x1000 : ea;        // INDF through INDF: reads 0, writes ignored
  }

  isIndirect(a) { return (a >= 0xFDB && a <= 0xFDF) || (a >= 0xFE3 && a <= 0xFE7) || (a >= 0xFEB && a <= 0xFEF); }

  pins(p) {
    const i = PORTS.indexOf(p);
    const tris = this.ram[S.TRISA + i], lat = this.ram[S.LATA + i];
    const ext = this.readPins(p);
    let mask = tris;
    if (p === 'A' || p === 'E') mask &= ~this.analogMask(p);
    return ((lat & ~tris) | (ext & mask)) & 0xff;
  }

  analogMask(p) {
    // ADCON1 PCFG: channels AN0..AN(12-pcfg) analog
    const pcfg = this.ram[S.ADCON1] & 0x0f;
    const nAnalog = pcfg >= 0x0f ? 0 : Math.min(13, 15 - pcfg);
    let m = 0;
    const map = p === 'A' ? [[0, 0], [1, 1], [2, 2], [3, 3], [4, 5]] : [[5, 0], [6, 1], [7, 2]];
    for (const [ch, bit] of map) if (ch < nAnalog) m |= 1 << bit;
    return m;
  }

  read(a) {
    if (a < 0xF80) return this.ram[a];
    if (a >= 0x1000) return 0;
    if (this.isIndirect(a)) { const ea = this.indirect(a, false); return this.isIndirect(ea) ? 0 : this.read(ea); }
    const r = this.ram;
    switch (a) {
      case S.PORTA: return this.pins('A');
      case S.PORTB: return this.pins('B');
      case S.PORTC: return this.pins('C');
      case S.PORTD: return this.pins('D');
      case S.PORTE: return this.pins('E') & 0x0f;
      case S.WREG: return this.w;
      case S.TMR0L: { this.tmr0hBuf = r[S.TMR0H]; return r[S.TMR0L]; }
      case S.PCL: r[S.PCLATH] = (this.pc >> 8) & 0xff; r[S.PCLATU] = (this.pc >> 16) & 0x1f; return this.pc & 0xff;
      case S.SSPBUF: r[S.SSPSTAT] &= ~1; return r[S.SSPBUF];
      case S.RCREG: {
        const v = this.rxFifo.length ? this.rxFifo.shift() : 0;
        if (!this.rxFifo.length) r[S.PIR1] &= ~0x20;
        return v;
      }
      case S.PIR1: return (r[S.PIR1] & ~0x10) | (this.txFull ? 0 : 0x10);
      case S.TXSTA: return (r[S.TXSTA] & ~2) | (this.tsrBusy ? 0 : 2);
      case S.STKPTR: return (r[S.STKPTR] & 0xc0) | this.sp;
      case S.TOSL: return this.stack[this.sp] & 0xff;
      case S.TOSH: return (this.stack[this.sp] >> 8) & 0xff;
      case S.TOSU: return (this.stack[this.sp] >> 16) & 0x1f;
      default: return r[a];
    }
  }

  write(a, v) {
    v &= 0xff;
    if (a < 0xF80) { this.ram[a] = v; return; }
    if (a >= 0x1000) return;
    if (this.isIndirect(a)) { const ea = this.indirect(a, true); if (!this.isIndirect(ea)) this.write(ea, v); return; }
    const r = this.ram;
    switch (a) {
      case S.PORTA: case S.LATA: r[S.LATA] = v; this.onPortWrite('A'); return;
      case S.PORTB: case S.LATB: r[S.LATB] = v; this.onPortWrite('B'); return;
      case S.PORTC: case S.LATC: r[S.LATC] = v; this.onPortWrite('C'); return;
      case S.PORTD: case S.LATD: r[S.LATD] = v; this.onPortWrite('D'); return;
      case S.PORTE: case S.LATE: r[S.LATE] = v & 7; this.onPortWrite('E'); return;
      case S.TRISA: case S.TRISB: case S.TRISC: case S.TRISD: case S.TRISE:
        r[a] = v; this.onPortWrite(PORTS[a - S.TRISA]); return;
      case S.WREG: this.w = v; return;
      case S.STATUS: r[a] = v & 0x1f; return;
      case S.BSR: r[a] = v & 0x0f; return;
      case S.PCL: this.pc = ((r[S.PCLATU] & 0x1f) << 16) | (r[S.PCLATH] << 8) | (v & 0xfe); this.pclWrite = true; return;
      case S.TMR0L:
        r[S.TMR0L] = v; r[S.TMR0H] = this.tmr0h; this.t0presc = 0; this.t0inh = 2; return;
      case S.TMR0H: this.tmr0h = v; return;     // buffered, applied on TMR0L write
      case S.OSCCON: r[a] = (r[a] & 0x0c) | (v & 0xf3) | 0x04; this.setClock(); return;
      case S.OSCTUNE: r[a] = v; this.setClock(); return;
      case S.SSPBUF:
        this.sspTx = v; r[a] = v;
        if (this.sspActive) r[S.SSPCON1] |= 0x80;   // WCOL
        return;
      case S.TXREG: this.txReg = v; this.txFull = true; this.uartLoad(); return;
      case S.TXSTA: r[a] = v; this.uartLoad(); return;
      case S.RCSTA: {
        let nv = (v & ~0x06) | (r[a] & 0x06);
        if (!(v & 0x10)) nv &= ~0x02;
        if (!(v & 0x80)) this.rxFifo = [];
        r[a] = nv; return;
      }
      case S.PIR1: r[a] = v & ~0x30 | (r[a] & 0x20); return;
      case S.ADCON0:
        r[a] = v;
        if ((v & 0x03) === 0x03 && !this.adcBusy) this.adcBusy = 12 * this.tadCycles();
        return;
      case S.EECON2:
        if (v === 0x55) this.eecon2seq = 1;
        else if (v === 0xaa && this.eecon2seq === 1) this.eecon2seq = 2;
        else this.eecon2seq = 0;
        return;
      case S.EECON1: {
        const old = r[a];
        r[a] = (v & ~0x03) | (old & 0x03);
        if ((v & 0x01) && !(v & 0xc0)) {                       // RD
          r[S.EEDATA] = this.eeprom[((r[S.EEADRH] & 3) << 8) | r[S.EEADR]];
        }
        if ((v & 0x02) && (v & 0x04) && this.eecon2seq === 2 && !(v & 0xc0)) {   // WR
          r[a] |= 0x02;
          this.eeWriteRemain = 0.004;
          this.eeWriteAddr = ((r[S.EEADRH] & 3) << 8) | r[S.EEADR];
          this.eeWriteData = r[S.EEDATA];
          this.eecon2seq = 0;
        }
        return;
      }
      case S.STKPTR: this.sp = v & 0x1f; return;
      case S.TOSL: this.stack[this.sp] = (this.stack[this.sp] & ~0xff) | v; return;
      case S.TOSH: this.stack[this.sp] = (this.stack[this.sp] & ~0xff00) | (v << 8); return;
      case S.TOSU: this.stack[this.sp] = (this.stack[this.sp] & ~0x1f0000) | ((v & 0x1f) << 16); return;
      default: r[a] = v;
    }
  }

  tadCycles() {
    const cs = this.ram[S.ADCON2] & 7;
    return [2, 8, 32, 1, 4, 16, 64, 1][cs] / 4 || 1;
  }

  // ---------------------------------------------------------------- SPI slave
  // called by the SPI master: returns the byte the slave shifts out
  spiExchange(b) {
    const r = this.ram;
    const con = r[S.SSPCON1];
    if (!(con & 0x20) || ((con & 0x0f) !== 4 && (con & 0x0f) !== 5)) return 0xff;
    const out = this.sspTx;
    if (r[S.SSPSTAT] & 1) r[S.SSPCON1] |= 0x40;           // SSPOV: previous byte not read
    else { r[S.SSPBUF] = b; }
    r[S.SSPSTAT] |= 1;
    r[S.PIR1] |= 0x08;
    this.sspTx = r[S.SSPBUF];                              // shift register now holds the received byte
    return out;
  }

  // ---------------------------------------------------------------- EUSART
  uartBitCycles() {
    const r = this.ram;
    const brg16 = r[S.BAUDCON] & 0x08, brgh = r[S.TXSTA] & 0x04;
    const n = brg16 ? ((r[S.SPBRGH] << 8) | r[S.SPBRG]) : r[S.SPBRG];
    const div = brg16 ? (brgh ? 4 : 16) : (brgh ? 16 : 64);
    return div * (n + 1) / 4;                              // in instruction cycles
  }
  uartFrame(tx) {
    const nine = tx ? (this.ram[S.TXSTA] & 0x40) : (this.ram[S.RCSTA] & 0x40);
    return this.uartBitCycles() * (nine ? 11 : 10);
  }
  uartLoad() {
    const r = this.ram;
    if (!(r[S.RCSTA] & 0x80) || !(r[S.TXSTA] & 0x20) || this.tsrBusy || !this.txFull) return;
    this.tsr = this.txReg; this.txFull = false; this.tsrBusy = true; this.tsrRemain = this.uartFrame(true);
  }
  uartInject(bytes) {
    let t = Math.max(this.time, this.rxQueue.length ? this.rxQueue[this.rxQueue.length - 1].t : 0);
    const f = this.uartFrame(false) * this.tcy;
    for (const b of bytes) { t += f; this.rxQueue.push({ t, b }); }
  }

  // ---------------------------------------------------------------- timers
  tick(cyc) {
    this.cycles += cyc;
    this.time += cyc * this.tcy;
    const r = this.ram;

    // TMR0
    const t0 = r[S.T0CON];
    if ((t0 & 0x80) && !(t0 & 0x20)) {
      let inc = 0;
      if (this.t0inh > 0) { this.t0inh = Math.max(0, this.t0inh - cyc); }
      else if (t0 & 0x08) inc = cyc;
      else {
        this.t0presc += cyc;
        const rate = 2 << (t0 & 7);
        while (this.t0presc >= rate) { this.t0presc -= rate; inc++; }
      }
      while (inc--) {
        if (t0 & 0x40) {
          r[S.TMR0L] = (r[S.TMR0L] + 1) & 0xff;
          if (r[S.TMR0L] === 0) r[S.INTCON] |= 0x04;
        } else {
          let v = ((r[S.TMR0H] << 8) | r[S.TMR0L]) + 1;
          if (v > 0xffff) { v = 0; r[S.INTCON] |= 0x04; }
          r[S.TMR0L] = v & 0xff; r[S.TMR0H] = v >> 8;
        }
      }
    }

    // TMR1 (internal clock)
    const t1 = r[S.T1CON];
    if ((t1 & 1) && !(t1 & 2)) {
      this.t1presc += cyc;
      const rate = 1 << ((t1 >> 4) & 3);
      while (this.t1presc >= rate) {
        this.t1presc -= rate;
        let v = ((r[S.TMR1H] << 8) | r[S.TMR1L]) + 1;
        if (v > 0xffff) { v = 0; r[S.PIR1] |= 0x01; }
        r[S.TMR1L] = v & 0xff; r[S.TMR1H] = v >> 8;
      }
    }

    // TMR3 (internal clock)
    const t3 = r[S.T3CON];
    if ((t3 & 1) && !(t3 & 2)) {
      this.t3presc += cyc;
      const rate = 1 << ((t3 >> 4) & 3);
      while (this.t3presc >= rate) {
        this.t3presc -= rate;
        let v = ((r[S.TMR3H] << 8) | r[S.TMR3L]) + 1;
        if (v > 0xffff) { v = 0; r[S.PIR2] |= 0x02; }
        r[S.TMR3L] = v & 0xff; r[S.TMR3H] = v >> 8;
      }
    }

    // TMR2
    const t2 = r[S.T2CON];
    if (t2 & 0x04) {
      this.t2presc += cyc;
      const rate = [1, 4, 16, 16][t2 & 3];
      while (this.t2presc >= rate) {
        this.t2presc -= rate;
        if (r[S.TMR2] === r[S.PR2]) {
          r[S.TMR2] = 0;
          if (++this.t2post > ((t2 >> 3) & 0x0f)) { this.t2post = 0; r[S.PIR1] |= 0x02; }
        } else r[S.TMR2] = (r[S.TMR2] + 1) & 0xff;
      }
    }

    // ADC
    if (this.adcBusy > 0) {
      this.adcBusy -= cyc;
      if (this.adcBusy <= 0) {
        this.adcBusy = 0;
        const ch = (r[S.ADCON0] >> 2) & 0x0f;
        const v = Math.max(0, Math.min(1023, Math.round(this.adcRead(ch))));
        if (r[S.ADCON2] & 0x80) { r[S.ADRESH] = v >> 8; r[S.ADRESL] = v & 0xff; }
        else { r[S.ADRESH] = v >> 2; r[S.ADRESL] = (v & 3) << 6; }
        r[S.ADCON0] &= ~0x02;
        r[S.PIR1] |= 0x40;
      }
    }

    // EUSART
    if (this.tsrBusy) {
      this.tsrRemain -= cyc;
      if (this.tsrRemain <= 0) { this.tsrBusy = false; this.uartTx(this.tsr); this.uartLoad(); }
    }
    if (this.rxQueue.length && this.time >= this.rxQueue[0].t) {
      const { b } = this.rxQueue.shift();
      const rc = r[S.RCSTA];
      if ((rc & 0x90) === 0x90) {
        if (this.rxFifo.length >= 2) r[S.RCSTA] |= 0x02;
        else if (!(rc & 0x02)) { this.rxFifo.push(b); r[S.PIR1] |= 0x20; }
      }
    }

    // EEPROM write cycle
    if (this.eeWriteRemain > 0) {
      this.eeWriteRemain -= cyc * this.tcy;
      if (this.eeWriteRemain <= 0) {
        this.eeprom[this.eeWriteAddr] = this.eeWriteData;
        r[S.EECON1] &= ~0x02;
        r[S.PIR2] |= 0x10;
        this.stats.eeWrites++;
      }
    }

    // WDT: 4 ms nominal x postscaler (CONFIG2H WDTPS), enabled by WDTEN or SWDTEN
    const cfg2h = this.config[3];
    if ((cfg2h & 1) || (r[S.WDTCON] & 1)) {
      this.wdt += cyc * this.tcy;
      if (this.wdt >= 0.004 * (1 << ((cfg2h >> 1) & 0x0f))) { this.wdt = 0; this.reset(true); }
    }
  }

  // external capture event on CCP1 (RC2)
  ccp1Edge(rising) {
    const r = this.ram;
    const m = r[S.CCP1CON] & 0x0f;
    const ok = (m === 4 && !rising) || (m === 5 && rising);
    if (m === 6 || m === 7) {                               // every 4th / 16th rising edge
      if (!rising) return;
      this.ccpPresc = ((this.ccpPresc || 0) + 1) % (m === 6 ? 4 : 16);
      if (this.ccpPresc) return;
    } else if (!ok) return;
    const useT3 = r[S.T3CON] & 0x48;                        // T3CCP bits
    r[S.CCPR1L] = useT3 ? r[S.TMR3L] : r[S.TMR1L];
    r[S.CCPR1H] = useT3 ? r[S.TMR3H] : r[S.TMR1H];
    r[S.PIR1] |= 0x04;
  }

  // ---------------------------------------------------------------- CPU
  word(a) { return this.w0[(a >> 1) & 0x7fff] ?? 0xffff; }
  push(v) { this.sp = (this.sp + 1) & 31; if (this.sp === 31) this.stats.stackOverflows++; this.stack[this.sp] = v; }
  pop() { const v = this.stack[this.sp]; this.sp = (this.sp - 1) & 31; return v; }

  addr(f, a) { return a ? ((this.ram[S.BSR] << 8) | f) : (f < 0x80 ? f : 0xF00 | f); }

  setNZ(v) { let s = this.ram[S.STATUS] & ~(N | Z); if (!(v & 0xff)) s |= Z; if (v & 0x80) s |= N; this.ram[S.STATUS] = s; }
  addFlags(a, b, cin) {
    const r = a + b + cin;
    let s = this.ram[S.STATUS] & ~0x1f;
    if (r > 0xff) s |= C;
    if (((a & 0xf) + (b & 0xf) + cin) > 0xf) s |= DC;
    if (!(r & 0xff)) s |= Z;
    if (r & 0x80) s |= N;
    if (((a ^ r) & (b ^ r) & 0x80)) s |= OV;
    this.ram[S.STATUS] = s;
    return r & 0xff;
  }
  // a - b - borrow  (C = no borrow)
  subFlags(a, b, bin) { return this.addFlags(a, (~b) & 0xff, 1 - bin); }

  interruptPending() {
    const r = this.ram;
    if (!(r[S.INTCON] & 0x80)) return false;
    const ic = r[S.INTCON];
    if (ic & (ic >> 3) & 0x07) return true;
    if (ic & 0x40) {
      if (r[S.PIR1] & r[S.PIE1] & ~0x10) return true;
      if ((r[S.PIE1] & 0x10) && !this.txFull) return true;
      if (r[S.PIR2] & r[S.PIE2]) return true;
    }
    return false;
  }

  step() {
    const r = this.ram;
    if (this.interruptPending()) {
      this.shadow = { w: this.w, status: r[S.STATUS], bsr: r[S.BSR] };
      this.push(this.pc);
      this.pc = 0x08;
      r[S.INTCON] &= ~0x80;
      this.tick(2);
      return;
    }
    const pc = this.pc;
    const w = this.word(pc);
    this.pc = (pc + 2) & 0x1fffff;
    this.pclWrite = false;
    let cyc = 1;
    const hi = w >> 8;
    const top4 = w >> 12;

    const skip = () => { const nw = this.word(this.pc); this.pc += (((nw >> 12) === 0xC) || ((nw >> 8) >= 0xEC && (nw >> 8) <= 0xEF)) ? 4 : 2; cyc = ((nw >> 12) === 0xC || ((nw >> 8) >= 0xEC && (nw >> 8) <= 0xEF)) ? 3 : 2; };
    // effective address; indirect registers are resolved once (one pointer update per instruction)
    const fa = () => { const a = this.addr(w & 0xff, (w >> 8) & 1); return this.isIndirect(a) ? this.indirectEA(a) : a; };
    const dst = (a, v) => { if ((w >> 9) & 1) this.write(a, v); else this.w = v & 0xff; };

    if (top4 === 0) {
      if (w === 0x0000) { /* NOP */ }
      else if (w === 0x0004) { this.wdt = 0; }
      else if (w === 0x0003) { /* SLEEP: treat as NOP */ }
      else if (w === 0x0005) { this.push(this.pc); }
      else if (w === 0x0006) { this.pop(); }
      else if (w === 0x0007) {                                            // DAW
        let v = this.w, s = r[S.STATUS];
        if ((v & 0x0f) > 9 || (s & DC)) v += 6;
        if (((v >> 4) & 0x1f) > 9 || (s & C)) v += 0x60;
        r[S.STATUS] = (s & ~C) | (v > 0xff ? C : 0); this.w = v & 0xff;
      }
      else if (w >= 0x0008 && w <= 0x000f) {                              // TBLRD / TBLWT
        let tp = r[S.TBLPTRL] | (r[S.TBLPTRH] << 8) | (r[S.TBLPTRU] << 16);
        const m = w & 3;
        if (m === 3) tp++;
        if (w < 0x000c) r[S.TABLAT] = tp < 0xC000 ? this.flash[tp] : (tp >= 0x300000 && tp < 0x30000e ? this.config[tp - 0x300000] : 0xff);
        if (m === 1) tp++; else if (m === 2) tp--;
        tp &= 0x3fffff;
        r[S.TBLPTRL] = tp & 0xff; r[S.TBLPTRH] = (tp >> 8) & 0xff; r[S.TBLPTRU] = (tp >> 16) & 0x3f;
        cyc = 2;
      }
      else if (w === 0x0010 || w === 0x0011) {                            // RETFIE
        this.pc = this.pop(); r[S.INTCON] |= 0x80;
        if (w & 1) { this.w = this.shadow.w; r[S.STATUS] = this.shadow.status; r[S.BSR] = this.shadow.bsr; }
        cyc = 2;
      }
      else if (w === 0x0012 || w === 0x0013) {                            // RETURN
        this.pc = this.pop();
        if (w & 1) { this.w = this.shadow.w; r[S.STATUS] = this.shadow.status; r[S.BSR] = this.shadow.bsr; }
        cyc = 2;
      }
      else if (w === 0x00ff) { this.reset(false); return; }
      else if ((w & 0xfff0) === 0x0100) { r[S.BSR] = w & 0x0f; }
      else if (hi >= 0x08 && hi <= 0x0f) {                                // literal ops
        const k = w & 0xff;
        switch (hi) {
          case 0x08: this.w = this.subFlags(k, this.w, 0); break;         // SUBLW
          case 0x09: this.w |= k; this.setNZ(this.w); break;
          case 0x0a: this.w ^= k; this.setNZ(this.w); break;
          case 0x0b: this.w &= k; this.setNZ(this.w); break;
          case 0x0c: this.w = k; this.pc = this.pop(); cyc = 2; break;    // RETLW
          case 0x0d: { const p = this.w * k; r[S.PRODL] = p & 0xff; r[S.PRODH] = p >> 8; break; }
          case 0x0e: this.w = k; break;
          case 0x0f: this.w = this.addFlags(this.w, k, 0); break;
        }
      }
      else if ((w >> 9) === 0x01) {                                       // MULWF
        const p = this.w * this.read(fa()); r[S.PRODL] = p & 0xff; r[S.PRODH] = p >> 8;
      }
      else if ((w >> 10) === 0x01) {                                      // DECF
        const a = fa(); const v = this.read(a); dst(a, this.subFlags(v, 1, 0));
      }
      else { this.stats.badOps++; }
    } else if (top4 <= 5) {
      const op = w >> 10, a = fa();
      const cin = r[S.STATUS] & C;
      let v, res;
      switch (op) {
        case 0x04: res = this.read(a) | this.w; this.setNZ(res); dst(a, res); break;       // IORWF
        case 0x05: res = this.read(a) & this.w; this.setNZ(res); dst(a, res); break;       // ANDWF
        case 0x06: res = this.read(a) ^ this.w; this.setNZ(res); dst(a, res); break;       // XORWF
        case 0x07: res = (~this.read(a)) & 0xff; this.setNZ(res); dst(a, res); break;      // COMF
        case 0x08: v = this.read(a); dst(a, this.addFlags(v, this.w, cin)); break;          // ADDWFC
        case 0x09: v = this.read(a); dst(a, this.addFlags(v, this.w, 0)); break;            // ADDWF
        case 0x0a: v = this.read(a); dst(a, this.addFlags(v, 1, 0)); break;                 // INCF
        case 0x0b: v = (this.read(a) - 1) & 0xff; dst(a, v); if (!v) skip(); break;         // DECFSZ
        case 0x0c: v = this.read(a); res = (v >> 1) | (cin << 7);                            // RRCF
          r[S.STATUS] = (r[S.STATUS] & ~C) | (v & 1); this.setNZ(res); dst(a, res); break;
        case 0x0d: v = this.read(a); res = ((v << 1) | cin) & 0xff;                          // RLCF
          r[S.STATUS] = (r[S.STATUS] & ~C) | (v >> 7); this.setNZ(res); dst(a, res); break;
        case 0x0e: v = this.read(a); dst(a, ((v << 4) | (v >> 4)) & 0xff); break;           // SWAPF
        case 0x0f: v = (this.read(a) + 1) & 0xff; dst(a, v); if (!v) skip(); break;         // INCFSZ
        case 0x10: v = this.read(a); res = (v >> 1) | ((v & 1) << 7); this.setNZ(res); dst(a, res); break; // RRNCF
        case 0x11: v = this.read(a); res = ((v << 1) | (v >> 7)) & 0xff; this.setNZ(res); dst(a, res); break; // RLNCF
        case 0x12: v = (this.read(a) + 1) & 0xff; dst(a, v); if (v) skip(); break;         // INFSNZ
        case 0x13: v = (this.read(a) - 1) & 0xff; dst(a, v); if (v) skip(); break;         // DCFSNZ
        case 0x14: v = this.read(a); this.setNZ(v); dst(a, v); break;                        // MOVF
        case 0x15: v = this.read(a); dst(a, this.subFlags(this.w, v, 1 - cin)); break;      // SUBFWB  W - f - !C
        case 0x16: v = this.read(a); dst(a, this.subFlags(v, this.w, 1 - cin)); break;      // SUBWFB  f - W - !C
        case 0x17: v = this.read(a); dst(a, this.subFlags(v, this.w, 0)); break;            // SUBWF
        default: this.stats.badOps++;
      }
    } else if (top4 === 6) {
      const a = fa(), op = (w >> 9) & 7;
      switch (op) {
        case 0: if (this.read(a) < this.w) skip(); break;                   // CPFSLT
        case 1: if (this.read(a) === this.w) skip(); break;                 // CPFSEQ
        case 2: if (this.read(a) > this.w) skip(); break;                   // CPFSGT
        case 3: if (this.read(a) === 0) skip(); break;                      // TSTFSZ
        case 4: this.write(a, 0xff); break;                                 // SETF
        case 5: this.write(a, 0); r[S.STATUS] |= Z; break;                  // CLRF
        case 6: { const v = this.read(a); this.write(a, this.subFlags(0, v, 0)); break; }   // NEGF
        case 7: this.write(a, this.w); break;                               // MOVWF
      }
    } else if (top4 >= 7 && top4 <= 0xb) {
      const a = fa(), bit = 1 << ((w >> 9) & 7);
      switch (top4) {
        case 7: this.write(a, this.read(a) ^ bit); break;                   // BTG
        case 8: this.write(a, this.read(a) | bit); break;                   // BSF
        case 9: this.write(a, this.read(a) & ~bit); break;                  // BCF
        case 0xa: if (this.read(a) & bit) skip(); break;                    // BTFSS
        case 0xb: if (!(this.read(a) & bit)) skip(); break;                 // BTFSC
      }
    } else if (top4 === 0xc) {                                              // MOVFF
      const w2 = this.word(this.pc); this.pc += 2;
      const v = this.read(w & 0xfff);
      this.write(w2 & 0xfff, v);
      cyc = 2;
    } else if (top4 === 0xd) {
      const n = ((w & 0x7ff) << 21) >> 21;
      if (w & 0x800) this.push(this.pc);                                   // RCALL
      this.pc = (this.pc + 2 * n) & 0x1fffff; cyc = 2;
    } else if (top4 === 0xe) {
      if (hi <= 0xe7) {
        const s = r[S.STATUS];
        const cond = [s & Z, !(s & Z), s & C, !(s & C), s & OV, !(s & OV), s & N, !(s & N)][hi & 7];
        if (cond) { this.pc = (this.pc + 2 * ((w << 24) >> 24)) & 0x1fffff; cyc = 2; }
      } else if (hi === 0xec || hi === 0xed) {                             // CALL
        const w2 = this.word(this.pc); this.pc += 2;
        if (hi & 1) this.shadow = { w: this.w, status: r[S.STATUS], bsr: r[S.BSR] };
        this.push(this.pc);
        this.pc = (((w2 & 0xfff) << 8) | (w & 0xff)) * 2; cyc = 2;
      } else if (hi === 0xef) {                                            // GOTO
        const w2 = this.word(this.pc);
        this.pc = (((w2 & 0xfff) << 8) | (w & 0xff)) * 2; cyc = 2;
      } else if (hi === 0xee) {                                            // LFSR
        const w2 = this.word(this.pc); this.pc += 2;
        this.setFsr((w >> 4) & 3, ((w & 0x0f) << 8) | (w2 & 0xff)); cyc = 2;
      } else this.stats.badOps++;
    } else {
      /* 0xFxxx: NOP (second word) */
    }
    if (this.pclWrite) cyc = 2;
    this.tick(cyc);
  }

  runUntil(t) { while (this.time < t) this.step(); }
}

export { S as PIC18_SFR };
