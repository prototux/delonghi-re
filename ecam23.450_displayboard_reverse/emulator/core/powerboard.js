// Power board stub: SPI slave + a simplified machine state machine.
//
// It speaks the protocol documented in docs/protocol.md: every ~30 ms the
// display board clocks an 11 byte frame out (keys, encoder, time...) and at
// the same time clocks this board's 11 byte frame in (machine state,
// parameters, flags, progress).
//
// The state machine is a plausible model of the machine, written from what
// the display firmware shows for each state. It is NOT the real power board
// firmware: timings and sequences are made up, the screens are real.

export const KEY = {
  CUP1: 0x01, CUP2: 0x02, HOTWATER: 0x04, MENU: 0x08, ONOFF: 0x10, CAPPU: 0x40, RINSE: 0x80,
};
const OK = KEY.HOTWATER, ESC = KEY.RINSE;

export const DRINKS = ['MY COFFEE', 'ESPRESSO', 'STANDARD', 'LONG', 'EXTRA LONG'];

// Settings menu order (pb_state values)
const MENU = [0x11, 0x12, 0x13, 0x29, 0x16, 0x26, 0x27, 0x28, 0x15, 0x17,
  0x14, 0x19, 0x1f, 0x18, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e];

export const STATE_NAMES = {
  0x00: 'standby', 0x01: 'warm-up', 0x02: 'turning off', 0x04: 'descaling', 0x07: 'ready / brewing',
  0x08: 'rinsing', 0x0a: 'milk', 0x0b: 'hot water', 0x0c: 'cleaning', 0x0d: 'first start',
  0x0e: 'hot water prompt', 0x0f: 'heating', 0x11: 'menu: clock', 0x12: 'menu: language',
  0x13: 'menu: auto-start', 0x14: 'menu: descaling', 0x15: 'menu: temperature', 0x16: 'menu: auto-off',
  0x17: 'menu: water hardness', 0x18: 'menu: default values', 0x19: 'menu: replace filter',
  0x1a: 'menu: stats coffee', 0x1b: 'menu: stats descaling', 0x1c: 'menu: stats water',
  0x1d: 'menu: stats filter', 0x1e: 'menu: stats milk', 0x1f: 'menu: install filter',
  0x21: 'display/button test', 0x22: 'load test', 0x23: 'electric test step', 0x24: 'electric test',
  0x25: 'energy saving', 0x26: 'menu: beep', 0x27: 'menu: energy saving', 0x28: 'menu: cup lighting',
  0x29: 'menu: auto-start time',
};

const bcd = n => ((Math.floor(n / 10) << 4) | (n % 10)) & 0xff;
const unbcd = b => (b >> 4) * 10 + (b & 15);

export class PowerBoard {
  constructor() {
    this.connected = true;
    this.manual = null;       // {state, p1, p2, f1..f5, progress} overrides the state machine
    this.settings = {
      language: 0, h24: true, beep: true, cupLight: true, energySaving: false, filter: false,
      autoStart: false, temperature: 1, hardness: 2, autoOff: 2,
    };
    this.alarms = {
      tankMissing: false, tankEmpty: false, groundsMissing: false, groundsFull: false,
      beansEmpty: false, spoutMissing: false, milkMissing: false, descale: false,
      replaceFilter: false, tooFine: false, general: false,
    };
    this.stats = { coffee: 0, descaling: 0, water: 0, filter: 0, milk: 0 };
    this.drink = 1; this.taste = 3;
    this.frames = 0; this.badFrames = 0;
    this.lastTx = []; this.lastRx = [];
    this.prevKeys = 0; this.prevPush = false; this.enc = null;
    this.languages = 15;
    this.go('boot', 0);
    // SPI framing
    this.idx = 11; this.lastByteT = -1; this.rx = []; this.resp = [];
  }

  // ------------------------------------------------------------ SPI slave
  exchange(b, t) {
    if (t - this.lastByteT > 0.005) { this.idx = 0; this.rx = []; this.resp = this.frame(t); }
    this.lastByteT = t;
    if (this.idx >= 11) return 0xff;
    const out = this.connected ? this.resp[this.idx] : 0xff;
    this.rx.push(b);
    this.idx++;
    if (this.idx === 11) this.onFrame(this.rx, t);
    return out;
  }

