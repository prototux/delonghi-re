// "Inside the machine": the water circuit, heaters, grinder and brew unit,
// with the power board's inputs and outputs, drawn from the machine model
// (core/plant.js). With the real power board firmware the loads are what its
// pins drive; with the stub they are simulated from the stub's phases.
//
// The hydraulic layout is a model (tank -> pump -> flowmeter, then either
// the coffee thermoblock and the brew unit, or the valves and the steam
// thermoblock to the side outlet), not a drawing of the real circuit.

import { CAPACITY } from '../core/plant.js';

const COLD = '#4aa3ff', HOT = '#ff9d4a', STEAM = '#d7dde5', COFFEE = '#8a5a34';

// pipes: id -> [path, which flow feeds it ('any' | 'brew' | 'steam'), color]
const PIPES = {
  pTank: ['M75 318 V336 H168', 'any', COLD],
  pPump: ['M212 336 H254', 'any', COLD],
  pMeter: ['M286 336 H330', 'any', COLD],
  pToA: ['M330 336 V214', 'brew', COLD],
  pAtoBU: ['M368 124 H560 V70 H585', 'brew', HOT],
  pBUout: ['M660 60 H760 V96', 'brew', COFFEE],
  pToEV: ['M330 336 H380', 'steam', COLD],
  pEVtoB: ['M420 336 H452', 'steam', COLD],
  pBout: ['M548 336 H760 V304', 'steam', HOT],
};

