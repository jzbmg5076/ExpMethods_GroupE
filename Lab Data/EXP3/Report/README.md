# EXP3 Report media - Group E (in-person presentation)

Everything visual from EXP3 in one place: lab photos, X-Modal mode animations, NX model images, comparison plots, X-Modal screenshots, and the result tables. Put together 2026-10-25.

**The current presentation is `EXP3_GroupE_Presentation_REV3.pptx`** (in this folder): 16 slides plus 7 hidden backup slides, with short talking points in the speaker notes. `EXP3_GroupE_Presentation_REV2.pptx` is Group E's revision it was built from, and `OLD/EXP3_GroupE_Presentation.pptx` is the first version. Every chart was made in MATLAB (`11_MATLAB_Charts`). Everything else on the slides is a lab photo, an X-Modal animation or screenshot, or an NX image.

- **These are copies.** The originals are still in `Lab Data/EXP3` and `Output/EXP3`, so nothing that points at them breaks.
- **Folders are numbered roughly in talk order.** The Deck slides column below lists the REV3 slides that use each folder (17-23 are the hidden backups).
- **`_manifest.csv`** lists all 292 files with where each came from and who made it.

## Folder to slide

| Folder | Deck slides | Files | What's in it |
|---|---|---|---|
| `01_Plates_and_Photos` | 1-3, 8, 9, 11, 20, 23 | 17 | Day 1 and Day 2 setup photos, plate weight photos |
| `02_Test_Setup` | - | 11 | Setup schematic, hit-point maps for all four tests, Day 2 planned setup maps, pre-lab setup / hammer / mic-distance figures |
| `03_Models_NX_and_Blevins` | 5, 7, 10, 12, 15, 19 | 70 | NX images for each plate (free-free and corner springs), NX shapes drawn on the test grids, Blevins and theory figures |
| `04_P1_Steel_Rectangle` | 7, 15 | 50 | Accelerometer (Day 1) and mic redo (Day 2) mode animations, all-modes panels, NX comparison plots, and the Day 1 centered-mic set |
| `05_P2_Aluminum_L_Plate` | 10 | 25 | Mode animations, all-modes panel, NX comparison plots |
| `06_P3_Aluminum_Frame` | 12 | 22 | Mode animations, all-modes panel, NX comparison plots |
| `07_Backup_XModal_Process` | 18 | 36 | X-Modal walkthrough screenshots, consistency diagrams, curve-fit overlays, hand-pick vs Wizard plots |
| `08_Backup_Coherence_and_Raw_FRFs` | - | 18 | Coherence and raw FRF plots for every test |
| `09_Data_Tables` | 6, 9, 11, 21, 22 (and every MATLAB chart) | 16 | X-Modal mode tables, NX comparisons, MAC, grid points (CSV), for building your own charts |
| `10_Reference` | - | 11 | Day 1 recap PDF, pre-lab guide PDF, and the rest of the pre-lab figures |
| `11_MATLAB_Charts` | 4, 6, 8, 9, 11, 13, 17 | 13 | The charts in the deck, the MATLAB script that makes them, and the numbers they plot |

## What each slide uses

| Slide | Topic | Visuals |
|---|---|---|
| 1 | Title | Day 2 photo of the rectangle under the mic stand |
| 2 | Objective and the three plates | Plate weight photos |
| 3 | Test setup | Day 1 photos (supports, mic, hammer) |
| 4 | From hits to modes | MATLAB C3: one hit's frequency response and coherence |
| 5 | Models | NX model images: all three plates on corner springs to a fixed block |
| 6 | Rectangle frequencies | MATLAB C1: Blevins and both sensors vs NX, plus a table |
| 7 | Rectangle shapes | X-Modal mode GIFs (accelerometer) above the NX corner-spring GIFs |
| 8 | Accelerometer vs mic | MATLAB C2: mic centered (Day 1) vs moved (Day 2), plus both mic photos |
| 9 | L-plate frequencies | MATLAB C4 (same layout as C1, no hand calc), table, Day 2 setup photo |
| 10 | L-plate shapes | X-Modal mode GIFs above NX corner-spring GIFs (same viewing angle as X-Modal) |
| 11 | Frame frequencies | MATLAB C5 (same layout as C1, no hand calc), table, Day 2 setup photo |
| 12 | Frame shapes | X-Modal mode GIFs above NX corner-spring GIFs (same viewing angle as X-Modal) |
| 13 | Conclusions | MATLAB C6: every plate and sensor vs NX |
| 14 | Recommendations | Five text cards |
| 15 | Questions | X-Modal GIF and NX GIF of rectangle mode 2 |
| 16 | Blank end slide | Stops the show before the backups |
| 17-23 | Hidden backups | MATLAB C8 (coherence), X-Modal screenshots, NX model details, L-plate dimension check, full frequency tables, Day 2 setup photos |

