// Drives the machine model (core/plant.js) from the stub power board, so the
// machine views work without the real power board firmware.
//
// The stub has no idea of pumps or heaters: this maps its phases to actuator
// states with invented timings that follow the stub's own (a brew is grind,
// close the brew unit, pump, open). Temperatures are pulled towards targets
// instead of being regulated. In the other direction, the physical state of
// the model (tank, grounds container, beans, spout / carafe) sets the stub's
// alarms, so taking the tank out behaves the same in both modes.

import { CAPACITY } from './plant.js';

// ml per cup for MY COFFEE, ESPRESSO, STANDARD, LONG, EXTRA LONG
const DRINK_ML = [80, 40, 100, 160, 220];
const TICK = 0.01;                         // s between model updates

export function attachPlant(stub, plant) {
  let last = 0, buTarget = 'bottom';

  function actuators(t) {
    const e = t - stub.t0, ph = stub.phase;
    const a = { relay: ph !== 'off' && ph !== 'boot', buSpeed: 250 };
    let hotA = 95, hotB = 110, pump = false, flowRate;
    switch (ph) {
      case 'warmup':
        buTarget = e < 3 ? 'top' : buTarget;
        if (e >= 3 && e < 6) { pump = true; flowRate = 12; }             // rinse: ~36 ml in 3 s
        break;
      case 'brew': {
        if (e < 1.5) { buTarget = 'bottom'; a.grinder = plant.bottomSwitch(); }
        else if (e < 2.4) buTarget = 'top';
        else if (e < 7.3) { pump = true; flowRate = DRINK_ML[stub.drink] * (stub.cups || 1) / 4.9; }
        else buTarget = 'bottom';
        break;
      }
      case 'milk':
        hotB = 130;
        if (e >= 4.5 && e < 8.5) { a.ev1 = true; pump = true; a.milkRate = 25; }   // ~100 ml of milk
        break;
      case 'hotwater':
        hotB = 80;                                                      // hot water, not steam
        if (e >= 4 && e < 9) { a.ev1 = a.ev2 = true; pump = true; flowRate = 30; }   // ~150 ml
        break;
      case 'rinse':
        if (e < 1.5) buTarget = 'top';
        else if (e < 4.5) { pump = true; flowRate = 10; }
        else buTarget = 'bottom';
        break;
      case 'ready': case 'menu':
        buTarget = 'bottom';
        break;
      default:
        hotA = hotB = 25;
        buTarget = 'bottom';
    }
    if (!a.relay) { hotA = hotB = 25; }
    a.pump = pump;
    if (flowRate !== undefined) a.flowRate = flowRate;
    a.up = buTarget === 'top' && !plant.topSwitch();
    a.down = buTarget === 'bottom' && !plant.bottomSwitch();
    a.heatA = a.relay && plant.tA < hotA - 1;
    a.heatB = a.relay && plant.tB < hotB - 1;
    return { a, hotA, hotB };
  }

  stub.runUntil = t => {
    if (t - last < TICK) return;
    const dt = Math.min(0.1, t - last);
    last = t;
    const { a, hotA, hotB } = actuators(t);
    plant.step(a, t, dt);
    // temperatures: move quickly towards the targets (the stub does not regulate)
    const pull = (v, target) => v + (target - v) * Math.min(1, dt * 0.6);
    plant.tA = plant.eA = plant.nA = pull(plant.tA, hotA);
    plant.tB = plant.eB = plant.nB = pull(plant.tB, hotB);

    const env = plant.env, al = stub.alarms;
    al.tankMissing = !env.tankPresent;
    al.tankEmpty = env.tankPresent && !plant.hasWater();
    al.groundsMissing = !env.groundsPresent;
    al.groundsFull = plant.grounds >= CAPACITY.pucks;
    al.beansEmpty = !plant.hasBeans();
    al.spoutMissing = env.accessory !== 'spout';
    al.milkMissing = env.accessory !== 'carafe';
  };
  stub.plant = plant;
}

// the stub alarms that attachPlant() computes from the model
export const PHYSICAL_ALARMS = ['tankMissing', 'tankEmpty', 'groundsMissing', 'groundsFull', 'beansEmpty',
  'spoutMissing', 'milkMissing'];
