// Front end of the emulator: renders the panel, forwards inputs to the
// board, drives the power board stub from the side panel.

import { Board } from '../core/board.js';
import { STATE_NAMES, DRINKS, hex } from '../core/powerboard.js';
import { RealPowerBoard } from '../core/realpb.js';
import { Plant } from '../core/plant.js';
import { glyph } from './lcdfont.js';

const FILES = '../../../files/machines/ECAM_23.450/';
const $ = id => document.getElementById(id);

let fwBytes, fwName = 'display_board_5513220041_v30_firmware.bin', eeBytes;
const PB_FW = 'power_board_unknown_v1.0_firmware.bin';
let pbImage = null;                     // power board firmware, for the 'real' mode
let pbMode = new URLSearchParams(location.search).get('pb') === 'real' ? 'real' : 'stub';
let plant = null;                       // machine model around the real power board
let board = null;
let running = true;
let speed = 1;
let bootWithPush = false;

// ------------------------------------------------------------------ loading
async function fetchBytes(name) {
  const r = await fetch(FILES + name);
  if (!r.ok) throw new Error(`${name}: HTTP ${r.status}`);
  return new Uint8Array(await r.arrayBuffer());
}

async function init() {
  try {
    fwBytes = await fetchBytes(fwName);
    eeBytes = await fetchBytes('display_board_5513220041_v30_eeprom.bin');
    pbImage = await fetchBytes(PB_FW).catch(() => null);
  } catch (e) {
    $('status').innerHTML = `<span class="bad">Could not load the default images (${e.message}).</span> ` +
      'Serve the repository root over HTTP (see README) or pick the files below.';
  }
  buildSidePanel();
  if (fwBytes && eeBytes) powerCycle();
  requestAnimationFrame(loop);
  // (the demo hook below runs before the first animation frame)
}

function powerCycle() {
  const prev = board;
  const eeprom = prev ? prev.eeprom.mem : eeBytes;         // keep EEPROM writes across power cycles
  let powerboard = null;
  if (pbMode === 'real' && pbImage) {
    if (!plant) plant = new Plant();
    plant.powerOn();
    powerboard = new RealPowerBoard(pbImage, plant, prev && prev.pb.cpu ? prev.pb.cpu.eeprom : null);
    powerboard.connected = $('pbConnected').checked;
  }
  board = new Board({ firmware: fwBytes, firmwareName: fwName, eeprom, clockSet: $('rtcSet').checked, powerboard });
  if (prev) board.rtc.regs.set(prev.rtc.regs);
  if (prev && prev.pb.settings && board.pb.settings) {       // keep the stub's configuration
    Object.assign(board.pb.settings, prev.pb.settings);
    Object.assign(board.pb.alarms, prev.pb.alarms);
    Object.assign(board.pb.stats, prev.pb.stats);
    board.pb.connected = prev.pb.connected;
    board.pb.manual = prev.pb.manual;
  }
  applyManual();
  board.onUart = onUart;
  if (bootWithPush) { board.keys.push = true; setTimeout(() => { if (board) board.keys.push = false; }, 900); bootWithPush = false; }
  svcRx = [];
  $('status').textContent = 'running';
}

// ------------------------------------------------------------------ main loop
let last = performance.now(), emuAcc = 0, realAcc = 0, lastStat = 0;
function loop(now) {
  const dt = Math.min(0.1, (now - last) / 1000);
  last = now;
  if (board && running) {
    const t0 = performance.now();
    board.run(dt * speed);
    realAcc += (performance.now() - t0) / 1000;
    emuAcc += dt * speed;
  }
  if (board) render(now);
  requestAnimationFrame(loop);
}

// ------------------------------------------------------------------ LCD
const THEMES = {
  blue:  { off: '#07122a', lit: '#1b4fb8', on: [236, 244, 255], dotOff: [255, 255, 255, 0.05] },
  green: { off: '#252b12', lit: '#a9c23f', on: [22, 30, 10],    dotOff: [0, 0, 0, 0.06] },
  amber: { off: '#0b0906', lit: '#1a1208', on: [255, 176, 64],  dotOff: [255, 176, 64, 0.05] },
};