- **Hidden slides are skipped in the slideshow.** To pull one up during questions, type its number and press Enter.
- **GIFs only move in slideshow mode,** not in the editing view.

## Mode animations: which format to use

Each measured mode comes three ways, named `<test>_Mode<N>_<freq>Hz`:

- `.gif` loops by itself in a PowerPoint slideshow (Insert > Pictures). Easiest for slides.
- `.mov` is the sharper video exported from X-Modal (Insert > Video > This Device).
- `_iso.png` is a still frame, for a static slide or handout.

The GIFs, stills and `_00_AllModes_panel.png` images were made from the X-Modal MOVs.

## Things to know

- **All charts in the deck come from `11_MATLAB_Charts/make_exp3_presentation_charts.m`.** It reads the CSVs in `09_Data_Tables` and the raw X-Modal `.mat` files in `Lab Data/EXP3/LabDay1` and `LabDay2`, then writes the 8 PNGs, `chart_numbers.csv` and `chart_log.txt` into `11_MATLAB_Charts`. Run it in MATLAB with no inputs to remake them.
- **The Python plots in folders 04-08 are not in the deck,** since the deck's charts are MATLAB only. They're still handy for checking numbers.
- **Day 2 photos (7)** are in `01_Plates_and_Photos/Day2_Photos`, with a README describing each one.
- **The pre-lab figures (`LabGuide_*`) were made before testing** with planning numbers (aluminum, 0.50 in thick). Use them for concepts, not results.
- **The P1 free-free images in `03_.../P1_NX/FreeFree/Renders` are renders made from the NX result files**, not screenshots taken in NX.
- **P2 and P3 corner-spring images (added 2026-10-26)** are in `03_.../P2_NX/CornerSprings` and `P3_NX/CornerSprings`: a model image (plate, springs, ground block, fixed constraint) and GIFs of the bounce mode and modes 7-12. They were captured in NX with the ground hidden and the camera turned to X-Modal's viewing angle (looking from the +x,+y corner, 45 degrees down), so they line up with the test animations. The raw 12-frame NX captures are in `Lab Data/EXP3/NX/P2_LPlate_Springs/Images` and `P3_CutoutFrame_Springs/Images`; the copies here loop forward then back and are 720 px wide.
- **`P3_NX_shapes_on_planned_6pt_grid.png` is drawn on the planned 6-point layout.** The test used 8 points.
- **`06_P3_Aluminum_Frame/P3_T5_Mode4_421Hz.mov` was copied from `Output/EXP3/Day2_P3_Accel`**, because the copy in `XModal_Results` is cut off and won't play.
- **Not copied:**
  - older versions (Day 1 accelerometer review v1/v2)
  - scratch check images
  - raw `.mat` / `.unv` data
  - the HTML reports, which are at `Output/EXP3/XModal_Results/00_INDEX.html`

## REV3 changes (2026-10-26)

- L-plate and frame charts now use the same layout as the rectangle chart (C1), minus the hand calc: modes 1-4, accelerometer vs NX free-free. All three plate charts show the first four modes, which is what the experiment asks for; modes 5-6 are in the backup tables.
- Each plate now has a frequency slide and a shapes slide (X-Modal on top, NX corner springs below). The L-plate frequency slide has its Day 2 setup photo.
- Slide 5 shows all three NX models with their corner springs.
- Recommendation 4 (same day, same setup) was removed; the cards were renumbered 1-5.
- The Questions slide shows the measured and the NX animation of the rectangle's first twist.
- Backup table labels match the new chart labels (L-plate mode 4: bend + twist; frame modes: bending, twist, bend + twist, 2nd bending).

## Who made what

| Made by | Files |
|---|---|
| Group E (phone photos) | 17 |
| X-Modal animations and stills (fits run by Claude) | 82 |
| X-Modal screenshots and diagrams (taken by Claude) | 33 |
| Claude (Python plots) | 63 |
| Claude (images of the NX results) | 40 |
| Claude (NX captures of the P2/P3 corner-spring models, 2026-10-26) | 16 |
| NX solver eigenvalue plots (solves run by Claude) | 6 |
| Claude (pre-lab guide, Day 1 recap) | 19 |
| MATLAB charts and their numbers (script written and run by Claude) | 12 |
| Claude (MATLAB chart script) | 1 |
| Claude (first presentation deck, now in `OLD/`) | 1 |
| Group E (REV2 deck) | 1 |
| Claude (REV3 deck: edits on Group E's REV2) | 1 |

The per-file breakdown is in `_manifest.csv`, in the `made_by` column.
