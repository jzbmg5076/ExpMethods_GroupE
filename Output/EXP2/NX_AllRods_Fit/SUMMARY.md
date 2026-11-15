# EXP2 - NX models for all five rods, anchored to the thermistor data (2026-10-08, Claude)

New NX files (all in Lab Data/EXP2/NX/EXPT2/, built from the partner's .prt files, which are unchanged):
| Rod | FEM / SIM | Results deck |
|---|---|---|
| Copper | copper_fem2.fem / copper_sim2.sim | copper_sim2-solution_1.* |
| Aluminum | Aluminum_fem1.fem / Aluminum_sim1.sim | aluminum_sim1-solution_1.* |
| Brass | Brass_fem1.fem / Brass_sim1.sim | brass_sim1-solution_1.* |
| Stainless | steel_fem1.fem / steel_sim1.sim | steel_sim1-solution_1.* |
| Copper tube | Copper_hollow_fem1.fem / Copper_hollow_sim1.sim | copper_hollow_sim1-solution_1.* |
(The original copper_fem1/copper_fem1_sim1_final files were not touched.)

## Setup, per Canvas NX tutorial except where noted
- Mesh: 3D tetrahedral CTETRA(4), 0.06 in (tube: 0.03 in because its wall is only ~0.04 in thick).
- Solution: Simcenter Nastran SOL 153 steady-state heat transfer. The tutorial uses Multiphysics
  coupled thermal-structural (SOL 401); only the thermal answer is needed here, and the partner's SOL 401
  set-up silently skipped its loads, so SOL 153 was used.
- Heat input: uniform heat flux on the heated end face (the tutorial's "thermal load on one end").
- Convection to ambient on the outer lateral surface. No structural constraints (thermal only).
- Heated end = the +Z end face in each model; thermistor positions are distance from that face.

## Data processing (same rule for every rod)
- Steady value = mean of last 3 min of each run.
- Channel offsets removed using the isothermal start of R1, R2, R5, R6, R7 (consistent across runs):
  Ch1 +0.02, Ch2 +1.41, Ch3 -0.57, Ch4 -0.86 degC subtracted.
- Ambient = mean of the 4 (corrected) channels before heating; stainless used its far channel (24.23 degC)
  because that rod started warm and cooled first.
- k held at the NX library value. h and Q chosen by least squares at the thermistor points
  (fin equation), h limited to the lecture range 5-25 W/m2K. NX was solved, then Q rescaled once so NX
  itself best fits the points (linear problem).

## Results (degC)
| Rod / run | k used (NX) | Tamb | h (W/m2K) | Q into rod (W) | thermistor x (in) | data | NX | NX max (heated end) |
|---|---|---|---|---|---|---|---|---|
| Copper R1 | 387 (Cu C10100) | 26.14 | 10.5 | 0.77 | 4.25/6.75/9.25/11.75 | 43.01/39.16/38.78/33.93 | 42.76/39.90/38.29/37.76 | 51.3 |
| Aluminum R2 | ~155 (Al 2014, temp-dep.) | 25.76 | 13.0 | 0.68 | 4.2/6.8/9.4/12 | 37.81/32.01/32.84/29.18 | 37.58/33.15/30.93/30.26 | 53.1 |
| Brass R6 | 116 (Brass) | 27.27 | 25 (cap) | 1.44 | 2.5/3.5/4.5/5.5 | 50.25/39.39/36.24/35.96 | 47.82/42.04/37.91/34.95 | 74.3 |
| Stainless R4 | 16.3 (AISI 304, ADDED) | 24.23 | 25 (cap) | 1.51 | 3/4.5/6/7.5 | 33.67/26.03/24.41/24.23 | 33.46/26.68/24.88/24.40 | 155.7 (!) |
| Cu tube R5 | 387 (Cu C10100) | 26.82 | 18.9 | 2.17 | 3.5/5.5/7.5/9.5 | 45.81/39.66/36.87/34.90 | 45.35/40.20/36.92/35.01 | 61.1 |
All Q values are below the 4.1 W electrical heater input.

## Flags
- Copper Ch4 (tip) excluded from the fit: 3.8 degC below any possible fin shape (sensor/contact).
- Aluminum: R2 used. R7 (Aluminum2) has Ch1 reading BELOW Ch2 and was still rising 0.3 degC/min.
- Brass R6: Ch3/Ch4 flat after a big Ch1-Ch2 drop - not fin-shaped; unconstrained fit wanted h=39.
- Stainless: steel.prt had NO material assigned (NX would not solve). AISI_SS_304-Annealed assigned on
  the FEM physical property PSOLID1. The steep measured decay forces a 156 degC heated-end
  temperature in an end-face-flux model - unrealistic (heater max ~120 degC). Heat really enters over
  the 1.5 in under the clamp; modelling that needs a split face. Fit at the thermistors is good.
- Tube: R5 not fully steady (Ch1 +0.3 degC/min). NX tube ID is 0.230 in vs measured 0.2365 in.
  Positions for R4-R7 come from RunsTerminalComands.txt; assumed measured from the heated end.

## Mass check vs lab weights (2026-10-09)
NX mass = meshed volume x NX library density. Lab weights are read to 0.005 lb, so +/-4% (copper) to +/-12% (aluminum).
| Rod | Lab (lb) | NX model (lb) | Diff | Implied density from lab weight + measured dims (kg/m3) | NX material (kg/m3) |
|---|---|---|---|---|---|
| Copper | 0.115 | 0.111 | -3.3% | 9070 +/-400 | Copper_C10100 8920 |
| Aluminum | 0.040 | 0.037 | -6.7% | 2950 +/-370 | Aluminum_2014 2794 (densest Al in library) |
| Brass | 0.110 | 0.114 | +3.6% | 8000 +/-370 | Brass 8409 (Bronze 8852 is further off) |
| Copper tube | 0.135 | 0.138 | +1.9% | - (see note) | Copper_C10100 8920 |
| Stainless | 0.105 | 0.105 | -0.2% | 8260 +/-400 | AISI_SS_304-Annealed 7900 |
Every rod matches within the scale resolution, and each material is already the closest-density option in the
NX library for its metal family -> no material change made. Density does not enter the steady-state (SOL 153)
answer at all; it only matters for a transient model.
Notes: steel.prt is modelled at 0.201 in dia (measured 0.195) - with the measured size NX mass would be 0.100 lb.
Tube: measured ID 0.2365 in implies a density above pure copper; the NX ID of 0.230 in is consistent with the
weight, so the ID measurement (or wall 0.0395 -> ID 0.2345) should be rechecked.
