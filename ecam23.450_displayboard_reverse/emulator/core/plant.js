// A simple physical model of the ECAM 23.450 around the power board:
// mains, water circuit, two thermoblocks, brew unit, grinder, sensors, and
// what comes out of the spouts. It only needs to be plausible enough for the
// real power board firmware to run its cycles; the constants were chosen to
// match the firmware's own thresholds (see docs/powerboard.md).
//
// Two drivers feed it:
//   - the real power board firmware (core/realpb.js): update() turns the PIC
//     pins (triac gates, relay, valves) into actuator states, and readPins()
//     / adc() give the PIC the sensors;
//   - the stub power board (core/stubplant.js): it calls step() with actuator
//     states derived from the stub's phases, so the views work in both modes.
//
// Pin map (docs/powerboard.md):
//   RC2  mains zero-cross (CCP1)          RA6  flowmeter
//   RC1  brew unit motor encoder          RA7  brew unit top switch (low = closed)
//   RE1  brew unit bottom switch (1 = at bottom)
//   RE0  hot water spout (low = fitted)   RA5  milk carafe (low = fitted)
//   RB4  water level (1 = water in the tank)
//   RB0  grounds container, RB1 water tank: AC sensed, toggling with the mains = missing
//   RB3  main relay (loads + sensors)     RB2/RB5 brew unit up/down (triac gates, active low)
//   RD1  coffee heater  RD7 steam heater  RD4 pump  RD2 grinder
//   RD5  EV1  RD3 EV2  RD6 brew unit motor full power
//
// Hydraulics (a model, not a drawing of the real circuit): tank -> pump ->
// flowmeter -> coffee thermoblock -> brew unit -> coffee spout when both
// valves are closed; with EV1 and/or EV2 open the water goes through the
// steam thermoblock to the side outlet instead, where the hot water spout or
// the milk carafe is plugged.

const R_AMB = 25;
const NTC_B = 4450, NTC_R25_OVER_RP = 12.96;     // divider: raw = 1023 * Rp / (Rntc + Rp)

export function tempToCode(t) {
  const r = NTC_R25_OVER_RP * Math.exp(NTC_B * (1 / (t + 273.15) - 1 / 298.15));
  return 1023 / (1 + r);                         // 10 bit ADC
}

export const CAPACITY = { tank: 1800, beans: 250, tray: 700, milk: 500, pucks: 14 };
const GRIND_G_PER_S = 2.6;                       // ~9 g for a 3.5 s standard dose
// Thermoblocks: a heating element (small mass) inside the block (large mass).
// The NTC sits near the element, so it sees the burst-fired element spikes:
// that is what makes the regulation overshoot a little, and the firmware
// relies on it (the energy saving warm-up waits for the coffee side to pass
// its setpoint).
const EL_C = 40, EL_G = 20, NTC_EL = 0.6, NTC_TAU = 0.5;

export class Plant {
  constructor() {
    this.mainsHz = 50;
    this.env = {
      tankPresent: true, waterInTank: true, groundsPresent: true, beans: true,
      accessory: 'spout',                        // 'spout' (hot water), 'carafe' (milk) or 'none'
    };
    this.tankMl = CAPACITY.tank;
    this.beansG = CAPACITY.beans;
    this.milkMl = CAPACITY.milk;                 // in the carafe
    this.trayMl = 0;                             // drip tray
    this.tA = R_AMB; this.tB = R_AMB;            // coffee / steam thermoblock (°C)
    this.eA = R_AMB; this.eB = R_AMB;            // their heating elements
    this.nA = R_AMB; this.nB = R_AMB;            // what their NTCs sense
    this.pos = 0;                                // brew unit position (encoder counts, 0 = bottom)
    this.TOP = 266;                              // full stroke in encoder pulses; the firmware misses the ~19
                                                 // pulses of the soft start, so an empty stroke reads ~247 (>= 0xF2)
    this.cake = 0;                               // ground coffee in the chamber (grinder seconds)
    this.pressed = false;                        // the cake has been compressed into a puck
    this.grounds = 0;                            // pucks in the grounds container
    this.water = 0;                              // ml pumped (total)
    this.flowPulses = 0;                         // flowmeter pulses (total)
    this.flow = 0;                               // ml/s through the pump right now
    this.path = null;                            // 'brew', 'steam' or null
    this.outlet = { kind: null, rate: 0, where: null };   // what comes out right now
    this.poured = { coffee: 0, water: 0, milk: 0, hotwater: 0 };   // ml out of the spouts (totals)
    this.puckDrops = 0;                          // increments when a puck falls (for the views)
    this.flowAcc = 0; this.encAcc = 0;
    this.pins = { rc2: 0, rc1: 0, ra6: 0 };
    this.nextZc = 0;
    this.last = { up: -1, down: -1, pump: -1, grinder: -1, heatA: -1, heatB: -1 };
    this.onTime = { heatA: 0, heatB: 0 };
    this.t = 0;
    this.act = {};
  }