  onFrame(f, t) {
    let sum = 0x55;
    for (let i = 0; i < 10; i++) sum = (sum + f[i]) & 0xff;
    this.lastRx = f.slice();
    if (f[0] !== 0xb0 || sum !== f[10]) { this.badFrames++; return; }
    this.frames++;
    this.display = decodeDisplayFrame(f);
    this.languages = f[9] || 15;
    const pressed = f[1] & ~this.prevKeys;
    const released = this.prevKeys & ~f[1];
    this.prevKeys = f[1];
    const push = !!(f[7] & 2);
    const pushed = push && !this.prevPush;
    this.prevPush = push;
    let d = 0;
    if (this.enc !== null) { d = (f[2] - this.enc) & 0xff; if (d > 127) d -= 256; }
    this.enc = f[2];
    if (!this.manual) this.input(pressed, released, d, pushed, t);
    this.update(t);
  }

  // ------------------------------------------------------------ outgoing frame
  frame(t) {
    this.update(t);
    let s;
    if (this.manual) {
      const m = this.manual;
      s = [0x0b, m.state, m.p1, m.p2, m.f1, m.f2, m.f3, m.f4, m.f5, m.progress];
    } else {
      s = [0x0b, this.state, this.p1, this.p2, this.flags1(), this.flags2(), this.flags3(),
        this.flags4(), 0x00, this.progress & 0xff];
    }
    let sum = 0x55;
    for (const b of s) sum = (sum + b) & 0xff;
    s.push(sum);
    this.lastTx = s;
    return s;
  }

  flags1() {
    const c = this.settings;
    return (c.autoStart ? 0 : 0x01) | (c.h24 ? 0x02 : 0) | (c.beep ? 0x04 : 0) | (c.cupLight ? 0x08 : 0) |
      (c.energySaving ? 0x10 : 0) | (c.filter ? 0x80 : 0);
  }
  flags2() {
    const on = this.phase !== 'off' && this.phase !== 'boot';
    return (this.settings.language & 0x0f) | (on && this.settings.cupLight ? 0x10 : 0) |
      (this.alarms.milkMissing ? 0x20 : 0);
  }
  flags3() {
    const a = this.alarms;
    return (a.spoutMissing ? 0 : 0x01) | (a.groundsMissing ? 0x08 : 0) | (a.tankMissing ? 0x10 : 0);
  }
  flags4() {
    const a = this.alarms;
    return (a.tankEmpty ? 0x01 : 0) | (a.groundsMissing || a.groundsFull ? 0x02 : 0) |
      (a.descale ? 0x04 : 0) | (a.replaceFilter ? 0x08 : 0) | (a.tooFine ? 0x10 : 0) |
      (a.beansEmpty ? 0x20 : 0) | (a.general ? 0xc0 : 0);
  }

  blocked() {
    const a = this.alarms;
    return a.tankMissing || a.tankEmpty || a.groundsMissing || a.groundsFull || a.general;
  }

  // ------------------------------------------------------------ state machine
  go(phase, t, extra = {}) {
    this.phase = phase; this.t0 = t; this.progress = 0;
    Object.assign(this, extra);
  }

  elapsed(t) { return t - this.t0; }

  input(pressed, released, d, pushed, t) {
    const p = this.phase;
    if (p === 'off') {
      if (pressed & KEY.ONOFF) this.go('warmup', t);
      return;
    }
    if (p === 'ready') {
      if (pressed & KEY.ONOFF) return this.go('turnoff', t);
      if (d) this.drink = (this.drink + (d > 0 ? 1 : -1) + 5) % 5;
      if (pushed) this.taste = this.taste >= 6 ? 1 : this.taste + 1;
      if (pressed & (KEY.CUP1 | KEY.CUP2)) {
        if (this.blocked() || this.alarms.beansEmpty) return;
        return this.go('brew', t, { cups: (pressed & KEY.CUP2) ? 2 : 1, cappu: false });
      }
      if (pressed & KEY.CAPPU) return this.go('milk', t);
      if (pressed & KEY.HOTWATER) return this.go('hotwater', t);
      if (pressed & KEY.RINSE) return this.go('rinse', t, { then: 'ready' });
      if (pressed & KEY.MENU) return this.go('menu', t, { item: 0, open: false });
      return;
    }
    if (p === 'brew' || p === 'milk' || p === 'hotwater') {
      if (pressed & (KEY.CUP1 | KEY.CUP2 | KEY.CAPPU | KEY.HOTWATER)) this.go('ready', t);  // stop
      return;
    }
    if (p === 'menu') this.menuInput(pressed, released, d, t);
  }

