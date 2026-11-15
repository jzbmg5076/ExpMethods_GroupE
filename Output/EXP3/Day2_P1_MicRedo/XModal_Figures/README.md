# P1 steel rectangle, Day 2 mic redo: X-Modal results (run 2026-10-20, ~14:40–14:56)

Workflow (Canvas X-Modal quick start): imported `Lab Data/EXP3/XModal/EXP3_P1_MicRedo_15pt_FRFs_only.unv` (MicN.mat → hit pt N, relabelled Response = pt N +Z, Reference = 16 = mic) and the existing P1 3×5 wireframe `EXP3_P1_Geometry_3x5.unv`; merged nodes/tracelines + FRFs into group `EXP3_P1_MicRedo_15pt_withGeo` (removed the duplicate units dataset) and exported it to `Lab Data/EXP3/XModal/EXP3_P1_MicRedo_15pt_withGeo_XModal.mat`. MPE: PTD, orders 2:20, 400–2520 Hz (544 lines) → start → Pole Wizard → hand picks → Save → Group Manager → Residue Setup start → Animation (isometric, amplitude 2.8).

## Where the Wizard found the poles
Wizard: 8 poles = **4 modes at 1250.76, 1287.60, 2187.50, 2465.92 Hz**. It skipped 453, 595 and 2136 Hz (only frequency/conjugate-stable symbols there — the mic hears those modes more weakly), so they were hand-picked at model order 19: **453.43, 595.42, 2136.25 Hz**.

| Mode | Shape | X-Modal f (Hz) | ζ (%) | Picked by | NX corner-spring (Hz) | Δ | MAC vs NX* | Day 1 accel (Hz) |
|---|---|---|---|---|---|---|---|---|
| 1 | (3,1) | 453.43 | 1.52 | hand | 457.9 | −1.0 % | 0.98 | 450.8 |
| 2 | (2,2) | 595.42 | 1.21 | hand | 606.0 | −1.7 % | 0.99 | 600.2 |
| 3 | (4,1) | 1250.76 | 0.47 | Wizard | 1247.3 | +0.3 % | 0.98 | 1239.6 |
| 4 | (3,2) | 1287.60 | 0.71 | Wizard | 1300.0 | −1.0 % | 0.98 | 1294.9 |
| 5 | (1,3) | 2136.25 | 0.26 | hand | 2159.4 | −1.1 % | 0.91 | not fit |
| 6 | (4,2) | 2187.50 | 0.44 | Wizard | 2201.4 | −0.6 % | 0.99 | 2196.2 |
| 7 | ? | 2465.92 | 0.40 | Wizard | above 12-mode solve | — | — | — |
*MAC from the Python fit of the same FRFs (`../EXP3_D2_P1_micredo_modes.csv`).

## Files
- `P1_MicRedo_00_AllModes_panel.png` — all 7 shapes with f, ζ, NX, MAC, Day 1 accel (report figure)
- `P1_MicRedo_01_ConsistencyDiagram_Wizard.png` / `_02_..._FinalPicks.png` — before and after hand picks
- `P1_MicRedo_03_FRF_Synthesis_pt1.png` — measured vs synthesized FRF (pt 1)
- `P1_MicRedo_ModeN_<f>Hz.mov / .gif / _iso.png` — X-Modal animation, 3 s GIF, peak-deflection still