  hasWater() { return this.env.tankPresent && this.env.waterInTank && this.tankMl > 60; }
  hasBeans() { return this.env.beans && this.beansG > 0; }

  // The piston compresses the cake against a spring; the top microswitch
  // closes when the force is reached, i.e. earlier with more coffee. The
  // firmware reads the travel at that point (bu_pos, see f_803e):
  //   < 0xB4 brew unit recovery, < 0xC9 "LESS COFFEE" (too much ground
  //   coffee), 0xC9..0xF1 normal, >= 0xF2 no coffee (beans empty).
  stallAt() { return this.TOP - Math.min(90, this.cake * 9); }    // 1 cup (3.5 s) reads ~0xD8
  topSwitch() { return this.pos >= this.stallAt() - 0.5; }
  bottomSwitch() { return this.pos <= 0; }

  // a new power board starts its clock at 0: keep the physical state
  // (temperatures, brew unit, grounds) but restart the timers
  powerOn() {
    this.nextZc = 0; this.t = 0;
    for (const k of Object.keys(this.last)) this.last[k] = -1;
    this.act = {};
  }

  // ---- inputs seen by the PIC
  readPins(p) {
    const e = this.env, zc = this.pins.rc2;
    if (p === 'A') {
      return (e.accessory === 'carafe' ? 0 : 0x20) | (this.pins.ra6 ? 0x40 : 0) | (this.topSwitch() ? 0 : 0x80);
    }
    if (p === 'B') {
      return (e.groundsPresent ? 0 : zc) | ((e.tankPresent ? 0 : zc) << 1) | (this.hasWater() ? 0x10 : 0);
    }
    if (p === 'C') return (this.pins.rc1 ? 0x02 : 0) | (zc ? 0x04 : 0);
    if (p === 'E') return (e.accessory === 'spout' ? 0 : 0x01) | (this.bottomSwitch() ? 0x02 : 0);
    return 0;
  }