  menuInput(pressed, released, d, t) {
    const item = MENU[this.item];
    if (!this.open) {
      if (pressed & (ESC | KEY.MENU)) return this.go('ready', t);
      if (d) this.item = (this.item + (d > 0 ? 1 : -1) + MENU.length) % MENU.length;
      if (pressed & OK) this.openItem(item);
      return;
    }
    if (this.closeOnRelease) {
      if (released & OK) { this.open = false; this.closeOnRelease = false; }
      return;
    }
    if (pressed & ESC) { this.open = false; return; }
    const c = this.settings;
    switch (item) {
      case 0x11: case 0x29: {          // clock / auto-start time: hours then minutes
        if (d) {
          if (!this.editMin) this.eh = (this.eh + d + 24) % 24;
          else this.em = (this.em + d + 60) % 60;
        }
        if (pressed & OK) {
          if (!this.editMin) this.editMin = true;
          else this.closeOnRelease = true;       // the display stores the time while OK is held
        }
        break;
      }
      case 0x12:
        if (d) this.val = (this.val + (d > 0 ? 1 : -1) + this.languages) % this.languages;
        if (pressed & OK) { c.language = this.val; this.open = false; }
        break;
      case 0x15: case 0x17:
        if (d) this.val = Math.max(0, Math.min(3, this.val + (d > 0 ? 1 : -1)));
        if (pressed & OK) { if (item === 0x15) c.temperature = this.val; else c.hardness = this.val; this.open = false; }
        break;
      case 0x16:
        if (d) this.val = Math.max(0, Math.min(4, this.val + (d > 0 ? 1 : -1)));
        if (pressed & OK) { c.autoOff = this.val; this.open = false; }
        break;
      case 0x13: case 0x26: case 0x27: case 0x28: case 0x1f: {
        const key = { 0x13: 'autoStart', 0x26: 'beep', 0x27: 'energySaving', 0x28: 'cupLight', 0x1f: 'filter' }[item];
        if (pressed & OK) { c[key] = !c[key]; this.open = false; }
        break;
      }
      case 0x14:
        if (pressed & OK) { this.open = false; this.alarms.descale = false; this.stats.descaling++; }
        break;
      case 0x19:
        if (pressed & OK) { this.open = false; this.alarms.replaceFilter = false; this.stats.filter++; }
        break;
      default:
        if (pressed & OK) this.open = false;
    }
  }

  openItem(item) {
    this.open = true; this.editMin = false; this.closeOnRelease = false;
    const c = this.settings;
    const disp = this.display || { hour: 12, min: 0 };
    this.eh = disp.hour; this.em = disp.min;
    this.val = { 0x12: c.language, 0x15: c.temperature, 0x17: c.hardness, 0x16: c.autoOff }[item] ?? 0;
  }

