import { defaultConfig, makePreset, materials } from './presets.js';
import { evaluate, simulate, runMonteCarlo, inferAxisInertia, rotation, add, mul, IN } from './physics.js';

const $ = id => document.getElementById(id);
const SVG = 'http://www.w3.org/2000/svg';
const titles = { compound: 'Rigid compound swing', bifilar: 'Bifilar twist', fourbar: 'Parallel-chain translation', twolink: 'Chain + free plate hinge' };
const clone = value => structuredClone(value);
let config;
try { config = JSON.parse(localStorage.getItem('chainPlateConfig')) || defaultConfig(); } catch { config = defaultConfig(); }
if (!Array.isArray(config.plates) || !config.plates.length || !config.suspension || !config.monteCarlo) config = defaultConfig();
let selectedId = config.plates[0].id, result = null, trace = [], mcResult = null, playing = false, startTime = 0, elapsedBefore = 0;

function selected() { return config.plates.find(p => p.id === selectedId) || config.plates[0]; }
function n(value, digits = 3) { return Number.isFinite(value) ? Number(value).toFixed(digits) : '—'; }
function siInertia(value) { return n(value * IN ** 2, 5); }
function save() { try { localStorage.setItem('chainPlateConfig', JSON.stringify(config)); } catch {} }
function vectorText(v) { return v.map(x => n(x, 3)).join(', '); }
function parseVector(value, label) {
  const parts = value.split(/[\s,;]+/).filter(Boolean).map(Number);
  if (parts.length !== 3 || parts.some(x => !Number.isFinite(x))) throw Error(`${label} needs three comma-separated numbers.`);
  if (Math.hypot(...parts) < 1e-9) throw Error(`${label} cannot be zero.`);
  return parts;
}
function textLines(points) { return points.map(p => p.map(v => Number(v.toFixed(6))).join(', ')).join('\n'); }
function parseLines(text, columns, name) {
  if (!text.trim()) return [];
  return text.trim().split(/\r?\n/).map((line, i) => {
    const p = line.split(/[\s,;]+/).filter(Boolean).map(Number);
    if (p.length !== columns || p.some(v => !Number.isFinite(v))) throw Error(`${name} line ${i + 1} needs ${columns} numeric values.`);
    return p;
  });
}
function plateColor(p) { return p.material === 'hdpe' ? '#b6d8d4' : p.material === 'stainless' ? '#9aa9b8' : '#87c6d8'; }
function setVisible(id, visible) { $(id).classList.toggle('hidden', !visible); }

