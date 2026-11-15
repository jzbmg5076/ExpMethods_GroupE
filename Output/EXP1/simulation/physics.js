// All geometry is entered in inches; mass is kg. Dynamics use SI internally.
export const IN = 0.0254;
export const G = 9.80665;
const EPS = 1e-12;
const TAU = 2 * Math.PI;

export const add = (a, b) => a.map((v, i) => v + b[i]);
export const sub = (a, b) => a.map((v, i) => v - b[i]);
export const mul = (a, s) => a.map(v => v * s);
export const dot = (a, b) => a.reduce((v, x, i) => v + x * b[i], 0);
export const norm = a => Math.hypot(...a);
export const unit = a => {
  const n = norm(a);
  if (!(n > EPS)) throw Error('Axis or gravity vector must be nonzero.');
  return mul(a, 1 / n);
};
const zero3 = () => [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
const madd = (a, b) => a.map((row, i) => row.map((v, j) => v + b[i][j]));
const msub = (a, b) => a.map((row, i) => row.map((v, j) => v - b[i][j]));
const mt = a => a[0].map((_, j) => a.map(row => row[j]));
const mm = (a, b) => a.map(row => b[0].map((_, j) => row.reduce((v, x, k) => v + x * b[k][j], 0)));
const mv = (a, v) => a.map(row => dot(row, v));
const outer = (a, b) => a.map(x => b.map(y => x * y));
const axisMoment = (I, a) => dot(a, mv(I, a));
const perp = (r, a) => sub(r, mul(a, dot(r, a)));
const parallelAxis = (m, r) => {
  const q = dot(r, r);
  return outer(r, r).map((row, i) => row.map((v, j) => m * ((i === j ? q : 0) - v)));
};

function signedPolygonMoments(poly) {
  let A = 0, Mx = 0, My = 0, X2 = 0, Y2 = 0, XY = 0;
  for (let i = 0; i < poly.length; i++) {
    const [x, y] = poly[i], [u, v] = poly[(i + 1) % poly.length];
    const c = x * v - u * y;
    A += c;
    Mx += (x + u) * c;
    My += (y + v) * c;
    X2 += (x * x + x * u + u * u) * c;
    Y2 += (y * y + y * v + v * v) * c;
    XY += (2 * x * y + x * v + u * y + 2 * u * v) * c;
  }
  const sign = Math.sign(A);
  if (!sign || Math.abs(A) < EPS) throw Error('Polygon has zero area.');
  return { A: sign * A / 2, Mx: sign * Mx / 6, My: sign * My / 6,
    X2: sign * X2 / 12, Y2: sign * Y2 / 12, XY: sign * XY / 24 };
}
function momentAdd(a, b, sign = 1) {
  for (const k of ['A', 'Mx', 'My', 'X2', 'Y2', 'XY']) a[k] += sign * b[k];
}
const pointIn = (p, poly) => {
  let inside = false;
  for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    const a = poly[i], b = poly[j];
    if (((a[1] > p[1]) !== (b[1] > p[1])) && p[0] < (b[0] - a[0]) * (p[1] - a[1]) / (b[1] - a[1]) + a[0]) inside = !inside;
  }
  return inside;
};
function pointSegmentDistance(p, a, b) {
  const d = sub(b, a), t = Math.max(0, Math.min(1, dot(sub(p, a), d) / Math.max(EPS, dot(d, d))));
  return norm(sub(p, add(a, mul(d, t))));
}
function edgeDistance(p, poly) {
  let best = Infinity;
  for (let i = 0; i < poly.length; i++) best = Math.min(best, pointSegmentDistance(p, poly[i], poly[(i + 1) % poly.length]));
  return best;
}
function orient(a, b, c) { return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0]); }
function onSegment(a, b, p) {
  return Math.abs(orient(a, b, p)) <= EPS && p[0] >= Math.min(a[0], b[0]) - EPS && p[0] <= Math.max(a[0], b[0]) + EPS && p[1] >= Math.min(a[1], b[1]) - EPS && p[1] <= Math.max(a[1], b[1]) + EPS;
}
function intersects(a, b, c, d) {
  const p = orient(a, b, c), q = orient(a, b, d), r = orient(c, d, a), s = orient(c, d, b);
  return (p * q < -EPS && r * s < -EPS) || onSegment(a, b, c) || onSegment(a, b, d) || onSegment(c, d, a) || onSegment(c, d, b);
}
function polysIntersect(a, b) {
  for (let i = 0; i < a.length; i++) for (let j = 0; j < b.length; j++)
    if (intersects(a[i], a[(i + 1) % a.length], b[j], b[(j + 1) % b.length])) return true;
  return false;
}
function validatePolygon(poly, name) {
  if (!Array.isArray(poly) || poly.length < 3 || poly.some(p => !Array.isArray(p) || p.length !== 2 || p.some(v => !Number.isFinite(v)))) throw Error(`${name} needs at least three finite x,y points.`);
  for (let i = 0; i < poly.length; i++) if (norm(sub(poly[i], poly[(i + 1) % poly.length])) < EPS) throw Error(`${name} has a duplicate consecutive vertex.`);
  for (let i = 0; i < poly.length; i++) for (let j = i + 1; j < poly.length; j++) {
    if (j === i + 1 || (i === 0 && j === poly.length - 1)) continue;
    if (intersects(poly[i], poly[(i + 1) % poly.length], poly[j], poly[(j + 1) % poly.length])) throw Error(`${name} crosses itself.`);
  }
  signedPolygonMoments(poly);
}

