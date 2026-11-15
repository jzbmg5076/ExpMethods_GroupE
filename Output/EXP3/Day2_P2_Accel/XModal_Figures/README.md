# P2 L plate, T3 accelerometer test: X-Modal results (run 2026-10-20, ~10:40–11:00)

Input: `Lab Data/EXP3/XModal/EXP3_P2_Accel_18pt_with_Geometry.unv` (18 FRFs relabelled by reciprocity, ref = node 19 accelerometer).
MPE settings: PTD, time domain, short basis, [A] orders 2:20, band 332–2352 Hz (518 lines), Pole Wizard → 14 poles (7 modes), saved as Mode Group 1. Residues: complex, frequency domain, long basis.

| Mode | X-Modal f (Hz) | ζ (%) | NX (Hz) | Δ vs NX | Claude Python fit (Hz) |
|---|---|---|---|---|---|
| 1 | 379.373 | 1.409 | 400.4 | −5.3 % | 379.28 |
| 2 | 577.814 | 1.101 | 599.4 | −3.6 % | 577.91 |
| 3 | 1032.551 | 0.638 | 1094.5 | −5.7 % | 1032.73 |
| 4 | 1305.782 | 0.550 | 1353.4 | −3.5 % | 1305.74 |
| 5 | 1724.872 | 0.433 | 1825.5 | −5.5 % | 1724.82 |
| 6 | 2055.735 | 0.635 | 2155.5 | −4.6 % | 2055.71 |
| 7 | 2246.904 | 0.578 | (not solved) | — | 2246.55 |

Damping is inflated by the 3.9 Hz resolution / window, same as P1.

## Files
- `P2_T3_00_AllModes_panel.png`: all 7 shapes on one page with frequency, damping and NX comparison (report figure)
- `P2_T3_01_ConsistencyDiagram.png`: X-Modal consistency (stability) diagram with the 7 picked clusters
- `P2_T3_ModeN_<f>Hz_iso.png`: single-mode isometric still at peak deflection (X-Modal header shows mode #, f, ζ). Taken from the X-Modal animation recording.
- `P2_T3_ModeN_<f>Hz.mov`: X-Modal animation recording (isometric, amplitude 2.8). Mode 1's clip is ~10 s; the others are ~3 s.
- `P2_T3_ModeN_<f>Hz.gif`: 3 s looping GIF of each MOV (for slides)
- Red wireframe = undeformed; black = deformed shape. X-Modal mode numbers are odd (#1, 3, 5 …) because each mode is listed with its conjugate pole.

Not done yet: exporting Mode Group 1 shapes to UFF (the MPE window locked up after residue estimation; the animation still worked).
