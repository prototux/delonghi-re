// A simple physical model of the ECAM 23.450 around the power board:
// mains, water circuit, two thermoblocks, brew unit, grinder, sensors.
// It only needs to be plausible enough for the real power board firmware
// to run its cycles; the constants were chosen to match the firmware's own
// thresholds (see docs/pb_notes and docs/powerboard.md).
//
// Pin map (docs/pb_notes/hw.md, units.md):
//   RC2  mains zero-cross (CCP1)          RA6  flowmeter
//   RC1  brew unit motor encoder          RA7  brew unit top switch (low = closed)
//   RE1  brew unit bottom limit (1 = at bottom)
//   RE0  water spout (low = present)      RB4  water level (1 = water in the tank)
//   RB0  grounds container, RB1 water tank: AC sensed, toggling with the mains = missing
//   RA5  unknown switch (kept low)
//   RB3  main relay (loads + sensors)     RB2/RB5 brew unit up/down (triac gates, active low)
//   RD1  coffee heater  RD7 steam heater  RD4 pump  RD2 grinder
//   RD5  EV1  RD3 EV2  RD6 brew unit motor full power

const R_AMB = 25;
const NTC_B = 4450, NTC_R25_OVER_RP = 12.96;     // divider: raw = 255 * Rp / (Rntc + Rp)

export function tempToCode(t) {
  const r = NTC_R25_OVER_RP * Math.exp(NTC_B * (1 / (t + 273.15) - 1 / 298.15));
  const raw = 1023 / (1 + r);                      // 10 bit ADC
  return raw;
}

export class Plant {
  constructor() {
    this.mainsHz = 50;
    this.env = {
      tankPresent: true, waterInTank: true, groundsPresent: true, spoutPresent: true,
      beans: true, ra5: false,
    };
    // state
    this.tA = R_AMB; this.tB = R_AMB;            // coffee / steam thermoblock (°C)
    this.pos = 0;                                // brew unit position (encoder counts, 0 = bottom)
    this.TOP = 266;                              // full stroke in encoder pulses; the firmware misses the ~19
                                                 // pulses of the soft start, so an empty stroke reads ~247 (>= 0xF2)
    this.cake = 0;                               // ground coffee in the chamber (grinder seconds)
    this.grounds = 0;                            // pucks in the grounds container
    this.water = 0;                              // ml dispensed
    this.flowAcc = 0; this.encAcc = 0;
    this.pins = { rc2: 0, rc1: 0, ra6: 0 };
    this.nextZc = 0;
    this.last = { up: -1, down: -1, pump: -1, grinder: -1, heatA: -1, heatB: -1 };
    this.onTime = { heatA: 0, heatB: 0 };
    this.t = 0;
    this.log = [];
    this.act = {};
  }

  // The piston compresses the cake against a spring; the top microswitch
  // closes when the force is reached, i.e. earlier with more coffee. The
  // firmware reads the travel at that point (bu_pos, see f_803e):
  //   < 0xB4 brew unit recovery, < 0xC9 "LESS COFFEE" (too much ground
  //   coffee), 0xC9..0xF1 normal, >= 0xF2 no coffee (beans empty).
  stallAt() { return this.TOP - Math.min(90, this.cake * 9); }    // 1 cup (3.5 s) reads ~0xD8

  // a new power board starts its clock at 0: keep the physical state
  // (temperatures, brew unit, grounds) but restart the timers
  powerOn() {
    this.nextZc = 0; this.t = 0;
    for (const k of Object.keys(this.last)) this.last[k] = -1;
    this.act = {};
  }

  // ---- inputs seen by the PIC
  readPins(p, pb) {
    const e = this.env, zc = this.pins.rc2;
    if (p === 'A') {
      return (e.ra5 ? 0x20 : 0) | (this.pins.ra6 ? 0x40 : 0) | (this.pos >= this.stallAt() - 0.5 ? 0 : 0x80);
    }
    if (p === 'B') {
      return (e.groundsPresent ? 0 : zc) | ((e.tankPresent ? 0 : zc) << 1) |
        ((e.tankPresent && e.waterInTank) ? 0x10 : 0);
    }
    if (p === 'C') return (this.pins.rc1 ? 0x02 : 0) | (zc ? 0x04 : 0);
    if (p === 'E') return (e.spoutPresent ? 0 : 0x01) | (this.pos <= 0 ? 0x02 : 0);
    return 0;
  }

  adc(ch) {
    if (ch === 0) return tempToCode(this.tB);
    if (ch === 1) return tempToCode(this.tA);
    return 512;
  }