function syncPlateControls() {
  const p = selected();
  for (const input of document.querySelectorAll('[data-kind="plate"]')) input.value = p[input.dataset.key] ?? '';
  for (const input of document.querySelectorAll('[data-kind="pose"]')) input.value = p.pose[input.dataset.key] ?? 0;
  $('outerEditor').value = textLines(p.outer);
  $('voidEditor').value = p.voids.map(textLines).join('\n\n');
  $('holeEditor').value = textLines(p.holes);
  $('plateSource').textContent = p.source ? `Source: ${p.source}` : 'Custom plate geometry';
  $('plateCount').textContent = `${config.plates.length} ${config.plates.length === 1 ? 'plate' : 'plates'}`;
  $('removePlate').disabled = config.plates.length === 1;
  renderPlateList();
}
function syncGeneralControls() {
  for (const input of document.querySelectorAll('[data-kind="suspension"], [data-kind="monteCarlo"]')) {
    const source = config[input.dataset.kind]; input.value = source[input.dataset.key] ?? '';
  }
  $('gravityInput').value = vectorText(config.gravity);
  $('axisInput').value = vectorText(config.suspension.axis);
  syncModeControls();
}
function renderPlateList() {
  const list = $('plateList'); list.replaceChildren();
  for (const p of config.plates) {
    const button = document.createElement('button'); button.type = 'button'; button.className = 'plate-row';
    button.setAttribute('role', 'listitem'); button.setAttribute('aria-current', String(p.id === selectedId));
    const left = document.createElement('span'); left.textContent = p.name;
    const actualMass = result?.body.parts.find(part => part.plate.id === p.id)?.local.massKg ?? p.massKg;
    const small = document.createElement('small'); small.textContent = `${materials[p.material]?.label || p.material} · ${n(actualMass, 3)} kg`;
    left.append(small); const dot = document.createElement('span'); dot.className = 'dot';
    button.append(left, dot); button.addEventListener('click', () => { selectedId = p.id; syncPlateControls(); }); list.append(button);
  }
}
function syncHoleOptions() {
  let holes = result?.body.holes || [];
  if (!holes.length) holes = config.plates.flatMap(p => p.holes.map((_, i) => ({ label: `${p.name} · H${i + 1}`, plateId: p.id, holeIndex: i })));
  const s = config.suspension, attachment = $('attachmentSelect');
  attachment.replaceChildren();
  holes.forEach((h, i) => {
    const option = document.createElement('option'); option.value = String(i); option.textContent = h.label;
    if (h.plateId === s.attachment?.plateId && h.holeIndex === Number(s.attachment?.holeIndex)) option.selected = true;
    attachment.append(option);
  });
  for (const [id, key] of [['firstHoleSelect', 'firstHole'], ['secondHoleSelect', 'secondHole']]) {
    const el = $(id); el.replaceChildren();
    holes.forEach((h, i) => { const option = document.createElement('option'); option.value = String(i); option.textContent = h.label; el.append(option); });
    el.value = String(Math.min(Math.max(0, Number(s[key])), holes.length - 1));
  }
}
function syncModeControls() {
  const s = config.suspension, bifilar = s.mode === 'bifilar';
  for (const id of ['topSpacingField', 'bottomModeField']) setVisible(id, bifilar);
  setVisible('bottomSpacingField', bifilar && s.bottomSpacingMode === 'manual');
  for (const id of ['firstHoleField', 'secondHoleField']) setVisible(id, bifilar && s.bottomSpacingMode === 'holes');
  setVisible('secondAngleField', s.mode === 'twolink');
  setVisible('axisField', !bifilar && s.mode !== 'fourbar');
  setVisible('attachmentField', s.mode === 'compound' || s.mode === 'twolink');
  $('modelBadge').textContent = titles[s.mode] || s.mode;
}

