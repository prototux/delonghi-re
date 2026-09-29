// The real power board firmware running on an emulated PIC18F4525, as a
// drop-in replacement for the PowerBoard stub (same exchange() interface).
//
// The machine around it (sensors, actuators) is modelled in `plant`:
// `readPins`/`adc` give the inputs, `outputs` records what the firmware
// drives. The pin map comes from docs/pb_notes/hw.md.

import { PIC18F4525, PIC18_SFR as S } from './pic18f4525.js';
import { decodeDisplayFrame, frameOk } from './powerboard.js';
import { pic18Image } from './firmware.js';

export class RealPowerBoard {
  constructor(image, plant = {}, eeprom = null) {
    this.cpu = new PIC18F4525();
    this.cpu.loadImage(pic18Image(image));          // raw dump or XC8 .hex
    if (eeprom) this.cpu.eeprom.set(eeprom);          // keep the data EEPROM across power cycles
    this.plant = plant;
    this.connected = true;
    this.lastTx = []; this.lastRx = []; this.frames = 0; this.badFrames = 0;
    this.cur = { tx: [], rx: [], t: -1 };
    this.cpu.readPins = p => (this.plant.readPins ? this.plant.readPins(p, this) : 0);
    this.cpu.adcRead = ch => (this.plant.adc ? this.plant.adc(ch, this) : 512);
    this.cpu.onPortWrite = p => { if (this.plant.portWrite) this.plant.portWrite(p, this); };
    this.cpu.uartTx = b => { if (this.onUart) this.onUart(b); };
  }

  // run the PIC to time t, updating the plant every 100 us
  runUntil(t) {
    const cpu = this.cpu;
    while (cpu.time < t) {
      const slice = Math.min(t, cpu.time + 0.0001);
      const t0 = cpu.time;
      while (cpu.time < slice) cpu.step();
      if (this.plant.update) this.plant.update(this, cpu.time, cpu.time - t0);
    }
  }

  // SPI byte from the display board (master) at time t
  exchange(b, t) {
    this.runUntil(t);
    if (!this.connected) return 0xff;
    if (t - this.cur.t > 0.005) {             // new frame
      if (this.cur.rx.length === 11) {
        this.lastRx = this.cur.rx; this.lastTx = this.cur.tx; this.frames++;
        if (frameOk(this.lastRx, 0xb0)) this.display = decodeDisplayFrame(this.lastRx); else this.badFrames++;
      }
      this.cur = { tx: [], rx: [], t };
    }
    this.cur.t = t;
    const out = this.cpu.spiExchange(b);
    this.cur.rx.push(b); this.cur.tx.push(out);
    return out;
  }

  ram(a) { return this.cpu.ram[a]; }
  lat(p) { return this.cpu.ram[S['LAT' + p]]; }
  tris(p) { return this.cpu.ram[S['TRIS' + p]]; }

  describe() {
    const f = this.lastTx;
    return f.length ? `real power board: state 0x${(f[1] ?? 0).toString(16)} p1 0x${(f[2] ?? 0).toString(16)} ` +
      `p2 0x${(f[3] ?? 0).toString(16)}` : 'real power board: no frame yet';
  }
}