function mix(a, b, t) {
  const pa = parseInt(a.slice(1), 16), pb = parseInt(b.slice(1), 16);
  const c = s => Math.round(((pa >> s) & 255) * (1 - t) + ((pb >> s) & 255) * t);
  return `rgb(${c(16)},${c(8)},${c(0)})`;
}

function drawLcd(backlight) {
  const cv = $('lcd'), g = cv.getContext('2d');
  const th = THEMES[$('lcdTheme').value];
  const lcd = board.lcd;
  g.fillStyle = mix(th.off, th.lit, backlight);
  g.fillRect(0, 0, cv.width, cv.height);
  const on = th.on, dim = 0.35 + 0.65 * backlight;
  const onCol = $('lcdTheme').value === 'green'
    ? `rgba(${on[0]},${on[1]},${on[2]},0.92)` : `rgba(${on[0]},${on[1]},${on[2]},${dim})`;
  const offCol = `rgba(${th.dotOff.join(',')})`;
  for (let line = 0; line < 2; line++) {
    for (let col = 0; col < 20; col++) {
      const code = lcd.displayOn ? lcd.ddram[line * 0x40 + col] : 0x20;
      let rows;
      if (code < 0x10) {
        const base = (code & 7) * 8;
        rows = Array.from(lcd.cgram.subarray(base, base + 8));
      } else {
        rows = glyph(code);
      }
      const x0 = 6 + col * 24, y0 = 4 + line * 40;
      for (let y = 0; y < 8; y++) {
        for (let x = 0; x < 5; x++) {
          g.fillStyle = (rows[y] >> (4 - x)) & 1 ? onCol : offCol;
          g.fillRect(x0 + x * 4, y0 + y * 4, 3, 3);
        }
      }
    }
  }
}

// ------------------------------------------------------------------ render
let audio = null;
function sound(on, freq) {
  if (!$('sound').checked) on = false;
  if (!audio && on) {
    try {
      const ctx = new AudioContext();
      const osc = ctx.createOscillator(), gain = ctx.createGain();
      osc.type = 'square'; osc.frequency.value = 3968; gain.gain.value = 0;
      osc.connect(gain).connect(ctx.destination); osc.start();
      audio = { ctx, osc, gain };
    } catch { return; }
  }
  if (!audio) return;
  if (freq) audio.osc.frequency.setTargetAtTime(freq, audio.ctx.currentTime, 0.001);
  audio.gain.gain.setTargetAtTime(on ? 0.04 : 0, audio.ctx.currentTime, 0.003);
}

let lastFreq = 3968, lastOut = null;
function render(now) {
  const o = board.outputs();
  lastOut = o;
  const bl = Math.min(1, o.backlight);
  drawLcd(bl);

  const led = (el, duty) => {
    const i = Math.min(1, duty * 2);          // "on" is a 50 % PWM in the firmware
    el.style.background = i > 0.05 ? `rgb(255, ${170 + 70 * i}, ${90 + 80 * i})` : '';
    el.style.boxShadow = i > 0.05 ? `0 0 ${8 + 12 * i}px ${2 * i}px rgba(255, 180, 80, ${0.9 * i})` : '';
  };
  led($('ledEsc'), o.esc);
  led($('ledOk'), o.ok);

  for (const id of ['cupL', 'cupR']) {
    const el = $(id), i = Math.min(1, o.cup);
    el.style.background = i > 0.05 ? `rgba(215, 232, 255, ${0.25 + 0.75 * i})` : '';
    el.style.boxShadow = i > 0.05 ? `0 0 26px 8px rgba(120, 170, 255, ${0.55 * i}), 0 18px 40px 10px rgba(255,255,255,${0.12 * i})` : '';
  }

  if (o.pwm.on) lastFreq = o.pwm.freq;
  const buzz = o.buzzer > 0.01;
  $('buzzer').classList.toggle('on', buzz);
  sound(buzz, lastFreq);

  if (now - lastStat > 250) { lastStat = now; updatePanels(); }
}