export function plateProperties(plate) {
  validatePolygon(plate.outer, `${plate.name} outline`);
  if (!Array.isArray(plate.voids) || !Array.isArray(plate.holes)) throw Error('Voids and holes must be arrays.');
  if (!(plate.thicknessIn > 0) || !Number.isFinite(plate.thicknessIn)) throw Error(`${plate.name}: thickness must be positive.`);
  const m = signedPolygonMoments(plate.outer);
  for (const [i, poly] of plate.voids.entries()) {
    validatePolygon(poly, `${plate.name} opening ${i + 1}`);
    if (poly.some(p => !pointIn(p, plate.outer)) || polysIntersect(poly, plate.outer)) throw Error(`${plate.name}: opening ${i + 1} must lie within the outline.`);
    for (let j = 0; j < i; j++) if (polysIntersect(poly, plate.voids[j]) || pointIn(poly[0], plate.voids[j]) || pointIn(plate.voids[j][0], poly)) throw Error(`${plate.name}: openings overlap.`);
    momentAdd(m, signedPolygonMoments(poly), -1);
  }
  for (const [i, hole] of plate.holes.entries()) {
    if (!Array.isArray(hole) || hole.length !== 3 || hole.some(v => !Number.isFinite(v)) || hole[2] <= 0) throw Error(`${plate.name}: hole ${i + 1} needs x,y,radius > 0.`);
    const [x, y, r] = hole, c = [x, y];
    if (!pointIn(c, plate.outer) || edgeDistance(c, plate.outer) + EPS < r) throw Error(`${plate.name}: hole ${i + 1} exits the outline.`);
    for (const poly of plate.voids) if (pointIn(c, poly) || edgeDistance(c, poly) + EPS < r) throw Error(`${plate.name}: hole ${i + 1} overlaps an opening.`);
    for (let j = 0; j < i; j++) if (norm(sub(c, plate.holes[j].slice(0, 2))) + EPS < r + plate.holes[j][2]) throw Error(`${plate.name}: holes ${i + 1} and ${j + 1} overlap.`);
    const area = Math.PI * r * r, Icircle = Math.PI * r ** 4 / 4;
    momentAdd(m, { A: area, Mx: area * x, My: area * y,
      X2: area * x * x + Icircle, Y2: area * y * y + Icircle, XY: area * x * y }, -1);
  }
  if (!(m.A > EPS)) throw Error(`${plate.name}: net material area must be positive.`);
  const volumeIn3 = m.A * plate.thicknessIn;
  const massKg = plate.massMode === 'density' ? plate.density * volumeIn3 * IN ** 3 : plate.massKg;
  if (!(massKg > 0) || !Number.isFinite(massKg)) throw Error(`${plate.name}: mass or density must be positive.`);
  const x = m.Mx / m.A, y = m.My / m.A, s = massKg / m.A;
  const Ixx = s * (m.Y2 - m.A * y * y) + massKg * plate.thicknessIn ** 2 / 12;
  const Iyy = s * (m.X2 - m.A * x * x) + massKg * plate.thicknessIn ** 2 / 12;
  const Ixy = -s * (m.XY - m.A * x * y);
  const Izz = s * (m.X2 + m.Y2 - m.A * (x * x + y * y));
  if (Math.min(Ixx, Iyy, Izz) <= 0) throw Error(`${plate.name}: inertia is not positive; inspect geometry.`);
  return { massKg, areaIn2: m.A, volumeIn3, effectiveDensity: massKg / (volumeIn3 * IN ** 3),
    centroid: [x, y, plate.thicknessIn / 2], inertia: [[Ixx, Ixy, 0], [Ixy, Iyy, 0], [0, 0, Izz]] };
}

