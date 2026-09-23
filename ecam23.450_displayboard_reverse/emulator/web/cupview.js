// "Under the spout": what the user sees below the control panel. The coffee
// spout with its cup lights, the side outlet (hot water spout, milk carafe or
// nothing), a cup on the drip tray that fills with what the machine pours,
// and the drip tray.
//
// Everything comes from the machine model (core/plant.js): the outlet (what
// flows where), and the poured totals, which are integrated in emulated time,
// so the cup fills the same at any emulator speed.

import { CAPACITY } from '../core/plant.js';

const CUP_ML = 240;
const COLORS = { coffee: '#5b3217', crema: '#b5793f', water: '#9cc9ef', hotwater: '#9cc9ef', milk: '#f4eee2' };

// cup geometry (inner), in scene units
const CUP = { x: 188, w: 84, top: 132, bottom: 222 };
const NOZZLES = [217, 243], NOZZLE_Y = 76;
const SIDE = { spout: [200, 118], carafe: [201, 112], none: [70, 40] };

export class CupView {
  constructor(root, { getPlant, onAccessory }) {
    this.getPlant = getPlant;
    this.onAccessory = onAccessory;
    this.cup = { present: true, coffee: 0, water: 0, milk: 0, hotwater: 0, last: null };
    this.served = [];
    this.lastPoured = { coffee: 0, water: 0, milk: 0, hotwater: 0 };   // totals already accounted for
    this.t = 0;
    root.innerHTML = `
      <svg class="cupscene" viewBox="0 0 460 250" role="img" aria-label="Under the spout">
        <defs>
          <linearGradient id="cvBody" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stop-color="#0c0d0f"/><stop offset="1" stop-color="#1b1d21"/></linearGradient>
          <linearGradient id="cvChrome" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stop-color="#8e949b"/><stop offset=".45" stop-color="#e4e7ea"/><stop offset="1" stop-color="#6f757c"/></linearGradient>
          <linearGradient id="cvGlass" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0" stop-color="rgba(255,255,255,.18)"/><stop offset=".25" stop-color="rgba(255,255,255,.05)"/>
            <stop offset=".8" stop-color="rgba(255,255,255,.03)"/><stop offset="1" stop-color="rgba(255,255,255,.16)"/></linearGradient>
          <radialGradient id="cvLight" cx=".5" cy="0" r="1">
            <stop offset="0" stop-color="rgba(170,200,255,.55)"/><stop offset="1" stop-color="rgba(170,200,255,0)"/></radialGradient>
          <clipPath id="cvCupClip"><path d="M${CUP.x} ${CUP.top} h${CUP.w} l-6 ${CUP.bottom - CUP.top - 10} q-2 10 -12 10 h${-(CUP.w - 36)} q-10 0 -12 -10 z"/></clipPath>
          <clipPath id="cvJugClip"><path d="M24 92 h92 l-6 118 q-1 8 -9 8 h-62 q-8 0 -9 -8 z"/></clipPath>
        </defs>
        <rect x="0" y="0" width="460" height="250" rx="0" fill="url(#cvBody)"/>
        <path d="M0 0 h460 v6 q-230 10 -460 0z" fill="#050506"/>

        <!-- light cone of the cup lights -->
        <path id="cvCone" d="M200 70 L150 228 H310 L260 70 Z" fill="url(#cvLight)" opacity="0"/>

        <!-- coffee spout unit -->
        <rect x="184" y="0" width="92" height="66" rx="10" fill="#141518" stroke="#2c2f35"/>
        <rect x="192" y="10" width="76" height="6" rx="3" fill="#24272c"/>
        ${NOZZLES.map(x => `<rect x="${x - 6}" y="62" width="12" height="14" rx="3" fill="url(#cvChrome)"/>`).join('')}
        <rect id="cvLedL" x="195" y="66" width="10" height="3" rx="1.5" fill="#2a2d33"/>
        <rect id="cvLedR" x="255" y="66" width="10" height="3" rx="1.5" fill="#2a2d33"/>
        <text id="cvBuzz" x="444" y="20" font-size="15" text-anchor="middle" fill="#3a3f47">♪</text>

        <!-- side outlet: connector + the three accessories -->
        <rect x="52" y="0" width="36" height="18" rx="4" fill="#141518" stroke="#2c2f35"/>
        <g id="cvSpout">
          <path d="M70 16 V70 Q70 104 104 108 H192 q8 0 8 8 v2" fill="none" stroke="url(#cvChrome)" stroke-width="9" stroke-linecap="round"/>
          <circle cx="70" cy="22" r="7" fill="#1f2226" stroke="#555b63"/>
        </g>
        <g id="cvCarafe">
          <path d="M70 16 V40 Q70 50 80 52 H100" fill="none" stroke="#c9cdd2" stroke-width="5"/>
          <path d="M24 92 h92 l-6 118 q-1 8 -9 8 h-62 q-8 0 -9 -8 z" fill="rgba(255,255,255,.06)" stroke="rgba(230,235,240,.55)" stroke-width="1.5"/>
          <g clip-path="url(#cvJugClip)"><rect id="cvMilkJug" x="20" y="120" width="110" height="110" fill="${COLORS.milk}" opacity=".92"/></g>
          <rect x="18" y="74" width="104" height="20" rx="6" fill="#d9dce0" stroke="#9aa0a7"/>
          <path d="M116 84 H176 q12 0 16 14 l6 14" fill="none" stroke="#d9dce0" stroke-width="6" stroke-linecap="round"/>
          <text x="70" y="160" text-anchor="middle" font-size="10" fill="#7d6f58" id="cvMilkTxt">500 ml</text>
          <circle cx="104" cy="84" r="5" fill="#9aa0a7"/>
        </g>

        <!-- streams -->
        <g id="cvStreams" stroke-linecap="round" fill="none">
          ${NOZZLES.map((x, i) => `<line id="cvS${i}" x1="${x}" y1="${NOZZLE_Y}" x2="${x}" y2="200" stroke-width="3" stroke-dasharray="7 5"/>`).join('')}
          <line id="cvSide" x1="200" y1="118" x2="200" y2="200" stroke-width="3" stroke-dasharray="7 5"/>
        </g>
        <g id="cvSteam" fill="rgba(235,240,245,.5)"></g>

        <!-- drip tray -->
        <rect x="30" y="224" width="400" height="26" rx="4" fill="#23262b"/>
        <rect id="cvTray" x="34" y="248" width="392" height="0" fill="#6b8fb0" opacity=".55"/>
        <g stroke="#34383f" stroke-width="3">
          ${Array.from({ length: 24 }, (_, i) => `<line x1="${44 + i * 16}" y1="226" x2="${44 + i * 16}" y2="236"/>`).join('')}
        </g>
        <rect x="30" y="236" width="400" height="14" rx="3" fill="#191b1f"/>
        <text id="cvTrayTxt" x="420" y="246" text-anchor="end" font-size="9" fill="#6d737d"></text>

        <!-- cup -->
        <g id="cvCup" style="cursor:pointer">
          <g clip-path="url(#cvCupClip)">
            <rect id="cvBodyLiq" x="${CUP.x - 4}" y="${CUP.bottom}" width="${CUP.w + 8}" height="0"/>
            <rect id="cvCrema" x="${CUP.x - 4}" y="${CUP.bottom}" width="${CUP.w + 8}" height="0" fill="${COLORS.crema}"/>
            <rect id="cvFoam" x="${CUP.x - 4}" y="${CUP.bottom}" width="${CUP.w + 8}" height="0" fill="${COLORS.milk}"/>
          </g>
          <path d="M${CUP.x} ${CUP.top} h${CUP.w} l-6 ${CUP.bottom - CUP.top - 10} q-2 10 -12 10 h${-(CUP.w - 36)} q-10 0 -12 -10 z"
            fill="url(#cvGlass)" stroke="rgba(235,240,245,.7)" stroke-width="1.6"/>
          <path d="M${CUP.x + CUP.w - 3} ${CUP.top + 18} q26 2 22 30 q-3 22 -26 22" fill="none" stroke="rgba(235,240,245,.6)" stroke-width="5"/>
          <text id="cvCupTxt" x="${CUP.x + CUP.w / 2}" y="${CUP.top - 6}" text-anchor="middle" font-size="10" fill="#9aa1ab"></text>
        </g>
        <text id="cvNoCup" x="${CUP.x + CUP.w / 2}" y="210" text-anchor="middle" font-size="11" fill="#6d737d">no cup · click to place one</text>
      </svg>
      <div class="cupbar">
        <div class="seg" id="cvAcc">
          <button data-acc="spout">Hot water spout</button><button data-acc="carafe">Milk carafe</button><button data-acc="none">Nothing</button>
        </div>
        <button id="cvServe" title="Take the cup away and put an empty one">Serve · new cup</button>
        <button id="cvRemove" title="No cup: what comes out goes into the drip tray">Remove cup</button>
        <button id="cvTrayBtn">Empty tray</button>
        <button id="cvMilkBtn">Refill milk</button>
      </div>
      <div class="served" id="cvServed"></div>`;
    const $ = id => root.querySelector('#' + id);
    this.el = {};
    for (const id of ['cvCone', 'cvLedL', 'cvLedR', 'cvBuzz', 'cvSpout', 'cvCarafe', 'cvMilkJug', 'cvMilkTxt', 'cvS0', 'cvS1',
      'cvSide', 'cvSteam', 'cvTray', 'cvTrayTxt', 'cvCup', 'cvBodyLiq', 'cvCrema', 'cvFoam', 'cvCupTxt', 'cvNoCup', 'cvServed'])
      this.el[id] = $(id);
    this.el.cvCup.addEventListener('click', () => this.serve());
    this.el.cvNoCup.addEventListener('click', () => this.serve());
    $('cvServe').onclick = () => this.serve();
    $('cvRemove').onclick = () => { this.serve(); this.cup.present = false; };
    $('cvTrayBtn').onclick = () => { const p = this.getPlant(); if (p) p.trayMl = 0; };
    $('cvMilkBtn').onclick = () => { const p = this.getPlant(); if (p) p.milkMl = CAPACITY.milk; };
    root.querySelectorAll('[data-acc]').forEach(b => { b.onclick = () => this.onAccessory(b.dataset.acc); });
    this.accButtons = root.querySelectorAll('[data-acc]');
    this.steamPuffs = [];
  }