export class InsideView {
  constructor(root, { getPlant, onToggle }) {
    this.getPlant = getPlant;
    this.onToggle = onToggle;
    this.ang = { pump: 0, meter: 0, burr: 0 };
    this.vol = { any: 0, brew: 0, steam: 0 };
    this.lastWater = null; this.lastPulses = null; this.pulseFlash = 0;
    this.zc = 0;
    const pipes = Object.entries(PIPES).map(([id, [d]]) =>
      `<path d="${d}" class="pipe"/><path id="${id}" d="${d}" class="flow" stroke-dasharray="8 10"/>`).join('');
    root.innerHTML = `
      <svg class="inside" viewBox="0 0 1000 396" role="img" aria-label="Inside the machine">
        <defs>
          <clipPath id="ivTankClip"><rect x="22" y="72" width="106" height="244" rx="10"/></clipPath>
          <clipPath id="ivHopClip"><path d="M420 14 h96 l-24 58 h-48 z"/></clipPath>
          <clipPath id="ivChamberClip"><rect x="586" y="92" width="72" height="140"/></clipPath>
          <linearGradient id="ivBlock" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stop-color="#5d636b"/><stop offset="1" stop-color="#32363c"/></linearGradient>
        </defs>
        ${pipes}

        <!-- water tank -->
        <g id="ivTank" class="clickable">
          <rect x="20" y="70" width="110" height="248" rx="12" class="glass"/>
          <g clip-path="url(#ivTankClip)"><rect id="ivWater" x="20" y="70" width="110" height="248" fill="${COLD}" opacity=".35"/></g>
          <text x="75" y="62" class="lbl" text-anchor="middle">water tank</text>
          <text id="ivTankTxt" x="75" y="200" class="big" text-anchor="middle"></text>
        </g>

        <!-- pump -->
        <g transform="translate(190 336)">
          <circle r="22" class="part" id="ivPumpBody"/>
          <g id="ivPumpRot"><path d="M0 -15 L4 0 L-4 0Z M13 7.5 L-2 3.5 L2 -3.5Z M-13 7.5 L-2 -3.5 L2 3.5Z" fill="#cfd4da"/></g>
          <text y="42" class="lbl" text-anchor="middle">pump</text>
        </g>
        <!-- flowmeter -->
        <g transform="translate(270 336)">
          <circle r="16" class="part" id="ivMeterBody"/>
          <g id="ivMeterRot"><path d="M-11 0 H11 M0 -11 V11" stroke="#cfd4da" stroke-width="3"/></g>
          <circle id="ivPulse" cx="12" cy="-12" r="3.5" fill="#2a2d33"/>
          <text y="36" class="lbl" text-anchor="middle">flowmeter</text>
          <text id="ivPulses" y="50" class="small" text-anchor="middle"></text>
        </g>

        <!-- coffee thermoblock -->
        <g id="ivBlockA">
          <rect x="292" y="110" width="76" height="104" rx="8" fill="url(#ivBlock)" stroke="#6d737b"/>
          <path id="ivCoilA" d="M302 126 h56 l-56 14 h56 l-56 14 h56 l-56 14 h56 l-56 14 h56" fill="none" stroke-width="3"/>
          <text x="330" y="102" class="lbl" text-anchor="middle">coffee thermoblock</text>
          <text id="ivTempA" x="378" y="160" class="big"></text>
          <text id="ivCodeA" x="378" y="176" class="small"></text>
        </g>

        <!-- valves -->
        <g transform="translate(400 336)">
          <path id="ivEV" d="M-20 -12 L20 12 V-12 L-20 12Z" class="part"/>
          <text y="-20" class="lbl" text-anchor="middle">EV1 · EV2</text>
          <text id="ivEVtxt" y="30" class="small" text-anchor="middle"></text>
        </g>

        <!-- steam thermoblock -->
        <g>
          <rect x="452" y="298" width="96" height="76" rx="8" fill="url(#ivBlock)" stroke="#6d737b"/>
          <path id="ivCoilB" d="M462 312 h76 l-76 12 h76 l-76 12 h76 l-76 12 h76" fill="none" stroke-width="3"/>
          <text x="500" y="290" class="lbl" text-anchor="middle">steam thermoblock</text>
          <text id="ivTempB" x="556" y="330" class="big"></text>
          <text id="ivCodeB" x="556" y="346" class="small"></text>
        </g>

        <!-- beans hopper and grinder -->
        <g id="ivHopper" class="clickable">
          <path d="M420 14 h96 l-24 58 h-48 z" class="glass"/>
          <g clip-path="url(#ivHopClip)"><rect id="ivBeans" x="420" y="14" width="96" height="58" fill="#6b4226"/></g>
          <text x="468" y="10" class="lbl" text-anchor="middle">beans</text>
          <text id="ivBeansTxt" x="522" y="40" class="small"></text>
        </g>
        <g transform="translate(468 88)">
          <circle r="15" class="part" id="ivBurrBody"/>
          <g id="ivBurr"><path d="M0 -11 L3 -3 L11 0 L3 3 L0 11 L-3 3 L-11 0 L-3 -3Z" fill="#cfd4da"/></g>
          <text x="-22" y="4" class="lbl" text-anchor="end">grinder</text>
        </g>
        <path id="ivChute" d="M478 100 L586 128" stroke="#6b4226" stroke-width="4" stroke-dasharray="3 5" fill="none"/>

        <!-- brew unit -->
        <g>
          <rect x="584" y="48" width="76" height="186" rx="6" class="glass"/>
          <rect x="588" y="52" width="68" height="36" rx="4" fill="#4b5058"/>
          <text x="622" y="44" class="lbl" text-anchor="middle">brew unit</text>
          <g clip-path="url(#ivChamberClip)">
            <rect id="ivCake" x="586" y="200" width="72" height="0" fill="#4a2c16"/>
            <rect id="ivCoffeeIn" x="586" y="200" width="72" height="0" fill="${COFFEE}" opacity=".55"/>
          </g>
          <rect id="ivPiston" x="588" y="226" width="68" height="10" rx="3" fill="#b7bcc2"/>
          <rect id="ivRod" x="617" y="236" width="10" height="0" fill="#8d939b"/>
          <circle id="ivTopSw" cx="672" cy="96" r="5"/>
          <text x="680" y="100" class="small">top</text>
          <circle id="ivBotSw" cx="672" cy="228" r="5"/>
          <text x="680" y="232" class="small">bottom</text>
          <g transform="translate(700 168)">
            <circle r="14" class="part" id="ivMotor"/>
            <text id="ivMotorDir" y="5" text-anchor="middle" class="big">·</text>
            <text x="20" y="-2" class="small">motor</text>
            <text id="ivPos" x="20" y="12" class="small"></text>
          </g>
        </g>

        <!-- grounds container -->
        <g id="ivGrounds" class="clickable">
          <rect x="580" y="252" width="84" height="40" rx="4" class="glass" id="ivGroundsBox"/>
          <g id="ivPucks"></g>
          <text x="622" y="306" class="lbl" text-anchor="middle">grounds</text>
          <text id="ivGroundsTxt" x="668" y="276" class="small"></text>
        </g>

        <!-- outlets -->
        <text x="760" y="30" class="lbl" text-anchor="middle">coffee spout</text>
        <text id="ivOutTxt" x="760" y="114" class="small" text-anchor="middle"></text>
        <text x="760" y="292" class="lbl" text-anchor="middle">side outlet</text>
        <text id="ivSideTxt" x="760" y="370" class="small" text-anchor="middle"></text>

        <!-- power board I/O -->
        <g transform="translate(816 6)">
          <rect x="0" y="0" width="182" height="384" rx="10" fill="#15171b" stroke="#2c2f35"/>
          <text x="12" y="20" class="lbl">power board I/O</text>
          <text id="ivMode" x="12" y="34" class="small"></text>
          <g id="ivIo" transform="translate(12 50)"></g>
        </g>
      </svg>`;
    const q = id => root.querySelector('#' + id);
    this.el = {};
    root.querySelectorAll('[id]').forEach(n => { this.el[n.id] = n; });
    q('ivTank').addEventListener('click', () => this.onToggle('tank'));
    q('ivHopper').addEventListener('click', () => this.onToggle('beans'));
    q('ivGrounds').addEventListener('click', () => this.onToggle('grounds'));
    this.io = [
      ['out', 'RB3', 'main relay', a => a.relay],
      ['out', 'RD1', 'coffee heater', a => a.heatA],
      ['out', 'RD7', 'steam heater', a => a.heatB],
      ['out', 'RD4', 'pump', a => a.pump],
      ['out', 'RD2', 'grinder', a => a.grinder],
      ['out', 'RB2', 'brew unit up', a => a.up],
      ['out', 'RB5', 'brew unit down', a => a.down],
      ['out', 'RD6', 'motor full power', a => a.fullPower],
      ['out', 'RD5', 'EV1', a => a.ev1],
      ['out', 'RD3', 'EV2', a => a.ev2],
      ['in', 'RC2', 'mains zero-cross', (a, p) => p.pins.rc2],
      ['in', 'RA6', 'flowmeter', (a, p) => p.pins.ra6],
      ['in', 'RC1', 'motor encoder', (a, p) => p.pins.rc1],
      ['in', 'RA7', 'top switch', (a, p) => p.topSwitch()],
      ['in', 'RE1', 'bottom switch', (a, p) => p.bottomSwitch()],
      ['in', 'RB1', 'water tank', (a, p) => p.env.tankPresent],
      ['in', 'RB4', 'water level', (a, p) => p.hasWater()],
      ['in', 'RB0', 'grounds container', (a, p) => p.env.groundsPresent],
      ['in', 'RE0', 'hot water spout', (a, p) => p.env.accessory === 'spout'],
      ['in', 'RA5', 'milk carafe', (a, p) => p.env.accessory === 'carafe'],
    ];
    this.el.ivIo.innerHTML = this.io.map(([dir, pin, name], i) => {
      const y = i * 14.6 + (dir === 'in' ? 8 : 0);
      return `<circle id="io${i}" cx="5" cy="${y}" r="4.5"/><text x="16" y="${y + 4}" class="io"><tspan class="pin">${pin}</tspan> ${name}</text>`;
    }).join('') +
      `<text x="0" y="${this.io.length * 14.6 + 14}" class="io" id="ivAdc"></text>`;
    this.el.ivIo.querySelectorAll('[id]').forEach(n => { this.el[n.id] = n; });
  }