export function rotation(pose = {}) {
  const rx = (pose.roll || 0) * Math.PI / 180, ry = (pose.pitch || 0) * Math.PI / 180, rz = (pose.yaw || 0) * Math.PI / 180;
  const [cx, sx, cy, sy, cz, sz] = [Math.cos(rx), Math.sin(rx), Math.cos(ry), Math.sin(ry), Math.cos(rz), Math.sin(rz)];
  return mm([[cz, -sz, 0], [sz, cz, 0], [0, 0, 1]], mm([[cy, 0, sy], [0, 1, 0], [-sy, 0, cy]], [[1, 0, 0], [0, cx, -sx], [0, sx, cx]]));
}
export function assemblyProperties(plates) {
  if (!Array.isArray(plates) || !plates.length) throw Error('Add at least one plate.');
  const parts = plates.map(p => {
    const local = plateProperties(p), R = rotation(p.pose), t = [p.pose?.x || 0, p.pose?.y || 0, p.pose?.z || 0];
    return { plate: p, local, R, centroid: add(mv(R, local.centroid), t), inertia: mm(mm(R, local.inertia), mt(R)) };
  });
  const massKg = parts.reduce((v, p) => v + p.local.massKg, 0);
  const centroid = mul(parts.reduce((v, p) => add(v, mul(p.centroid, p.local.massKg)), [0, 0, 0]), 1 / massKg);
  let inertia = zero3();
  for (const p of parts) inertia = madd(inertia, madd(p.inertia, parallelAxis(p.local.massKg, sub(p.centroid, centroid))));
  const holes = parts.flatMap(part => part.plate.holes.map((h, i) => ({
    label: `${part.plate.name} · H${i + 1}`, plateId: part.plate.id, holeIndex: i,
    point: add(mv(part.R, [h[0], h[1], part.plate.thicknessIn / 2]), [part.plate.pose?.x || 0, part.plate.pose?.y || 0, part.plate.pose?.z || 0])
  })));
  return { massKg, centroid, inertia, parts, holes, principal: eigenSymmetric(inertia) };
}

export function eigenSymmetric(matrix) {
  const a = matrix.map(row => [...row]);
  const v = [[1, 0, 0], [0, 1, 0], [0, 0, 1]];
  for (let n = 0; n < 40; n++) {
    let p = 0, q = 1, big = Math.abs(a[0][1]);
    for (const [i, j] of [[0, 2], [1, 2]]) if (Math.abs(a[i][j]) > big) { p = i; q = j; big = Math.abs(a[i][j]); }
    if (big < 1e-12) break;
    const phi = .5 * Math.atan2(2 * a[p][q], a[q][q] - a[p][p]);
    const c = Math.cos(phi), s = Math.sin(phi);
    const Q = [[1, 0, 0], [0, 1, 0], [0, 0, 1]];
    Q[p][p] = c; Q[q][q] = c; Q[p][q] = s; Q[q][p] = -s;
    const updated = mm(mm(mt(Q), a), Q);
    for (let i = 0; i < 3; i++) for (let j = 0; j < 3; j++) a[i][j] = updated[i][j];
    const vectors = mm(v, Q);
    for (let i = 0; i < 3; i++) for (let j = 0; j < 3; j++) v[i][j] = vectors[i][j];
  }
  return [0, 1, 2].map(i => ({ value: a[i][i], axis: v.map(row => row[i]) })).sort((x, y) => x.value - y.value);
}

