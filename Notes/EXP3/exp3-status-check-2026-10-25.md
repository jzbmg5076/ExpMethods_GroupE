# EXP3 status check and presentation plan (2026-10-25)

Checked against every EXP3 note and the ExperimentalMethods folder (Lab Data/EXP3, Output/EXP3, Canvas/EXP3, Transcripts, MEMORY.md). Lab Day 1 was Tue 10/13 and Lab Day 2 was Tue 10/20.

## Group decisions (2026-10-25)

- **Report format: in-person presentation.** Guidelines: about 10 min at roughly 1 slide per minute. Flow is cover → purpose/objective → results that lead to the conclusion → conclusion → recommendations → questions, plus an optional blank slide. Use slide numbers and no large tables.
- **Charts must come from MATLAB only.** Photos, X-Modal animations/screenshots and NX images are fine as they are.
- **No mic tests needed on P2/P3.** This matches the Day 1 in-lab briefing: the rectangle gets full accel + full mic + NX + Blevins, and the other plates get one experimental test with either sensor + NX.
- **P2/P3 NX alloys** (Al 2014 / Al 6061) were chosen because they best matched the measured plate weights.
- **P1 Day 2 mic position** was the Day 2 plan spot: 1 in above (8.0, 5.25) in, on the far long edge between pts 13 and 14. It wasn't separately recorded; the Day 2 photos agree with it (see below).
- **Day 2 photos:** 7 photos saved to `Lab Data/EXP3/Photos` and `Report/01_Plates_and_Photos/Day2_Photos` under descriptive names.
- **Tracking workbook dropped.** The NX parts carry the measurements. The only measured data that lives only in the workbook is P1's six thickness readings: 0.3745–0.381 in, mean 0.378 in.

## Presentation deck (built 2026-10-25; superseded by REV3 — see exp3-presentation-rev3.md)

- **File:** `Lab Data/EXP3/Report/EXP3_GroupE_Presentation.pptx` (the original is in `Report/OLD/`, not included in this package). 14 slides plus 8 hidden backup slides (15–22). Each slide has short talking points in its speaker notes. GIFs animate only in slideshow mode. To show a hidden backup during questions, type its number and press Enter.
- **Every chart is from MATLAB.** `Report/11_MATLAB_Charts/make_exp3_presentation_charts.m` makes all 8 charts (C1–C8) from the `09_Data_Tables` CSVs and the raw X-Modal `.mat` files in `LabDay1`/`LabDay2`. It was run in MATLAB R2022b ("8 charts written, 0 failed") and also writes `chart_numbers.csv`. Every other visual is a lab photo, an X-Modal GIF or screenshot, or an NX image.
- **Possible presenter split:** slides 2–4, 5–7, 8–11.

## Report media folder (built 2026-10-25)

- `Lab Data/EXP3/Report/` holds copies of every EXP3 photo, X-Modal mode animation (GIF/MOV/still), NX image, comparison plot, X-Modal screenshot and result CSV, plus the Day 2 photos, the MATLAB chart folder and the deck.
- **Folders:** 01 plates/photos · 02 setup · 03 models (NX + Blevins) · 04 P1, 05 P2, 06 P3 · 07–08 backup (X-Modal process, coherence/raw FRFs) · 09 data tables · 10 reference · 11 MATLAB charts
- **`README.md`** maps each folder to the deck slides that use it. **`_manifest.csv`** lists each file's source and who made it.
- **Broken copy in `XModal_Results`:** `Output/EXP3/XModal_Results/P3_CutoutFrame/.../P3_T5_Mode4_421Hz.mov` is cut off at 128 KiB and won't play. The Report copy comes from `Output/EXP3/Day2_P3_Accel/XModal_Figures/` and plays.

## Day 2 photo check (by eye from the photos)

- **P1 mic redo:** mic hangs from the K'nex stand near the far long edge (pts 11–15 side), between pts 13 and 14 — matches the planned (8.0, 5.25) in spot within ~0.5 in, tip ~1 in above the plate. Tennis balls under all four corners (two blue, one pink, one green). Day 1 used a different mix of balls — a plausible cause of the <1 % Day 1 (accel) vs Day 2 (mic) frequency shifts.
- **P2:** accelerometer waxed on the long straight edge ~6.7 in from the short end (planned (6.75, 0.75) in). Grid labels: 1–5 along the straight edge, 6–10 middle, 11–15 inner row, 16–18 on the foot. Ball positions not visible.
- **P3:** points 1–8 labeled as tested. Tennis balls at the corners by pts 1 and 3; a PVC ring visible through the cut-out near pt 8. These corner supports are behind mode 2's +6.4 %. Accelerometer spot (planned (23.1, 2.1) in) not visible.