function metric(label, value, sub) {
  const card = document.createElement('div'); card.className = 'metric';
  for (const [tag, cls, text] of [['span', 'metric-label', label], ['strong', 'metric-value', value], ['small', 'metric-sub', sub]]) {
    const child = document.createElement(tag); child.className = cls; child.textContent = text; card.append(child);
  }
  return card;
}
function tableRow(table, label, value) {
  const tr = document.createElement('tr'), a = document.createElement('td'), b = document.createElement('td');
  a.textContent = label; b.textContent = value; tr.append(a, b); table.append(tr);
}
function renderResults() {
  const r = result, s = config.suspension;
  const metrics = $('metrics'); metrics.replaceChildren();
  metrics.append(
    metric('Total plate mass', `${n(r.body.massKg, 3)} kg`, `${r.body.parts.length} ${r.body.parts.length === 1 ? 'body' : 'rigid bodies'}`),
    metric(s.mode === 'fourbar' ? 'Plate axis inertia*' : 'Target axis inertia', `${n(r.axisMomentKgM2, 5)}`, 'kg·m² · *not observable in translation'),
    metric('Small-angle frequency', `${n(r.frequencyHz, 3)} Hz`, r.modeFrequenciesHz ? `Second mode ${n(r.modeFrequenciesHz[1], 3)} Hz` : `T₀ = ${n(r.periodSmallS, 3)} s`),
    metric('Finite-angle period', `${n(r.periodFiniteS, 3)} s`, `${n(Math.abs(s.initialAngleDeg), 1)}° conservative release`)
  );
  const details = $('bodyDetails'), table = document.createElement('table'); table.className = 'property-table';
  tableRow(table, 'CG [x, y, z] (in)', r.body.centroid.map(v => n(v, 3)).join(', '));
  tableRow(table, 'Ixx (kg·m²)', siInertia(r.body.inertia[0][0]));
  tableRow(table, 'Iyy (kg·m²)', siInertia(r.body.inertia[1][1]));
  tableRow(table, 'Izz (kg·m²)', siInertia(r.body.inertia[2][2]));
  tableRow(table, 'Ixy (kg·m²)', siInertia(r.body.inertia[0][1]));
  tableRow(table, 'Chain mass (kg)', n(r.chainMassKg, 4));
  details.replaceChildren(table);
  const principal = document.createElement('p'); principal.className = 'principal-list';
  principal.textContent = r.body.principal.map((p, i) => `J${i + 1} ${siInertia(p.value)} kg·m²  ·  e${i + 1} = [${p.axis.map(v => n(v, 2)).join(', ')}]`).join('\n');
  principal.style.whiteSpace = 'pre-line'; details.append(principal);

  const warnings = $('warnings'); warnings.replaceChildren();
  const notes = [...r.warnings];
  if (s.observedPeriodS) {
    try {
      const inferred = inferAxisInertia(r, s, s.observedPeriodS);
      notes.unshift(inferred.valid ? `Observed T = ${n(Number(s.observedPeriodS), 3)} s implies J = ${n(inferred.inertiaKgM2, 5)} kg·m² (${n(inferred.errorPct, 1)}% vs modeled axis).` : `Observed period: ${inferred.reason}`);
    } catch (error) { notes.unshift(error.message); }
  }
  if (s.mode === 'compound') notes.unshift(`Pivot-to-CG radial distance: ${n(r.params.radialDistanceIn, 3)} in. Plate J is ${n(r.params.inertiaShare * 100, 1)}% of total pivot inertia.`);
  if (s.mode === 'bifilar') notes.unshift(`At equilibrium, vertical strand drop is ${n(r.params.h0, 3)} in; lower half-spacing is ${n(r.params.b, 3)} in.`);
  notes.push('Time trace includes ideal viscous damping. Frequency and Monte Carlo periods are conservative (zero damping).');
  for (const [i, message] of notes.entries()) { const box = document.createElement('div'); box.className = `warning ${i === 0 ? 'info' : ''}`; box.textContent = message; warnings.append(box); }
}

