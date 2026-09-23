// Bit level I2C bus (open drain, wired-AND) and the three devices of the
// display board: ST7036 LCD controller, M41T00 RTC and M24256 EEPROM.
//
// The bus is fed with the SCL/SDA levels the PIC drives after every
// PORTB/TRISB write; slaves answer by pulling `slaveSda` low.

export class I2CBus {
  constructor(devices) {
    this.devices = devices;
    this.scl = 1; this.sda = 1;
    this.slaveSda = 1;
    this.phase = 'idle';
    this.dev = null;
    this.shift = 0; this.bits = 0; this.read = false;
    this.log = [];           // optional transaction trace
    this.trace = false;
  }

  // called with the levels the master drives (1 = released/high)
  update(scl, sdaMaster) {
    const sda = sdaMaster & this.slaveSda;
    const pScl = this.scl, pSda = this.sda;
    this.scl = scl; this.sda = sda;

    if (scl && pScl && sda !== pSda) {
      if (!sda) this.start(); else this.stop();
      return;
    }
    if (scl && !pScl) this.rising(sda);
    else if (!scl && pScl) this.falling();
  }

  line() { return this.sda; }

  start() {
    if (this.trace) this.log.push('S');
    this.phase = 'addr'; this.shift = 0; this.bits = 0;
    this.slaveSda = 1;
    if (this.dev && this.dev.restart) this.dev.restart();
    this.dev = null;
  }

  stop() {
    if (this.trace) this.log.push('P');
    if (this.dev && this.dev.stop) this.dev.stop();
    this.dev = null; this.phase = 'idle'; this.slaveSda = 1;
  }

  rising(sda) {
    switch (this.phase) {
      case 'addr':
      case 'rx':
        this.shift = ((this.shift << 1) | sda) & 0xff;
        this.bits++;
        break;
      case 'txack':
        this.masterAck = !sda;
        break;
      default: break;
    }
  }

  falling() {
    switch (this.phase) {
      case 'addr':
      case 'rx':
        if (this.bits < 8) return;
        this.bits = 0;
        let ack = false;
        if (this.phase === 'addr') {
          const a = this.shift & 0xfe;
          this.read = !!(this.shift & 1);
          this.dev = this.devices.find(d => d.addr === a) || null;
          ack = this.dev ? this.dev.start(this.read) : false;
          if (this.trace) this.log.push(`A${this.shift.toString(16)}${ack ? '+' : '-'}`);
        } else {
          ack = this.dev ? this.dev.write(this.shift) : false;
          if (this.trace) this.log.push(`W${this.shift.toString(16)}${ack ? '+' : '-'}`);
        }
        this.acked = ack;
        this.slaveSda = ack ? 0 : 1;
        this.phase = 'ack';
        break;
      case 'ack':
        this.slaveSda = 1;
        if (!this.acked) { this.phase = 'nack'; break; }
        if (this.read) { this.loadTx(); } else { this.phase = 'rx'; this.shift = 0; }
        break;
      case 'tx':
        if (--this.txBit >= 0) this.slaveSda = (this.txByte >> this.txBit) & 1;
        else { this.slaveSda = 1; this.phase = 'txack'; }
        break;
      case 'txack':
        if (this.masterAck) this.loadTx(); else { this.phase = 'nack'; this.slaveSda = 1; }
        break;
      default: break;
    }
  }

  loadTx() {
    this.txByte = this.dev.read() & 0xff;
    if (this.trace) this.log.push(`R${this.txByte.toString(16)}`);
    this.txBit = 7;
    this.slaveSda = (this.txByte >> 7) & 1;
    this.phase = 'tx';
  }
}

// ---------------------------------------------------------------------------
// ST7036 (I2C, write only). 2 lines x 40 DDRAM, 64 bytes CGRAM.
export class ST7036 {
  constructor() { this.addr = 0x78; this.reset(); }

  reset() {
    this.ddram = new Uint8Array(0x80).fill(0x20);
    this.cgram = new Uint8Array(64);
    this.ac = 0; this.cg = false; this.inc = true;
    this.is = 0; this.displayOn = false; this.cursor = false; this.blink = false;
    this.contrast = 0x20; this.booster = false; this.icon = false;
    this.writes = 0;
    this.inReset = false;
  }

  start(read) { if (read || this.inReset) return false; this.expectCtrl = true; return true; }
  stop() {}

  write(b) {
    if (this.expectCtrl) {
      this.co = (b >> 7) & 1; this.rs = (b >> 6) & 1;
      this.expectCtrl = false;
      return true;
    }
    if (this.rs) this.data(b); else this.command(b);
    this.writes++;
    if (this.co) this.expectCtrl = true;
    return true;
  }

  command(b) {
    if (b >= 0x80) { this.ac = b & 0x7f; this.cg = false; return; }
    if (b >= 0x40) {
      if (this.is === 0) { this.ac = b & 0x3f; this.cg = true; return; }
      const hi = b & 0xf0;
      if (hi === 0x50) { this.icon = !!(b & 8); this.booster = !!(b & 4); this.contrast = (this.contrast & 0x0f) | ((b & 3) << 4); }
      else if (hi === 0x70) this.contrast = (this.contrast & 0x30) | (b & 0x0f);
      return;
    }
    if (b >= 0x20) { this.is = b & 1; this.lines = (b >> 3) & 1; return; }
    if (b >= 0x10) return;                       // shift / bias
    if (b >= 0x08) { this.displayOn = !!(b & 4); this.cursor = !!(b & 2); this.blink = !!(b & 1); return; }
    if (b >= 0x04) { this.inc = !!(b & 2); return; }
    if (b >= 0x02) { this.ac = 0; this.cg = false; return; }
    if (b === 0x01) { this.ddram.fill(0x20); this.ac = 0; this.cg = false; this.inc = true; }
  }