// ------------------------------------------------------------------ inputs
const KEYMAP = { q: 'onoff', w: 'menu', e: 'rinse', i: 'cup1', o: 'cup2', p: 'hotwater', c: 'cappu' };

function setKey(k, down) {
  if (!board) return;
  board.keys[k] = down;
  document.querySelectorAll(`[data-key="${k}"]`).forEach(b => b.classList.toggle('down', down));
  if (k === 'push') $('knobCap').classList.toggle('down', down);
  if (down && audio && audio.ctx.state === 'suspended') audio.ctx.resume();
}

let knobAngle = 0;
function turn(n) {
  if (!board) return;
  board.turn(n);
  knobAngle += n * 18;
  $('knobRing').style.transform = `rotate(${knobAngle}deg)`;
}

function bindInputs() {
  document.querySelectorAll('.key').forEach(b => {
    const k = b.dataset.key;
    b.addEventListener('pointerdown', e => { e.preventDefault(); b.setPointerCapture(e.pointerId); setKey(k, true); });
    b.addEventListener('pointerup', () => setKey(k, false));
    b.addEventListener('pointercancel', () => setKey(k, false));
  });
  const cap = $('knobCap');
  cap.addEventListener('pointerdown', e => { e.preventDefault(); cap.setPointerCapture(e.pointerId); setKey('push', true); });
  cap.addEventListener('pointerup', () => setKey('push', false));

  // drag the ring: one detent every 18 degrees
  const ring = $('knobRing');
  let dragAngle = null;
  const angleOf = e => {
    const r = $('knob').getBoundingClientRect();
    return Math.atan2(e.clientY - (r.top + r.height / 2), e.clientX - (r.left + r.width / 2)) * 180 / Math.PI;
  };
  ring.addEventListener('pointerdown', e => { ring.setPointerCapture(e.pointerId); dragAngle = angleOf(e); ring.style.cursor = 'grabbing'; });
  ring.addEventListener('pointermove', e => {
    if (dragAngle === null) return;
    let d = angleOf(e) - dragAngle;
    if (d > 180) d -= 360; if (d < -180) d += 360;
    if (Math.abs(d) >= 18) { const n = Math.trunc(d / 18); turn(n); dragAngle += n * 18; }
  });
  ring.addEventListener('pointerup', () => { dragAngle = null; ring.style.cursor = ''; });
  $('knob').addEventListener('wheel', e => { e.preventDefault(); turn(e.deltaY > 0 ? 1 : -1); }, { passive: false });
  $('cw').onclick = () => turn(1);
  $('ccw').onclick = () => turn(-1);

  window.addEventListener('keydown', e => {
    if (e.target.tagName === 'INPUT' || e.target.tagName === 'SELECT' || e.repeat) return;
    const k = KEYMAP[e.key.toLowerCase()];
    if (k) { setKey(k, true); e.preventDefault(); return; }
    if (e.key === 'ArrowRight') { turn(1); e.preventDefault(); }
    else if (e.key === 'ArrowLeft') { turn(-1); e.preventDefault(); }
    else if (e.key === 'ArrowDown') { setKey('push', true); e.preventDefault(); }
    else if (e.key === ' ') { toggleRun(); e.preventDefault(); }
  });
  window.addEventListener('keyup', e => {
    const k = KEYMAP[e.key.toLowerCase()];
    if (k) setKey(k, false);
    if (e.key === 'ArrowDown') setKey('push', false);
  });
  window.addEventListener('blur', () => { if (board) for (const k of Object.keys(board.keys)) setKey(k, false); });
}

function toggleRun() { running = !running; $('run').textContent = running ? 'Pause' : 'Run'; $('status').textContent = running ? 'running' : 'paused'; }

// ------------------------------------------------------------------ side panel
const ALARMS = [
  ['tankMissing', 'water tank removed'], ['tankEmpty', 'water tank empty'],
  ['groundsMissing', 'grounds container removed'], ['groundsFull', 'grounds container full'],
  ['beansEmpty', 'beans empty'], ['spoutMissing', 'water spout removed'],
  ['milkMissing', 'milk container removed'], ['descale', 'descale needed'],
  ['replaceFilter', 'replace filter'], ['tooFine', 'ground too fine'],
  ['general', 'general alarm'],
];