  cupMl() { const c = this.cup; return c.coffee + c.water + c.milk + c.hotwater; }

  // pour what the machine delivered since the last call into the cup (the
  // model keeps totals, so nothing is lost between frames or during demos)
  absorb(plant) {
    const p = plant.poured, c = this.cup;
    for (const k of Object.keys(p)) {
      let d = p[k] - this.lastPoured[k];
      this.lastPoured[k] = p[k];
      if (d <= 0) continue;
      if (c.present) {
        const into = Math.min(d, Math.max(0, CUP_ML - this.cupMl()));
        c[k] += into; c.last = k;
        d -= into;
      }
      plant.trayMl = Math.min(CAPACITY.tray, plant.trayMl + d);            // missed the cup / overflow
    }
  }

  // take the cup away (if it has something, it goes to the "served" list)
  // and put an empty one
  serve() {
    const plant = this.getPlant();
    if (plant) this.absorb(plant);
    const c = this.cup, ml = this.cupMl();
    if (c.present && ml >= 1) {
      this.served.unshift({ name: drinkName(c), ml: Math.round(ml), color: liquidColor(c) });
      this.served.length = Math.min(this.served.length, 6);
      this.renderServed();
    }
    this.cup = { present: true, coffee: 0, water: 0, milk: 0, hotwater: 0, last: null };
  }

