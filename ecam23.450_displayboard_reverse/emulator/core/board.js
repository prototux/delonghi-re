// The display board around the PIC: key matrix, rotary encoder, I2C bus
// with LCD/RTC/EEPROM, 74HC4052 link mux, power board stub, LED /
// backlight / cup light / buzzer sampling, UART service tool.
//
// Polarities (from the schematic: BC807 / BCP51 PNP drivers on a -5 V
// supply): rows, LEDs, backlight and cup light are active low; key
// columns and the encoder read 1 when closed.

import { PIC16F916 } from './pic16f916.js';
import { I2CBus, ST7036, M41T00, M24256 } from './i2c.js';
import { PowerBoard } from './powerboard.js';
import { parseFirmware } from './firmware.js';

export const KEYS = ['onoff', 'menu', 'rinse', 'hotwater', 'cup2', 'cup1', 'cappu', 'push'];

export class Board {
  constructor({ firmware, firmwareName = '', eeprom, date = new Date(), clockSet = true, powerboard = null }) {
    this.cpu = new PIC16F916();
    const fw = parseFirmware(firmware, firmwareName);
    this.cpu.load(fw.words, fw.config);

    this.lcd = new ST7036();
    this.rtc = new M41T00(date, clockSet);
    this.eeprom = new M24256(eeprom, () => this.cpu.time, () => !!(this.cpu.lat.B & 0x02));
    this.i2c = new I2CBus([this.lcd, this.rtc, this.eeprom]);
    this.pb = powerboard || new PowerBoard();

    this.keys = Object.fromEntries(KEYS.map(k => [k, false]));
    this.encA = 0; this.encB = 0;
    this.encQueue = [];               // [{a, b, until}]

    // pin integrators (seconds low / high) for PWM'ed outputs
    this.pins = { RA3: 0, RA4: 0, RA6: 0, RA7: 0, RC5: 0 };
    this.low = { RA3: 0, RA4: 0, RA6: 0, RA7: 0 };
    this.lastPinT = 0; this.prevA = 0xff; this.prevPwm = false;
    this.buzzOn = 0;                  // seconds the PWM ran since last sample
    this.lastRtcT = 0;
    this.uartLog = [];                // {dir:'rx'|'tx', b, t}
    this.onUart = null;

    const cpu = this.cpu;
    cpu.readPins = (p) => this.readPins(p);
    cpu.onPortWrite = (p) => this.portWrite(p);
    cpu.spiExchange = (b) => (this.cpu.lat.C & 0x08) ? this.pb.exchange(b, this.cpu.time) : 0xff;
    cpu.uartTx = (b) => this.uartFromPic(b);
    cpu.rxEnabled = () => !(this.cpu.lat.C & 0x08);   // mux on UART
    this.lastLcdRst = 1;
  }

  // ------------------------------------------------------------ inputs
  readPins(p) {
    const cpu = this.cpu;
    if (p === 'B') {
      const rows = cpu.lat.A;       // row active when low
      const r0 = !(rows & 1), r1 = !(rows & 2), r2 = !(rows & 4);
      const k = this.keys;
      const c5 = (k.cappu && r2);
      const c6 = (k.onoff && r0) || (k.rinse && r1) || (k.cup2 && r2);
      const c7 = (k.menu && r0) || (k.hotwater && r1) || (k.cup1 && r2);
      return (c5 ? 0x20 : 0) | (c6 ? 0x40 : 0) | (c7 ? 0x80 : 0) | (this.i2c.line() ? 0x08 : 0) | 0x17;
    }
    if (p === 'C') {
      return (this.encA ? 1 : 0) | (this.encB ? 2 : 0) | (this.keys.push ? 4 : 0) | 0x80;
    }
    return 0;
  }

  portWrite(p) {
    const cpu = this.cpu;
    if (p === 'A') this.samplePins();
    if (p === 'B') {
      const trisB = cpu.sfr[0x86];
      const scl = (trisB & 0x10) ? 1 : (cpu.lat.B >> 4) & 1;
      const sda = (trisB & 0x08) ? 1 : (cpu.lat.B >> 3) & 1;
      this.i2c.update(scl, sda);
      const rst = (cpu.lat.B >> 2) & 1;
      if (!rst) { this.lcd.reset(); this.lcd.inReset = true; }
      else if (!this.lastLcdRst) this.lcd.inReset = false;
      this.lastLcdRst = rst;
    }
  }