const PRESETS = [
  ['— pick a preset —', null],
  ['standby, clock', [0x00, 0x02, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00]],
  ['ready, espresso', [0x07, 0x00, 0x32, 0x07, 0x10, 0x01, 0x00, 0x00, 0x00]],
  ['display / button test (0x21)', [0x21, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00]],
  ['display test, all blocks', [0x21, 0x00, 0x01, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00]],
  ['load test (0x22, keys)', [0x22, 0x03, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00]],
  ['load test: brew unit motor', [0x22, 0x04, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00]],
  ['electric test step 1: OK LED', [0x23, 0x00, 0x01, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00]],
  ['electric test step 3: backlight', [0x23, 0x00, 0x03, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00]],
  ['electric test step 5: glyph 0', [0x23, 0x00, 0x05, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00]],
  ['energy saving (0x25)', [0x25, 0x01, 0x00, 0x17, 0x00, 0x00, 0x00, 0x00, 0x00]],
  ['first start: language (0x0D)', [0x0d, 0x00, 0x01, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00]],
  ['descaling: add descaler', [0x04, 0x01, 0x00, 0x07, 0x00, 0x01, 0x00, 0x00, 0x00]],
  ['cleaning (0x0C) 60 %', [0x0c, 0x02, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x3c]],
  ['brew unit fault: PRESS ESC + OK', [0x07, 0x00, 0x00, 0x07, 0x00, 0x00, 0x40, 0x41, 0x00]],
];
const FIELDS = ['state', 'p1', 'p2', 'f1', 'f2', 'f3', 'f4', 'f5', 'progress'];

function buildSidePanel() {
  const al = $('alarms');
  for (const [k, label] of ALARMS) {
    const l = document.createElement('label');
    l.innerHTML = `<input type="checkbox" data-alarm="${k}"> ${label}`;
    al.appendChild(l);
  }
  al.addEventListener('change', e => { if (board) board.pb.alarms[e.target.dataset.alarm] = e.target.checked; });
  $('pbConnected').onchange = e => { if (board) board.pb.connected = e.target.checked; };
  $('pbMode').value = pbMode;
  $('pbMode').onchange = e => {
    pbMode = e.target.value;
    if (pbMode === 'real' && !pbImage) {
      $('status').innerHTML = `<span class="bad">${PB_FW} could not be loaded.</span>`;
      pbMode = e.target.value = 'stub';
    }
    showPbPanels();
    if (fwBytes && eeBytes) powerCycle();
  };
  showPbPanels();

  const pe = $('plantEnv');
  for (const [k, label] of PLANT_ENV) {
    const l = document.createElement('label');
    l.innerHTML = `<input type="checkbox" data-env="${k}" checked> ${label}`;
    pe.appendChild(l);
  }
  pe.addEventListener('change', e => {
    if (!plant) plant = new Plant();
    const k = e.target.dataset.env;
    plant.env[k] = e.target.checked;
    if (k === 'groundsPresent' && !e.target.checked) plant.grounds = 0;   // emptied
  });

  const fe = $('frameEdit');
  FIELDS.forEach(f => {
    const l = document.createElement('label');
    l.innerHTML = `${f}<input data-field="${f}" value="00">`;
    fe.appendChild(l);
  });
  fe.addEventListener('input', applyManual);
  $('manualOn').onchange = applyManual;
  const ps = $('preset');
  PRESETS.forEach(([name], i) => { const o = document.createElement('option'); o.value = i; o.textContent = name; ps.appendChild(o); });
  ps.onchange = () => {
    const v = PRESETS[ps.value][1];
    if (!v) return;
    FIELDS.forEach((f, i) => { fe.querySelector(`[data-field=${f}]`).value = v[i].toString(16).padStart(2, '0'); });
    $('manualOn').checked = true;
    applyManual();
  };

  $('run').onclick = toggleRun;
  $('reset').onclick = () => { if (fwBytes && eeBytes) powerCycle(); };
  $('speed').onchange = e => { speed = parseFloat(e.target.value); };
  $('fwFile').onchange = async e => {
    const f = e.target.files[0]; if (!f) return;
    fwBytes = new Uint8Array(await f.arrayBuffer()); fwName = f.name; board = null;
    if (eeBytes) powerCycle();
  };
  $('eeFile').onchange = async e => {
    const f = e.target.files[0]; if (!f) return;
    eeBytes = new Uint8Array(await f.arrayBuffer()); board = null;
    if (fwBytes) powerCycle();
  };
  $('eeSave').onclick = () => {
    if (!board) return;
    const a = document.createElement('a');
    a.href = URL.createObjectURL(new Blob([board.eeprom.mem]));
    a.download = 'eeprom.bin'; a.click();
  };
  $('svcBoot').onclick = () => { bootWithPush = true; powerCycle(); };
  $('svcRead').onclick = () => {
    const a = parseInt($('svcAddr').value, 16) & 0x7fff;
    svcSend(0x95, [a >> 8, a & 0xff]);
  };
  $('svcSum').onclick = () => svcSend(0xb3, []);
  bindInputs();
}