function attachmentPoint(assembly, suspension) {
  const found = assembly.holes.find(h => h.plateId === suspension.attachment?.plateId && h.holeIndex === Number(suspension.attachment?.holeIndex));
  if (found) return found.point;
  return assembly.holes[0]?.point || assembly.centroid;
}
function chainMass(s) { return Math.max(0, s.chainLinearDensityKgM) * s.chainLengthIn * IN * s.chainCount; }
function modeFrequencies(A, B, C, K1, K2) {
  const determinant = A * C - B * B;
  if (!(determinant > 0)) throw Error('Two-link mass matrix is singular.');
  const sum = K1 * C + K2 * A;
  const delta = Math.sqrt(Math.max(0, sum * sum - 4 * determinant * K1 * K2));
  return [Math.sqrt((sum - delta) / (2 * determinant)) / TAU, Math.sqrt((sum + delta) / (2 * determinant)) / TAU];
}

export function evaluate(config) {
  const body = assemblyProperties(config.plates), s = config.suspension;
  const gravity = unit(config.gravity), axis = unit(s.axis), L = Number(s.chainLengthIn), stock = Number(s.stockLengthIn);
  if (!(L > 0) || !(stock > 0) || L > stock + 1e-9) throw Error('Active chain length must be positive and no longer than chain stock.');
  if (!Number.isInteger(Number(s.chainCount)) || s.chainCount < 1 || s.chainCount > 20) throw Error('Chain count must be an integer from 1 to 20.');
  const expectedStrands = ['bifilar', 'fourbar'].includes(s.mode) ? 2 : 1;
  if (s.chainCount !== expectedStrands) throw Error(`${s.mode} model requires exactly ${expectedStrands} ${expectedStrands === 1 ? 'strand' : 'strands'}.`);
  if (!Number.isFinite(s.chainLinearDensityKgM) || s.chainLinearDensityKgM < 0) throw Error('Chain linear density cannot be negative.');
  const warnings = [];
  if (s.chainLinearDensityKgM === 0) warnings.push('Chain mass is unmeasured. Enter its linear density to include chain inertia and gravity.');
  for (const part of body.parts) {
    const nominal = Number(part.plate.density), effective = part.local.effectiveDensity;
    if (nominal > 0 && Math.abs(effective / nominal - 1) > .12) warnings.push(`${part.plate.name}: mass/volume implies ${effective.toFixed(0)} kg/m³, ${Math.abs(100 * (effective / nominal - 1)).toFixed(0)}% from selected material density.`);
    if (part.plate.caveat) warnings.push(`${part.plate.name}: ${part.plate.caveat}`);
  }
  if (config.plates.length > 1) {
    warnings.push('Assembly inertia includes rotated plates and parallel-axis terms. Contact, fastener mass, and structural flexibility need separate measurements.');
    if (new Set(config.plates.map(p => p.material)).size < 2) warnings.push('The course assembly requires two different materials; this configuration uses one material category.');
    for (let i = 0; i < body.parts.length; i++) for (let j = i + 1; j < body.parts.length; j++) {
      const first = body.parts[i], second = body.parts[j];
      if (norm(sub(first.centroid, second.centroid)) < .01) warnings.push(`${first.plate.name} and ${second.plate.name} have nearly coincident CGs, contrary to the course assembly rule.`);
      const e1 = eigenSymmetric(first.inertia), e2 = eigenSymmetric(second.inertia);
      if (e1.some(x => e2.some(y => Math.abs(dot(x.axis, y.axis)) > .9999))) warnings.push(`${first.plate.name} and ${second.plate.name} share a principal-axis direction, contrary to the course assembly rule.`);
    }
  }
  const mc = chainMass(s), m = body.massKg, J = axisMoment(body.inertia, axis) * IN ** 2;
  const result = { body, warnings, mode: s.mode, chainMassKg: mc, axisMomentKgM2: J, axis, gravity };
  if (s.mode === 'compound') {
    if (Math.abs(dot(axis, gravity)) > .01) throw Error('Compound pivot axis must be horizontal (perpendicular to gravity).');
    const attach = attachmentPoint(body, s), pivot = sub(attach, mul(gravity, L));
    const rp = perp(sub(body.centroid, pivot), axis), rc = perp(mul(gravity, L / 2), axis);
    const radialMass = add(mul(rp, m), mul(rc, mc));
    const K = G * IN * norm(radialMass);
    const M = J + m * dot(rp, rp) * IN ** 2 + mc * L * L * IN ** 2 / 3;
    result.params = { M, K, radialDistanceIn: norm(rp), pivot, attach, inertiaShare: J / M };
    result.frequencyHz = Math.sqrt(K / M) / TAU;
    warnings.push('Rigid compound mode assumes the selected attachment and chain act as one locked body about the upper fulcrum. Use free-hinge mode if the plate can rock on its screw.');
    if (result.params.inertiaShare < .05) warnings.push('Plate inertia is under 5% of pivot inertia; inversion from period will be ill-conditioned.');
  } else if (s.mode === 'fourbar') {
    const M = (m + mc / 3) * (L * IN) ** 2, K = (m + mc / 2) * G * L * IN;
    result.params = { M, K, inertiaShare: 0 };
    result.frequencyHz = Math.sqrt(K / M) / TAU;
    warnings.push('Parallel-chain four-bar motion translates the plate. Its period cannot identify any plate moment of inertia.');
  } else if (s.mode === 'twolink') {
    if (Math.abs(dot(axis, gravity)) > .01) throw Error('Rocking hinge axis must be horizontal (perpendicular to gravity).');
    const attach = attachmentPoint(body, s), d = norm(perp(sub(body.centroid, attach), axis));
    if (!(d > 1e-5)) throw Error('Two-link model needs CG offset below its plate hinge.');
    const li = L * IN, di = d * IN;
    const A = (m + mc / 3) * li * li, B = m * li * di, C = J + m * di * di;
    const K1 = (m + mc / 2) * G * li, K2 = m * G * di;
    result.params = { A, B, C, K1, K2, hingeDistanceIn: d, attach };
    result.modeFrequenciesHz = modeFrequencies(A, B, C, K1, K2);
    result.frequencyHz = result.modeFrequenciesHz[0];
    warnings.push('Two-link rocking assumes a free, frictionless hinge and taut straight chain; impact and slack are outside this model.');
  } else if (s.mode === 'bifilar') {
    let a = Number(s.topHalfSpacingIn), b = Number(s.bottomHalfSpacingIn), centerOffsetIn = 0;
    if (s.bottomSpacingMode === 'holes') {
      const h1 = body.holes[Number(s.firstHole)], h2 = body.holes[Number(s.secondHole)];
      if (!h1 || !h2 || h1 === h2) throw Error('Choose two different valid bottom holes.');
      b = norm(perp(sub(h1.point, h2.point), gravity)) / 2;
      centerOffsetIn = norm(perp(sub(mul(add(h1.point, h2.point), .5), body.centroid), gravity));
      if (centerOffsetIn > .05) warnings.push(`Selected hole midpoint is ${centerOffsetIn.toFixed(3)} in from the CG axis. Symmetric bifilar equation is approximate; recenter the support.`);
    } else warnings.push('Manual bottom half-spacing assumes the lower anchors are symmetric about the assembly CG axis.');
    if (!(a > 0 && b > 0 && L > Math.abs(a - b))) throw Error('Bifilar spacings must be positive and |top − bottom half-spacing| < chain length.');
    const verticalAxis = mul(gravity, -1), Jv = axisMoment(body.inertia, verticalAxis) * IN ** 2;
    const strandMass = mc / 2, h0 = Math.sqrt(L * L - (a - b) ** 2);
    const M0 = Jv + 2 * strandMass * (b * IN) ** 2 / 3;
    const K = (m + strandMass) * G * a * b / h0 * IN;
    result.params = { a, b, L, h0, Jv, strandMass, M0, K, centerOffsetIn, inertiaShare: Jv / M0 };
    result.axisMomentKgM2 = Jv;
    result.frequencyHz = Math.sqrt(K / M0) / TAU;
    if (Math.abs(dot(axis, gravity)) < .99) warnings.push('Bifilar axis follows gravity, independent of the compound/hinge axis setting.');
  } else throw Error('Choose a supported motion model.');
  result.periodSmallS = 1 / result.frequencyHz;
  result.periodFiniteS = finitePeriod(result, s.initialAngleDeg * Math.PI / 180);
  if (Math.abs(s.initialAngleDeg) > 25) warnings.push('Large release angles can excite out-of-plane motion or chain slack; the ideal mode may not match the apparatus.');
  return result;
}