  renderServed() {
    this.el.cvServed.innerHTML = this.served.length
      ? 'Served: ' + this.served.map(s => `<span><i style="background:${s.color}"></i>${s.name} ${s.ml} ml</span>`).join('')
      : '';
  }

  // called when the machine leaves "ready" to start something new: a full
  // cup is served automatically, so each drink gets its own cup
  newDrink() { if (this.cupMl() >= 1) this.serve(); }

  // outputs: board outputs (cup light, buzzer); dt: emulated seconds since the last call
  update(outputs, dt) {
    const plant = this.getPlant();
    const el = this.el;
    this.t += dt;

    // cup lights and buzzer
    const i = outputs ? Math.min(1, outputs.cup) : 0;
    for (const led of [el.cvLedL, el.cvLedR]) {
      led.setAttribute('fill', i > 0.05 ? `rgba(215,232,255,${0.3 + 0.7 * i})` : '#2a2d33');
      led.style.filter = i > 0.05 ? `drop-shadow(0 0 ${6 * i}px rgba(140,180,255,.9))` : '';
    }
    el.cvCone.setAttribute('opacity', (0.8 * i).toFixed(2));
    el.cvBuzz.setAttribute('fill', outputs && outputs.buzzer > 0.01 ? '#e0a458' : '#3a3f47');

    if (!plant) return;
    const acc = plant.env.accessory;
    el.cvSpout.style.display = acc === 'spout' ? '' : 'none';
    el.cvCarafe.style.display = acc === 'carafe' ? '' : 'none';
    this.accButtons.forEach(b => b.classList.toggle('on', b.dataset.acc === acc));
    const milkH = 96 * plant.milkMl / CAPACITY.milk;
    el.cvMilkJug.setAttribute('y', (218 - milkH).toFixed(1));
    el.cvMilkTxt.textContent = `${Math.round(plant.milkMl)} ml`;

    this.absorb(plant);
    const c = this.cup;

    // streams
    const o = plant.outlet;
    const surface = c.present ? CUP.bottom - (CUP.bottom - CUP.top - 4) * Math.min(1, this.cupMl() / CUP_ML) : 228;
    const dash = (-this.t * 60).toFixed(1);
    const stream = (line, on, color, x, y, w) => {
      line.style.display = on ? '' : 'none';
      if (!on) return;
      line.setAttribute('stroke', color);
      line.setAttribute('x1', x); line.setAttribute('x2', x);
      line.setAttribute('y1', y); line.setAttribute('y2', surface.toFixed(1));
      line.setAttribute('stroke-width', w);
      line.setAttribute('stroke-dashoffset', dash);
    };
    const fromSpout = o.where === 'coffee' && o.rate > 0;
    const width = r => Math.max(1.5, Math.min(5, 1 + r)).toFixed(1);
    NOZZLES.forEach((x, n) => stream(el[`cvS${n}`], fromSpout, COLORS[o.kind] || COLORS.water, x, NOZZLE_Y, width(o.rate / 2)));
    const sidePt = SIDE[acc];
    const fromSide = o.where === 'side' && o.kind && o.kind !== 'steam' && o.rate > 0;
    stream(el.cvSide, fromSide, COLORS[o.kind] || COLORS.water, sidePt[0], sidePt[1], width(o.rate / 2));

    // steam puffs at the side outlet (steam, or milk being frothed)
    const steaming = o.where === 'side' && (o.kind === 'steam' || o.kind === 'milk');
    if (steaming && Math.random() < 0.5) this.steamPuffs.push({ x: sidePt[0] + (Math.random() - 0.5) * 10, y: sidePt[1], age: 0 });
    this.steamPuffs = this.steamPuffs.filter(s => (s.age += dt) < 1.6);
    el.cvSteam.innerHTML = this.steamPuffs.map(s =>
      `<circle cx="${(s.x + Math.sin(s.age * 5 + s.x) * 6).toFixed(1)}" cy="${(s.y - s.age * 40).toFixed(1)}" r="${(4 + s.age * 8).toFixed(1)}" opacity="${(0.6 * (1 - s.age / 1.6)).toFixed(2)}"/>`).join('');

    // cup
    el.cvCup.style.display = c.present ? '' : 'none';
    el.cvNoCup.style.display = c.present ? 'none' : '';
    const hOf = ml => (CUP.bottom - CUP.top) * ml / CUP_ML;
    const bodyMl = c.coffee + c.water + c.hotwater;
    const bodyH = hOf(bodyMl), foamH = hOf(c.milk);
    const cremaH = c.coffee > 3 && c.last === 'coffee' ? Math.min(4, bodyH * 0.12) : 0;
    el.cvBodyLiq.setAttribute('y', (CUP.bottom - bodyH).toFixed(1));
    el.cvBodyLiq.setAttribute('height', bodyH.toFixed(1));
    el.cvBodyLiq.setAttribute('fill', bodyColor(c));
    el.cvCrema.setAttribute('y', (CUP.bottom - bodyH).toFixed(1));
    el.cvCrema.setAttribute('height', cremaH.toFixed(1));
    el.cvFoam.setAttribute('y', (CUP.bottom - bodyH - foamH).toFixed(1));
    el.cvFoam.setAttribute('height', foamH.toFixed(1));
    el.cvCupTxt.textContent = this.cupMl() >= 1 ? `${drinkName(c)} · ${Math.round(this.cupMl())} ml` : '';

    // drip tray
    const trayH = 12 * plant.trayMl / CAPACITY.tray;
    el.cvTray.setAttribute('y', (248 - trayH).toFixed(1));
    el.cvTray.setAttribute('height', trayH.toFixed(1));
    el.cvTrayTxt.textContent = plant.trayMl >= 1 ? `tray ${Math.round(plant.trayMl)} ml` : '';
  }
}

function bodyColor(c) {
  const body = c.coffee + c.water + c.hotwater;
  if (body <= 0) return COLORS.water;
  const k = Math.min(1, c.coffee / body * 1.6);                  // coffee darkens even when diluted
  const mix = (a, b) => Math.round(a + (b - a) * k);
  return `rgb(${mix(156, 91)},${mix(201, 50)},${mix(239, 23)})`;
}

function liquidColor(c) {
  if (c.milk > c.coffee + c.water + c.hotwater) return COLORS.milk;
  return bodyColor(c);
}

function drinkName(c) {
  const coffee = c.coffee >= 2, milk = c.milk >= 2, water = c.water + c.hotwater >= 2;
  if (coffee && milk) return 'cappuccino';
  if (coffee) return c.coffee < 50 ? 'espresso' : c.coffee < 130 ? 'coffee' : 'long coffee';
  if (milk) return 'frothed milk';
  if (c.hotwater >= 2) return 'hot water';
  if (water) return 'rinse water';
  return '';
}