  // mode: 'real' | 'stub'; dt: emulated seconds since the last call; pb: power board
  update(mode, dt, pb) {
    const p = this.getPlant();
    if (!p) return;
    const a = p.act || {}, el = this.el;

    // flow bookkeeping, in emulated time
    if (this.lastWater === null) this.lastWater = p.water;
    const dv = Math.max(0, p.water - this.lastWater);
    this.lastWater = p.water;
    this.vol.any += dv;
    if (p.path) this.vol[p.path] += dv;
    for (const [id, [, feed, color]] of Object.entries(PIPES)) {
      const on = feed === 'any' ? !!p.path : p.path === feed;
      const f = el[id];
      f.style.display = on ? '' : 'none';
      if (!on) continue;
      let c = color;
      if (feed === 'steam' && color === HOT && p.tB > 100) c = STEAM;
      if (id === 'pBUout' && p.outlet.kind !== 'coffee') c = HOT;
      f.setAttribute('stroke', c);
      f.setAttribute('stroke-dashoffset', (-this.vol[feed] * 8).toFixed(1));
    }

    // tank
    const lvl = p.env.tankPresent ? p.tankMl / CAPACITY.tank : 0;
    const wh = 244 * (p.env.waterInTank ? lvl : 0);
    el.ivWater.setAttribute('y', (316 - wh).toFixed(1));
    el.ivWater.setAttribute('height', wh.toFixed(1));
    el.ivTank.style.opacity = p.env.tankPresent ? 1 : 0.3;
    el.ivTankTxt.textContent = !p.env.tankPresent ? 'removed' : p.hasWater() ? `${(p.tankMl / 1000).toFixed(2)} L` : 'empty';

    // pump, flowmeter
    this.ang.pump += (a.pump ? 720 : 0) * dt;
    this.ang.meter += p.flow * 180 * dt;
    el.ivPumpRot.setAttribute('transform', `rotate(${(this.ang.pump % 360).toFixed(1)})`);
    el.ivPumpBody.classList.toggle('on', !!a.pump);
    el.ivMeterRot.setAttribute('transform', `rotate(${(this.ang.meter % 360).toFixed(1)})`);
    if (this.lastPulses !== null && p.flowPulses !== this.lastPulses) this.pulseFlash = 0.08;
    this.lastPulses = p.flowPulses;
    this.pulseFlash = Math.max(0, this.pulseFlash - dt);
    el.ivPulse.setAttribute('fill', this.pulseFlash > 0 ? '#7bd88f' : '#2a2d33');
    el.ivPulses.textContent = `${p.flowPulses} pulses · ${p.flow.toFixed(1)} ml/s`;

    // heaters
    const heat = (coil, on, t) => {
      const k = Math.max(0, Math.min(1, (t - 25) / 110));
      coil.setAttribute('stroke', on ? '#ff5a2a' : `rgb(${Math.round(90 + 120 * k)},${Math.round(95 - 40 * k)},${Math.round(105 - 70 * k)})`);
      coil.style.filter = on ? 'drop-shadow(0 0 4px #ff6a2a)' : '';
    };
    heat(el.ivCoilA, a.heatA, p.tA);
    heat(el.ivCoilB, a.heatB, p.tB);
    el.ivTempA.textContent = `${p.tA.toFixed(0)} °C`;
    el.ivTempB.textContent = `${p.tB.toFixed(0)} °C`;
    const code = ch => Math.max(0, Math.min(255, 255 - Math.floor(p.adc(ch) / 4)));
    el.ivCodeA.textContent = `NTC 0x${code(1).toString(16)}`;
    el.ivCodeB.textContent = `NTC 0x${code(0).toString(16)}`;

    // valves
    el.ivEV.classList.toggle('on', !!(a.ev1 || a.ev2));
    el.ivEVtxt.textContent = `${a.ev1 ? 'open' : 'closed'} · ${a.ev2 ? 'open' : 'closed'}`;

    // beans, grinder
    const bh = 58 * (p.env.beans ? p.beansG / CAPACITY.beans : 0);
    el.ivBeans.setAttribute('y', (72 - bh).toFixed(1));
    el.ivBeans.setAttribute('height', bh.toFixed(1));
    el.ivBeansTxt.textContent = p.hasBeans() ? `${Math.round(p.beansG)} g` : 'empty';
    this.ang.burr += (a.grinder ? 900 : 0) * dt;
    el.ivBurr.setAttribute('transform', `rotate(${(this.ang.burr % 360).toFixed(1)})`);
    el.ivBurrBody.classList.toggle('on', !!a.grinder);
    el.ivChute.style.display = a.grinder && p.hasBeans() ? '' : 'none';
    el.ivChute.setAttribute('stroke-dashoffset', (-this.ang.burr / 20).toFixed(1));

    // brew unit: piston 0 (bottom, y 226) .. TOP (y 92)
    const py = 226 - 134 * p.pos / p.TOP;
    el.ivPiston.setAttribute('y', py.toFixed(1));
    el.ivRod.setAttribute('y', (py + 10).toFixed(1));
    el.ivRod.setAttribute('height', Math.max(0, 236 - py - 10).toFixed(1));
    const cakeH = Math.min(40, p.cake * 7);
    el.ivCake.setAttribute('y', (py - cakeH).toFixed(1));
    el.ivCake.setAttribute('height', cakeH.toFixed(1));
    const brewing = p.outlet.where === 'coffee' && p.outlet.kind === 'coffee';
    el.ivCoffeeIn.setAttribute('y', (py - cakeH - 6).toFixed(1));
    el.ivCoffeeIn.setAttribute('height', brewing ? '6' : '0');
    el.ivTopSw.setAttribute('class', p.topSwitch() ? 'led on' : 'led');
    el.ivBotSw.setAttribute('class', p.bottomSwitch() ? 'led on' : 'led');
    el.ivMotor.classList.toggle('on', !!(a.up || a.down));
    el.ivMotorDir.textContent = a.up ? '↑' : a.down ? '↓' : '·';
    const buPos = pb && pb.cpu ? pb.ram(0x6d) | (pb.ram(0x6e) << 8) : null;
    el.ivPos.textContent = buPos !== null ? `bu_pos ${buPos} (0x${buPos.toString(16)})` : `${Math.round(p.pos)} / ${p.TOP}`;

    // grounds container
    el.ivGrounds.style.opacity = p.env.groundsPresent ? 1 : 0.3;
    const n = Math.min(p.grounds, CAPACITY.pucks);
    el.ivPucks.innerHTML = Array.from({ length: n }, (_, i) =>
      `<ellipse cx="${592 + (i % 5) * 15}" cy="${286 - Math.floor(i / 5) * 9}" rx="7" ry="4" fill="#4a2c16" stroke="#2c1a0c"/>`).join('');
    el.ivGroundsTxt.textContent = p.env.groundsPresent ? `${p.grounds} puck${p.grounds === 1 ? '' : 's'}` : 'removed';

    // outlets
    const acc = { spout: 'hot water spout', carafe: 'milk carafe', none: 'nothing fitted' }[p.env.accessory];
    el.ivSideTxt.textContent = acc;
    const o = p.outlet;
    el.ivOutTxt.textContent = o.where === 'coffee' ? `${o.kind} ${o.rate.toFixed(1)} ml/s` : o.where === 'tray' ? 'into the drip tray' : '';

    // I/O panel
    el.ivMode.textContent = mode === 'real' ? 'PIC18F4525 firmware' : 'stub (simulated)';
    this.io.forEach(([dir, , , f], i) => {
      const on = !!f(a, p);
      el['io' + i].setAttribute('class', `led ${dir} ${on ? 'on' : ''}`);
    });
    el.ivAdc.textContent = `AN1 0x${code(1).toString(16)} · AN0 0x${code(0).toString(16)}`;
  }
}