function agm(a, b) {
  for (let n = 0; n < 30 && Math.abs(a - b) > 1e-14 * a; n++) [a, b] = [(a + b) / 2, Math.sqrt(a * b)];
  return a;
}
export function finitePeriod(result, angleRad) {
  const amp = Math.abs(angleRad);
  if (amp < 1e-5 || result.mode === 'twolink') return result.periodSmallS;
  if (amp >= Math.PI) throw Error('Release angle must be below 180° for an oscillatory solution.');
  if (result.mode !== 'bifilar') {
    const k = Math.sin(amp / 2);
    return result.periodSmallS / agm(1, Math.sqrt(1 - k * k));
  }
  const { a, b, L, h0, Jv, strandMass } = result.params;
  const h = q => Math.sqrt(L * L - a * a - b * b + 2 * a * b * Math.cos(q));
  const hA = h(amp);
  if (!Number.isFinite(hA) || hA <= 0) throw Error('This twist angle is impossible for the chosen cable length and spacings.');
  let sum = 0;
  const N = 160;
  for (let i = 0; i < N; i++) {
    const u = (i + .5) * Math.PI / (2 * N), q = amp * Math.sin(u), hq = h(q);
    const hp = -a * b * Math.sin(q) / hq;
    const M = Jv + (result.body.massKg + 2 * strandMass / 3) * (hp * IN) ** 2 + 2 * strandMass * (b * IN) ** 2 / 3;
    const dh = 2 * a * b * (Math.cos(q) - Math.cos(amp)) / (hq + hA);
    const deltaU = (result.body.massKg + strandMass) * G * dh * IN;
    sum += amp * Math.cos(u) * Math.sqrt(M / (2 * deltaU));
  }
  return 4 * sum * Math.PI / (2 * N);
}