  // gate pulses (motor, pump, grinder) are short: remember when they happened
  portWrite(p, pb) {
    const t = pb.cpu.time;
    if (p === 'B') {
      const lat = pb.lat('B');
      if (!(lat & 0x04)) this.last.up = t;
      if (!(lat & 0x20)) this.last.down = t;
    } else if (p === 'D') {
      const lat = pb.lat('D');
      if (lat & 0x10) this.last.pump = t;
      if (lat & 0x04) this.last.grinder = t;
      if (lat & 0x02) this.last.heatA = t;            // triac gates: conducts until the next zero-cross
      if (lat & 0x80) this.last.heatB = t;
    }
  }

  // advance the physics by dt at time t
  update(pb, t, dt) {
    this.t = t;
    const cpu = pb.cpu;
    // mains zero-cross
    while (t >= this.nextZc) {
      this.nextZc += 1 / (2 * this.mainsHz);
      this.pins.rc2 ^= 1;
      cpu.ccp1Edge(!!this.pins.rc2);
    }
    const latB = pb.lat('B'), latD = pb.lat('D');
    const relay = !!(latB & 0x08);
    const recent = x => t - x < 0.025;
    const a = this.act = {
      relay,
      up: relay && recent(this.last.up),
      down: relay && recent(this.last.down),
      pump: relay && recent(this.last.pump),
      grinder: relay && recent(this.last.grinder),
      heatA: relay && t - this.last.heatA < 0.0105,
      heatB: relay && t - this.last.heatB < 0.0105,
      ev1: relay && !!(latD & 0x20),
      ev2: relay && !!(latD & 0x08),
      fullPower: !!(latD & 0x40),
    };
    this.onTime.heatA += a.heatA ? dt : 0;
    this.onTime.heatB += a.heatB ? dt : 0;

    // ---- brew unit: ~80 counts/s, stalls on the coffee cake when going up.
    // The firmware wants the stall between 0xB4 and 0xC9 counts (fsm.md).
    const speed = a.fullPower ? 80 : 40;
    const stallAt = this.stallAt();
    let moved = 0;
    if (a.up && !a.down && this.pos < stallAt) moved = Math.min(speed * dt, stallAt - this.pos);
    if (a.down && !a.up && this.pos > 0) moved = -Math.min(speed * dt, this.pos);
    if (moved) {
      this.pos += moved;
      this.encAcc += Math.abs(moved);
      if (moved < 0 && this.pos < this.TOP * 0.3 && this.cake > 0) {   // going down: the puck drops
        this.cake = 0;
        this.grounds++;
      }
    }
    // encoder: one pulse per count, 50 % duty
    while (this.encAcc >= 0.5) { this.encAcc -= 0.5; this.pins.rc1 ^= 1; }

    // ---- grinder
    if (a.grinder && this.env.beans) this.cake += dt;

    // ---- water circuit
    const water = this.env.tankPresent && this.env.waterInTank;
    let flow = 0;                                  // ml/s
    if (a.pump && water) {
      const chamberClosed = this.pos > this.TOP * 0.5;
      flow = (a.ev1 || a.ev2) ? 5 : (chamberClosed && this.cake > 0 ? 1.8 : 4);
    }
    this.water += flow * dt;
    this.flowAcc += flow * dt * 2.1 * 2;           // ~2.1 pulses per ml, 2 edges per pulse
    while (this.flowAcc >= 1) { this.flowAcc -= 1; this.pins.ra6 ^= 1; }

    // ---- thermoblocks
    const coolA = 2 + flow * 4.18 * ((a.ev1 || a.ev2) ? 0 : 1);
    const coolB = 1.5 + flow * 4.18 * ((a.ev1 || a.ev2) ? 1 : 0);
    this.tA += dt * ((a.heatA ? 1100 : 0) - coolA * (this.tA - R_AMB)) / 350;
    this.tB += dt * ((a.heatB ? 1000 : 0) - coolB * (this.tB - R_AMB)) / 250;
    this.tA = Math.min(this.tA, 180); this.tB = Math.min(this.tB, 200);
  }

  summary() {
    const a = this.act;
    const on = Object.entries(a).filter(([k, v]) => v && k !== 'relay').map(([k]) => k).join(' ');
    return `relay ${a.relay ? 'on' : 'off'} | coffee ${this.tA.toFixed(0)}°C steam ${this.tB.toFixed(0)}°C | ` +
      `brew unit ${this.pos.toFixed(0)}/${this.TOP} cake ${this.cake.toFixed(1)} | water ${this.water.toFixed(0)} ml | ${on}`;
  }
}