  samplePins() {
    const t = this.cpu.time, dt = t - this.lastPinT;
    if (dt > 0) {
      const a = this.prevA;
      for (const [name, bit] of [['RA3', 8], ['RA4', 16], ['RA6', 64], ['RA7', 128]])
        if (!(a & bit)) this.low[name] += dt;
      if (this.prevPwm) this.buzzOn += dt;
    }
    this.lastPinT = t;
    this.prevA = this.cpu.lat.A;
    this.prevPwm = this.cpu.pwm().on;
  }

  // ------------------------------------------------------------ encoder
  // one detent: CW = A, A+B, B, idle ; CCW = B, A+B, A, idle (15 ms each,
  // like a hand-turned knob: the firmware only polls once per main loop pass,
  // which can take ~12 ms while the LCD is being redrawn)
  turn(steps) {
    const dir = Math.sign(steps);
    const seq = dir > 0 ? [[1, 0], [1, 1], [0, 1], [0, 0]] : [[0, 1], [1, 1], [1, 0], [0, 0]];
    for (let i = 0; i < Math.abs(steps); i++) for (const [a, b] of seq) this.encQueue.push({ a, b, dur: 0.015 });
  }

  pumpEncoder() {
    if (!this.encQueue.length) return;
    const q = this.encQueue[0];
    if (q.until === undefined) { q.until = this.cpu.time + q.dur; this.encA = q.a; this.encB = q.b; }
    if (this.cpu.time >= q.until) this.encQueue.shift();
  }

  // ------------------------------------------------------------ UART service tool
  uartFromPic(b) {
    this.uartLog.push({ dir: 'tx', b, t: this.cpu.time });
    if (this.onUart) this.onUart(b);
  }

  uartSend(bytes) {
    for (const b of bytes) this.uartLog.push({ dir: 'rx', b, t: this.cpu.time });
    this.cpu.uartInject(bytes);
  }

  // service frame: 0A len cmd args... chk(xor, seed 0x55)
  static serviceFrame(cmd, args = []) {
    const f = [0x0a, 3 + args.length, cmd, ...args];
    let c = 0x55;
    for (const b of f) c ^= b;
    return [...f, c];
  }

  // ------------------------------------------------------------ run
  run(seconds) {
    const cpu = this.cpu;
    const end = cpu.time + seconds;
    while (cpu.time < end) {
      // run in 100 us slices for the slow devices
      const slice = Math.min(end, cpu.time + 0.0001);
      while (cpu.time < slice) cpu.step();
      if (this.pb.runUntil) this.pb.runUntil(cpu.time);    // real power board firmware
      this.pumpEncoder();
      const dt = cpu.time - this.lastRtcT;
      if (dt > 0.01) { this.rtc.tick(dt); this.lastRtcT = cpu.time; }
    }
    this.samplePins();
  }

  // duty cycles (fraction of time low) since the previous call
  outputs() {
    this.samplePins();
    const w = Math.max(1e-9, this.cpu.time - (this.lastOutT ?? 0));
    this.lastOutT = this.cpu.time;
    const o = {
      esc: this.low.RA3 / w, ok: this.low.RA4 / w, backlight: this.low.RA6 / w, cup: this.low.RA7 / w,
      buzzer: this.buzzOn / w, pwm: this.cpu.pwm(),
    };
    for (const k of Object.keys(this.low)) this.low[k] = 0;
    this.buzzOn = 0;
    return o;
  }

  // LCD content as text (codes >= 0x80 shown as '?', CGRAM as '#')
  lcdText() {
    const conv = c => (c >= 0x20 && c < 0x7f) ? String.fromCharCode(c) : (c < 0x10 ? '#' : (c === 0xff ? '█' : '?'));
    return [0, 1].map(n => this.lcd.line(n).map(conv).join(''));
  }
}
