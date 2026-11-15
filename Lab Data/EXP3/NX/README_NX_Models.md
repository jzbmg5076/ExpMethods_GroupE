# EXP3 NX models — all three plates (built 2026-10-18)

Every model follows the Canvas *Presentation for Siemens NX – Modal Analysis* recipe:

- Pre/Post → New FEM and Simulation (Simcenter Nastran, Structural)
- SOL 103 Real Eigenvalues, Lanczos, **12 modes**
- 3D tetrahedral mesh (CTETRA10)
- Solve

As the 10/05 lecture says, there is **no fixed face**. P1 also gets the Canvas *Spring constraint steps*.

## Folder layout (Lab Data/EXP3/NX)

| Folder | What's in it |
|---|---|
| `P1_SteelRectangle/` | `SteelRectagle.prt` plus the new FEM/SIM with **corner springs** (solution `CornerSprings_Modal`), Nastran outputs, `Images/` |
| `P2_LPlate/` | `Experiment3_Model2.prt` plus the FEM/SIM (solution `FreeFree_Modal`), Nastran outputs, `Images/` |
| `P3_CutoutFrame/` | `Experiment3_Model3.prt` plus the FEM/SIM (solution `FreeFree_Modal`), Nastran outputs, `Images/` |
| `_Archive_P1_FreeFree_Run_2026-10-13/` | The earlier P1 free-free FEM/SIM/results that I made on 10/13, kept as the "ideal" P1 comparison |

The part files themselves were not changed. The one exception is the SS304 material assignment on `SteelRectagle.prt`, which was made on 10/13.

## P1 steel rectangle with corner springs (Canvas spring steps)

**Setup**

1. Ground: a 12.95 × 5.93 × 0.25 in block placed 1 in below the plate, added in the idealized part. It is SS304 with a 0.25 in tet mesh.
2. Springs: 4 × CELAS1, node-to-node from each ground top corner to the matching plate bottom corner.
   - Node pairs: 48972→2, 48976→19, 48978→21, 48974→3.
   - Direction is **Z (vertical)** at both ends. NX's default is X, so this had to be changed.
3. Spring property: one shared property, `PELAS_Corner_323`.
   - Translational k = **323 lbf/in** per corner, rotational = 0.
   - k was sized so the plate bounces on the springs at the measured ~39 Hz: k = M(2π·39)²/4.
4. Fixed constraint on the ground's top face.
5. Plate mesh: 0.2 in CTETRA10, the same as the archived free-free run.

**Results** (test values are from the Day 1 accelerometer full grid)

| Mode | Free-free (Hz) | Corner springs (Hz) | Test (Hz) | Springs vs free-free | Springs vs test |
|---|---|---|---|---|---|
| support: 3 in-plane | 0 | ≈0 | — | — | — |
| support: bounce | 0 | **38.3** | ~39 | — | −2 % |
| support: pitch / roll | 0 | 67.1 / 67.3 | — | — | — |
| (31) | 451.6 | 457.9 | 453.1 | +1.4 % | +1.1 % |
| (22) | 597.4 | 606.0 | 601.6 | +1.4 % | +0.7 % |
| (41) | 1245.5 | 1247.3 | 1242.2 | +0.1 % | +0.4 % |
| (32) | 1295.1 | 1300.0 | 1293.0 | +0.4 % | +0.5 % |
| (13) | 2158.7 | 2159.4 | 2175.8 | 0.0 % | −0.8 % |
| (42) | 2198.2 | 2201.4 | 2195.3 | +0.1 % | +0.3 % |

**What this shows**

- The model's bounce mode lands at 38.3 Hz, matching the measured ~39 Hz. That confirms the spring stiffness.
- Putting the springs exactly on the corners stiffens the first two modes by 1.4 %. That is a little more than the test shows: the test sits between the free-free and corner-spring results.
- This fits the balls touching a bit inboard of the true corner. My hand estimate for a 0.5–1 in inset was +0.6–0.9 %.
- The higher modes barely notice the supports.
- The springs act in Z only, so the three in-plane rigid modes stay at ~0 Hz. That is expected and harmless.

**Images (`P1_SteelRectangle/Images`)**

- `P1_model_ground_springs_fixed.png`: the model, showing the ground, springs and fixed face
- GIFs: bounce mode (mode 4) and modes 7–12. The ground is hidden in the animations so the plate is visible.

## P2 L plate and P3 cut-out frame (ideal, free-free)

| | P2 L plate | P3 cut-out frame |
|---|---|---|
| Part size (bounding box) | 15.83 × 7.80 × 0.501 in | 23.84 × 12.00 × 0.502 in |
| Material already on the part | **Aluminum 2014** (E 10.6 Mpsi, ρ 2794 kg/m³, ν 0.33) | **Aluminum 6061** (E 10.0 Mpsi, ρ 2711 kg/m³, ν 0.33) |
| NX mass vs scale | 4.916 vs 4.900 lb (+0.3 %) | 9.910 vs 9.900 lb (+0.1 %) |
| Mesh | 0.25 in CTETRA10 (25,141 elements) | 0.25 in CTETRA10 (47,418 elements) |
| Rigid modes 1–6 | ≈ 0 Hz | ≈ 0 Hz |
| Deformation mode 1 | 400.4 Hz | 150.1 Hz |
| Deformation mode 2 | 599.4 Hz | 159.3 Hz |
| Deformation mode 3 | 1094.5 Hz | 347.1 Hz |
| Deformation mode 4 | 1353.4 Hz | 428.5 Hz |
| Deformation mode 5 | 1825.5 Hz | 558.8 Hz |
| Deformation mode 6 | 2155.5 Hz | 706.6 Hz |

**Images (`Images/` in each folder)**