const PLANT_ENV = [
  ['tankPresent', 'water tank in place'], ['waterInTank', 'water in the tank'],
  ['groundsPresent', 'grounds container in place'], ['spoutPresent', 'hot water spout fitted'],
  ['beans', 'beans in the hopper'],
];

// the stub's controls make no sense with the real firmware and vice versa
function showPbPanels() {
  const real = pbMode === 'real';
  $('plantPanel').hidden = !real;
  $('alarmPanel').hidden = real;
  $('manualPanel').hidden = real;
  $('pbSettings').hidden = real;
}

function applyManual() {
  if (!board || !board.pb.settings) return;
  if (!$('manualOn').checked) { board.pb.manual = null; return; }
  const m = {};
  for (const f of FIELDS) m[f] = parseInt(document.querySelector(`[data-field=${f}]`).value, 16) & 0xff || 0;
  board.pb.manual = m;
}

// ---- service port
let svcRx = [];
function svcSend(cmd, args) {
  if (!board) return;
  const f = Board.serviceFrame(cmd, args);
  svcLog(`→ ${f.map(b => hex(b).slice(2)).join(' ')}`);
  svcRx = [];
  board.uartSend(f);
}
function onUart(b) {
  svcRx.push(b);
  if (svcRx.length >= 2 && svcRx.length === svcRx[1] + 1) {
    const f = svcRx; svcRx = [];
    let line = `← ${f.map(x => hex(x).slice(2)).join(' ')}`;
    if (f[2] === 0x95) line += `\n   "${String.fromCharCode(...f.slice(5, 21).map(c => (c >= 32 && c < 127 ? c : 46)))}"`;
    if (f[2] === 0xb3) line += `\n   sum = 0x${((f[3] << 8) | f[4]).toString(16).padStart(4, '0')}`;
    svcLog(line);
  }
}
function svcLog(s) { const el = $('svcLog'); el.textContent += s + '\n'; el.scrollTop = el.scrollHeight; }

// ---- periodic panel refresh
function updatePanels() {
  const pb = board.pb;
  if (pb.cpu) updateRealPb(pb); else updateStub(pb);
  updateFrames(pb);
  updateCpu();
}

