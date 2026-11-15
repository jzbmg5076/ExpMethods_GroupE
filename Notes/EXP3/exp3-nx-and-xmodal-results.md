# EXP3 — NX models (all three plates) and X-Modal results

## NX models (built 2026-10-18 / 10-20)

Every model follows the Canvas *Presentation for Siemens NX – Modal Analysis* recipe: Pre/Post → New FEM and Simulation (Simcenter Nastran, Structural) → SOL 103 Real Eigenvalues, Lanczos, **12 modes** → 3D tetrahedral mesh (CTETRA10) → Solve. As the 10/05 lecture says, there is **no fixed face** for free-free. Corner-spring versions follow the Canvas *Spring constraint steps*.

Folders in `Lab Data/EXP3/NX`: `P1_SteelRectangle/`, `P2_LPlate/`, `P2_LPlate_Springs/`, `P3_CutoutFrame/`, `P3_CutoutFrame_Springs/`, `_journals/` (NX journal scripts used to build the spring models — paths inside must be edited to your own folder), `README_NX_Models.md`. Solver outputs (.op2/.dat/.f06/.log) are not in this package — re-solve in NX to regenerate.

### P1 steel rectangle with corner springs
1. Ground: 12.95 × 5.93 × 0.25 in block 1 in below the plate (SS304, 0.25 in tet mesh).
2. Springs: 4 × CELAS1, node-to-node from each ground top corner to the matching plate bottom corner. Direction **Z** at both ends (NX default is X — change it).
3. Spring property `PELAS_Corner_323`: k = **323 lbf/in** per corner, sized so the plate bounces at the measured ~39 Hz: k = M(2π·39)²/4.
4. Fixed constraint on the ground's top face. Plate mesh 0.2 in CTETRA10.

| Mode | Free-free (Hz) | Corner springs (Hz) | Test (Hz) | Springs vs free-free | Springs vs test |
|---|---|---|---|---|---|
| support: bounce | 0 | **38.3** | ~39 | — | −2 % |
| support: pitch / roll | 0 | 67.1 / 67.3 | — | — | — |
| (31) | 451.6 | 457.9 | 453.1 | +1.4 % | +1.1 % |
| (22) | 597.4 | 606.0 | 601.6 | +1.4 % | +0.7 % |
| (41) | 1245.5 | 1247.3 | 1242.2 | +0.1 % | +0.4 % |
| (32) | 1295.1 | 1300.0 | 1293.0 | +0.4 % | +0.5 % |
| (13) | 2158.7 | 2159.4 | 2175.8 | 0.0 % | −0.8 % |
| (42) | 2198.2 | 2201.4 | 2195.3 | +0.1 % | +0.3 % |

The test sits between free-free and corner-spring results — consistent with the balls touching a bit inboard of the true corner.

### P2 L plate and P3 cut-out frame (free-free)

| | P2 L plate | P3 cut-out frame |
|---|---|---|
| Part size (bounding box) | 15.83 × 7.80 × 0.501 in | 23.84 × 12.00 × 0.502 in |
| Material | **Aluminum 2014** (E 10.6 Mpsi, ρ 2794 kg/m³) | **Aluminum 6061** (E 10.0 Mpsi, ρ 2711 kg/m³) |
| NX mass vs scale | 4.916 vs 4.900 lb (+0.3 %) | 9.910 vs 9.900 lb (+0.1 %) |
| Mesh | 0.25 in CTETRA10 (25,141 el) | 0.25 in CTETRA10 (47,418 el) |
| Deformation modes 1–6 (Hz) | 400.4 / 599.4 / 1094.5 / 1353.4 / 1825.5 / 2155.5 | 150.1 / 159.3 / 347.1 / 428.5 / 558.8 / 706.6 |

Corner-spring results (10/20, ground 1 in below, 4 CELAS1 at outer corners, DOF Z, PELAS 323 lbf/in): P2 bounce 48.7 Hz, modes 412.7/612.7/1098.6/1360.1/1828.3/2161.0 (+3.1/+2.2/+0.4/+0.5/+0.2/+0.3 % vs free-free). P3 bounce 32.5 Hz, modes 161.0/176.3/355.5/431.0/563.8/712.0 (+7.3/+10.7/+2.4/+0.6/+0.9/+0.8 %).

## X-Modal results (organized 2026-10-20)

Root: `Output/EXP3/XModal_Results/`. Start with `00_INDEX.html`; `00_XModal_Walkthrough.html` is an illustrated step-by-step from 22 screenshots. Each test folder (`P1_SteelRectangle/Accelerometer`, `P1_SteelRectangle/Microphone`, `P2_LPlate/Accelerometer`, `P3_CutoutFrame/Accelerometer`) has a `<tag>_REPORT.html` and subfolders 01_Raw_Data → 07_NX_Comparison.

| Test | Modes (Hz; W = Wizard / H = hand pick) | Δ vs NX free-free | MAC vs NX |
|---|---|---|---|
| P1 accelerometer | 450.89 W, 600.20 W, 1239.63 W, 1294.91 W, 2174.04 H, 2196.10 W | −0.5 to +0.7 % | 0.93–0.99 |
| P1 mic redo | 453.43 H, 595.42 H, 1250.76 W, 1287.60 W, 2136.25 H, 2187.50 W, 2465.92 W | −1.0 to +0.4 % (vs corner springs: −1.7 to +0.3 %) | 0.92–0.99 |
| P2 | 379.37, 577.81, 1032.55, 1305.78, 1724.87, 2055.74, 2246.90 (all W) | −5.7 to −3.5 % | 0.98–1.00 |
| P3 | 149.83 H, 169.51 H, 346.69 W, 421.40 W, 557.11 W, 697.04 W | −1.7 to +6.4 % | 0.96–0.99 |

Hand-picked frequencies agree with an independent Python fit to within half a frequency line (±1.95 Hz). Hand-picked damping is less reliable (e.g. P3 modes 1–2: 5.1 / 5.8 % in X-Modal vs 3.5 % from Python).