export function inferAxisInertia(result, s, observedPeriodS) {
  const observed = Number(observedPeriodS);
  if (!(observed > 0) || !Number.isFinite(observed)) throw Error('Observed period must be positive.');
  if (result.mode === 'fourbar') return { valid: false, reason: 'Four-bar translation contains no plate-inertia information.' };
  if (result.mode === 'twolink') return { valid: false, reason: 'A single observed period cannot select either coupled rocking mode.' };
  if (result.mode === 'compound') {
    const amplitude = Math.abs(s.initialAngleDeg) * Math.PI / 180;
    const correction = 1 / agm(1, Math.sqrt(1 - Math.sin(amplitude / 2) ** 2));
    const smallPeriod = observed / correction;
    const { K, M } = result.params;
    const plateInertia = K * (smallPeriod / TAU) ** 2 - (M - result.axisMomentKgM2);
    if (plateInertia <= 0) return { valid: false, reason: 'This period implies negative plate inertia for the entered pivot/chain geometry.' };
    return { valid: true, inertiaKgM2: plateInertia, errorPct: 100 * (plateInertia / result.axisMomentKgM2 - 1) };
  }
  const angle = Math.abs(s.initialAngleDeg) * Math.PI / 180;
  const baseline = result.params.M0 - result.params.Jv;
  const trialPeriod = Jv => {
    const params = { ...result.params, Jv, M0: Jv + baseline };
    return finitePeriod({ ...result, params, periodSmallS: TAU * Math.sqrt(params.M0 / params.K) }, angle);
  };
  if (trialPeriod(0) > observed) return { valid: false, reason: 'Observed period is below the zero-plate-inertia bound for this bifilar geometry.' };
  let lo = 0, hi = Math.max(result.params.Jv * 2, 1e-9);
  for (let n = 0; n < 60 && trialPeriod(hi) < observed; n++) hi *= 2;
  for (let n = 0; n < 60; n++) { const mid = (lo + hi) / 2; if (trialPeriod(mid) < observed) lo = mid; else hi = mid; }
  const inertiaKgM2 = (lo + hi) / 2;
  return { valid: true, inertiaKgM2, errorPct: 100 * (inertiaKgM2 / result.axisMomentKgM2 - 1) };
}