- Mesh image
- GIFs of modes 7–12
- `*_NX_mode_shapes.png`: top view with the nodal lines
- `*_support_map.png`: where to put the springs or balls later

**Using the support maps**

- Shading shows the largest motion over the first four deformation modes. White means the plate barely moves there.
- Red circles mark 4 quiet spots, two on each side of the center of mass. They are a starting point; shift them to where a PVC ring actually fits.
  - **P2:** ≈ (2.6, 2.0), (2.8, 3.4), (13.1, −0.5), (13.0, 3.3) in
  - **P3:** ≈ (4.5, 3.4), (4.3, 8.5), (19.1, 3.4), (20.8, 8.1) in
- All coordinates are in each part's own NX origin.

## Things to check

1. **P2 and P3 use different aluminum alloys** in the part files: 2014 and 6061. If both plates are the same stock, pick one. The choice moves the frequencies by about 1.4 %.
2. **P3's first two modes are only 6 % apart** (150 vs 159 Hz). Confirm them by shape, using the corner up/down pattern, not by order.
3. **P3 is low-frequency.** Its first mode is about 4× the ~39 Hz support bounce, where P1's is about 12×. Support placement will matter more for P3, so put its springs on the quiet spots and not at the corners.
4. P1's spring model can be refined later by moving the springs inboard to where the balls actually touch (measure this on Day 2). Right now it brackets the test frequencies together with the free-free model.

## P2 and P3 with corner springs (built 2026-10-20)

New folders `P2_LPlate_Springs/` and `P3_CutoutFrame_Springs/` are copies of the free-free models with the Canvas *Spring constraint steps* added, same recipe as P1. The original `P2_LPlate/` and `P3_CutoutFrame/` folders were not touched.

Setup (both plates):

1. Ground: a 0.25 in block 1 in below the plate, added in the idealized part (`GROUND_BLOCK`), meshed 0.25 in CTETRA10 in its own collector `Ground_Solid` (PSOLID2, same aluminum as the plate).
2. Springs: 4 x CELAS1 from 1D Connection, node to node, ground top to plate bottom corner, collector `Corner_Springs`. DOF Z (3) at both ends.
3. Property `PELAS_Corner_323`: k = 323 lbf/in per corner (same balls as P1), rotation 0.
4. `Fixed_Ground` fixed constraint on all 6 ground faces. Solution renamed `CornerSprings_Modal` (SOL 103, Lanczos, 12 modes).

Spring node pairs (ground -> plate):

- P2: 44097->2 (0,0), 44021->3 (0,5.236), 44025->19 (15.826,5.236), 44023->35 (15.826,-2.564). The L has 5 outside corners; the inside one at the foot (10.98,-2.56) has no spring. The ground node for the (0,0) corner sits 0.05 in off in y (scalar spring, so no effect).
- P3: 83067->2, 83069->3, 83073->29, 83071->27 (the 4 outer corners).

Results (Hz). Test = Day 2 accelerometer fits.

| Mode | P2 free-free | P2 springs | shift | P2 test | P3 free-free | P3 springs | shift | P3 test |
|---|---|---|---|---|---|---|---|---|
| bounce / pitch / roll | 0 | 48.7 / 83.8 / 91.5 | | ~23-43 | 0 | 32.5 / 52.9 / 55.7 | | |
| 1 | 400.4 | 412.7 | +3.1 % | 379.3 | 150.1 | 161.0 | +7.3 % | 151.8 |
| 2 | 599.4 | 612.7 | +2.2 % | 577.9 | 159.3 | 176.3 | +10.7 % | 167.8 |
| 3 | 1094.5 | 1098.6 | +0.4 % | 1032.7 | 347.1 | 355.5 | +2.4 % | 346.8 |
| 4 | 1353.4 | 1360.1 | +0.5 % | 1305.7 | 428.5 | 431.0 | +0.6 % | 421.0 |
| 5 | 1825.5 | 1828.3 | +0.2 % | 1724.8 | 558.8 | 563.8 | +0.9 % | 557.1 |
| 6 | 2155.5 | 2161.0 | +0.3 % | 2055.7 | 706.6 | 712.0 | +0.8 % | 698.5 |

Notes:

- Modes are listed by order; with P3's close 1/2 pair, check shapes before matching.
- Exact-corner springs raise P3 modes 1-2 a lot (+7 to +11 %). The test sits between free-free and springs, like P1, because real balls touch inboard of the corner.
- P2 test is below both models (-4 to -8 % vs springs); that gap is stiffness/geometry (see Day 2 P2 notes), not the supports.
- Journals used to build these are in `_journals/` (NXOpen Python, run from Developer > Play).
- Mode GIFs and a model image were added on 2026-10-26 (see below).

## P2 and P3 corner-spring images (captured 2026-10-26)

Captured in NX 2512 from the existing `CornerSprings_Modal` results (nothing re-solved, no NX file saved). Each `Images/` folder now has:

- `P#_model_ground_springs_fixed.png`: plate, ground block, corner springs and fixed constraint, NX isometric view (same style as P1's).
- `P#_springs_mode04_*Hz_bounce.gif` and `P#_springs_mode07..12_*Hz.gif`: NX animations, Z displacement, 10% model deformation, ground mesh hidden, 12 frames from +max to -max.
- The animations use X-Modal's camera angle (looking from the +x,+y corner, 45 degrees down) so they can sit directly under the X-Modal test GIFs. That angle puts P2's foot at the top left of the picture.
- Deck-ready loops (frames forward then back, 720 px wide) are in `Report/03_Models_NX_and_Blevins/P2_NX/CornerSprings` and `P3_NX/CornerSprings`.
- The journals that made them are in `Sandbox/Claude/exp3_rev3_work/nx/` (`capture_v2_template.py`).
