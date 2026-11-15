# EXP3 Day 2: X-Modal wireframes for P2 (L plate) and P3 (frame)

Built 2026-10-20 from the Day 2 test plan (`Output/EXP3/Day2_Plan`). These files use the same format as `EXP3_P1_Geometry_3x5.unv`, which imported correctly into X-Modal on 10/13: datasets 151 (header), 164 (units), 15 (nodes) and 82 (tracelines).

## Files

| File | Use for | What's inside |
|---|---|---|
| `EXP3_P2_Geometry_T3_Full18.unv` | **T3**, P2 accelerometer full grid | Nodes 1–18 (hits), 19 (accelerometer A), 20 (mic M, 1 in up); 9 tracelines |
| `EXP3_P2_Geometry_T4_MicPartial6.unv` | **T4**, P2 mic partial | Nodes 1, 2, 5, 10, 11, 18 plus 19 and 20; one closed loop |
| `EXP3_P3_Geometry_T5T6_Partial6.unv` | **T5 and T6**, P3 accelerometer and mic partials | Nodes 1–6 (hits), 7 (accelerometer A), 8 (mic M, 1 in up); one closed ring |
| `EXP3_Day2_XModal_nodes_tracelines.csv` | Typing the geometry in by hand, if an import fails | Node and traceline tables for all three |
| `EXP3_P2_expected_shapes_on_wireframe.png` / `EXP3_P3_…png` | Checking the animation | NX shapes drawn on these wireframes |

Use the 6-point file for T4, not the full grid. If you use the full grid, the 12 nodes you didn't hit sit at zero in the animation and make the shape look wrong.

## Coordinates

All coordinates are in inches, with z up.

- **P2:** x is measured from the short left end. y = 5.236 − d, where d is the setup map's distance from the long straight edge. This makes the long straight edge the top of the view, the same as the setup map and NX. Node 1 is at the top-left.
- **P3:** x is measured from the left end (the wide 6.8 in band). y is measured from the near long edge (the wide 4.1 in band). Node 1 is the bottom-left corner, and the numbering goes counter-clockwise around the ring.
- **Sensor nodes:** the accelerometer and mic nodes stand alone, with no tracelines. They show where each sensor was without pulling on the animated shape. The mic node is drawn at z = +1 in.

## Channel Dialog: set these before every hit

| Test | Ch 1, hammer | Ch 2, sensor |
|---|---|---|
| T3 P2 accel | hit node 1–18, **−Z** | 19, **+Z** |
| T4 P2 mic | hit node 1, 2, 5, 10, 11 or 18, −Z | 20, +Z |
| T6 P3 mic | hit node 1–6, −Z | 8, +Z |
| T5 P3 accel | hit node 1–6, −Z | 7, +Z |

This follows the 10/13 briefing: point number and direction for every hit, accelerometer +Z, hammer −Z. With these labels set, the files map straight onto the wireframe.

## Steps

1. Data Manager → File → Import → File… → choose the `.unv` for the test.
2. Check the result in Tools → Animation or the Wireframe Model Editor. You should see the flat grid or ring with the node labels where the setup map has them.
3. After taking data, copy the geometry into the same data group as the FRFs (Merge quick start, step 1). Then run Modal Parameter Estimation and animate.
4. Compare the animation with the expected-shapes PNG and the fingerprint tables in the test plan. X-Modal may show a shape flipped overall, so compare the pattern, not the sign.

## If MPE or the animation doesn't map the shapes

With the hammer roving, each test is "many inputs × 1 output." On 10/13 the P1 set was relabelled by reciprocity to "1 input × many outputs" (Response = hit node, Reference = sensor node), and X-Modal fit and animated it cleanly. If Day 2's sets don't animate, the same relabel can be done from the saved `.mat` files afterwards. The data values don't change.

## Check status

- The files parse cleanly with a UFF reader (pyuff 2.5.8).
- **Verified in X-Modal on 10/19, 8:15 PM, over the VPN.**
  - The three files import through Data Manager → File → Import → File… and are listed as 151 Header, 164 Units, 15 Nodes and 82 Trace Lines (9 tracelines for the T3 file, 1 for each of the others).
  - Tools → Animation, with Label checked, draws every wireframe with its labels in the right places:
    - **P2 grid:** the foot (16–18) is off the end.
    - **T4 loop:** 1-2-5-10-18-11, with 19 and 20 floating.
    - **P3 ring:** 7 next to corner 3, and 8 (the mic) above the bottom band.
- **Viewer note:** the View → "+Y" button gives the plan (top-down) view, rotated 90° from the setup map; "Default" is the 3D view. If Tools → Animation only reports "Animation closed", click it again.

## T3 data, ready to import (built 2026-10-20 after Lab Day 2)

The raw `LabDay2/LPlate/Acc{r}x{c}.mat` files were saved with the default channel labels (Response = CHAN 2, Reference = CHAN 1), so they were relabelled the same way as P1:

- File map: `Acc{r}x{c}` → point (r−1)·5 + c (rows 1–3 = pts 1–15, row 4 = foot pts 16–18). Confirmed by MAC vs NX (≥ 0.98 for all six modes).
- Each FRF relabelled by reciprocity: **Response = PT j (+Z), Reference = PT 19 (+Z)**. Data values unchanged (checked to machine precision).

| File | What it is |
|---|---|
| `EXP3_P2_Accel_18pt_with_Geometry.unv` | T3 wireframe (nodes 1–20, 9 tracelines) + 18 FRFs. Import this one. |
| `EXP3_P2_Accel_18pt_Merged.mat` | Same 18 relabelled FRFs in the X-Modal .mat layout (no geometry) |

X-Modal steps: Data Manager → File → Import → File… → the `.unv` → MPE (PTD), band ≈ 330–2350 Hz → Wizard pick → animate. Expect 7 modes near 379 / 578 / 1033 / 1306 / 1725 / 2056 / 2247 Hz (see `Output/EXP3/Day2_P2_Accel/`).