function svgEl(name, attrs = {}, text = null) {
  const e = document.createElementNS(SVG, name);
  for (const [k, v] of Object.entries(attrs)) e.setAttribute(k, String(v));
  if (text !== null) e.textContent = text;
  return e;
}
function line(svg, x1, y1, x2, y2, attrs = {}) { svg.append(svgEl('line', { x1, y1, x2, y2, ...attrs })); }
function textSvg(svg, x, y, value, attrs = {}) { svg.append(svgEl('text', { x, y, fill: '#a6c2cb', 'font-size': 11, ...attrs }, value)); }
function project2(part, p) {
  const R = part.R, pose = part.plate.pose;
  const z = part.plate.thicknessIn / 2;
  return [R[0][0] * p[0] + R[0][1] * p[1] + R[0][2] * z + (pose.x || 0), R[1][0] * p[0] + R[1][1] * p[1] + R[1][2] * z + (pose.y || 0)];
}
function renderPlateView() {
  const svg = $('plateView'); svg.replaceChildren();
  if (!result) return;
  const parts = result.body.parts, points = parts.flatMap(part => part.plate.outer.map(p => project2(part, p)));
  let minX = Math.min(...points.map(p => p[0])), maxX = Math.max(...points.map(p => p[0]));
  let minY = Math.min(...points.map(p => p[1])), maxY = Math.max(...points.map(p => p[1]));
  const spanX = Math.max(2, maxX - minX), spanY = Math.max(2, maxY - minY), scale = Math.min(530 / spanX, 300 / spanY);
  const mx = (minX + maxX) / 2, my = (minY + maxY) / 2;
  const xy = p => [320 + (p[0] - mx) * scale, 190 - (p[1] - my) * scale];
  for (let i = 0; i <= 10; i++) { const x = i * 64, y = i * 38; line(svg, x, 0, x, 380, { stroke: '#27404b', 'stroke-width': .6 }); line(svg, 0, y, 640, y, { stroke: '#27404b', 'stroke-width': .6 }); }
  for (const part of parts) {
    const pathPoints = poly => poly.map((p, i) => { const [x, y] = xy(project2(part, p)); return `${i ? 'L' : 'M'}${x},${y}`; }).join(' ') + ' Z';
    const path = [pathPoints(part.plate.outer), ...part.plate.voids.map(pathPoints)].join(' ');
    svg.append(svgEl('path', { d: path, fill: plateColor(part.plate), 'fill-opacity': part.plate.id === selectedId ? .76 : .42, stroke: part.plate.id === selectedId ? '#cae7e7' : '#83a4ae', 'stroke-width': 2, 'fill-rule': 'evenodd' }));
    for (const h of part.plate.holes) { const [x, y] = xy(project2(part, h)); svg.append(svgEl('circle', { cx: x, cy: y, r: Math.max(2.2, h[2] * scale), fill: '#0c1822', stroke: '#d1edef', 'stroke-width': 1.2 })); }
    const [cx, cy] = xy(part.centroid);
    svg.append(svgEl('circle', { cx, cy, r: 4.4, fill: '#efb76f', stroke: '#17232b', 'stroke-width': 1.5 }));
  }
  const [cx, cy] = xy(result.body.centroid);
  for (const [i, principal] of result.body.principal.entries()) {
    const a = principal.axis, projection = Math.hypot(a[0], a[1]);
    if (projection < .1) continue;
    const length = 70, dx = length * a[0] / projection, dy = -length * a[1] / projection;
    line(svg, cx - dx, cy - dy, cx + dx, cy + dy, { stroke: i === 0 ? '#f6bd7b' : '#75d6bb', 'stroke-width': 1.6, 'stroke-dasharray': '6 5' });
  }
  svg.append(svgEl('circle', { cx, cy, r: 6, fill: '#eea462', stroke: '#1c242b', 'stroke-width': 2 }));
  textSvg(svg, cx + 9, cy - 10, 'assembly CG', { fill: '#ffcf8d', 'font-weight': 700 });
  const attach = result.body.holes.find(h => h.plateId === config.suspension.attachment?.plateId && h.holeIndex === Number(config.suspension.attachment?.holeIndex));
  if (attach) { const [x, y] = xy(attach.point); svg.append(svgEl('circle', { cx: x, cy: y, r: 8, fill: 'none', stroke: '#f9d476', 'stroke-width': 2.5 })); }
  textSvg(svg, 20, 356, 'x →', { fill: '#7198a3' }); textSvg(svg, 20, 338, 'y ↑', { fill: '#7198a3' });
}