function updateRealPb(pb) {
  const f = pb.lastTx.length === 11 ? pb.lastTx : null;
  $('pbState').innerHTML = f
    ? `<b>real firmware</b> · state ${hex(f[1])} ${STATE_NAMES[f[1] & 0x3f] || ''}<br>` +
      `p1 ${hex(f[2])} · p2 ${hex(f[3])} · flags ${f.slice(4, 9).map(b => hex(b).slice(2)).join(' ')} · progress ${f[9]}%`
    : '<b>real firmware</b> · no frame yet';
  $('pbStats').textContent = `frames ${pb.frames} (bad ${pb.badFrames})`;

  const p = plant, a = p.act || {};
  const gauge = (label, value, frac, cls = '') =>
    `<div class="gauge ${cls}">${label}<b>${value}</b><div class="bar"><i style="width:${Math.max(0, Math.min(100, frac * 100)).toFixed(0)}%"></i></div></div>`;
  const buPos = pb.ram(0x6d) | (pb.ram(0x6e) << 8);
  $('plantView').innerHTML =
    gauge('coffee thermoblock', `${p.tA.toFixed(0)} °C`, (p.tA - 20) / 110, a.heatA ? 'hot' : '') +
    gauge('steam thermoblock', `${p.tB.toFixed(0)} °C`, (p.tB - 20) / 140, a.heatB ? 'hot' : '') +
    gauge('brew unit', `${p.pos.toFixed(0)} / ${p.TOP}`, p.pos / p.TOP) +
    gauge('firmware bu_pos', `${buPos} (0x${buPos.toString(16)})`, buPos / 0xf2) +
    gauge('water pumped', `${p.water.toFixed(0)} ml`, (p.water % 250) / 250) +
    gauge('grounds container', `${p.grounds} puck${p.grounds === 1 ? '' : 's'}${p.cake > 0 ? ` · ${p.cake.toFixed(1)} s in chamber` : ''}`, p.grounds / 14);
  $('plantLoads').innerHTML = [
    ['relay', 'main relay'], ['heatA', 'coffee heater'], ['heatB', 'steam heater'], ['pump', 'pump'],
    ['grinder', 'grinder'], ['up', 'brew unit up'], ['down', 'brew unit down'], ['ev1', 'EV1'], ['ev2', 'EV2'],
  ].map(([k, n]) => `<span class="${a[k] ? 'on' : ''}">${n}</span>`).join('');
  const c = pb.cpu;
  $('pbCpu').textContent =
    `PIC18F4525 ${c.time.toFixed(1)} s   PC 0x${c.pc.toString(16).padStart(4, '0')}\n` +
    `WDT resets ${c.stats.wdtResets}   bad ops ${c.stats.badOps}   EEPROM writes ${c.stats.eeWrites}`;
}

function updateStub(pb) {
  const st = pb.manual ? pb.manual.state : pb.state;
  $('pbState').innerHTML = pb.manual
    ? `<b>manual frame</b> · state ${hex(st)} (${STATE_NAMES[st & 0x3f] || '?'})`
    : `<b>${pb.phase}</b> · state ${hex(pb.state)} ${STATE_NAMES[pb.state & 0x3f] || ''}<br>` +
      `p1 ${hex(pb.p1)} · p2 ${hex(pb.p2)} · progress ${pb.progress}% · drink ${DRINKS[pb.drink]} · taste ${pb.taste}`;
  const c = pb.settings;
  $('pbSettings').innerHTML = [
    ['language', c.language], ['clock', c.h24 ? '24 h' : '12 h'], ['beep', c.beep ? 'on' : 'off'],
    ['cup lighting', c.cupLight ? 'on' : 'off'], ['energy saving', c.energySaving ? 'on' : 'off'],
    ['water filter', c.filter ? 'installed' : 'none'], ['temperature', c.temperature], ['hardness', c.hardness],
  ].map(([k, v]) => `<div><span>${k}</span> ${v}</div>`).join('');
  $('pbStats').textContent = `frames ${pb.frames} (bad ${pb.badFrames}) · coffees ${pb.stats.coffee} · milk ${pb.stats.milk} · water ${pb.stats.water}`;
  document.querySelectorAll('[data-alarm]').forEach(el => { el.checked = !!pb.alarms[el.dataset.alarm]; });
}

function updateFrames(pb) {
  const h = a => (a && a.length) ? a.map(b => hex(b).slice(2)).join(' ') : '—';
  $('frameTx').textContent = h(pb.lastRx);
  $('frameRx').textContent = h(pb.lastTx);
  const d = pb.display;
  if (d) {
    const keys = [['1cup', 1], ['2cups', 2], ['hotwater', 4], ['menu', 8], ['onoff', 16], ['cappu', 64], ['rinse', 128]]
      .filter(([, m]) => d.keys & m).map(([n]) => n);
    if (d.push) keys.push('knob');
    $('frameDecode').textContent =
      `keys    ${keys.join(' ') || '—'} (${d.keyCount} held)\n` +
      `encoder ${d.enc}\n` +
      `clock   ${String(d.hour).padStart(2, '0')}:${String(d.min).padStart(2, '0')}:${String(d.sec).padStart(2, '0')} ${d.clockValid ? '(set)' : '(not set)'}\n` +
      `eeprom  cfg ${hex(d.cfg)}, ${d.languages} languages`;
  }
}