function derivative(result, s, state) {
  const zeta = Math.max(0, Number(s.dampingRatio));
  if (result.mode === 'twolink') {
    const [q1, w1, q2, w2] = state;
    const { A, B, C, K1, K2 } = result.params;
    const m = result.body.massKg, L = s.chainLengthIn * IN, d = result.params.hingeDistanceIn * IN;
    const cross = m * L * d * Math.cos(q1 - q2), nonlin = m * L * d * Math.sin(q1 - q2);
    const c1 = 2 * zeta * Math.sqrt(K1 * A), c2 = 2 * zeta * Math.sqrt(K2 * C);
    const f1 = -nonlin * w2 * w2 - K1 * Math.sin(q1) - c1 * w1;
    const f2 = nonlin * w1 * w1 - K2 * Math.sin(q2) - c2 * w2;
    const det = A * C - cross * cross;
    return [w1, (C * f1 - cross * f2) / det, w2, (A * f2 - cross * f1) / det];
  }
  const [q, w] = state;
  if (result.mode === 'bifilar') {
    const { a, b, L, Jv, strandMass, M0, K } = result.params;
    const h = Math.sqrt(L * L - a * a - b * b + 2 * a * b * Math.cos(q));
    if (!(h > 0)) throw Error('Chain geometry became impossible during integration.');
    const hp = -a * b * Math.sin(q) / h;
    const hpp = -a * b * Math.cos(q) / h - (a * b * Math.sin(q)) ** 2 / h ** 3;
    const verticalMass = result.body.massKg + 2 * strandMass / 3;
    const M = Jv + 2 * strandMass * (b * IN) ** 2 / 3 + verticalMass * (hp * IN) ** 2;
    const halfDerivative = verticalMass * hp * hpp * IN ** 2;
    const restoring = -(result.body.massKg + strandMass) * G * hp * IN;
    const c = 2 * zeta * Math.sqrt(K * M0);
    return [w, -(halfDerivative * w * w + restoring + c * w) / M];
  }
  const { M, K } = result.params, c = 2 * zeta * Math.sqrt(K * M);
  return [w, (-K * Math.sin(q) - c * w) / M];
}
function rk4(result, s, state, dt) {
  const k1 = derivative(result, s, state);
  const k2 = derivative(result, s, state.map((v, i) => v + .5 * dt * k1[i]));
  const k3 = derivative(result, s, state.map((v, i) => v + .5 * dt * k2[i]));
  const k4 = derivative(result, s, state.map((v, i) => v + dt * k3[i]));
  return state.map((v, i) => v + dt * (k1[i] + 2 * k2[i] + 2 * k3[i] + k4[i]) / 6);
}
export function simulate(result, s) {
  const duration = Number(s.durationS);
  if (!(duration > 0 && duration <= 120)) throw Error('Duration must be between 0 and 120 s.');
  if (!(s.dampingRatio >= 0 && s.dampingRatio < 1)) throw Error('Damping ratio must be from 0 to below 1.');
  const n = Math.min(20000, Math.max(1200, Math.ceil(duration * Math.max(...(result.modeFrequenciesHz || [result.frequencyHz])) * 110)));
  const dt = duration / n, out = [];
  let state = result.mode === 'twolink' ? [s.initialAngleDeg * Math.PI / 180, 0, s.secondAngleDeg * Math.PI / 180, 0] : [s.initialAngleDeg * Math.PI / 180, 0];
  const stride = Math.max(1, Math.floor(n / 900));
  for (let i = 0; i <= n; i++) {
    if (i % stride === 0 || i === n) out.push({ t: i * dt, angle: state[0] * 180 / Math.PI, secondary: result.mode === 'twolink' ? state[2] * 180 / Math.PI : null });
    if (i < n) state = rk4(result, s, state, dt);
    if (state.some(v => !Number.isFinite(v))) throw Error('Numerical integration diverged. Reduce amplitude or adjust geometry.');
  }
  return out;
}