function drawPlateBar(svg, centerX, centerY, angle, label, width = 180) {
  const degrees = -angle * 180 / Math.PI;
  svg.append(svgEl('rect', { x: centerX - width / 2, y: centerY - 19, width, height: 38, rx: 7, fill: '#87c6d8', stroke: '#cbe9eb', 'stroke-width': 2, transform: `rotate(${degrees} ${centerX} ${centerY})` }));
  svg.append(svgEl('circle', { cx: centerX, cy: centerY, r: 5, fill: '#f1b76f' }));
  textSvg(svg, centerX, centerY + 4, label, { 'text-anchor': 'middle', fill: '#113344', 'font-weight': 700 });
}
function renderMotion() {
  const svg = $('motionView'); svg.replaceChildren();
  if (!result || !trace.length) return;
  const index = Math.min(trace.length - 1, Math.round(Number($('timeSlider').value) / 1000 * (trace.length - 1)));
  const sample = trace[index], q = sample.angle * Math.PI / 180, q2 = (sample.secondary ?? sample.angle) * Math.PI / 180;
  $('clockLabel').textContent = `t = ${n(sample.t, 2)} s`;
  $('angleLabel').textContent = `${n(sample.angle, 1)}°`;
  line(svg, 0, 328, 640, 328, { stroke: '#27424d', 'stroke-width': 1 });
  line(svg, 320, 42, 320, 321, { stroke: '#3d5962', 'stroke-width': 1, 'stroke-dasharray': '5 6' });
  if (result.mode === 'bifilar') {
    const cx = 320, topY = 50, bottomY = 239, topRad = 96, bottomRad = 91;
    line(svg, 180, 45, 460, 45, { stroke: '#b8cdd0', 'stroke-width': 8, 'stroke-linecap': 'round' });
    const bx1 = cx - bottomRad * Math.cos(q), bx2 = cx + bottomRad * Math.cos(q), by1 = bottomY + bottomRad * Math.sin(q), by2 = bottomY - bottomRad * Math.sin(q);
    line(svg, cx - topRad, topY, bx1, by1, { stroke: '#efc071', 'stroke-width': 3 });
    line(svg, cx + topRad, topY, bx2, by2, { stroke: '#efc071', 'stroke-width': 3 });
    drawPlateBar(svg, cx, bottomY, q, 'plate', 2 * bottomRad);
    svg.append(svgEl('circle', { cx: cx - topRad, cy: topY, r: 5, fill: '#eaf3f2' }), svgEl('circle', { cx: cx + topRad, cy: topY, r: 5, fill: '#eaf3f2' }));
    textSvg(svg, 320, 296, 'twist about vertical CG axis', { 'text-anchor': 'middle' });
  } else if (result.mode === 'fourbar') {
    line(svg, 180, 46, 460, 46, { stroke: '#b8cdd0', 'stroke-width': 8, 'stroke-linecap': 'round' });
    const dx = 153 * Math.sin(q), dy = 153 * Math.cos(q);
    line(svg, 222, 50, 222 + dx, 50 + dy, { stroke: '#efc071', 'stroke-width': 3 });
    line(svg, 418, 50, 418 + dx, 50 + dy, { stroke: '#efc071', 'stroke-width': 3 });
    drawPlateBar(svg, 320 + dx, 229 + dy - 153, 0, 'plate translates', 225);
    textSvg(svg, 320, 296, 'plate angle stays zero · J is unobservable', { 'text-anchor': 'middle' });
  } else {
    line(svg, 210, 46, 430, 46, { stroke: '#b8cdd0', 'stroke-width': 8, 'stroke-linecap': 'round' });
    const ax = 320 + 171 * Math.sin(q), ay = 54 + 171 * Math.cos(q);
    line(svg, 320, 54, ax, ay, { stroke: '#efc071', 'stroke-width': 3.5 });
    svg.append(svgEl('circle', { cx: 320, cy: 54, r: 6, fill: '#eaf3f2' }));
    const barAngle = result.mode === 'twolink' ? q2 : q;
    const bx = ax + 44 * Math.sin(barAngle), by = ay + 44 * Math.cos(barAngle);
    drawPlateBar(svg, bx, by, barAngle, result.mode === 'twolink' ? 'free plate' : 'rigid plate');
    svg.append(svgEl('circle', { cx: ax, cy: ay, r: 5, fill: '#f8da92' }));
    textSvg(svg, 320, 321, result.mode === 'twolink' ? 'chain swing + independent plate rocking' : 'plate and chain rotate together', { 'text-anchor': 'middle' });
  }
  textSvg(svg, 20, 27, `deployed chain ${n(config.suspension.chainLengthIn, 2)} in`, { fill: '#adc6cc', 'font-weight': 600 });
}