  // compute state/p1/p2 for the current phase
  update(t) {
    const e = this.elapsed(t);
    this.p1 = 0; this.p2 = 0;
    switch (this.phase) {
      case 'boot':
        this.state = 0x00; this.p1 = 0;                 // "Self-diagnosis"
        if (e > 2) this.go('off', t);
        break;
      case 'off':
        this.state = 0x00; this.p1 = 2;                 // clock
        break;
      case 'warmup':
        this.state = 0x01;
        if (this.blocked()) { this.t0 = t; break; }
        if (e < 3) { this.p1 = 0; break; }              // "Heating up / Please wait"
        this.p1 = 5; this.p2 = 0x80;                    // "Rinsing" + progress
        this.progress = Math.min(100, Math.floor((e - 3) / 3 * 100));
        if (e > 6) this.go('ready', t);
        break;
      case 'ready':
        this.state = 0x07; this.p1 = 0;
        this.p2 = (this.drink << 1) | ((this.taste & 7) << 4);
        break;
      case 'brew': {
        this.state = 0x07;
        if (this.blocked()) { this.go('ready', t); break; }
        const base = (this.cups === 2 ? 0x20 : 0) | (this.cappu ? 0x40 : 0);
        this.p2 = (this.drink << 1) | ((this.taste & 7) << 4);
        if (e < 1.5) { this.p1 = base | 1; break; }     // grinding: drink + taste
        const pr = Math.min(100, Math.floor((e - 1.5) / 6 * 100));
        this.progress = pr;
        this.p1 = base | Math.min(13, 4 + Math.floor(pr / 11));
        if (e > 7.5) {
          this.stats.coffee += this.cups;
          if (this.cappu) this.stats.milk++;
          this.go('ready', t);
        }
        break;
      }
      case 'milk':
        this.state = 0x0a;
        if (this.alarms.milkMissing) { this.t0 = t; this.p1 = 0; break; }   // "INSERT MILK CONTAINER"
        if (e < 1.5) { this.p1 = 0; break; }            // "Heating up"
        if (e < 4.5) { this.p1 = 1 | 0x40; break; }     // "Cappuccino" + marquee
        this.p1 = 2 | 0x40;
        this.progress = Math.min(100, Math.floor((e - 4.5) / 4 * 100));
        if (e > 8.5) this.go('brew', t, { cups: 1, cappu: true });
        break;
      case 'hotwater':
        this.state = 0x0b;
        if (this.alarms.spoutMissing) { this.t0 = t; this.p1 = 0; break; } // "INSERT WATER SPOUT"
        if (e < 1) { this.p1 = 0; break; }
        if (e < 4) { this.p1 = 1; break; }
        this.p1 = 2;
        this.progress = Math.min(100, Math.floor((e - 4) / 5 * 100));
        if (e > 9) { this.stats.water++; this.go('ready', t); }
        break;
      case 'rinse':
        this.state = 0x08;
        if (e < 1.5) { this.p1 = 0; break; }            // "Rinsing / Please wait"
        this.p1 = 5;
        this.progress = Math.min(100, Math.floor((e - 1.5) / 3 * 100));
        if (e > 4.5) this.go(this.then || 'ready', t);
        break;
      case 'turnoff':
        this.state = 0x02;
        if (e > 2) this.go('rinse', t, { then: 'off' });
        break;
      case 'menu': {
        const item = MENU[this.item];
        this.state = item | (this.open ? 0x80 : 0);
        if (!this.open) break;
        switch (item) {
          case 0x11: case 0x29:
            this.p1 = bcd(this.eh) | (this.editMin ? 0x80 : 0); this.p2 = bcd(this.em); break;
          case 0x12: case 0x15: case 0x16: case 0x17: this.p1 = this.val; break;
          case 0x13: this.p1 = this.settings.autoStart ? 0 : 1; break;
          case 0x26: this.p1 = this.settings.beep ? 1 : 0; break;
          case 0x27: this.p1 = this.settings.energySaving ? 1 : 0; break;
          case 0x28: this.p1 = this.settings.cupLight ? 1 : 0; break;
          case 0x1f: this.p1 = this.settings.filter ? 1 : 0; break;
          case 0x1a: case 0x1b: case 0x1c: case 0x1d: case 0x1e: {
            const v = this.stats[{ 0x1a: 'coffee', 0x1b: 'descaling', 0x1c: 'water', 0x1d: 'filter', 0x1e: 'milk' }[item]];
            this.p1 = (v >> 8) & 0xff; this.p2 = v & 0xff; break;
          }
          default: break;
        }
        break;
      }
      default: break;
    }
  }

  describe() {
    if (this.manual) return `manual: state ${hex(this.manual.state)}`;
    const name = STATE_NAMES[this.state & 0x3f] || '?';
    return `${this.phase} (state ${hex(this.state)} ${name}, p1 ${hex(this.p1)}, p2 ${hex(this.p2)}, progress ${this.progress})`;
  }
}

// what the display board says in its 11-byte frame (docs/protocol.md)
export function decodeDisplayFrame(f) {
  return {
    keys: f[1], enc: f[2], hour: f[4], min: f[5], sec: f[6],
    keyCount: (f[7] >> 3) & 0xf, push: !!(f[7] & 2), clockValid: !!(f[7] & 0x80),
    cfg: f[8], languages: f[9],
  };
}

export function frameOk(f, header) {
  if (f.length !== 11 || f[0] !== header) return false;
  let sum = 0x55;
  for (let i = 0; i < 10; i++) sum = (sum + f[i]) & 0xff;
  return sum === f[10];
}

export function hex(v) { return '0x' + (v & 0xff).toString(16).padStart(2, '0'); }
export { bcd, unbcd };
