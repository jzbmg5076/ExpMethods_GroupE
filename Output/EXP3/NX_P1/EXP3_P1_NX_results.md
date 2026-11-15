# EXP3 — Steel rectangle (P1), NX modal simulation

Built 2026-10-13 from the Canvas *Presentation for Siemens NX – Modal Analysis* and the 10/05 and 10/07 lectures.

## Files (Lab Data/EXP3/NX)

- `SteelRectagle.prt`: your part. The only change is that AISI_SS_304-Annealed is now assigned to the body (Tools → Assign Materials).
- `SteelRectagle_fem1.fem` / `_fem1_i.prt`: CTETRA(10) 3D tet mesh, 0.2 in element size (≈ the tutorial's 5 mm). Material is inherited from the part.
- `SteelRectagle_sim1.sim`: solution **FreeFree_Modal**, SOL 103 Real Eigenvalues, Lanczos with **12 modes** (object `Lanczos_12modes`).
- `steelrectagle_sim1-freefree_modal.*`: Nastran outputs. The `.f06` has the eigenvalue table.

## Setup choices and the source behind each

| Step | What was done | Why |
|---|---|---|
| Geometry | Used your part as-is: 12.95 × 5.93 × 0.381 in, 12 × Ø0.18 in holes | You asked to start from this part |
| Material | AISI_SS_304-Annealed (NX library): E = 27.56 Mpsi (190 GPa), ρ = 7900 kg/m³, ν = 0.30 | Measured density from Plate Specs (3.733 kg over your measured volume) is about 7980 kg/m³, which is stainless |
| Mesh | 3D tetrahedral, CTETRA10, 0.2 in (28,000 elements) | Presentation recommends 5 mm |
| Boundary condition | **None.** Free-free, with no fixed face | 10/05 lecture: take the tutorial's cantilever constraint off |
| Modes requested | 12 | 10/05 lecture: modes 1–6 are rigid-body at ≈0 Hz, so asking for 12 gives about six deformation modes |
| Added mass | Not used | 10/05 lecture, Canvas walkthrough: "if you need to add mass to your model… I don't think we need that." The accelerometer is a few grams on a 3.7 kg plate |
| Springs | **Not yet used. This version is the ideal free-free case.** | Correction: the "don't need" remark in the 10/05 Canvas walkthrough was about added mass, not springs. The lecture treats springs as the realistic support model: "go to a soft support, and then in the FEA, add soft springs" and "How do you model the supports? That's the springs to ground." A corner-spring version still needs to be built (see the sensitivity section below) |

## Results

The NX model is **not tuned to any test data**. It uses nominal library material and your part geometry. The test column below uses **all 15 grid points** (accelerometer fixed at pt 1, hammer roved). The MAC values compare the measured shape directly with the NX shape at those 15 points (1.0 = identical).

| NX mode | NX f (Hz) | Shape (Blevins ij) | Test, full grid (Hz) | Test vs NX | MAC vs NX | Blevins (Hz)* |
|---|---|---|---|---|---|---|
| 1–6 | ≤ 0.001 | rigid body | ~39 Hz support bounce | — | — | — |
| 7 | 451.6 | (31) 1st bending along length | 453.1 | +0.3 % | 0.996 | 458 |
| 8 | 597.4 | (22) 1st twist | 601.6 | +0.7 % | 0.994 | 616 |
| 9 | 1245.5 | (41) 2nd bending along length | 1242.2 | −0.3 % | 0.94† | 1260 |
| 10 | 1295.1 | (32) bending + twist | 1293.0 | −0.2 % | 0.99 | 1353 |
| 11 | 2158.7 | (13) bending across the width | 2175.8 (middle row) | +0.8 % | 0.997‡ | — |
| 12 | 2198.2 | (42) 2nd bending + twist | 2195.3 | −0.1 % | 0.98 | — |

Cross-MAC between different modes is ≤ 0.05, so no two test modes are confused with each other.

†(41) is only 51 Hz from (32), and that neighbor pulls on its shape. An X-Modal curve fit should separate the two.

‡(13) is masked by (42) on the outer rows. The MAC is computed on the middle row only (pts 6–10), where (42) is nodal. A two-mode fit, (13) + (42), explains 96 % of all 15 FRFs at that frequency.

The first point-1-only comparison gave (41) at 1238 Hz. The full grid puts it at 1242 Hz, because the (32) overlap shifts the pt 1 peak.

\*Blevins was computed with the Plate Specs inputs: a = 12.9, b = 5.875, h = 0.378 in mean, SS304 at 193 GPa and 8000 kg/m³, with linear interpolation between a/b = 1.5 and 2.5. The (32) value is the weakest (+4 %) because its λ² changes the most with a/b, which the 10/07 lecture warned about.

**Mesh check.** I re-ran with a 0.125 in mesh (94,277 elements). Every frequency changed by 0.07 % or less: 451.6 / 597.0 / 1245.5 / 1294.2 / 2159.4 / 2196.8 Hz. The 0.2 in mesh is converged. I kept 0.2 in because the finer run wrote a 650 MB .op2 file.

**Shape check.** The corner pattern for each mode matches the fingerprint in the lab guide:

- (31): all four corners move the same way.
- (22): diagonal corners move together.
- (41): the left end is opposite the right end.
- (32): the bottom edge is opposite the top edge.

## Support sensitivity: what corner springs would do (estimate, not yet run in NX)

On Day 1 the balls sat at the **four corners**, where the modes move the most. I sized one spring per corner so the plate bounces at the measured ~39 Hz:

k = M(2π·39)²/4 ≈ 323 lbf/in, or about 57 kN/m per corner.

I then used the NX mode shapes to estimate how much each elastic mode would rise:

| Ball contact point | (31) | (22) | (41) | (32) | (13) | (42) |
|---|---|---|---|---|---|---|
| 0.25 in from the corner | +1.2 % | +1.2 % | +0.1 % | +0.3 % | 0.0 % | +0.1 % |
| 0.5 in | +0.9 % | +0.9 % | +0.1 % | +0.2 % | 0.0 % | +0.1 % |
| 1.0 in | +0.6 % | +0.6 % | 0.0 % | +0.1 % | 0.0 % | 0.0 % |

The supports matter at the ~1 % level for the first two modes only. That is the same size as the test-vs-NX gaps and as the thickness question (0.381 vs 0.378 in, about −0.8 %). The proper check in NX is a second solution with CELAS1 springs at the 4 corners, following the Canvas spring tutorial.

## Things the model tells you about the hit grid (3 × 5, 0.75 in inset)

- **Middle row (pts 6–10)** sits on a nodal line for modes 8, 10 and 12. Hits there will not show those modes. That is expected, not bad data.
- **Center column (pts 3, 8, 13)** is nodal for modes 8, 9 and 12.
- **Modes 11 and 12 are only about 1–2 % apart.** At pt 1 the mode 11 amplitude is low: 0.27 compared with 0.51 for mode 12. That is why pt 1 shows a single peak near 2199 Hz. The middle-row hits (pts 6–10) do show mode 11 by itself at 2176 Hz.
- The **2512 Hz** peak in the Day 1 data is above NX mode 12. Blevins (51) predicts about 2490 Hz, so it is most likely the 3rd bending mode (NX mode 13). Requesting 14 modes would confirm it.

## Open items

1. **Plate Specs, Material (B7)** still says *Aluminum 6061-T6*. Change it to *Stainless steel 304*, because the Blevins sheet reads from this cell.
2. **Dimensions disagree.** Plate Specs has 12.9 × 5.875 in, which are the EXP1 example values. The NX part is 12.95 × 5.93 in. Which one is the measured steel plate?
3. **Thickness.** The NX part is 0.381 in. The measured mean is 0.378 in, a 0.8 % difference, and f scales directly with h, so NX would drop about 0.8 %. NX mass is 3.773 kg against 3.733 kg measured (+1.1 %), which points the same way.
4. NX's SS304 modulus is 27.56 Mpsi. The lecture's "30 Mpsi" is a carbon-steel value. The NX vs experiment agreement supports the roughly 28 Mpsi stainless value.
5. The FEM has two empty mesh collectors, Solid(1) and Solid(2), left over from the mesh check. They are harmless and can be deleted. The live mesh is in Solid(3).