function canvasContext(canvas) {
  const rect = canvas.getBoundingClientRect(), dpr = Math.max(1, window.devicePixelRatio || 1);
  canvas.width = Math.max(2, Math.round(rect.width * dpr)); canvas.height = Math.max(2, Math.round(Number(canvas.getAttribute('height')) * dpr));
  const ctx = canvas.getContext('2d'); ctx.scale(dpr, dpr); return { ctx, w: canvas.width / dpr, h: canvas.height / dpr };
}
function drawAxes(ctx, w, h, left, right, top, bottom, yMin, yMax, xMin, xMax, yLabel, xLabel) {
  ctx.font = '11px system-ui'; ctx.strokeStyle = '#304451'; ctx.fillStyle = '#819ba6'; ctx.lineWidth = 1;
  for (let i = 0; i <= 4; i++) {
    const y = top + i * (h - top - bottom) / 4, value = yMax - i * (yMax - yMin) / 4;
    ctx.beginPath(); ctx.moveTo(left, y); ctx.lineTo(w - right, y); ctx.stroke(); ctx.fillText(n(value, 1), 6, y + 3);
  }
  for (let i = 0; i <= 5; i++) { const x = left + i * (w - left - right) / 5; ctx.fillText(n(xMin + i * (xMax - xMin) / 5, 1), x - 8, h - 6); }
  ctx.fillText(yLabel, left + 4, 14); ctx.fillText(xLabel, w - right - 15, h - 6);
}
function drawTrace() {
  const canvas = $('traceChart'), { ctx, w, h } = canvasContext(canvas); ctx.clearRect(0, 0, w, h);
  if (!trace.length) return;
  const values = trace.flatMap(p => p.secondary === null ? [p.angle] : [p.angle, p.secondary]);
  const largest = Math.max(2, ...values.map(Math.abs)) * 1.15, left = 55, right = 18, top = 24, bottom = 27;
  drawAxes(ctx, w, h, left, right, top, bottom, -largest, largest, 0, config.suspension.durationS, 'angle (°)', 's');
  const x = t => left + t / config.suspension.durationS * (w - left - right);
  const y = v => top + (largest - v) / (2 * largest) * (h - top - bottom);
  for (const [key, color] of [['angle', '#76d2c0'], ['secondary', '#eab878']]) {
    if (key === 'secondary' && trace[0].secondary === null) continue;
    ctx.beginPath(); ctx.strokeStyle = color; ctx.lineWidth = 1.9;
    trace.forEach((p, i) => { const X = x(p.t), Y = y(p[key]); if (i) ctx.lineTo(X, Y); else ctx.moveTo(X, Y); }); ctx.stroke();
  }
  if (trace[0].secondary !== null) { ctx.fillStyle = '#eab878'; ctx.fillText('plate', w - 75, 18); ctx.fillStyle = '#76d2c0'; ctx.fillText('chain', w - 125, 18); }
}
function drawHistogram() {
  const canvas = $('histChart');
  if (!mcResult) { canvas.hidden = true; return; }
  canvas.hidden = false;
  const { ctx, w, h } = canvasContext(canvas), values = mcResult.rows.map(r => r.periodS).sort((a, b) => a - b);
  const lo = values[0], hi = values.at(-1), bins = 32, range = Math.max(1e-9, hi - lo), counts = Array(bins).fill(0);
  for (const value of values) counts[Math.min(bins - 1, Math.floor((value - lo) / range * bins))]++;
  const maxCount = Math.max(...counts), left = 50, right = 16, top = 22, bottom = 30;
  ctx.clearRect(0, 0, w, h); drawAxes(ctx, w, h, left, right, top, bottom, 0, maxCount, lo, hi, 'trials', 's');
  const bw = (w - left - right) / bins;
  for (let i = 0; i < bins; i++) { const bh = counts[i] / maxCount * (h - top - bottom); ctx.fillStyle = '#59bcae'; ctx.fillRect(left + i * bw + 1, h - bottom - bh, Math.max(1, bw - 2), bh); }
  ctx.fillStyle = '#b8cbd0'; ctx.font = '10px system-ui'; ctx.fillText(`${n(lo, 3)} s`, left, h - 5); ctx.fillText(`${n(hi, 3)} s`, w - right - 45, h - 5);
}
function renderMc() {
  const root = $('mcResults'); root.replaceChildren();
  if (!mcResult) { root.className = 'mc-results empty'; root.textContent = 'Choose uncertainty inputs and run the trials.'; $('mcStatus').textContent = 'Run trials to see uncertainty'; $('exportCsv').disabled = true; drawHistogram(); return; }
  root.className = 'mc-results';
  const stats = [['Valid trials', `${mcResult.rows.length} / ${mcResult.count}`], ['5th percentile', `${n(mcResult.period.p05, 3)} s`], ['Median', `${n(mcResult.period.median, 3)} s`], ['95th percentile', `${n(mcResult.period.p95, 3)} s`]];
  for (const [label, value] of stats) { const div = document.createElement('div'); div.className = 'mc-stat'; const a = document.createElement('span'); a.textContent = label; const b = document.createElement('strong'); b.textContent = value; div.append(a, b); root.append(div); }
  $('mcStatus').textContent = `${mcResult.invalid} invalid geometries · seed ${config.monteCarlo.seed}`;
  $('exportCsv').disabled = false; requestAnimationFrame(drawHistogram);
}
function refresh() {
  playing = false; $('playButton').textContent = '▶ Play'; elapsedBefore = 0; $('timeSlider').value = '0';
  try {
    result = evaluate(config); trace = simulate(result, config.suspension);
    $('errorBox').hidden = true;
    renderResults(); renderPlateList(); syncHoleOptions(); renderPlateView(); renderMotion(); requestAnimationFrame(drawTrace);
    save();
  } catch (error) {
    result = null; trace = []; $('errorBox').hidden = false; $('errorBox').textContent = error.message;
    $('metrics').replaceChildren(); $('bodyDetails').replaceChildren(); $('warnings').replaceChildren(); $('plateView').replaceChildren(); $('motionView').replaceChildren();
    syncHoleOptions();
  }
  mcResult = null; renderMc();
}
function download(name, content, type) {
  const blob = new Blob([content], { type }), link = document.createElement('a'), url = URL.createObjectURL(blob);
  link.href = url; link.download = name; document.body.append(link); link.click(); link.remove(); setTimeout(() => URL.revokeObjectURL(url), 1000);
}

