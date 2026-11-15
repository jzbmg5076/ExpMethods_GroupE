# EXP3 presentation REV3 (built 2026-10-26, from Group E's REV2)

File: `Lab Data/EXP3/Report/EXP3_GroupE_Presentation_REV3.pptx` (16 slides + 7 hidden backups). REV2 was not changed.

## What was asked for and what changed

| Request | Done |
|---|---|
| Why P2/P3 charts differed from P1, and why the mode counts differed | Old C4/C5 were each built to argue one point (L-plate: bending vs twist split; frame: test between the two NX versions) and showed all six fitted modes. C1 shows four because the lab asks for the first four modes and Blevins only covers four. |
| Make P2/P3 charts like P1's, minus the hand calc | MATLAB script updated and re-run (8 charts, 0 failed). New `C4_Lplate_vs_NX.png` and `C5_frame_vs_NX.png`: same layout as C1 (NX free-free = 0, ±1% band, accelerometer circles), modes 1–4. |
| NX visuals of P2/P3 with springs | Captured in NX from the CornerSprings_Modal results: model image + bounce + modes 7–12 GIFs per plate. Camera set to X-Modal's angle (+x,+y corner, 45° down). |
| L-plate setup image missing | Day 2 photo added to the L-plate frequency slide. |
| Same structure as P1 | Each plate has a frequency slide (chart + table Mode/NX/NX springs/Accel. + photo) and a shapes slide (X-Modal GIFs above NX GIFs, Test/NX/MAC under each). |
| Remove recommendation 4 | Removed "Same day, same setup"; renumbered 1–5. |
| NX animation on the Questions slide | Measured X-Modal GIF + NX corner-spring GIF of rectangle mode 2. |

## Slide order (REV3)

1 Title · 2 Objective · 3 Setup · 4 Hits to modes · 5 Models · 6 P1 frequencies · 7 P1 shapes · 8 Accel vs mic · 9 P2 frequencies · 10 P2 shapes · 11 P3 frequencies · 12 P3 shapes · 13 Conclusions · 14 Recommendations · 15 Questions · 16 Blank · 17–23 hidden backups.

## Mode names (from the NX nodal-line maps)

- P2: 1 1st bending, 2 1st twist, 3 2nd bending, 4 bend + twist (same order as P1).
- P3: 1 1st bending (all corners together), 2 1st twist (diagonal corners), 3 bend + twist (long edges opposite), 4 2nd bending (ends opposite).

## Orientation questions

- **L-plate "starts from the top":** X-Modal's camera looks from the corner past point 5 toward point 11, so the far end is at the top of the picture and the foot of the L sticks up at the top left.
- **Cut-out "in the center":** X-Modal's P3 model is only the 8 rim points, so it draws a plain rectangle. The real and NX cut-outs are both off-center: ~6.8 vs 3.1 in from the two ends (closer to the 3-5-8 end) and 4.1 vs 1.9 in from the long edges (closer to the 6-7-8 edge).

## Flags left for Group E

1. Slide 5 says the materials are "304 steel, Al 2014, Al 2014". The frame's NX model is Al 6061.
2. Conclusions (slide 13) say the L-plate's NX *width* is the likely cause; slide 9 and backup slide 20 say the part is ~2% too *short* (length).
3. C6 (conclusions chart) still shows six modes per plate; the per-plate charts show four.
4. Talk length: 14 content slides plus Questions/blank, at ~1 slide per minute.

## Files

- `NX/P2_LPlate_Springs/Images`, `NX/P3_CutoutFrame_Springs/Images`: raw NX captures.
- `Report/03_Models_NX_and_Blevins/P2_NX/CornerSprings`, `P3_NX/CornerSprings`: deck-ready loops + model PNGs.
- `Report/11_MATLAB_Charts`: C1–C8 charts and script.
