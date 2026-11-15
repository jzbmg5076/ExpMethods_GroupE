# Copper rod NX model: tuned to run R1 (2026-10-08, Claude)

File edited: Lab Data/EXP2/NX/OLD/EXPT2_OLD/copper_fem1_sim1_final.sim (The group moved it to OLD/ on 10/8; Lab Data/EXP2/NX/EXPT2/ now holds the untouched originals).
Originals backed up first: Lab Data/EXP2/NX/EXPT2/_backup_before_claude_2026-10-08/

## Data used (R1, Runs/R1/Copper.txt, last 3 min, steady)
| x from heated end (in) | 4.25 | 6.75 | 9.25 | 11.75 (tip) |
|---|---|---|---|---|
| Thermistor (degC) | 43.03 | 40.57 | 38.21 | 33.07 |
Ambient taken as 25 degC (rod temps before heating). Rod 0.195 in x 11.75 in (Rod Specs).

## Changes
1. Solution 1 (Multiphysics, SOL 401), existing objects:
   - Thermal Load(1): 0.73 W -> 0.81 W (end face)
   - Convection to Environment(1): h 15 -> 10 W/m^2K (ambient 25 degC unchanged)
   - Note: this solution cannot run on this PC ("Simcenter 3D Thermal Flow" not installed), and its
     thermal load + convection are NOT inside the step, so the solver skips them (also true of the
     9/29 lab run in "Final output folder": its .diag says "Skipping load and constraint set").
2. NEW Solution 2 "SOL153_SteadyThermal_R1fit" (Simcenter Nastran, SOL 153 steady heat transfer):
   - Flux(1): 42,040 W/m^2 on the heated end face (z = 11.75 in in model coords) = 0.80 W on the meshed face
   - Conv(1): h = 10 W/m^2K on the lateral surface, ambient 77 degF (25 degC)
   - Material unchanged: Copper_C10100, k = 387 W/mK (NX library)
   - Nastran is not installed on this PC, so NX wrote the deck but could not run it:
     copper_fem1_sim1_final-solution_2sol153_steadythermal_r1fit.dat
     Claude solved that exact deck (same mesh, k, h, flux) with an independent linear-tet FE solve.

## Result (deck solved by Claude; re-run on a lab PC to get the NX contour plot)
| x (in) | 4.25 | 6.75 | 9.25 | 11.75 |
|---|---|---|---|---|
| Model (degC) | 43.04 | 40.07 | 38.36 | 37.81 |
| Data (degC) | 43.03 | 40.57 | 38.21 | 33.07 |
| Original setup, h=15, 0.73 W (analytic) | 36.1 | 33.6 | 32.3 | 31.8 |
Ch1-Ch3 match within 0.5 degC. Ch4 (tip) is 4.7 degC low; an insulated or convecting copper tip can't
drop that fast, so this points at the tip thermistor (contact/offset; calibration already flagged it
reading ~1.9 degC low).

## How h and Q were chosen
Fin equation fitted to Ch1-Ch3 (tip excluded): best fit h = 10.1 W/m^2K, Q = 0.815 W (k = 391).
Only m = sqrt(hP/kA) and Q/k can be identified from a steady profile, so k was held at the
handbook value and h, Q were tuned (as the 9/23 lecture and the FAQ suggest).
0.81 W is ~20% of the 4.1 W electrical heater input (4.98 V, 6.1 ohm), consistent with "not all the power reaches the rod".

## UPDATE 2026-10-08 evening: solved in NX on a group member's PC
After the group installed the solver add-ons, Solution 2 (SOL 153) was run in NX: Simcenter Nastran converged,
END OF JOB, no fatal errors. Results files are next to the sim in OLD/EXPT2_OLD/ (.op2/.f06).
NX nodal temperatures (read from the .op2, averaged at each station; NX reports in degF):
| x (in) | 0 | 1.5 | 4.25 | 6.75 | 9.25 | 11.75 |
|---|---|---|---|---|---|---|
| NX (degC) | 51.84 | 48.14 | 43.04 | 40.07 | 38.36 | 37.81 |
| Data (degC) | - | - | 43.03 | 40.57 | 38.21 | 33.07 |
Contour range 100.06-125.39 degF (37.8-51.9 degC). Identical to Claude's earlier independent solve of
the same deck to 0.01 degC, so the earlier numbers stand. Solution 1 (SOL 401) was not re-run.