## Status matrix

| | P1 SS304 rectangle | P2 Al L plate | P3 Al cut-out frame |
|---|---|---|---|
| Analytical (Blevins) | Done: 458 / 616 / 1260 / 1353 Hz | n/a (rectangle only) | n/a |
| NX free-free | Done, mesh-checked | Done (Al 2014, weight-matched) | Done (Al 6061, weight-matched) |
| NX corner springs | Done (bounce 38.3 Hz vs ~39 measured) | Done | Done |
| Accelerometer | T1 full, 15 pts, Day 1 | T3 full, 18 pts, Day 2 | T5, 8 pts, Day 2 |
| Microphone | T2 full, 15 pts, Day 2 redo at (8.0, 5.25) in, 1 in up. The Day 1 centered set is supporting | Not needed | Not needed |
| X-Modal fit + NX comparison | Done for both sensors | Done | Done |

## Headline results (X-Modal f in Hz; Δ is vs NX free-free unless noted)

- **P1 accelerometer:** 450.89 / 600.20 / 1239.63 / 1294.91 / 2174.04 / 2196.10. Δ −0.5 to +0.7 %, MAC 0.93–0.99.
- **P1 mic redo:** 453.43 / 595.42 / 1250.76 / 1287.60 / 2136.25 / 2187.50, plus 2465.92 as a possible mode. Δ −1.0 to +0.4 % (−1.7 to +0.3 % vs corner springs), MAC 0.92–0.99. Five of six modes agree with the accelerometer within 0.9 %; (1,3) is off by −1.7 %.
- **P1 Blevins vs test:** test is 1.5–4.3 % below Blevins, worst on (32), where the a/b interpolation matters most (10/07 lecture).
- **P1 Day 1 centered mic:** heard only the center-symmetric modes. The off-center Day 2 spot heard all six, as predicted.
- **P2:** 379.37 / 577.81 / 1032.55 / 1305.78 / 1724.87 / 2055.74 / 2246.90. Every mode 3.5–5.7 % below NX; MAC 0.98–1.00.
- **P3:** 149.83 / 169.51 / 346.69 / 421.40 / 557.11 / 697.04. All within 1.7 % of NX except mode 2 at +6.4 % (tennis balls at corners; the corner-spring NX model, 176.3 Hz, brackets it). MAC 0.96–0.99.

## P2 gap analysis

- Modes 1 and 3 are bending along the length (gaps −5.3 / −5.7 %). Modes 2 and 4 are twist-type (−3.6 / −3.5 %). Mode 5 foot-dominated (−5.5 %), mode 6 −4.6 %.
- A uniform thickness or E/ρ error shifts every mode by the same percent, so the split points at the planform. Going from Al 2014 to 6061 lowers f by only 1.4 %.
- Bending scales as 1/L², twist as 1/(L·W) → bending drop = U + 2ε, twist drop = U + ε → ε ≈ 1.9 % (length), U ≈ 1.7 % (≈ the 2014 → 6061 effect). A 6061 plate ~2 % longer than the NX part (≈16.1 vs 15.83 in) would weigh 4.86 lb vs 4.90 lb on the scale.
- Ruled out by weight: a uniformly thinner + narrower plate.
- **Check:** re-measure the L's overall and leg lengths. Otherwise present this as the leading explanation.

## Open items (as of 10/25)

1. Click through the deck in slideshow mode on the presenting computer; decide presenters; rehearse to ~10 min.
2. P2 ball positions and the P3 accelerometer spot are not visible in any photo (minor).
3. Q&A prep: P3 was an 8-point test (separated all six modes, MAC ≥ 0.96); P1 (1,3) differs accel vs mic by 1.7 % (different days, different balls); Blevins (32) is +4.3 %.
4. **Damping is inflated** by the window and the 3.9 Hz line spacing. Report frequencies and shapes, caveat ζ.