  adc(ch) {
    if (ch === 0) return tempToCode(this.nB);
    if (ch === 1) return tempToCode(this.nA);
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

  // real power board: mains, then the actuators from the PIC pins
  update(pb, t, dt) {
    const cpu = pb.cpu;
    while (t >= this.nextZc) {
      this.nextZc += 1 / (2 * this.mainsHz);
      this.pins.rc2 ^= 1;
      cpu.ccp1Edge(!!this.pins.rc2);
    }
    const latB = pb.lat('B'), latD = pb.lat('D');
    const relay = !!(latB & 0x08);
    const recent = x => t - x < 0.025;
    this.step({
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
    }, t, dt);
  }

  // advance the physics by dt at time t with the given actuator states.
  // Optional overrides (stub driver): buSpeed (counts/s), flowRate and milkRate (ml/s).
  step(a, t, dt) {
    this.t = t;
    this.act = a;
    this.onTime.heatA += a.heatA ? dt : 0;
    this.onTime.heatB += a.heatB ? dt : 0;

    // ---- brew unit: ~80 counts/s, stops on the coffee cake when going up
    const speed = a.buSpeed || (a.fullPower ? 80 : 40);
    const stallAt = this.stallAt();
    let moved = 0;
    if (a.up && !a.down && this.pos < stallAt) moved = Math.min(speed * dt, stallAt - this.pos);
    if (a.down && !a.up && this.pos > 0) moved = -Math.min(speed * dt, this.pos);
    if (moved) {
      this.pos += moved;
      this.encAcc += Math.abs(moved);
      if (moved < 0 && this.pos < this.TOP * 0.3 && this.pressed) {          // going down: the puck drops
        this.cake = 0; this.pressed = false;
        this.puckDrops++;
        if (this.env.groundsPresent) this.grounds++;
      }
    }
    if (this.cake > 0 && this.topSwitch()) this.pressed = true;               // the cake is compressed
    while (this.encAcc >= 0.5) { this.encAcc -= 0.5; this.pins.rc1 ^= 1; }   // one pulse per count

    // ---- grinder (the ground coffee drops into the open chamber)
    if (a.grinder && this.hasBeans()) {
      this.cake += dt;
      this.beansG = Math.max(0, this.beansG - GRIND_G_PER_S * dt);
    }

    // ---- water circuit
    const chamberClosed = this.pos > this.TOP * 0.5;
    const steam = a.ev1 || a.ev2;
    let flow = 0;
    if (a.pump && this.hasWater()) {
      if (a.flowRate !== undefined) flow = a.flowRate;
      else if (steam) flow = this.env.accessory === 'carafe' ? 2 : 4;   // the firmware pulses the pump for steam
      else flow = chamberClosed && this.cake > 0 ? 1.8 : 4;
    }
    this.flow = flow;
    this.path = flow ? (steam ? 'steam' : 'brew') : null;
    this.water += flow * dt;
    this.tankMl = Math.max(0, this.tankMl - flow * dt);
    this.flowAcc += flow * dt * 2.1 * 2;           // ~2.1 pulses per ml, 2 edges per pulse
    while (this.flowAcc >= 1) { this.flowAcc -= 1; this.pins.ra6 ^= 1; if (this.pins.ra6) this.flowPulses++; }

    // ---- where it comes out
    let kind = null, rate = 0, where = null;
    const acc = this.env.accessory, steamHot = this.tB > 100;
    if (this.path === 'brew') {
      if (chamberClosed) { kind = this.cake > 0 ? 'coffee' : 'water'; rate = flow; where = 'coffee'; }
      else { kind = 'water'; rate = flow; where = 'tray'; }                // open chamber: into the tray
    } else if (steam && acc === 'carafe' && steamHot && a.relay) {
      // the firmware pulses the pump into the hot steam block: steam comes out
      // continuously and draws the milk up through the carafe's venturi
      rate = Math.min(this.milkMl / dt, a.milkRate || 2);
      if (rate > 0) { this.milkMl -= rate * dt; kind = 'milk'; } else kind = 'steam';
      where = 'side';
    } else if (this.path === 'steam') {
      if (acc === 'spout') { kind = steamHot ? 'steam' : 'hotwater'; rate = flow; where = 'side'; }
      else if (acc === 'carafe') { kind = 'water'; rate = flow; where = 'side'; }
      else { kind = 'water'; rate = flow; where = 'tray'; }
    }
    this.outlet = { kind, rate, where };
    if (where === 'tray') this.trayMl = Math.min(CAPACITY.tray, this.trayMl + rate * dt);
    else if (kind && kind !== 'steam') this.poured[kind] += rate * dt;

    // ---- thermoblocks (steam: the water also takes the heat of vaporisation)
    const vap = this.tB > 100 ? 2260 : 0;
    const coolA = 2 + (this.path === 'brew' ? flow * 4.18 : 0);
    const coolB = 1.5 + (this.path === 'steam' ? flow * (4.18 + vap / Math.max(1, this.tB - R_AMB)) : 0);
    const inA = EL_G * (this.eA - this.tA), inB = EL_G * (this.eB - this.tB);
    this.eA += dt * ((a.heatA ? 1100 : 0) - inA) / EL_C;
    this.eB += dt * ((a.heatB ? 1000 : 0) - inB) / EL_C;
    this.tA += dt * (inA - coolA * (this.tA - R_AMB)) / 350;
    this.tB += dt * (inB - coolB * (this.tB - R_AMB)) / 250;
    this.tA = Math.min(this.tA, 180); this.tB = Math.min(this.tB, 200);
    const k = Math.min(1, dt / NTC_TAU);
    this.nA += (this.tA + NTC_EL * (this.eA - this.tA) - this.nA) * k;
    this.nB += (this.tB + NTC_EL * (this.eB - this.tB) - this.nB) * k;
  }

  summary() {
    const a = this.act;
    const on = Object.entries(a).filter(([k, v]) => v === true && k !== 'relay').map(([k]) => k).join(' ');
    return `relay ${a.relay ? 'on' : 'off'} | coffee ${this.tA.toFixed(0)}°C steam ${this.tB.toFixed(0)}°C | ` +
      `brew unit ${this.pos.toFixed(0)}/${this.TOP} cake ${this.cake.toFixed(1)} | water ${this.water.toFixed(0)} ml | ${on}`;
  }
}