document.querySelectorAll('[data-kind]').forEach(input => input.addEventListener(input.tagName === 'SELECT' ? 'change' : 'input', () => {
  const kind = input.dataset.kind, key = input.dataset.key, raw = input.value;
  if (raw === '' && input.type === 'number') return;
  const target = kind === 'plate' ? selected() : kind === 'pose' ? selected().pose : config[kind];
  const value = input.type === 'number' ? Number(raw) : raw;
  target[key] = value;
  if (kind === 'plate' && key === 'material') { target.density = materials[value]?.density || target.density; syncPlateControls(); }
  if (kind === 'suspension' && key === 'mode') { target.chainCount = ['bifilar', 'fourbar'].includes(value) ? 2 : 1; syncGeneralControls(); }
  if (kind === 'suspension' && key === 'bottomSpacingMode') syncModeControls();
  if (kind === 'plate') renderPlateList();
  refresh();
}));
for (const [id, key] of [['gravityInput', 'gravity'], ['axisInput', 'axis']]) $(id).addEventListener('change', () => {
  try { const v = parseVector($(id).value, key === 'axis' ? 'Pivot axis' : 'Gravity'); if (key === 'axis') config.suspension.axis = v; else config.gravity = v; refresh(); }
  catch (error) { $('errorBox').hidden = false; $('errorBox').textContent = error.message; }
});
$('attachmentSelect').addEventListener('change', () => { const h = result?.body.holes[Number($('attachmentSelect').value)]; if (h) { config.suspension.attachment = { plateId: h.plateId, holeIndex: h.holeIndex }; refresh(); } });
for (const [id, key] of [['firstHoleSelect', 'firstHole'], ['secondHoleSelect', 'secondHole']]) $(id).addEventListener('change', () => { config.suspension[key] = Number($(id).value); refresh(); });
$('applyGeometry').addEventListener('click', () => {
  try {
    const p = selected(), outer = parseLines($('outerEditor').value, 2, 'Outer polygon');
    const voids = $('voidEditor').value.trim() ? $('voidEditor').value.trim().split(/\r?\n\s*\r?\n/).map((block, i) => parseLines(block, 2, `Opening ${i + 1}`)) : [];
    const holes = parseLines($('holeEditor').value, 3, 'Holes');
    const old = { outer: p.outer, voids: p.voids, holes: p.holes };
    p.outer = outer; p.voids = voids; p.holes = holes;
    try { evaluate(config); } catch (error) { Object.assign(p, old); throw error; }
    p.source = 'User-edited geometry'; p.caveat = ''; refresh(); syncPlateControls();
  } catch (error) { $('errorBox').hidden = false; $('errorBox').textContent = error.message; }
});
$('addPlate').addEventListener('click', () => { const p = makePreset($('presetSelect').value); if (config.plates.length) p.pose = { x: 2 + 2 * config.plates.length, y: 1 + config.plates.length, z: .7 * config.plates.length, roll: 7 * config.plates.length, pitch: 5 * config.plates.length, yaw: 13 * config.plates.length }; config.plates.push(p); selectedId = p.id; syncPlateControls(); refresh(); });
$('duplicatePlate').addEventListener('click', () => { const p = clone(selected()); p.id = `copy-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`; p.name += ' copy'; p.pose.x += 2; p.pose.y += 1; p.pose.z += p.thicknessIn; p.pose.yaw += 13; config.plates.push(p); selectedId = p.id; syncPlateControls(); refresh(); });
$('removePlate').addEventListener('click', () => { if (config.plates.length <= 1) return; config.plates = config.plates.filter(p => p.id !== selectedId); selectedId = config.plates[0].id; config.suspension.attachment = { plateId: selectedId, holeIndex: 0 }; syncPlateControls(); refresh(); });
$('runMonteCarlo').addEventListener('click', () => {
  if (!result) return;
  const button = $('runMonteCarlo'); button.disabled = true; button.textContent = 'Running…';
  setTimeout(() => { try { mcResult = runMonteCarlo(config); renderMc(); } catch (error) { $('errorBox').hidden = false; $('errorBox').textContent = error.message; } finally { button.disabled = false; button.textContent = 'Run Monte Carlo'; } }, 25);
});
$('exportCsv').addEventListener('click', () => { if (!mcResult) return; const rows = ['trial,period_s,frequency_hz,axis_inertia_kg_m2,plate_mass_kg,second_mode_hz', ...mcResult.rows.map(r => [r.trial, r.periodS, r.frequencyHz, r.axisMomentKgM2, r.massKg, r.secondModeHz ?? ''].join(','))]; download('chain-plate-monte-carlo.csv', rows.join('\n'), 'text/csv'); });
$('exportConfig').addEventListener('click', () => download('chain-plate-configuration.json', JSON.stringify(config, null, 2), 'application/json'));
$('importConfig').addEventListener('change', async event => { const file = event.target.files?.[0]; if (!file) return; try { const incoming = JSON.parse(await file.text()); if (!Array.isArray(incoming.plates) || !incoming.plates.length || !incoming.monteCarlo || !incoming.suspension) throw Error('Missing configuration sections.'); evaluate(incoming); config = incoming; selectedId = config.plates[0].id; syncGeneralControls(); syncPlateControls(); refresh(); } catch (error) { $('errorBox').hidden = false; $('errorBox').textContent = `Import failed: ${error.message}`; } event.target.value = ''; });
$('timeSlider').addEventListener('input', () => { playing = false; $('playButton').textContent = '▶ Play'; renderMotion(); });
$('playButton').addEventListener('click', () => { if (!trace.length) return; playing = !playing; $('playButton').textContent = playing ? 'Ⅱ Pause' : '▶ Play'; if (playing) { elapsedBefore = Number($('timeSlider').value) / 1000 * config.suspension.durationS; startTime = performance.now(); requestAnimationFrame(animate); } });
function animate(now) { if (!playing) return; const elapsed = elapsedBefore + (now - startTime) / 1000; const frac = elapsed / config.suspension.durationS; if (frac >= 1) { playing = false; $('playButton').textContent = '▶ Play'; $('timeSlider').value = '1000'; renderMotion(); return; } $('timeSlider').value = String(Math.round(frac * 1000)); renderMotion(); requestAnimationFrame(animate); }
window.addEventListener('resize', () => { if (trace.length) drawTrace(); if (mcResult) drawHistogram(); });
syncGeneralControls(); syncPlateControls(); refresh();