  data(b) {
    if (this.cg) { this.cgram[this.ac & 0x3f] = b & 0x1f; this.ac = (this.ac + 1) & 0x3f; return; }
    this.ddram[this.ac & 0x7f] = b;
    let a = this.ac + (this.inc ? 1 : -1);
    if (a === 0x28) a = 0x40; else if (a === 0x68) a = 0x00;
    else if (a === 0x3f) a = 0x27; else if (a === -1) a = 0x67;
    this.ac = a & 0x7f;
  }

  // visible text codes (2 x 20)
  line(n) { return Array.from(this.ddram.subarray(n * 0x40, n * 0x40 + 20)); }
}

// ---------------------------------------------------------------------------
// M41T00 serial RTC: 8 BCD registers, auto-incrementing pointer.
const bcd = n => ((Math.floor(n / 10) << 4) | (n % 10)) & 0xff;
const unbcd = b => ((b >> 4) * 10 + (b & 15));

export class M41T00 {
  constructor(date = new Date(), set = true) {
    this.addr = 0xd0;
    this.regs = new Uint8Array(8);
    this.setDate(date);
    this.regs[7] = set ? 0x00 : 0x80;     // OUT = 1 after a power loss of the RTC
    this.ptr = 0; this.frac = 0; this.first = false;
  }

  setDate(d) {
    const r = this.regs;
    r[0] = bcd(d.getSeconds()); r[1] = bcd(d.getMinutes()); r[2] = bcd(d.getHours());
    r[3] = d.getDay() + 1; r[4] = bcd(d.getDate()); r[5] = bcd(d.getMonth() + 1); r[6] = bcd(d.getFullYear() % 100);
  }

  start(read) { this.first = !read; return true; }
  stop() {}

  write(b) {
    if (this.first) { this.ptr = b & 7; this.first = false; return true; }
    this.regs[this.ptr] = b;
    if (this.ptr === 0) this.frac = 0;
    this.ptr = (this.ptr + 1) & 7;
    return true;
  }

  read() { const v = this.regs[this.ptr]; this.ptr = (this.ptr + 1) & 7; return v; }

  // advance by dt seconds
  tick(dt) {
    if (this.regs[0] & 0x80) return;       // ST: oscillator stopped
    this.frac += dt;
    while (this.frac >= 1) { this.frac -= 1; this.second(); }
  }

  second() {
    const r = this.regs;
    let s = unbcd(r[0] & 0x7f) + 1;
    if (s < 60) { r[0] = bcd(s); return; }
    r[0] = 0;
    let m = unbcd(r[1] & 0x7f) + 1;
    if (m < 60) { r[1] = bcd(m); return; }
    r[1] = 0;
    let h = unbcd(r[2] & 0x3f) + 1;
    if (h < 24) { r[2] = (r[2] & 0xc0) | bcd(h); return; }
    r[2] = r[2] & 0xc0;
    r[3] = (r[3] % 7) + 1;
    r[4] = bcd(unbcd(r[4]) + 1);            // good enough for an emulator
  }

  time() { const r = this.regs; return [unbcd(r[2] & 0x3f), unbcd(r[1] & 0x7f), unbcd(r[0] & 0x7f)]; }
}

// ---------------------------------------------------------------------------
// M24256: 32 KiB, 64 byte pages, /WC pin, 5 ms write cycle (NACK while busy)
export class M24256 {
  constructor(image, now, wc) {
    this.addr = 0xa0;
    this.mem = new Uint8Array(32768).fill(0xff);
    if (image) this.mem.set(image.subarray(0, 32768));
    this.now = now;           // () => seconds
    this.wc = wc;             // () => true if write protected
    this.ptr = 0; this.busyUntil = 0; this.dirty = false;
    this.writesDone = 0;
  }

  start(read) {
    if (this.now() < this.busyUntil) return false;
    this.n = 0; this.reading = read; this.page = [];
    return true;
  }

  write(b) {
    if (this.n === 0) { this.hi = b & 0x7f; this.n++; return true; }
    if (this.n === 1) { this.ptr = (this.hi << 8) | b; this.n++; return true; }
    if (this.wc()) return false;
    this.page.push(b);
    this.n++;
    return true;
  }

  stop() {
    if (!this.reading && this.page && this.page.length) {
      const base = this.ptr & 0x7fc0;
      let off = this.ptr & 0x3f;
      for (const b of this.page.slice(-64)) { this.mem[base | off] = b; off = (off + 1) & 0x3f; }
      this.busyUntil = this.now() + 0.005;
      this.dirty = true;
      this.writesDone++;
    }
    this.page = [];
  }

  read() { const v = this.mem[this.ptr]; this.ptr = (this.ptr + 1) & 0x7fff; return v; }
}
