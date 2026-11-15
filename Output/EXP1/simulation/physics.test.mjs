import test from 'node:test';
import assert from 'node:assert/strict';
import { makePreset, defaultConfig } from './presets.js';
import { plateProperties, assemblyProperties, evaluate, simulate, runMonteCarlo, inferAxisInertia, rotation, IN } from './physics.js';

const near = (actual, expected, tolerance = 1e-6) => assert.ok(Math.abs(actual - expected) <= tolerance, `${actual} != ${expected} (tol ${tolerance})`);

test('four lecture plate presets reproduce independent MATLAB geometry reports', () => {
  const expected = {
    rectangle: { cg: [6.45, 2.95], I: [31.799, 150.923, 181.990] },
    notched: { cg: [8.659210796, 4.640604598], I: [29.175148061, 159.488987543, 187.963144751] },
    offset: { cg: [11.143786410, 5.580672504], I: [444.261094757, 1711.362814580, 2154.404821318] },
    irregular: { cg: [11.993665004, 6.223113778], I: [960.358626488, 3619.652497427, 4577.577720273] }
  };
  for (const [key, target] of Object.entries(expected)) {
    const p = plateProperties(makePreset(key));
    near(p.centroid[0], target.cg[0], 1e-8); near(p.centroid[1], target.cg[1], 1e-8);
    for (let i = 0; i < 3; i++) {
      if (key === 'rectangle') continue; // default 0.50 in follows the later lab correction, unlike older 0.45 in MATLAB report.
      near(p.inertia[i][i] * 2.54 ** 2, target.I[i], 2e-6);
    }
  }
});

test('finite-thickness rectangle agrees with corrected lab estimates', () => {
  const withHoles = plateProperties(makePreset('rectangle'));
  const plate = makePreset('rectangle'); plate.holes = [];
  const solid = plateProperties(plate);
  const lbmIn2 = solid.inertia.map((row, i) => row[i] * 2.20462262185);
  near(lbmIn2[0], 10.87, .01);
  near(lbmIn2[1], 51.65, .01);
  near(lbmIn2[2], 62.36, .01);
  assert.ok(withHoles.inertia[0][0] < solid.inertia[0][0]);
});

test('rigid assembly uses rotation and full parallel-axis tensor', () => {
  const a = makePreset('rectangle'), b = makePreset('rectangle');
  a.holes = []; b.holes = [];
  a.outer = [[-1, -1], [1, -1], [1, 1], [-1, 1]];
  b.outer = structuredClone(a.outer);
  a.massKg = 1; b.massKg = 1; a.thicknessIn = b.thicknessIn = .1;
  a.pose = { x: -2, y: 0, z: 0, roll: 0, pitch: 0, yaw: 0 };
  b.pose = { x: 2, y: 0, z: 0, roll: 0, pitch: 0, yaw: 90 };
  const assembly = assemblyProperties([a, b]);
  near(assembly.massKg, 2); near(assembly.centroid[0], 0);
  const one = plateProperties(a);
  near(assembly.inertia[2][2], 2 * one.inertia[2][2] + 8);
  near(assembly.inertia[0][1], 0);
  assert.equal(assembly.principal.length, 3);
  assert.ok(assembly.principal.every(p => p.value > 0));
  for (const eigen of assembly.principal) {
    const product = assembly.inertia.map(row => row.reduce((sum, x, i) => sum + x * eigen.axis[i], 0));
    for (let i = 0; i < 3; i++) near(product[i], eigen.value * eigen.axis[i], 1e-9);
  }
  const R = rotation({ roll: 20, pitch: 30, yaw: 40 });
  for (const row of R) near(row.reduce((s, x) => s + x * x, 0), 1, 1e-12);
});

test('parallel-chain translation is independent of plate inertia but sensitive to chain length', () => {
  const c = defaultConfig(); c.suspension.mode = 'fourbar';
  const f1 = evaluate(c).frequencyHz;
  c.plates[0].outer[1][0] += 2; c.plates[0].outer[2][0] += 2;
  const f2 = evaluate(c).frequencyHz;
  near(f1, f2, 1e-12);
  c.suspension.chainLengthIn = 11.53;
  near(evaluate(c).frequencyHz, .921, .003);
  const invalid = inferAxisInertia(evaluate(c), c.suspension, 1.0855);
  assert.equal(invalid.valid, false);
});

test('bifilar exact geometry tends to course formula at small angle', () => {
  const c = defaultConfig(); c.suspension.initialAngleDeg = .1;
  const r = evaluate(c), { a, b, L, Jv } = r.params;
  near(r.frequencyHz, Math.sqrt(r.body.massKg * 9.80665 * (a * IN) * (b * IN) / ((L * IN) * Jv)) / (2 * Math.PI), .02);
  near(r.periodFiniteS, r.periodSmallS, .001);
  const inference = inferAxisInertia(r, c.suspension, r.periodFiniteS);
  assert.equal(inference.valid, true); near(inference.inertiaKgM2, r.axisMomentKgM2, 1e-7);
});

test('bifilar finite-angle energy quadrature agrees with time-domain oscillations', () => {
  const c = defaultConfig(); c.suspension.initialAngleDeg = 35;
  c.suspension.dampingRatio = 0; c.suspension.durationS = 8;
  const r = evaluate(c), time = simulate(r, c.suspension), crossings = [];
  for (let i = 1; i < time.length; i++) if (time[i - 1].angle > 0 && time[i].angle <= 0) {
    const a = time[i - 1], b = time[i], fraction = a.angle / (a.angle - b.angle);
    crossings.push(a.t + fraction * (b.t - a.t));
  }
  assert.ok(crossings.length > 4);
  near(crossings[2] - crossings[1], r.periodFiniteS, .001);
  assert.ok(r.periodFiniteS > r.periodSmallS);
});

test('free plate hinge has two coupled modes with a higher rocking frequency', () => {
  const c = defaultConfig(); c.suspension.mode = 'twolink'; c.suspension.chainCount = 1;
  const r = evaluate(c);
  assert.equal(r.modeFrequenciesHz.length, 2);
  assert.ok(r.modeFrequenciesHz[1] > r.modeFrequenciesHz[0]);
  assert.ok(simulate(r, c.suspension).some(p => p.secondary !== null));
});

test('compound time integration and period inversion are consistent', () => {
  const c = defaultConfig(); c.suspension.mode = 'compound'; c.suspension.chainCount = 1;
  c.suspension.initialAngleDeg = 10; c.suspension.dampingRatio = 0;
  const r = evaluate(c), time = simulate(r, c.suspension);
  assert.ok(time.length > 500);
  near(time[0].angle, 10);
  assert.ok(time.every(row => Number.isFinite(row.angle)));
  const inversion = inferAxisInertia(r, c.suspension, r.periodFiniteS);
  assert.equal(inversion.valid, true); near(inversion.inertiaKgM2, r.axisMomentKgM2, 1e-8);
});

test('Monte Carlo is seeded, handles full-stock chain uncertainty, and spans nominal prediction', () => {
  const c = defaultConfig(); c.monteCarlo.trials = 200;
  const nominal = evaluate(c).periodFiniteS;
  const first = runMonteCarlo(c), second = runMonteCarlo(c);
  assert.deepEqual(first.period, second.period);
  assert.equal(first.invalid, 0);
  assert.ok(first.period.p05 < nominal && first.period.p95 > nominal);
});

test('invalid overlapping holes are rejected instead of double-subtracted', () => {
  const p = makePreset('rectangle'); p.holes.push([...p.holes[0]]);
  assert.throws(() => plateProperties(p), /overlap/);
});