function updateCpu() {
  const cpu = board.cpu;
  const ratio = realAcc > 0 ? (emuAcc / realAcc) : 0;
  $('cpu').textContent =
    `time    ${cpu.time.toFixed(1)} s   (${(cpu.fosc / 1e6).toFixed(0)} MHz, ${cpu.cycles.toLocaleString()} cycles)\n` +
    `speed   ${ratio ? ratio.toFixed(1) + '× real time possible' : '—'}\n` +
    `PC      0x${cpu.pc.toString(16).padStart(4, '0')}   WDT resets ${cpu.stats.wdtResets}   bad ops ${cpu.stats.badOps}\n` +
    `LCD     ${board.lcd.displayOn ? 'on' : 'off'}, ${board.lcd.writes} writes   EEPROM writes ${board.eeprom.writesDone}\n` +
    (lastOut ? `pins    backlight ${(lastOut.backlight * 100).toFixed(0)}%  cup ${(lastOut.cup * 100).toFixed(0)}%  ` +
      `ESC ${(lastOut.esc * 100).toFixed(0)}%  OK ${(lastOut.ok * 100).toFixed(0)}%  (time driven low)` : '');
  emuAcc = realAcc = 0;
}

// ?demo=<name>: run a scripted sequence before the first frame (used for
// screenshots and quick checks)
const DEMOS = {
  standby: b => b.run(3.5),
  ready: b => { b.run(3.2); press(b, 'onoff'); b.run(10); },
  brew: b => { b.run(3.2); press(b, 'onoff'); b.run(10); b.turn(1); b.run(0.4); press(b, 'cup2'); b.run(4.8); },
  menu: b => { b.run(3.2); press(b, 'onoff'); b.run(10); press(b, 'menu'); b.run(0.4); press(b, 'hotwater'); b.run(0.6); },
  alarm: b => { b.run(3.2); press(b, 'onoff'); b.run(10); b.pb.alarms.beansEmpty = true; b.run(0.6); },
  cappu: b => { b.run(3.2); press(b, 'onoff'); b.run(10); press(b, 'cappu'); b.run(2.8); },
  // with ?pb=real: warm up on the real power board firmware, then brew
  warmup: b => { b.run(3.2); press(b, 'onoff'); b.run(45); },
  coffee: b => { b.run(3.2); press(b, 'onoff'); untilReady(b); press(b, 'cup1'); b.run(20); },
};
function untilReady(b) {
  for (let i = 0; i < 300 && !(b.pb.lastTx && b.pb.lastTx[1] === 7 && b.pb.lastTx[2] === 0); i++) b.run(0.5);
}
function press(b, k) { b.keys[k] = true; b.run(0.15); b.keys[k] = false; b.run(0.1); }

const demo = new URLSearchParams(location.search).get('demo');
if (demo && DEMOS[demo]) {
  // synchronous load so the whole sequence runs before the page's load event
  const sync = name => {
    const x = new XMLHttpRequest();
    x.open('GET', FILES + name, false);
    x.overrideMimeType('text/plain; charset=x-user-defined');
    x.send();
    return Uint8Array.from(x.responseText, c => c.charCodeAt(0) & 0xff);
  };
  fwBytes = sync(fwName);
  eeBytes = sync('display_board_5513220041_v30_eeprom.bin');
  if (pbMode === 'real') pbImage = sync(PB_FW);
  buildSidePanel();
  powerCycle();
  DEMOS[demo](board);
  board.outputs();
  board.run(0.1);
  render(performance.now());
  updatePanels();
  requestAnimationFrame(loop);
} else {
  init();
}
