// End-to-end scenarios: boot the real firmware against the power board stub
// (or, for `realpb`, against the real power board firmware and the plant
// model) and check what the LCD shows. Shared by the Node runner (run.mjs) and the
// browser runner (run.html).

import { Board } from '../core/board.js';
import { RealPowerBoard } from '../core/realpb.js';
import { Plant } from '../core/plant.js';
import { attachPlant } from '../core/stubplant.js';

export async function runScenarios(firmware, eeprom, log, { only, pbImage, pbEeprom, uiAddr = 0x2e, buPosAddr = 0x6d } = {}) {
  let failures = 0, checks = 0;
  const date = new Date(2026, 8, 23, 12, 34, 56);
  const mk = (opts = {}) => new Board({ firmware, eeprom, date, ...opts });

  const lcd = b => b.lcdText();
  const show = (b, tag) => {
    const [l1, l2] = lcd(b);
    log(`  [${b.cpu.time.toFixed(2)}s] |${l1}|${l2}|  ${tag || ''}`);
  };
  const expect = (b, re, what) => {
    checks++;
    const s = lcd(b).join('\n');
    if (re.test(s)) { log(`  ok   ${what}`); return true; }
    failures++;
    log(`  FAIL ${what}: expected ${re}, got\n       |${lcd(b)[0]}|\n       |${lcd(b)[1]}|`);
    return false;
  };
  const ok = (cond, what) => { checks++; if (cond) log(`  ok   ${what}`); else { failures++; log(`  FAIL ${what}`); } };
  const press = (b, key, hold = 0.15) => { b.keys[key] = true; b.run(hold); b.keys[key] = false; b.run(0.1); };
  // run until the LCD matches (or timeout)
  const until = (b, re, timeout) => {
    const end = b.cpu.time + timeout;
    while (b.cpu.time < end) { b.run(0.05); if (re.test(lcd(b).join('\n'))) return true; }
    return false;
  };

  const scenarios = {
    async boot() {
      const b = mk();
      b.run(0.8);
      show(b, 'after 0.8 s');
      expect(b, /Self-diagnosis/, 'power board boot state shows "Self-diagnosis"');
      ok(b.pb.frames > 5, `SPI frames exchanged with the power board (${b.pb.frames}, bad ${b.pb.badFrames})`);
      b.run(2.5);
      show(b, 'standby');
      expect(b, /12[: ]3[45]/, 'standby shows the RTC time (colon blinks)');
      b.outputs(); b.run(0.5); const o = b.outputs();
      ok(b.cpu.stats.wdtResets === 0, `no watchdog reset (${b.cpu.stats.wdtResets})`);
      ok(b.cpu.stats.badOps === 0, 'no invalid opcode executed');
      log(`  info backlight duty ${o.backlight.toFixed(2)}, eeprom cfg sent 0x${(b.pb.display?.cfg ?? 0).toString(16)}, languages ${b.pb.display?.languages}`);
      return b;
    },

    async brew() {
      const b = mk();
      b.run(3.2);
      press(b, 'onoff');
      ok(until(b, /Heating up/, 2), 'ON/OFF starts the warm-up ("Heating up")');
      show(b);
      ok(until(b, /Rinsing/, 5), 'warm-up rinse ("Rinsing" + progress)');
      show(b);
      ok(until(b, /ESPRESSO/, 6), 'ready screen shows the selected drink');
      show(b);
      b.turn(1); b.run(0.3);
      expect(b, /STANDARD/, 'encoder CW selects the next drink');
      show(b);
      b.keys.push = true; b.run(0.2); b.keys.push = false; b.run(0.3);
      show(b, 'after encoder push (taste)');
      b.outputs();
      press(b, 'cup1');
      const o = b.outputs(); const click = o.buzzer * (0.25);
      ok(click > 0.02, `key click on the buzzer (~${(click * 1000).toFixed(0)} ms)`);
      ok(until(b, /1 STANDARD COFFEE/, 3), 'brewing "1 STANDARD COFFEE"');
      show(b);
      b.run(4);
      show(b, 'progress bar');
      expect(b, /█/, 'progress bar blocks on line 2');
      ok(until(b, /STANDARD COFFEE\s*\|?\n?.*taste/i, 6) || until(b, /taste/, 4), 'back to the ready screen');
      show(b);
      ok(b.pb.stats.coffee === 1, 'power board counted one coffee');
      return b;
    },

    async alarms() {
      const b = mk();
      b.run(3.2); press(b, 'onoff'); until(b, /ESPRESSO/, 10);
      b.pb.alarms.tankMissing = true;
      ok(until(b, /INSERT TANK/, 1), 'water tank removed -> "INSERT TANK"');
      show(b);
      b.pb.alarms.tankMissing = false; b.pb.alarms.groundsFull = true;
      ok(until(b, /EMPTY GROUNDS/, 1), 'grounds full -> "EMPTY GROUNDS CONTAINER"');
      show(b);
      b.pb.alarms.groundsFull = false; b.pb.alarms.beansEmpty = true;
      ok(until(b, /FILL BEANS/, 1), 'beans empty -> "FILL BEANS CONTAINER"');
      show(b);
      b.pb.alarms.beansEmpty = false;
      ok(until(b, /ESPRESSO/, 1), 'alarm cleared -> ready screen');
      return b;
    },

    async menu() {
      const b = mk();
      b.run(3.2); press(b, 'onoff'); until(b, /ESPRESSO/, 10);
      press(b, 'menu');
      ok(until(b, /Adjust time/, 1), 'P opens the menu at "Adjust time"');
      show(b);
      b.turn(1); b.run(0.3);
      expect(b, /Set language/, 'encoder moves to "Set language"');
      press(b, 'hotwater');
      ok(until(b, /install ENGLISH/, 1), 'OK opens the language item');
      show(b);
      b.turn(1); b.run(0.5);
      ok(until(b, /DEUTSCH/, 1), 'encoder previews the next language (German)');
      show(b);
      press(b, 'hotwater');
      b.run(0.3);
      press(b, 'rinse');
      ok(until(b, /ESPRESSO|KAFFEE/, 2), 'ESC leaves the menu');
      show(b, 'ready screen, now in German');
      return b;
    },

    async clock() {
      const b = mk({ clockSet: false });
      b.run(3.2);
      show(b, 'RTC never set: no clock in standby');
      expect(b, /^\s*\n\s*$/, 'blank standby while the clock is not set');
      ok(b.pb.display && !b.pb.display.clockValid, 'display reports "clock not set" to the power board');
      press(b, 'onoff'); until(b, /ESPRESSO/, 10);
      press(b, 'menu'); until(b, /Adjust time/, 1);
      press(b, 'hotwater'); b.run(0.3);             // open: edit hours
      const h0 = b.pb.eh, m0 = b.pb.em;
      show(b, 'editing hours');
      b.turn(2); b.run(0.4);                        // +2 h
      press(b, 'hotwater'); b.run(0.3);             // minutes
      b.turn(-4); b.run(0.6);                       // -4 min
      show(b, 'editing minutes');
      b.keys.hotwater = true; b.run(0.4); b.keys.hotwater = false; b.run(0.3);  // OK held: display writes the RTC
      const [h, m] = b.rtc.time();
      const eh = (h0 + 2) % 24, em = (m0 + 56) % 60;
      ok(h === eh && m === em, `RTC set to ${h}:${String(m).padStart(2, '0')} by the display firmware (expected ${eh}:${String(em).padStart(2, '0')})`);
      ok(!(b.rtc.regs[7] & 0x80), 'RTC OUT bit cleared ("clock set" marker)');
      b.run(0.5);
      ok(b.pb.display.clockValid, 'display now reports a valid clock');
      return b;
    },

    async linklost() {
      const b = mk();
      b.run(3.2);
      b.pb.connected = false;
      b.run(3.0);
      show(b, 'power board silent for 3 s');
      ok(b.cpu.ram[uiAddr] & 0x80, 'firmware flags ui.link_lost after the 2.5 s timeout');   // `ui` bit 7
      // quirk of the original: the text lines blank but the clock overlay stays (frozen)
      const t1 = lcd(b).join('|'); b.run(2); 
      ok(lcd(b).join('|') === t1, 'screen frozen while the link is down (clock overlay kept, as in the original)');
      b.pb.connected = true;
      ok(until(b, /12[: ]3/, 2), 'screen comes back with the link');
      return b;
    },

    async testmodes() {
      const b = mk();
      b.run(1);
      const frame = (state, p1 = 0, p2 = 0) =>
        ({ state, p1, p2, f1: 0x07, f2: 0, f3: 0, f4: 0, f5: 0, progress: 0 });
      b.pb.manual = frame(0x21);
      ok(until(b, /DISPLAY TEST MODE/, 1), 'manual frame state 0x21 -> "DISPLAY TEST MODE"');
      b.keys.hotwater = true; b.run(0.3);
      show(b, 'hot water held');
      expect(b, /BUTTON\s+6/, 'button test shows key number 6 for HOT WATER');
      b.keys.hotwater = false;
      b.pb.manual = frame(0x22, 0x03);
      b.keys.menu = true; b.run(0.3);
      expect(b, /HEATER ON/, 'load test: P held -> "HEATER ON"');
      b.keys.menu = false;
      b.pb.manual = null;
      return b;
    },

    async service() {
      const b = mk();
      b.keys.push = true;                // hold the encoder button at power up
      b.run(0.8);
      b.keys.push = false;
      b.run(0.3);
      show(b);
      expect(b, /UART MODE/, 'encoder button at power up -> "UART MODE"');
      const got = [];
      b.onUart = x => got.push(x);
      b.uartSend(Board.serviceFrame(0x95, [0x00, 0x14]));   // read message 0 of English
      b.run(0.2);
      const hex = got.map(x => x.toString(16).padStart(2, '0')).join(' ');
      log(`  info reply: ${hex}`);
      ok(got[0] === 0xa0 && got[2] === 0x95, 'read reply header A0 .. 95');
      const txt = String.fromCharCode(...got.slice(5, 21));
      ok(/minutes/.test(txt), `reply carries the EEPROM text ("${txt}")`);
      // EEPROM checksum (32 KiB through the soft I2C: several seconds)
      got.length = 0;
      b.uartSend(Board.serviceFrame(0xb3));
      const t0 = b.cpu.time;
      while (got.length < 6 && b.cpu.time - t0 < 15) b.run(0.1);
      log(`  info checksum took ${(b.cpu.time - t0).toFixed(1)} s`);
      let sum = 0;
      for (let i = 0; i < 0x8000; i++) sum = (sum + eeprom[i]) & 0xffff;
      const rsum = (got[3] << 8) | got[4];
      ok(got[2] === 0xb3 && rsum === sum, `checksum reply 0x${rsum.toString(16)} (expected 0x${sum.toString(16)})`);
      // write 16 bytes, read them back (the firmware ignores RX for 10 ms after a reply)
      b.run(0.05);
      got.length = 0;
      const data = Array.from('HELLO FROM EMU!!', c => c.charCodeAt(0));
      b.uartSend(Board.serviceFrame(0x85, [0x7f, 0xc0, ...data]));
      b.run(0.3);
      ok(got[2] === 0x85 && got[5] === 1, 'write accepted');
      got.length = 0;
      b.uartSend(Board.serviceFrame(0x95, [0x7f, 0xc0]));
      b.run(0.3);
      ok(String.fromCharCode(...got.slice(5, 21)) === 'HELLO FROM EMU!!', 'data written through the service port reads back');
      return b;
    },

    // both real firmwares together: warm-up, a coffee, then no beans
    async realpb() {
      if (!pbImage) { log('  skip (no power board image)'); return; }
      const plant = new Plant();
      const pb = new RealPowerBoard(pbImage, plant, pbEeprom);
      const b = mk({ powerboard: pb });
      const state = () => pb.lastTx[1], step = () => pb.lastTx[2];
      const runUntil = (cond, timeout) => {
        const end = b.cpu.time + timeout;
        while (b.cpu.time < end) { b.run(0.25); if (cond()) return true; }
        return false;
      };
      b.run(3.2);
      show(b, 'standby');
      ok(pb.frames > 50 && pb.badFrames === 0, `frames both ways (${pb.frames}, bad ${pb.badFrames})`);
      press(b, 'onoff');
      ok(until(b, /Heating up/, 3), 'the power board starts the warm-up');
      ok(until(b, /Rinsing/, 60), 'rinse once the coffee thermoblock is hot');
      show(b, `coffee ${plant.tA.toFixed(0)} °C`);
      ok(runUntil(() => state() === 7 && step() === 0, 90), 'ready');
      show(b);
      press(b, 'cup1');
      ok(runUntil(() => step() === 0x0b, 40), 'grind, compact, pre-infuse, then dose');
      const measure = pb.ram(buPosAddr);                     // bu_pos (low byte)
      ok(measure >= 0xc9 && measure < 0xf2, `compaction stroke in the normal window (0x${measure.toString(16)})`);
      show(b, `${plant.water.toFixed(0)} ml pumped`);
      ok(runUntil(() => step() === 0, 60), 'back to ready');
      ok(plant.grounds === 1, 'the puck went into the grounds container');
      ok(plant.poured.coffee > 30, `coffee came out of the spout (${plant.poured.coffee.toFixed(0)} ml)`);
      plant.env.beans = false;
      press(b, 'cup1');
      ok(until(b, /FILL BEANS/, 40), 'an empty hopper gives "FILL BEANS CONTAINER"');
      show(b);
      ok(pb.cpu.stats.wdtResets === 0 && pb.cpu.stats.badOps === 0, 'power board: no watchdog reset, no bad opcode');
      return b;
    },

    // the stub driving the machine model: what the views show in stub mode
    async stubplant() {
      const plant = new Plant();
      const b = mk();
      attachPlant(b.pb, plant);
      b.run(3.2);
      press(b, 'onoff');
      ok(until(b, /ESPRESSO/, 12), 'stub warm-up to ready');
      ok(plant.poured.water > 5, `warm-up rinse through the coffee spout (${plant.poured.water.toFixed(0)} ml)`);
      press(b, 'cup1');
      b.run(8.5);
      ok(plant.poured.coffee > 20 && plant.grounds === 1, `a coffee (${plant.poured.coffee.toFixed(0)} ml) and its puck`);
      plant.env.tankPresent = false;
      b.run(0.5);
      show(b);
      expect(b, /FILL TANK|WATER TANK|INSERT/i, 'taking the tank out of the model raises the stub alarm');
      plant.env.tankPresent = true;
      b.run(0.5);
      plant.env.accessory = 'carafe';
      press(b, 'cappu');
      b.run(9);
      ok(plant.poured.milk > 50, `milk from the carafe (${plant.poured.milk.toFixed(0)} ml)`);
      return b;
    },
  };

  for (const [name, fn] of Object.entries(scenarios)) {
    if (only && !only.includes(name)) continue;
    log(`scenario ${name}`);
    try { await fn(); } catch (e) { failures++; log(`  FAIL exception: ${e.stack || e}`); }
  }
  log(`${checks - failures}/${checks} checks passed`);
  return failures;
}
