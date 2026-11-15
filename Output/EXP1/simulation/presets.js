const CM = 1 / 2.54;
const rect = (w, h) => [[0, 0], [w, 0], [w, h], [0, h]];
const cmPoints = points => points.map(([x, y]) => [x * CM, y * CM]);

function perimeterHoles(w, h, nx, ny, offset, radius) {
  const holes = [];
  for (let i = 0; i < nx; i++) {
    const x = offset + i * (w - 2 * offset) / (nx - 1);
    holes.push([x, offset, radius], [x, h - offset, radius]);
  }
  for (let i = 1; i < ny - 1; i++) {
    const y = offset + i * (h - 2 * offset) / (ny - 1);
    holes.push([offset, y, radius], [w - offset, y, radius]);
  }
  return holes;
}

function notchedHoles() {
  const w = 40.2 * CM, h = 19.9 * CM;
  const run = 17.5 * CM, leftY = 6.6 * CM, stepX = 27.9 * CM, stepY = 3.6 * CM;
  const e = 0.25, r = 0.184 / 2, holes = [];
  for (let i = 0; i < 5; i++) holes.push([e + i * (w - 2 * e) / 4, h - e, r]);
  for (let i = 0; i < 4; i++) holes.push([w - e, e + i * (h - 2 * e) / 4, r]);
  for (let i = 0; i < 3; i++) holes.push([e + i * (run - 2 * e) / 2, leftY + e, r]);
  const dx = stepX - run, dy = stepY - leftY, n = Math.hypot(dx, dy);
  holes.push([run + .82 * dx - e * dy / n, leftY + .82 * dy + e * dx / n, r]);
  holes.push([stepX + e, stepY / 2, r]);
  holes.push([(stepX + w) / 2, e, r]);
  holes.push([e, (leftY + h) / 2, r]);
  return holes;
}

export const materials = {
  hdpe: { label: 'HDPE', density: 950 },
  aluminum: { label: 'Aluminum 6061', density: 2700 },
  stainless: { label: 'Stainless steel', density: 7800 },
  custom: { label: 'Custom', density: 2700 }
};

const presetData = {
  rectangle: {
    name: 'Rectangle · lab plate', material: 'aluminum', density: 2700,
    massMode: 'measured', massKg: 1.687, thicknessIn: .5,
    outer: rect(12.9, 5.9), voids: [], holes: perimeterHoles(12.9, 5.9, 5, 3, .25, .09),
    source: 'LabData Notes.txt; Day 1 Data Review §3. The 0.50 in thickness follows measured mass / aluminum density. The earlier 0.45 in entry remains editable.',
    caveat: 'Thickness is disputed: 0.45 in in workbook/NX setup; 0.50 in inferred in Day 1 review.'
  },
  notched: {
    name: 'Plate 1 · notched HDPE', material: 'hdpe', density: 950,
    massMode: 'measured', massKg: 1.15897386, thicknessIn: .75,
    outer: cmPoints([[0, 6.6], [17.5, 6.6], [27.9, 3.6], [27.9, 0], [40.2, 0], [40.2, 19.9], [0, 19.9]]),
    voids: [], holes: notchedHoles(),
    source: 'Plate_measurements.pdf p.3; Analytical_Plate_Models/plate01_notched_solid_model.m',
    caveat: 'Lower curved transition and some hole centers are straight-chord/photo approximations.'
  },
  offset: {
    name: 'Plate 2 · offset frame', material: 'aluminum', density: 2700,
    massMode: 'measured', massKg: 4.5350165, thicknessIn: .5,
    outer: rect(60.7 * CM, 30.5 * CM),
    voids: [rect(35.6 * CM, 15.4 * CM).map(([x, y]) => [x + 17.4 * CM, y + 10.1 * CM])],
    holes: perimeterHoles(60.7 * CM, 30.5 * CM, 5, 5, .25, .184 / 2),
    source: 'Plate_measurements.pdf p.4; Analytical_Plate_Models/plate02_offset_rectangular_frame_model.m',
    caveat: 'Hole diameter is assumed from Plate 1. Simplified opening differs from NX geometry by ~4–5% normalized inertia.'
  },
  irregular: {
    name: 'Plate 3 · irregular frame', material: 'stainless', density: 7800,
    massMode: 'measured', massKg: 9.052279652, thicknessIn: .5,
    outer: rect(61.1 * CM, 30.4 * CM),
    voids: [cmPoints([[8.6, 7.6], [20.9, 4.4], [21.8, 8.1], [32.3, 8.1], [52.1, 2.7], [55.5, 16.1], [13.7, 27.2]])],
    holes: perimeterHoles(61.1 * CM, 30.4 * CM, 5, 5, .25, .184 / 2),
    source: 'Plate_measurements.pdf p.5; Analytical_Plate_Models/plate03_irregular_window_frame_model.m',
    caveat: '0.50 in thickness and hole diameter are assumptions. Measured mass implies ~6122 kg/m³, unlike nominal stainless density.'
  }
};

export function makePreset(key) {
  const value = presetData[key];
  if (!value) throw Error(`Unknown preset: ${key}`);
  return structuredClone({ ...value, id: `plate-${crypto.randomUUID()}`, pose: { x: 0, y: 0, z: 0, roll: 0, pitch: 0, yaw: 0 } });
}
export function presetKeys() { return Object.keys(presetData); }

export function defaultConfig() {
  const plate = makePreset('rectangle');
  return {
    plates: [plate],
    gravity: [0, -1, 0],
    suspension: {
      mode: 'bifilar', stockLengthIn: 23, chainLengthIn: 23,
      chainCount: 2, chainLinearDensityKgM: 0,
      attachment: { plateId: plate.id, holeIndex: 1 },
      axis: [0, 0, 1], topHalfSpacingIn: 6,
      bottomHalfSpacingIn: 6, bottomSpacingMode: 'holes',
      firstHole: 1, secondHole: 9,
      initialAngleDeg: 10, secondAngleDeg: 10, dampingRatio: .015,
      durationS: 12
    },
    monteCarlo: {
      trials: 1000, seed: 260912,
      massPct: 1, vertexSigmaIn: .01, holeSigmaIn: .005,
      thicknessPct: 1, poseSigmaIn: 0,
      chainLengthSigmaIn: .125, spacingSigmaIn: .05,
      chainDensityPct: 10, angleSigmaDeg: 1
    }
  };
}
