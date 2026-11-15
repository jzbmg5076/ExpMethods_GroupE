# P3 cut-out frame, T5 accelerometer test: X-Modal results (run 2026-10-20, ~11:18–11:36)

## As-tested point numbering (inches; x along the 23.84 in side from the wide 6.8 in band, y across from the wide 4.1 in band)
| Node | x | y | Note |
|---|---|---|---|
| 1 | 0.9 | 0.9 | corner |
| 2 | 13.0 | 0.9 | long-side middle |
| 3 | 22.95 | 0.9 | corner next to accelerometer |
| 4 | 0.9 | 6.0 | short-end middle (added Day 2) |
| 5 | 22.95 | 6.0 | short-end middle (added Day 2) |
| 6 | 0.9 | 11.1 | corner (was plan pt 6) |
| 7 | 13.0 | 11.1 | long-side middle (was plan pt 5) |
| 8 | 22.95 | 11.1 | corner (was plan pt 4) |
| 9 | 23.1 | 2.1 | accelerometer (plan location — confirm) |
Traceline: 1-2-3-5-8-7-6-4-1. File map: Acc1x1.mat → pt 1, AccN.mat → pt N.

## Workflow (followed the Canvas "X-Modal quick start")
1. Data Manager → Import `EXP3_P3_Accel_8pt_FRFs_only.unv` (8 FRFs relabelled Response = pt N +Z, Reference = 9 +Z; raw files had CHAN 2/CHAN 1).
2. Wireframe Model Editor → Edit model → 9 new nodes + 1 traceline → Save → Data Manager. (Also saved as `Lab Data/EXP3/XModal/EXP3_P3_Geometry_8pt_XModalWME.ufb`.)
3. Merge: copied 151/164/58 from the FRF group plus 15/82 from the geometry group into a new group, removed the "bogus" SI-meter 164 units file, saved as group `EXP3_P3_Frame_Accel_8pt_withGeo` and exported to `Lab Data/EXP3/XModal/EXP3_P3_Frame_Accel_8pt_withGeo_XModal.mat`.
4. MPE: PTD, orders 2:20, band 125–742 Hz (159 lines) → green start → Pole Wizard → hand-picked the 150/170 Hz pair → Save → Group Manager → Residue Setup start → Animation.

## Where the Wizard found the poles
The Wizard returned 8 poles = **4 modes: 346.69, 421.40, 557.11, 697.04 Hz**. It skipped the two lowest modes: around 150–170 Hz the diagram only shows pole/frequency/conjugate-stable symbols (no "pole & vector" column), because those modes are heavily damped (~5 %) and only ~5 frequency lines apart. They were picked by hand at model order 19: **149.83 Hz** and **169.51 Hz**.

| Mode | X-Modal f (Hz) | ζ (%) | Picked by | NX (Hz) | Δ | MAC vs NX* | Python fit (Hz) |
|---|---|---|---|---|---|---|---|
| 1 | 149.83 | 5.11 | hand | 150.12 | −0.2 % | 0.96 | 151.8 |
| 2 | 169.51 | 5.80 | hand | 159.27 | +6.4 % | 0.98 | 167.9 |
| 3 | 346.69 | 1.82 | Wizard | 347.1 | −0.1 % | 0.99 | 346.95 |
| 4 | 421.40 | 1.50 | Wizard | 428.5 | −1.7 % | 0.99 | 421.06 |
| 5 | 557.11 | 1.26 | Wizard | 558.8 | −0.3 % | 0.98 | 557.12 |
| 6 | 697.04 | 1.32 | Wizard | 706.6 | −1.4 % | 0.99 | 698.52 |
*MAC uses the Python-fit shapes of the same FRFs vs NX at the 8 points. Sign fingerprints (relative to pt 3) match NX exactly for all six modes. Note: with only 8 points, NX modes 2 and 6 look alike spatially (NX cross-MAC 0.77) — they are separated by frequency.

## Files
- `P3_T5_00_AllModes_panel.png` — all 6 shapes with f, ζ, NX, MAC (report figure)
- `P3_T5_00_Wireframe_PlanView_Labels.png` — as-tested wireframe, plan view, node labels
- `P3_T5_01_ConsistencyDiagram_Wizard.png` — Wizard picks only (4 clusters)
- `P3_T5_02_ConsistencyDiagram_FinalPicks.png` — after hand-picking the 150/170 Hz pair
- `P3_T5_03_FRF_Synthesis_pt1.png` — measured vs synthesized FRF (pt 1), residue fit band
- `P3_T5_ModeN_<f>Hz.mov / .gif / _iso.png` — X-Modal animation, looping GIF, peak-deflection still
- `../EXP3_D2_P3_shapes_vs_NX.png`, `../EXP3_D2_P3_accel_modes.csv` — measured vs NX shape comparison and table
