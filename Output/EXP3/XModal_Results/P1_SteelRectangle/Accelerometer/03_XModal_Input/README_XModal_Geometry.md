# EXP3 P1 (steel rectangle): X-Modal geometry and merged data

Built 2026-10-13 from the Grid Points sheet in EXP3_TestPlan_and_RunLog.xlsx, the 15 Day 1 files in LabDay1/Steel_Rectagle, and the Canvas X-Modal (quick start).

## Files

| File | What it is | How to use it |
|---|---|---|
| `EXP3_P1_Accel_15pt_with_Geometry.unv` | **Main file.** Header, units, 15 nodes, 8 tracelines and all 15 FRFs, already labelled with the correct node and direction | Data Manager → Import File → open it → Modal Parameter Estimation |
| `EXP3_P1_Accel_15pt_Merged.mat` | The same 15 FRFs, merged and relabelled, in X-Modal's own .mat (UFCELLS) layout. **No geometry** | Use it if the .unv import fails. Then add geometry with the next file or by hand |
| `EXP3_P1_Geometry_3x5.unv` | Geometry only: nodes and tracelines | Import it, then copy it into the same data group as the FRFs (Merge quick start, step 1) |
| `EXP3_P1_XModal_nodes_tracelines.csv` | Node and traceline table | Use it to type the geometry into the Wireframe Model Editor by hand |
| `EXP3_P1_expected_shapes_on_wireframe.png` / `.csv` | Shapes I picked from the FRFs directly | Compare these against what X-Modal animates |

## Geometry (inches, z = 0, numbered row by row from the bottom-left corner)

|  | Col 1 x = 0.75 | Col 2 x = 3.60 | Col 3 x = 6.45 | Col 4 x = 9.30 | Col 5 x = 12.15 |
|---|---|---|---|---|---|
| Row 3, y = 5.125 | 11 | 12 | 13 | 14 | 15 |
| Row 2, y = 2.9375 | 6 | 7 | 8 | 9 | 10 |
| Row 1, y = 0.75 | **1 (accel)** | 2 | 3 | 4 | 5 |

Tracelines (type each list into the Tracelines field and click Add line):
`1 2 3 4 5` · `6 7 8 9 10` · `11 12 13 14 15` · `1 6 11` · `2 7 12` · `3 8 13` · `4 9 14` · `5 10 15`

## Why the raw files can't be merged as they are

Every raw file has the same labels: Response = node 2 (the accelerometer channel) and Reference = node 0 or 1 (the hammer channel). Direction is 0. These are channel numbers, not point numbers, because the Channel Dialog point numbers (quick start step 5.a) weren't changed between hits. If you merged the raw files, X-Modal would see 15 copies of the same measurement and couldn't map them onto the wireframe.

How the files fix this. The accelerometer stayed at point 1 and the hammer moved, so each file is H(1, j). By Maxwell reciprocity, H(1, j) = H(j, 1). Each FRF is therefore labelled **Response = point j, +Z** and **Reference = point 1, +Z**. That is the standard single-reference layout that Modal Parameter Estimation and the animation expect. The FRF data values are bit-for-bit unchanged; only the labels are different.

- Point 1 uses `Rect1x1.MAT`. Its median coherence is 0.91, against 0.87 for the `Rect1x1.2` repeat.
- The units block is copied from the measurements, so there's no extra "bogus" units file to delete. The coordinates are in inches. X-Modal's length factor only affects the axis labels, not the shapes.
- The coherence functions were left out of the merged files so MPE sees only FRFs. They're still in the raw files.

## Steps in X-Modal (on the UC network or VPN for the license)

1. Data Manager → **Import File** → `EXP3_P1_Accel_15pt_with_Geometry.unv`. Check that the group shows 151, 164, 15, 82 (×8) and 58 (×15).
2. Optional: open the Wireframe Model Editor to confirm you see a flat 3 × 5 grid with point 1 at the bottom-left.
3. **Modal Parameter Estimation.** Bracket about 400–2300 Hz, press start, pick the modes (the Wizard is allowed), then click Save.
4. **Group Manager → Animation.** Compare each shape with the PNG and the corner fingerprints below.

## What X-Modal should show (check our work)

| Mode | Peak (Hz) | NX (Hz) | Check in the animation |
|---|---|---|---|
| (3,1) 1st bending | ~451 | 451.6 | All four corners move together. Columns 2–4 move opposite the ends |
| (2,2) 1st twist | 601.6 | 597.4 | Diagonal corners move together. Middle row and center column are about 0 |
| (4,1) 2nd bending | 1242 | 1245.5 | The left end is opposite the right end. The center column is about 0 |
| (3,2) bend + twist | 1293 | 1295.1 | The bottom row is opposite the top row. The middle row is about 0 |
| (1,3) cross bending | ~2160–2172 | 2158.7 | The middle row is opposite the outer rows. The peak-pick is messy because it's only about 1.5 % from the next mode, so **use the curve fit here** |
| (4,2) 2nd bend + twist | 2195 | 2198.2 | Like (4,1) but antisymmetric top to bottom. The middle row is about 0 |

If an animated shape looks scrambled, check node labels before anything else. The geometry is fine if the undeformed grid looks right.

## Result of the X-Modal run (2026-10-13, 14:03)

These settings are the defaults, not values tuned for this data. The band is 383–2352 Hz, the method is PTD (time domain, short basis, orders 2:20), and the poles were picked with the Wizard. Mode Group 1 was exported as ASCII UFF to `EXP3_P1_Accel_MPE_ModeGroup1.rpt`. That file contains the geometry and the DSN 55 mode shapes.

The MAC column compares X-Modal's shape with the shapes in `EXP3_P1_expected_shapes.csv`, which were picked independently.

| Mode | X-Modal f (Hz) | ζ (%)* | MPC | NX (Hz) | Δ vs NX | MAC |
|---|---|---|---|---|---|---|
| (3,1) 1st bending | 450.83 | 1.16 | 95.0 % | 451.6 | −0.2 % | 0.999 |
| (2,2) 1st twist | 600.20 | 1.30 | 95.7 % | 597.4 | +0.5 % | 0.999 |
| (4,1) 2nd bending | 1239.62 | 0.61 | 92.1 % | 1245.5 | −0.5 % | 0.995 |
| (3,2) bend + twist | 1294.91 | 0.73 | 93.7 % | 1295.1 | −0.0 % | 0.998 |
| (4,2) 2nd bend + twist | 2196.15 | 0.50 | 88.3 % | 2198.2 | −0.1 % | 0.998 |

*Damping still includes the force/exponential window's added damping (the lecture says to ignore it this time).

- The auto-MAC between the five X-Modal modes is about 0 off the diagonal, so they are distinct modes.
- The node pattern matches NX: the middle row stays at about 0 for (2,2), (3,2) and (4,2), and the center column stays at about 0 for (2,2) and (4,1).
- **Not fit:** the (1,3) cross-bending mode, NX 2158.7 Hz. In the consistency diagram it shows only as frequency-stable poles near 2180 Hz, so the Wizard skipped it. To try for it, pick that column by hand or narrow the band to about 2100–2250 Hz with a higher model order.