export function runMonteCarlo(config) {
  const mc = config.monteCarlo, count = Math.round(mc.trials);
  if (!(count >= 10 && count <= 10000)) throw Error('Monte Carlo trials must be 10–10,000.');
  let seed = (Number(mc.seed) >>> 0) || 1;
  const random = () => { seed = (seed + 0x6D2B79F5) >>> 0; let t = seed; t = Math.imul(t ^ t >>> 15, t | 1); t ^= t + Math.imul(t ^ t >>> 7, t | 61); return ((t ^ t >>> 14) >>> 0) / 4294967296; };
  const gaussian = () => Math.sqrt(-2 * Math.log(Math.max(1e-12, random()))) * Math.cos(TAU * random());
  const rows = [], failures = {};
  for (let i = 0; i < count; i++) {
    const c = structuredClone(config), s = c.suspension;
    for (const p of c.plates) {
      if (p.massMode === 'measured') p.massKg *= Math.max(.01, 1 + gaussian() * mc.massPct / 100);
      else p.density *= Math.max(.01, 1 + gaussian() * mc.massPct / 100);
      p.thicknessIn *= Math.max(.01, 1 + gaussian() * mc.thicknessPct / 100);
      p.outer = p.outer.map(([x, y]) => [x + gaussian() * mc.vertexSigmaIn, y + gaussian() * mc.vertexSigmaIn]);
      p.voids = p.voids.map(poly => poly.map(([x, y]) => [x + gaussian() * mc.vertexSigmaIn, y + gaussian() * mc.vertexSigmaIn]));
      p.holes = p.holes.map(([x, y, r]) => [x + gaussian() * mc.holeSigmaIn, y + gaussian() * mc.holeSigmaIn, r]);
      for (const k of ['x', 'y', 'z']) p.pose[k] += gaussian() * mc.poseSigmaIn;
    }
    const fullStock = Math.abs(s.chainLengthIn - s.stockLengthIn) < 1e-9;
    s.chainLengthIn += gaussian() * mc.chainLengthSigmaIn;
    if (fullStock) s.stockLengthIn = s.chainLengthIn;
    s.topHalfSpacingIn += gaussian() * mc.spacingSigmaIn;
    s.bottomHalfSpacingIn += gaussian() * mc.spacingSigmaIn;
    s.chainLinearDensityKgM *= Math.max(0, 1 + gaussian() * mc.chainDensityPct / 100);
    s.initialAngleDeg += gaussian() * mc.angleSigmaDeg;
    try {
      const r = evaluate(c);
      rows.push({ trial: i + 1, periodS: r.periodFiniteS, frequencyHz: 1 / r.periodFiniteS,
        axisMomentKgM2: r.axisMomentKgM2, massKg: r.body.massKg,
        secondModeHz: r.modeFrequenciesHz?.[1] ?? null });
    } catch (error) { failures[error.message] = (failures[error.message] || 0) + 1; }
  }
  if (!rows.length) throw Error('No valid Monte Carlo trials. Reduce uncertainty or correct the geometry.');
  const sorted = rows.map(r => r.periodS).sort((a, b) => a - b);
  const quantile = p => { const x = (sorted.length - 1) * p, lo = Math.floor(x), hi = Math.ceil(x); return sorted[lo] + (sorted[hi] - sorted[lo]) * (x - lo); };
  return { rows, count, invalid: count - rows.length, failures, period: { p05: quantile(.05), median: quantile(.5), p95: quantile(.95) } };
}
