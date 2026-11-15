# Experimental Methods — session log (Group E)

Running log of what's been done in this class folder, session by session, so any tool
(Claude, ChatGPT/Codex, or a group member) opening just this folder can see what's current
without re-deriving it. Newest entry at the top. Add a new entry after any session that
changes something here — don't rewrite history, append.

Note: this is the shared Group E copy of the folder. A few things referenced in older
entries are not included here: `Sandbox/` (scratch space), `OLD/`, `_Archive*` and
`_backup*` folders, and NX solver output files (.op2/.dat/.f04/.f06/.log — re-solve the
.sim files in NX to regenerate them). Detailed write-ups referenced as "Notes" are in `Notes/`.

---

## 2026-11-15 -- Shared Group E copy created
Folder packaged for the group as a clean, AI-ready copy: experiment memory kept (this log,
CLAUDE.md/AGENTS.md, and the per-experiment write-ups in `Notes/`), personal/other-course
material removed, absolute Windows paths replaced with `C:\path\to\ExpMethods_GroupE`
(edit to your own folder; MATLAB scripts now find the root from their own location),
photo GPS data stripped, document author metadata cleared.

## 2026-11-15 -- EXP4 Day 2 (11/10) filed
Transcript saved as Transcripts/InLab/11-10-2026_Lab.docx. 4 Day 2 photos saved to Lab Data/EXP4/Photos/DAY2/
(D2_01..D2_04). Day 2 CSVs in Lab Data/EXP4/LabDay2/LabDay2 map to tests by file name: config A (engine inverted, top heat,
foil heater) t1 11.64 V, t2 11 V, t3 10.51 V, t4 ~9.99 V (use t4-9.98v-.csv, the newer one); config B (upright on foam bowl,
insulated bottom, built-in heater) T5 11.62 V, T6 10.0 V, T7 8.5 V, T8 7 V. Buck photos give P = V*I for t1 (11.64 V, 0.40 A,
4.66 W) and T5 (11.62 V, 0.51 A, 5.93 W) -- the different current at the same voltage (29 vs 23 ohm) is unresolved.
Config A ran at only ~14-16 C dT (below the ~20 C the professor says is needed). Heater resistance not usable from the
recording. Full write-up: Notes/EXP4/exp4-day2-lab-notes-2026-11-10.md.


## 2026-11-10 -- EXP4 Day 1 temperature units confirmed (group)
Meters were switched between F and C during the lab. Test 2 = deg C (53/32). Tests 4 and 5 = deg F (160/95 -> 344.3/308.2 K; 148/93 -> 337.6/307.0 K).
The block-heater "degrees of difference" remarks were deg F (40+ F ~ 20+ C). Day1_Data_Map.md updated.

## 2026-11-07 (later) -- EXP4 Day 1 data mapped to transcript + photos (Claude)
Filed 13 Day 1 photos in Lab Data/EXP4/Photos (D1_0936..D1_1019, named by clock time). Wrote Lab Data/EXP4/LabDay1/Day1_Data_Map.md:
clock-time timeline (recording start 9:28 AM) and file-to-test map. Correction to the entry below: the spoken temps are read
at each step-down for the test just finished, so 160/95 (F) = test 4 (11.7 V) and ~148/93 (F) = test 5 (10 V); test 6 temps not stated.
Test 2 = 53/32 C. data_38_000.bin = failed first save (~11:11). Units were switched between F and C during the lab -- confirm with group.
Buck converter display shows output V and A (photo D1_0959_02) -> P = V*I possible on Day 2.

## 2026-11-07 -- EXP4 Day 1 status + lab transcript filed (Claude)
Filed the group's Day 1 recording as Transcripts/InLab/10-27-2026_Lab.docx. Matched it to the 6 tach CSVs in Lab Data/EXP4/LabDay1/LabDay1:
tests 1-3 = dual external block heaters under the base on balsa (test1 ~11.75 V ~46 RPM; t2 10 V ~40 RPM, bottom 53 / top 32;
003 9.5 V ~21 RPM, erratic); tests 4-6 = built-in foil heater (t4 11.7 V ~111 RPM; t5 10 V ~74 RPM, ~160/95; t6 9.5 V ~71 RPM,
~148/93). The 160/95 and 148/93 readings are probably deg F (160 C would be past the ~100 C limit) -- confirm with photos.
Ambient before heating: bottom 22.2 C, top 23.2 C. Thermocouples 1.25 in in from the edge, same spot top and bottom. Exposed base
only; no insulated bowl, no top heating (planned for Day 2), no dimensions, no heater resistance. Professor's notes on Day 1: keep it level,
it needs ~20 C difference to run, start high and step down (it won't restart low), and use the built-in heater for bottom heating. Status: Notes/EXP4/exp4-day1-status-2026-11-07.md.

## 2026-10-27 -- EXP4 lab game plan built (Claude)
Built Lab Data/EXP4/ (README.txt, Figures/, LabDay1/, LabDay2/, Model/, Photos/, Scope/) in the EXP3 kickoff format:
EXP4_Lab_Guide_GroupE.pdf (14 pp, 11 figures) and EXP4_TestPlan_and_RunLog.xlsx (14 sheets, 4060 formulas, recalculated,
0 errors; Run Log charts tested with sample rows). Sources: Canvas/EXP4 README + FAQ + realStirlingEngine.m, lectures
10/19 + 10/21, Equipment FAQ, EXP2 FAQ. Script findings (checked with a Python port): Schmidt-type model; temps in K;
R = 2077 is helium (air 287) and cancels out of P when the mass-estimate line runs (it always overwrites typed m);
posted geometry is impossible (regenerator -4.22 cm3, CR 1.754); no work/efficiency/ideal-cycle output; air under the
piston counts as cold volume. Run plan: A bottom/exposed, B bottom/insulated (match base temp -> power lost), C top heat
(reverse at same dT), D orientation (optional), R repeats. Open: top-heat heaters (10/21 garbled), buck display,
efficiency method, ideal-cycle requirement, report format, Day 2 date (inferred Tue 11/3).

## 2026-10-26 (night) -- EXP3 deck REV3 from Group E's REV2 (Claude)
Built Lab Data/EXP3/Report/EXP3_GroupE_Presentation_REV3.pptx (24.9 MB, 16 slides + 7 hidden) from Group E's REV2 (REV2 untouched).
- P2/P3 now mirror P1: frequency slide (MATLAB C4/C5 redone in the C1 layout minus Blevins, modes 1-4; table Mode|NX|NX springs|Accel.;
  Day 2 setup photo) + shapes slide (X-Modal GIFs above NX corner-spring GIFs). Why the old charts differed: C4/C5 were built to argue
  one point each (bending-vs-twist split; test between the two NX versions) and showed all six fitted modes; C1 shows four because
  the lab asks for the first four and Blevins only covers four.
- NX: new P2/P3 corner-spring captures (model image + bounce + modes 7-12 GIFs) in NX/P2_LPlate_Springs/Images and
  NX/P3_CutoutFrame_Springs/Images, camera set to X-Modal's view (+x,+y corner, 45 deg down). Report copies are looped, 720 px.
  MATLAB script re-run (8 charts, 0 failed); C4_Lplate_vs_NX.png and C5_frame_vs_NX.png are the new charts.
- Recs: removed #4 (same day, same setup) per the group; Questions slide now also shows the NX animation of rectangle mode 2.
- Orientation answers: X-Modal's camera looks from the corner past P2 point 5, so the L's foot shows at the top left; X-Modal's P3
  model is only the 8 rim points (no hole). The real P3 cut-out and the NX one are both off-center (toward the 3-5-8 end and 6-7-8 edge).
- Flags left for Group E: slide 5 says "Al 2014, Al 2014" but the frame's NX model is Al 6061; conclusions say L-plate "width"
  while slide 9 and backup 20 say the part is ~2% too short (length). Typos fixed on slide 5 (effect, frequencies).
- NX crashed once during API testing (no files affected; model mtimes still 10/20); NX was left open on the start page.

---

## 2026-10-25 — EXP3 objectives checked against lecture recordings (Codex)
Reviewed Oct 5/7 lectures, Canvas Structural Dynamics README, and Oct 13 lab clarifications. Sourced study notes:
`Output/EXP3/EXP3_Objectives_Transcript_Review.md`. Explicit Oct 7 35:10–40:29 requirement = 3 full + 3 partial surveys:
rectangle full accel + full mic (same impact points); second plate full either + partial other; third plate partial both.
Also 3 NX models, Blevins for rectangle only, first 4 out-of-plane elastic modes (inspect ~6 to avoid omissions), no damping.
Cross-check flag: earlier Oct25 user decision that P2/P3 mic tests were unnecessary differs from the lecture baseline.
Oct13 2:24:00 encouragement about rectangle data is not an explicit waiver; separate later permission may exist but is not
documented in the available transcripts. No raw data, models, presentation, or prior decision entries changed.

---

## 2026-10-25 (night) -- EXP3 presentation deck + MATLAB charts (Claude)
Built Lab Data/EXP3/Report/EXP3_GroupE_Presentation.pptx (17.6 MB): 14 slides + 8 hidden backups (15-22), short talking
points in the speaker notes, GIFs animate in slideshow. The group's rule: every chart must come from MATLAB, so the 8 charts
(C1-C8) come from Report/11_MATLAB_Charts/make_exp3_presentation_charts.m, run in MATLAB R2022b on a group member's laptop (reads
Report/09_Data_Tables CSVs + raw X-Modal .mat in LabDay1/LabDay2; also writes chart_numbers.csv and chart_log.txt).
Every other visual is a lab photo, X-Modal GIF/screenshot or NX image; the older Python plots are not used in the deck.
Talk order: title, objective/plates, setup, hits->modes (C3), models (Blevins + NX), rectangle freqs (C1), rectangle
shapes, accel vs mic (C2), L-plate (C4), frame (C5), conclusions (C6), recommendations, questions, blank end slide.
Backups: MAC (C7), coherence (C8), X-Modal process, NX details, L-plate dimension check, full tables, Day 2 photos.
Report/README.md now maps each slide to its files; Report/_manifest.csv has 272 rows (12 new).

## 2026-10-25 (later) -- EXP3 Day 2 photos added (Claude)
7 Day 2 (10/20) photos from the group saved to Lab Data/EXP3/Photos and Report/01_Plates_and_Photos/Day2_Photos (descriptive names,
phone-shared 1512x2016 copies). What they show: P1 mic redo on the K'nex stand near the far long edge between pts 13 and 14
(the Day 2 plan spot), tennis balls under all 4 P1 corners (Day 1 used a different mix of balls); P2 accelerometer on the long
straight edge at the planned ~6.75 in spot, P2 grid labels match the plan numbering (1-5 straight edge, 16-18 foot); P3 points
1-8 match the as-tested numbering, tennis balls at the corners by pts 1 and 3 + a ring visible through the cut-out. P2 supports
and the P3 accelerometer are not visible in any photo.

## 2026-10-25 -- EXP3 Report media folder built (Claude)
EXP3 group report = in-person presentation (~10 min, ~12 slides). Copied every EXP3 photo, X-Modal mode animation
(GIF/MOV/still), NX image, comparison plot, X-Modal screenshot and result CSV into Lab Data/EXP3/Report/ (253 files,
194 MB), numbered in slide order: 01 plates/photos, 02 setup, 03 models (NX + Blevins), 04 P1, 05 P2, 06 P3,
07-08 backup (X-Modal process, coherence/raw FRFs), 09 data tables, 10 reference. Copies only - originals untouched.
Report/README.md = folder-to-slide map, format tips, caveats; Report/_manifest.csv = source path + made_by per file.
Day2_Photos/ is empty until the group adds the 10/20 photos. P3 Mode 4 MOV taken from Output/EXP3/Day2_P3_Accel because the
XModal_Results copy is cut off at 128 KiB. All copies md5-verified; all 71 GIF/MOV play.
Decisions (group, 10/25): no mic tests needed on P2/P3; NX alloys for P2 (2014) / P3 (6061) chosen by weight match;
P1 mic redo was at the Day 2 plan spot, 1 in above (8.0, 5.25) in; EXP3_TestPlan_and_RunLog.xlsx retired.

## 2026-10-20 -- EXP3 NX: P2 and P3 corner-spring models built and solved (Claude)
Copied P2/P3 free-free NX models to Lab Data/EXP3/NX/P2_LPlate_Springs and P3_CutoutFrame_Springs and added the Canvas
spring steps (ground block 1 in below, 4 CELAS1 1D connections at outer corners, DOF Z, PELAS 323 lbf/in, fixed ground),
solution CornerSprings_Modal. P2: bounce 48.7 Hz, modes 412.7/612.7/1098.6/1360.1/1828.3/2161.0 (+3.1/+2.2/+0.4/+0.5/+0.2/+0.3 %).
P3: bounce 32.5 Hz, modes 161.0/176.3/355.5/431.0/563.8/712.0 (+7.3/+10.7/+2.4/+0.6/+0.9/+0.8 %). Details in NX/README_NX_Models.md.
Originals untouched. Build journals in NX/_journals/. No images yet.

---


## 2026-10-13 -- EXP3 recap v2: NX model section expanded (Claude)
Lab Data/EXP3/EXP3_Day1_Recap_GroupE.pdf now 12 pp. Section 7a = full write-up of the P1 NX model Claude built from
SteelRectagle.prt (SS304 27.56 Mpsi/7900, CTETRA10 0.2 in 28,000 el/48,970 nodes, SOL 103 Lanczos 12 modes free-free,
34 s solve, 0.125 in mesh <=0.07%, NX 8.32 lb vs 8.230 lb). Live NX (Designcenter NX 2512) would not open a window via
computer use, so images are RENDERS from the .dat/.op2 (pyNastran + pyvista), not NX screenshots:
Output/EXP3/NX_P1/Renders/ (NX_A..D composites, mesh iso/zoom, NX_mode7..12, nx_model_extract.npz source data).
Still open: NX for L + cut-out (aluminum); settle P1 size/thickness; take own NX screenshots for the report.


## 2026-10-13 -- EXP3 Day 1 recap PDF (Claude)
Lab Data/EXP3/EXP3_Day1_Recap_GroupE.pdf (10 pp): requirements, plates (P1 SS rect 8.230 lb; Al L 4.900 lb; Al cut-out 9.900 lb
from scale photos), setup schematic + photos, accel data, mic data, in-lab quotes, separate "Work performed by AI" section
(NX model, X-Modal geometry/fit, this review), then thoughts/suggestions. New figs R1-R3 in Output/EXP3/Day1_Review.


## 2026-10-13 -- EXP3 clarifications from the group
Rectangle (P1, stainless) sat on balls at the 4 corners. Other two plates: L-shaped plate and rectangular cut-out (frame)
plate, BOTH aluminum -- dimensions + weights measured on Day 1 but not yet entered in Plate Specs; not yet tested.
NX files for all plates were being updated (in progress).


## 2026-10-13 -- EXP3 Day 1 in-lab transcript reviewed (Claude)
Transcripts/InLab/10-13-2026_Lab.docx. Key facts: hammer ch1 / sensor ch2 (not both at once); ~800 lines, 5 avgs (3 ok);
lower trigger level; set point # and +/-Z per hit in Channel Setup (accel +Z, hammer -Z) -- group didn't, hence relabelling;
white (hard) tip used after soft tip looked worse; accel "1 in in, 1 in over"; mass 8.230 lb = 3.733 kg; supports placement
debated (record it); mic height chosen by comparing one hit location only -> settled ~1 in above center. Instructor:
structural + acoustic set on the rectangle = good shape. Plates 2-3 not tested yet. Notes: Notes/EXP3/exp3-day1-lab-transcript-notes.md.


## 2026-10-13 -- EXP3 P1 microphone grid reviewed (Claude)
Mic held 1 in above pt 8 (plate center), same 15 hit points (MIC/MicRect*.mat). Mic hears only center-symmetric modes:
(31) 453 Hz (shape MAC vs accel 0.996), (13) 2176 Hz (clean), ~(51) 2473 Hz. Antisymmetric (22) 602, (32) 1293, (42) are
missing (~5-10x suppressed vs accel); (41) 1242 weak/contaminated -> pressures from opposite-phase halves cancel at center.
Recommend redo mic grid with mic off both center lines (e.g. 1 in above pt 15) after a 2-3 hit check; keep center set as
a supporting result. Coherence 0.97-0.996 except pts 7 (0.82), 10, 13 (0.92). Outputs: Output/EXP3/Day1_Review/*mic_center*.


## 2026-10-13 -- EXP3 P1 accelerometer location correction (group)
On the steel rectangle (P1) the accelerometer was mounted at about (1.0 in, 1.0 in) from the corner, NOT at grid point 1
(0.75, 0.75 in). Point 1 was the hit beside it (~0.35 in away). Rect1x1 = near-driving-point. Shapes unaffected; X-Modal/NX
reference DOF belongs at (1.0, 1.0). Retakes reviewed: use Rect1x2.2, Rect1x5.2, Rect2x1.2 (coherence ~0.93 -> 0.996-0.999);
keep originals elsewhere. Outputs: Output/EXP3/Day1_Review/*_v2_bestset.*, *_v3_bestset.png.


## 2026-10-13 -- EXP3 Day 1: steel rectangle full grid (accelerometer) reviewed (Claude)
15 points (Lab Data/EXP3/LabDay1/Steel_Rectagle/Rect{row}x{col}.mat, accel fixed at pt 1). Modes at 453 / 602 / 1242 / 1293 Hz
match NX (451.6 / 597.4 / 1245.5 / 1295.1) within 0.7% and Blevins SS304 within 1-4%; measured shapes match predicted (31)/(22)/(41)/(32)
(MAC 0.94-1.00). Middle-row-only 2176 Hz peak = NX mode 11 (13). Coherence 0.98-1.0 except pts 1,2,5,6 (0.92-0.94) -> optional retake.
Outputs: Output/EXP3/Day1_Review/ (png + shapes csv). Still open: Plate Specs material = Aluminum; sheet dims vs NX part dims differ.


## 2026-10-12 -- EXP3 Structural Dynamics kickoff package (Claude)
Read all of Canvas/EXP3 (README, Blevins free-free plate extract, NX modal tutorial, spring-constraint and
add-mass tutorials, K'nex part count) + lectures 10-05 and 10-07. Built Lab Data/EXP3/ with
EXP3_Lab_Guide_GroupE.pdf (13 pp, 17 figures), EXP3_TestPlan_and_RunLog.xlsx (14 sheets, recalculated, 0 errors),
Figures/, README.txt, and empty LabDay1/ LabDay2/ NX/ Photos/.
Spec per sources: THREE plates (all different shapes, >=2 materials, metallic rectangle drafted first; all-metal
recommended, HDPE not) via snake draft A-J-A-J (Group E picks #5/#16/#25); hammer + accelerometer AND hammer +
microphone, run back-to-back; first 4 OUT-OF-PLANE modes; 6 tests = rect FULL accel + FULL mic (same points),
plate 2 FULL (either) + 4-6 pt partial (other), plate 3 two 4-6 pt partials; Blevins on rectangle only, NX on all 3
(free-free -> 6 rigid modes, ask 12; tutorial's fixed face must be removed). Mic gap: lecture says expect 1-6 in.
Planning prediction (EXP1-size rect 12.9x5.9x0.50 in, Al): (31) 622, (22) 835, (41) 1713, (32) 1833 Hz; SS ~3% lower.
(41)/(32) only ~7% apart -> order may flip; confirm by shape. f proportional to h.
Flags: the group thought 2 plates / mic only -- sources say 3 plates + both sensors. EXP1 rectangle records conflict
(notes: stainless, 0.45 in; CSV 0.50 in; 1.687 kg matches 0.50 in ALUMINUM within 0.6%). Lecture "30 Mpsi" is
carbon steel (304 ~28 Mpsi). Lab dates for Group E inferred Tue 10/13 + Tue 10/20 (unconfirmed). EXP3 report
format not stated yet.


## 2026-10-11 — EXP2 NX screenshots captured and video deck completed (Codex)
Resolved the screenshot blocker: DNS/licensing works outside the restricted shell. NX CLI opened copper; its image-export call was unavailable in that session, so the computer-use skill captured live NX views instead. Final AI_SIM_TAKE_2 Solution1 nodal temperature contours for all5 rods, in Celsius, plus full hollow-copper CAD geometry and bore detail. Screenshot min/max match Take2 reports (Cu37.69–51.22,Al31.57–71.23,brass28.92–72.21,SS24.23–149.17,tube33.90–62.49°C). No model or solver file saved.
Completed `Lab Data/EXP2/Report/EXP2_GroupE_Video_Report_Rev4_Final.pptx` + PDF and `EXP2_Recording_Guide_Rev4.md`.21 slides total:11 main/480s,10 hidden including detailed NX screenshots. Earlier revisions preserved. Authentic PNGs/source hashes in `Rev4_Support/NX_Screenshots`, MATLAB source/data/figures in `Rev4_Support/MATLAB`. All17 embedded source images byte-verified (10MATLAB plots,5NX contours,2CAD views); package/layout/font/import validation passed; changed slides inspected; allPDF pages rendered/checked. Ready for group review and voice-over recording; no audio/video embedded. Prior data/model caveats retained.

## 2026-10-10 — EXP2 recorded report deck rebuilt (Codex)
Created `Lab Data/EXP2/Report/EXP2_GroupE_Video_Report_Rev3_Final.pptx`, matching the blue/white EXP1 screenshot reference, with 11 main slides and 4 hidden supporting slides. Suggested narration totals 8:00 (1008 words), with presenter assignments and per-slide sources. PDF preview, `EXP2_Recording_Guide.md`, and reproducible MATLAB assets/source in `Rev3_Support/MATLAB/` accompany it. Raw data and existing report drafts preserved.
Cross-checked Guidelines pp3–4, Canvas EXP2 docs, unstruck LabLog entries, raw Runs and current Take2 reports. Plots all regenerated in MATLAB. Brass/stainless pass operational final3min <0.1°C/min check; copper Ch1–3 pass but tip fails; aluminum/tube fail. Disclosed Al assumed+5°C Ch1, Cu excluded tip, brass mixed R6/R3 fit targets, fixed-library k, and fitted rather than independently validated NX agreement. NX has lateral+tip convection; analytical baseline has insulated tip. SS current material PH15-5, face149°C. Station/geometry discrepancies retained in appendix.
Authentic NX images still unavailable: university license server `currents.ad.uc.edu` fails DNS; journals fail before initialization. No MATLAB geometry re-renders substituted. Capture instructions in `Rev3_Support/NX_capture_status.md`. Slides currently show numerical NX interpretation and MATLAB profile plots; genuine NX geometry/contour captures remain the optional visual completion once university licensing is reachable. Deck is ready for group review/narration, not yet an MP4 recording.

## 2026-10-09 -- partner package + mass check
Built Lab Data/EXP2/NX/EXP2_NX_Package_for_Partner (+ .zip, 52 MB): 01 models/parts, 02 solver outputs,
03 per-rod PDF reports, 04 combined PDF report, README. NX masses match lab weights within scale resolution;
no material changes. Open items: stainless end-face heating (156 degC), steel.prt dia 0.201 vs 0.195, tube ID.


## 2026-10-08 (night) -- NX models for all 5 rods built and anchored to data
New FEM/SIM files per rod in Lab Data/EXP2/NX/EXPT2 (SOL 153, CTETRA4 0.06 in, end-face heat flux,
lateral convection). h/Q least-squares at thermistor points, h capped 5-25. steel.prt had no material ->
AISI 304 assigned in FEM. Full table + flags: Output/EXP2/NX_AllRods_Fit/SUMMARY.md.


## 2026-10-08 (evening) -- copper NX model solved in NX
The group installed the solver add-ons and moved Claude's edited files to Lab Data/EXP2/NX/OLD/EXPT2_OLD/
(EXPT2/ = untouched originals). Ran Solution 2 (SOL 153) there: converged; NX gives 43.04/40.07/38.36/37.81 degC
at the 4 thermistor stations, identical to the earlier independent solve. Results saved beside the sim.


## 2026-10-08 -- NX copper rod tuned to R1
Edited Lab Data/EXP2/NX/EXPT2/copper_fem1_sim1_final.sim (backup in _backup_before_claude_2026-10-08/).
Fit fin eq. to R1 Ch1-Ch3: h = 10 W/m^2K, Q = 0.81 W (k = 387-391 held). Added SOL 153 Nastran
solution; this PC has no NX thermal/Nastran solver, so the deck was solved independently: 43.0/40.1/38.4/37.8
vs data 43.0/40.6/38.2/33.1 degC. Original SOL 401 setup skips its loads (not in step). Details:
Output/EXP2/NX_Copper_R1_Fit/CHANGELOG.md.


## 2026-09-22 (evening, cont'd) -- full photo-to-transcript cross-reference
The group supplied capture times for all 5 lecture photos; mapped against the 3:34 PM
lecture start, each lines up cleanly with a specific transcript block:
- IMG_5701 (3:49 PM, ~15 min) -> Speaker 1 @13:54 block: professor narrating the
  materials pile (tape types, tubing, fan) -- matches the photo directly.
- IMG_5705 (3:52 PM, ~18 min) -> Speaker 3 @16:08 block: this is a near word-for-word
  narration of the EXPT2(setup) slide's own bullets. Confirms, straight from his own
  words in this block: "the Arduino with four-channel maximum. You don't have to use
  all four" (4-channel, not 6); "updates about every half second... log the data...
  about once every five seconds" (matches 0.5s LCD / 5s nominal capture); "set up to run
  for about 20 minutes"; and -- important -- "the rods are nominally... about two tenths
  of an inch in diameter... not only about a foot long... hollow tube is about three
  tenths and also about a foot," which directly confirms the ~12" rod length from his
  own mouth (independent of the setup-slide photo), putting the earlier NX-tutorial
  25" mixup fully to rest. Also restates the "keep length consistent" rule and the
  attachment-method options (foil wrap / foil tape / polyimide) that get their own slide
  5 minutes later.
- IMG_5706 (3:57 PM, ~23 min) -> Speaker 3 @21:43 block: "here's some examples of the
  mounting using foil wraps or foil tape... thermistors on this are tiny" -- matches the
  Attaching the Thermistor slide directly, no surprises.
- IMG_5709 (3:59 PM, ~25 min) -> same Speaker 3 @23:05-29:45 block as IMG_5708 (already
  logged) -- "Here's an example of code" moment, right after the LCD/serial monitor demo.
Net effect on the open 6-channel-vs-4-channel question (IMG_5708's LCD showing T0-T5):
IMG_5705's block reconfirms "four-channel maximum" only ~5-7 minutes before the T0-T5
LCD photo was taken, with no mention anywhere in the surrounding transcript of a second
Arduino, expansion board, or more than 4 sensors. This strengthens the case that the
6-value LCD screen is an outlier/unrelated demo fixture rather than the real setup, but
doesn't fully resolve it -- still worth asking about Wednesday.

## 2026-09-22 (evening, cont'd) -- cross-referenced IMG_5708 against the lecture transcript
The group pointed out the 09-21 lecture started 3:34 PM (per the transcript header) and
IMG_5708 was taken ~3:58 PM, i.e. ~24 min in. The transcript's Speaker 3 23:05-29:45
block lines up almost exactly and is literally the professor live-demoing that same
screen: "They'll be just reported there [the LCD], as well as dumped to the serial
monitor... the program actually has a separate command that you can execute, and it'll
dump it all out in one vector that you can then read directly in MATLAB... you send it a
capital D, and it will dump the current buffer. You don't have to wait for the 20
minutes... if you feel like it's arrived at steady state [at e.g. 7 minutes in]. You can
dump the data at that point." Also directly confirms, in his own words at this exact
moment: nominal 5s update is "not five seconds long... can be as much as seven seconds,"
and that the delay is fairly consistent/deterministic (not wildly jittery) even though
it's not the nominal 5s -- supports using a fixed ~7s correction as reasonable if no
real per-sample timestamp is available.
This does NOT resolve the 6-channel (T0-T5) vs. 4-channel (A0-A3) discrepancy noted
earlier -- no channel count is mentioned in this specific block. Everywhere channel
count IS stated elsewhere in the lecture (~16:08-21:43 block), it's "four-channel
maximum, don't have to use all four" -- never six. Still an open question for Wednesday.

## 2026-09-22 (evening, cont'd) -- steady-state detector dry-run tool
The group drew an analogy to CFD residual convergence (AND-ing continuity/momentum/energy
residuals against a criterion, e.g. 1e-4/1e-5) and asked whether the same idea could
replace manually watching the Arduino display and typing "D" to dump the buffer.
Landed on: automate it laptop-side (MATLAB reading the live serial stream, or offline
against a saved dump), NOT by modifying the Arduino sketch -- keeps the given
hardware/firmware untouched on lab day per the professor's evident protectiveness of it.
Drafted in Sandbox/Claude/EXP2_SteadyStateTool/: check_steady_state.m (rolling-window
linear-fit slope per channel, ANDed across all channels, verified against a Python port
of the same math on 2026-09-22), test_steady_state_offline.m (dry run against
Canvas/EXP2/SampleOutput.txt -- confirmed it correctly never declares steady on that
snippet since it's monotonically heating throughout), and monitor_live_serial.m (live
version, explicitly flagged as NOT validated since the real Arduino print format in
loop() isn't known yet -- only a setup() screenshot exists; the .ino wasn't on Canvas as
of tonight). Two things needed before trusting this in lab: the real serial print format
(to fix parseLine()), and a slopeThresh calibrated against real transient data instead of
the 0.05 C/s placeholder. Not moved to Output/EXP2/ yet -- still Sandbox until validated.

## 2026-09-22 (evening) — EXP2 material review
The EXP2 Canvas materials were pulled in today (Canvas/EXP2/: Experiment_2.docx,
HeatTransferFAQs.docx, Heat Transfer Equations for Thin Rod.pdf, Presentation for
Siemens NX - Heat Transfer.pdf, SampleOutput.txt) and the 09-21-2026 lecture (intro to
EXP2) is now transcribed, the class notes are written up, and lecture photos are in
Class Notes/ClassPhotos/09-21-2026_Lecture_Photos/. Did a full cross-check pass against
the earlier conceptual walkthrough (the Socratic EXP2 kickoff done before this material
existed). Key confirmed/new facts, grounded in the lecture slide photos and Canvas docs:
- Rods: four solid (aluminum, stainless, copper, brass), nominal 0.2" dia x 12" long;
  one hollow copper rod, nominal 0.3" dia x 12" long. (The NX tutorial PDF's "25 inch"
  aluminum rod is just a generic modeling example, not the actual lab rod length --
  don't confuse the two.)
- Heaters: 12V resistive elements, two max-temp ratings (80C and 120C). Actual power
  into the rod must be estimated (measure heater resistance cold, at the two screw
  terminals, P = V^2/R) -- not all of that power reaches the rod.
- Thermistor circuit: 10k-ohm series resistor + 10k-ohm NTC thermistor voltage divider,
  Beta = 3977 (from the actual Arduino code shown in lecture), Arduino 10-bit ADC
  (0-1023), 5.0V reference (4.7V if USB-powered -- matters for accuracy), 4 usable
  channels (A0-A3; A4/A5 reserved for the I2C LCD bus).
- Data logging: LCD updates every 0.5s, data captured every 5s nominal (~7s actual due
  to loop overhead -- correct using real elapsed time, don't assume exact 5s spacing),
  max run ~20 min, buffer holds up to 250 samples x 4 channels, serial "D" command dumps
  the buffer on demand (don't have to wait the full 20 min if steady state hits early).
- Rough air convective coefficient range given in lecture: h ~ 5-25 W/m^2K (still needs
  narrowing for the actual setup; the NX demo used h=4 W/m^2K as a placeholder).
- FAQ explicitly offers the insulated-tip simplification (ignore end-of-rod convective
  loss) as an acceptable steady-state simplifying assumption, and says the full
  closed-form transient PDE solve is not worth the effort -- steady-state analysis
  (with finite-difference-estimated k/h from data) is the expected path.
- Clarification questions session is Wednesday 2026-09-23.
Still open (group decision): exact h to use, whether to keep or drop the end-loss term,
attachment method (foil wrap/foil tape/polyimide tape), how many points along the rod,
one-rod-at-a-time vs. simultaneous testing, transient heating vs. cooling test
conditions, thermistor-vs-thermocouple cross-check.

## 2026-09-22 — Folder reorganization + EXP1 status

**What happened:** Reorganized this whole folder from a scattered per-experiment layout
into content-type-first: `Transcripts/` (split Lectures vs. InLab, per-experiment
subfolders), `Class Notes/`, `Canvas/`, `Lab Data/` (raw only), `Output/` (analysis,
scripts, report drafts — this is the "working deliverable" folder per experiment), and
`Sandbox/` (Claude/ChatGPT scratch space, kept out of the real structure). Updated the
MATLAB pipeline and `make_report_figures.py` data paths to match the new `Lab Data/`
location — verified against the actual file tree post-move. See `claude.md.txt` in this
folder for the full structure and the reasoning behind each category.

Left behind: a few empty folders from the old layout (`EXP1/`, `Class_Transcripts/`) —
harmless empty shells.

**EXP1 status (Moments of Inertia) — where it stands:**
- Day 1 (9/8) and Day 2 (9/15) both complete. Validated: **Ixx** = 735 ± 50 lbm·in² vs.
  736 analytical (Al offset frame, V-hang, compound, X-Modal). **Izz** = 52.6 ± 2 lbm·in²
  vs. 51.5 analytical (rectangle, bifilar, Arduino+X-Modal). **Iyy** — frequency agrees
  but MOI not resolvable from the into-table HDPE run; reported as a limitation, not a
  forced number.
- Specimen corrections locked in: rectangle plate is 6061-T6511 aluminum, 0.500 in
  thick (not stainless, not 0.45 in as `Notes.txt` originally said).
- Summary report V2 draft exists in `Output/EXP1/Report/` (due 22 Sep, 8–10 pages,
  required-content only). `Output/EXP1/EXP1_Final_Analysis/run_exp1_all.m` is the
  consolidated pipeline that regenerates the report tables/figures.
- Open items: lab-frame definition sentence for the report, Day 1 date, NX/MATLAB
  versions, IEPE model/serial, assembly composition/mass/rig (never fully logged), NX
  Config 4 principal-axis vectors (old NX, possibly flipped — not used).

**Next likely session:** finish/submit the V2 summary report; start EXP2 once assigned
(Lab Data/EXP2, Canvas/EXP2, Transcripts/.../EXP2, Output/EXP2 are all ready to receive
it, same pattern as EXP1).

## 2026-09-22 (later) — the group refined the reorg themselves

The group further simplified the structure Claude set up earlier the same day:
- **Transcripts/** and **Class Notes/** are now flat (no `EXP1/` subfolder layer) and
  use date-based filenames instead — `Transcripts/Lectures/MM-DD-YYYY_Lecture.docx`,
  `Transcripts/InLab/MM-DD-YYYY_Lab.docx`, `Class Notes/MM-DD-YYYY_Lecture.pdf`. The
  date in the filename is what pairs a note to its transcript now, not a shared
  subfolder. Confirmed working: `Class Notes/08-31-2026_Lecture.pdf` pairs with
  `Transcripts/Lectures/08-31-2026_Lecture.docx`.
- Canvas/, Lab Data/, Output/, and Sandbox/ were left as Claude set them up — unchanged.
- The empty leftover folders from the old pre-reorg layout (`EXP1/`, `Class_Transcripts/`,
  `Claude outputs/`) are gone — the group deleted them themselves.
- `claude.md.txt` in this folder updated to match (Transcripts/Class Notes section
  rewritten to describe the flat, date-named layout).

New lecture/in-lab transcripts have also shown up since the morning session
(`08_24-2026_Lecture.docx`, `09-14-2026_Lecture.docx`, `09-21-2026_Lecture.docx`,
`09-01-2026_Lab.docx`, `09-17-2026_Lab.docx`) — haven't been reviewed for content yet;
next session should read through these for anything that updates the EXP1 status above
or points to EXP2 starting.

## 2026-09-22 (later still) — another round of the group's own refinements

- Fixed the date-format inconsistency themselves: `08-24-2026_Lecture.docx` now matches the
  `MM-DD-YYYY` hyphenated pattern used everywhere else (was underscored before).
- Added `Class Notes/09-14-2026_Lecture.docx` and `Class Notes/09-21-2026_Lecture.docx`
  — now 3 dated notes total, each pairing with its same-dated Transcripts/Lectures file.
- New subfolder: `Class Notes/ClassPhotos/09-21-2026_Lecture_Photos/` — 5 photos
  (IMG_5701, 5705, 5706, 5708, 5709.jpg), presumably projector/board shots from that
  lecture. This is a new pattern — photos of class material live under
  `Class Notes/ClassPhotos/MM-DD-YYYY_Lecture_Photos/`, same date-matching convention as
  the rest of Class Notes/Transcripts. Documented in claude.md.txt.
- `EXP1/` (the old empty leftover shell) is present again, still empty — harmless, not
  investigated further.
- Canvas/, Lab Data/, Output/, Sandbox/ unchanged.

Still haven't read through the 5 newer transcripts (08-24, 09-14, 09-21 lectures;
09-01, 09-17 in-lab) for content — carrying that forward as the next open item.


## 2026-09-22 (later still x2) — EXP1 submitted, EXP2 (Heat Transfer) begins

**EXP1 close-out:**
- Summary report **submitted/turned in** — EXP1 is done.
- New deliverable: **post-lab reflection report, due Friday 2026-09-25**. Not yet
  started — add to Output/EXP1/ when work on it begins (a `PostLab_Reflection`
  subfolder would fit the existing pattern).

**EXP2 (Heat Transfer) — started as of the Mon 9/21 lecture:**

Reviewed all three sources for the 9/21 lecture: the auto-transcript
(`Transcripts/Lectures/09-21-2026_Lecture.docx`), the group's notes
(`Class Notes/09-21-2026_Lecture.docx`), and the 5 slide photos in
`Class Notes/ClassPhotos/09-21-2026_Lecture_Photos/`. **Important:** the auto-transcript
is unreliable on specifics this time — it garbles rod dimensions and wrongly claims the
Arduino output has no timestamps. The slide photos are the ground truth and resolve
both. Going forward for EXP2, trust the photos over the transcript when they conflict.

- **Objective:** map steady-state and transient 1-D temperature distribution along
  rods of different materials, model the same setup in NX, and compare
  analytical / NX-numerical / experimental results.
- **Specimens (confirmed via IMG_5705, "EXPT2 (setup)" slide):** four solid rods,
  nominal **0.2 in × 12 in**, in aluminum, stainless steel, copper, and brass — plus one
  hollow copper rod, nominal **0.3 in × 12 in**. (The auto-transcript gives contradictory
  "about a foot" vs. "about 25 inches" figures for rod length — the photo's 12 in figure
  is what to use.)
- **Heating:** 12V heater(s), rated 80°C and 120°C variants. **Cooling:** forced
  convection via a 1.5 in square fan (still air vs. fan-forced is presumably one of the
  test conditions, though this wasn't spelled out explicitly).
- **Instrumentation:** DMM(s) with thermocouple for spot-checks, plus an Arduino-based
  4-channel thermistor voltage-divider setup as the main data logger — 10kΩ series
  resistor + 10kΩ NTC thermistor per channel, on analog inputs A0–A3 (A4/A5 reserved
  for I2C, used by a 20x4 LCD at address 0x27). LCD refresh 0.5s; data logged to serial
  every 5s; max single run ~20 min.
- **Arduino code (from IMG_5709, partially visible, values confirmed):**
  `RT0 = 10000` (thermistor nominal resistance at 25°C), `B = 3977` (Beta parameter),
  `adcBits = 10`, `adcScale = 1023`, `adcRefVolt = 5.0`, series `R = 10000`, `nChan = 4`,
  `nSamp = 250`, `tDelay = 500`. Uses `LiquidCrystal_I2C`, `analogReadResolution(adcBits)`,
  `Serial.begin(115200)`. Code continues into a `Temp(int val)` conversion function that
  was cut off in the photo — worth getting the full listing once Canvas/EXP2 is
  populated.
- **Serial output DOES include timestamps** (confirmed via IMG_5708, the "Data
  Sampling" slide's Serial Monitor screenshot: e.g.
  `15:05:34.121 -> Temperature: 51.04C ... 57.85C`) — directly contradicts the
  auto-transcript's claim of "no time data." The same slide's LCD photo shows what
  looks like **6** channel readings displayed (`T0`–`T5`: 54.7, 41.1, 36.3, 32.6, 30.9,
  28.5 °C) even though the code constant is `nChan = 4` — flagged as something to verify
  in lab (T0 may be a reference/ambient channel rather than a 5th/6th rod channel).
- **Attachment method (IMG_5706):** thermistor mounted to the rod under foil wrap /
  foil tape / polyimide tape — three material options shown, actual choice affects
  contact quality and is one of the open test-plan decisions below.
- **Kit of parts (IMG_5701):** fan, foil, silicone tubing, wiring, DMMs, rulers/dowels
  — general hardware inventory shot, nothing new beyond what's listed above.
- **Open design decisions (from the group's notes, not yet resolved):** thermistor
  attachment method (which of the three from IMG_5706), number/spacing of measurement
  points along each rod, sampling rate/duration, and sequential vs. simultaneous testing
  of the different rod materials. These need to get settled before/during the next lab
  session.
- **Canvas/EXP2 not populated yet** — the group will pull material over once available. Their
  notes reference a Canvas file `SampleOutput.txt` (example Arduino serial output) that
  hasn't been located yet — read it once it shows up in `Canvas/EXP2/`.
- Folder skeleton (`Lab Data/EXP2/`, `Canvas/EXP2/`, `Transcripts/.../EXP2` as needed,
  `Output/EXP2/`) is ready to receive material as it comes in, same pattern as EXP1.

**Next likely session:** post-lab reflection report (due 9/25); EXP2 Canvas material
once the group pulls it, including `SampleOutput.txt`; first EXP2 lab session planning
(resolving the open design decisions above).


## 2026-09-22 (later still x3) — Canvas/EXP2 populated

The group added `Canvas/EXP2/Experiment_2.docx`, `Canvas/EXP2/HeatTransferFAQs.docx`,
`Canvas/EXP2/SampleOutput.txt`, `Canvas/EXP2/Heat Transfer Equations for Thin Rod.pdf`,
and `Canvas/EXP2/Presentation for Siemens NX - Heat Transfer.pdf`. Read the two .docx
files and SampleOutput.txt; this resolves/updates a few things from the 9/21 lecture
digest above:

- **Channel count resolved:** `SampleOutput.txt` and `Experiment_2.docx` both confirm
  the Arduino dump format is **4 channels only** — `[T0 T1 T2 T3, T0 T1 T2 T3, ...]`
  per time step, no header row, no embedded timestamp in the raw dump (elapsed time has
  to be reconstructed from the known step interval). This settles the "6 values on the
  LCD vs. nChan=4 in code" discrepancy flagged earlier — the dump format is
  authoritative at 4 channels; the LCD's extra values were likely a different display
  state, not part of the logged data.
- **Real sample interval is ~7s, not 5s** (HeatTransferFAQs.docx, "sample time spacing"
  Q&A): the 5s figure is just the delay in the main loop; LCD refresh overhead pushes
  the actual capture-to-capture time closer to 7s. Must correct for this by measuring
  real elapsed time rather than assuming a clean 5s grid when reducing data.
- **Heater power isn't directly measurable** — can't put a DMM in series with the
  heater (would destroy it). Instead: measure heater resistance in isolation (disconnect
  from supply, meter across the two screw terminals, can do hot or cold), then estimate
  power via P = V²/R at 12V. Not all of that power goes into the rod (asterisk on any
  energy-balance check).
- **Resistor/thermistor calibration:** nominal 10kΩ values in the voltage divider are
  just nominal — to get actual values, isolate one channel at a time (disconnect one
  thermistor leg + the Arduino A0–A3 connection) and meter across it. If measured
  values differ from nominal, the monotonic thermistor curve can be inverted after the
  fact to recompute temperatures from the original sampled voltages without re-running
  the experiment — or, more simply, reference against the DMM thermocouple reading and
  apply an additive/multiplicative correction.
- **Steady-state modeling guidance:** ignore end-of-rod heat flow, treat convective loss
  out the side as a bulk/average value over the rod length, and optionally back out k
  and h from a finite-difference estimate of the measured temperature profile (three-
  point central difference suggested). Transient PDE solving via MATLAB `ode`/`pde`
  solvers is available but flagged by the FAQ itself as likely more effort than it's
  worth — the analytical steady-state approach is the intended path.
- **Materials/equipment list confirmed** (Experiment_2.docx) matches the photo-derived
  spec already logged: 4 solid rods (Al, stainless, Cu, brass) + 1 hollow Cu rod,
  4-channel Arduino thermistor board, DMM w/ thermocouple, foil/foil tape/polyimide
  tape, fan, 12V heaters (80°C & 120°C), plus binder clamps, backing plates, and balsa
  wood (mounting/insulation hardware not mentioned in the lecture photos).
- **Two reference PDFs now in Canvas/EXP2/** not yet read in detail: "Heat Transfer
  Equations for Thin Rod.pdf" (the governing 1-D transient/steady-state model
  equations — read this before doing any analysis) and "Presentation for Siemens NX -
  Heat Transfer.pdf" (NX modeling tutorial, parallel to the EXP1 NX presentation).
  Read both once analysis work starts.


## 2026-09-23 — Today's lecture ("Thermal Conductivity Lab Setup and Requirements")

The transcript for today wasn't available (only Class Notes + 10 photos,
`IMG_5718`–`IMG_5727`). Cross-checked all 10 photos, the class notes, and a summary doc
(`Notes/EXP2/exp2-lecture-09-23-2026-thermal-conductivity.md`), an auto-generated
lecture summary, treated as a secondary source needing verification rather than trusted at face value.

**Confirmed from code slides (IMG_5719–5727, full `loop()`/`Temp()`/`dispTemps()`):**
- **4 channels only, definitively** — `TX0 = Temp(analogRead(A0))` through
  `TX3 = Temp(analogRead(A3))`. This resolves the 9/21 LCD-showing-6-values anomaly
  (IMG_5708) — that was evidently a different/older code version; the professor had
  mentioned on 9/21 he might revise the code before this lecture.
- **`Temp()` returns Kelvin, not Celsius** — new detail. `loop()` immediately does
  `TX0 = TX0 - 273.15;` (and same for TX1–TX3) right after the `Temp()` calls, before
  anything else happens to the values. So `T0` in the Beta-equation code
  (`TX = 1/((ln(RT/RT0)/B)+(1/T0))`) must be in Kelvin.
- **`dispTemps(T0,T1,T2,T3)` takes Celsius as input** and prints both C and F per
  channel on the LCD (`1.8*T0+32` for F) — one row per channel, matches the 20x4
  display.
- **`if (Serial.available() > 0) {` begins right after the buffer-save `if/else`
  block** in `loop()` — this is almost certainly the start of the "type D to dump"
  handling. But no photo captured further than that opening line — the actual body
  (what gets printed/how the dump is formatted over serial) is still unknown. This
  matters for `monitor_live_serial.m`'s `parseLine()`, which is still a placeholder
  guess, not a confirmed format.
- No photo shows the physical rods, heaters, or power supply — all 10 are code/slide
  shots. Can't verify rod diameter or power-supply readout claims from these.

**From the group's notes today:**
- NX modeling is **steady-state only** — "don't need to solve the transient." Model
  should be tuned to match experimental data, not solved independently.
- Ambient reference: use a multimeter or a thermocouple to read ambient rather than
  relying on a thermistor channel for it.
- **Group idea, worth building on:** thermistor placement — one in the center of
  the tube bore, one on the inner surface, one on the outer surface, plus one ambient
  reference. Not yet settled whether this is a proposal for the hollow rod
  specifically or a general placement scheme.

**From the (unverified) summary doc — flagged, not yet confirmed against primary
sources:**
- Matches the group's notes on steady-state-only NX modeling, and adds NX boundary-condition
  detail (adiabatic vs. flow-out-the-end, adjustable power/heat-flux/imposed-temp) and
  "must use each sensor type at least once" as a requirement.
- Also claims 3 convection modes (none / parallel-flow-away / counter-flow), titanium
  excluded this year, ±0.1°C accuracy, one transient dataset per material (optional),
  no lab 9/24 or 9/25 (lab begins Monday 9/28), instructor unavailable Tue–Fri
  10:10am–2pm, submission filename convention `EXP_TEST_PT_[TYPE]_[NAME]`.
- **Two claims directly contradict previously well-grounded facts and remain
  unresolved:** (1) says all solid rods are ~0.3" diameter — but 0.2" was confirmed
  twice independently earlier (0.3" was previously confirmed as the *hollow* rod's
  diameter only). (2) says a "vintage power supply displays current, voltage, and
  power directly, ~60W max" — contradicts the FAQ-confirmed fact that current can't be
  measured directly (would destroy the DMM) and must be estimated via P=V²/R from a
  disconnected resistance measurement. Neither claim could be checked against the group's
  own photos/notes (none show the physical setup) or a transcript (none exists for
  today). Asked the group to confirm from memory.

**Still open:** full "D"-command serial dump format (blocks finishing
`monitor_live_serial.m` for real), and the two flagged discrepancies above.

## 2026-09-23 (later) — Both flagged EXP2 discrepancies resolved (the group confirmed directly)

Asked the group to confirm the two contradictions flagged earlier today between the
(unverified) lecture summary doc and the primary sources (9/21 photos + Canvas FAQ).
Both resolved in favor of the primary sources — the summary doc was wrong on both:

- **Power supply readout: confirmed it does NOT display current/voltage/power
  directly.** The FAQ's method stands as the only way to get input power: disconnect
  the heater, meter its resistance in isolation, compute P = V²/R at 12V. Not all of
  that reaches the rod (energy-balance caveat still applies).
- **Rod dimensions: confirmed.** Four solid rods (aluminum, stainless, copper, brass),
  nominal 0.2" diameter x 12" long. One hollow copper rod, nominal 0.3" diameter x 12"
  long. Matches the 9/21 photo-derived spec exactly; the summary doc's "all rods
  ~0.3"" was wrong (that figure is the hollow tube's diameter only).

Also corrected the summary doc itself (`Notes/EXP2/exp2-lecture-09-23-2026-thermal-conductivity.md`)
in place with a Corrections section reflecting both fixes.

**No longer open:** both discrepancies from the "2026-09-23" entry above. Remaining
open items from that entry are unchanged: the full "D"-command serial dump format,
and reading the two Canvas reference PDFs (Heat Transfer Equations for Thin Rod;
Siemens NX Heat Transfer presentation) before analysis work starts.

## 2026-09-29 — EXP2 Lab Day 1 (9/28) data reviewed (cowork session)
Full write-up in `Notes/EXP2/exp2-day1-data-review.md`; figure at
`Output/EXP2/Day1_Review/EXP2_Day1_runs_review.png`. Key points:
- R1 copper steady from ~18 min; R2 aluminum quasi-steady (root drifted down ~4 C after 15 min);
  R3 "Bronze" is the BRASS rod, 13 min, NOT steady.
- `check_steady_state` default 0.05 C/s is far too loose (it declares steady at 0.3 min). Use a
  ~3-min window with <0.1 C/min instead. Not yet changed in the tool.
- TC at T0 reads 4-8 C above thermistor Ch1; per-channel offsets are ~1-2 C; Ch4 (tip) looks
  suspect. Needs an isothermal calibration on Day 2.
- Workbook Run Log / TC Cross-Check / Issues are blank; TC notes only in Sheet1.
- (9/29 later) The group updated the LabLog. Struck-through sheets/cells are INVALID (Checklist, Equipment,
  Run Log headers, Calibration % diff). New facts: the heater covers 1.5 in of the rod; positions are
  measured from the heated end (Ch4 at the tip); the Sheet1 TC readings are at T0; heater R = 6.1 ohm
  -> ~23.6 W upper bound. TC is always 2-10 C above Ch1 (systematic). Notes updated.
- (9/29) Heater was fed through the buck converter; the group measured 4.98 V output -> P = 4.98^2/6.1 ~ 4.1 W
  (NOT 23.6 W from the assumed 12 V). The workbook Calibration B13 still says 12 V.

## 2026-10-06 — R4 (stainless steel) reviewed
- Runs/R4/Steel.txt has a NEW format: CSV rows of `time_s, T0, T1, T2, T3` (2 decimals, CRLF, a blank first
  line, time counting from Arduino power-up, starting at 1051 s). This is not the Canvas D-dump, and
  import_arduino_dump.m misreads it (time read as a channel).
- Measured sample spacing is 5.54 s (the 5.06 s for R1-R3 was only an assumption). Steady ~10 min after
  heating starts; final 33.7/27.4/23.8/23.4 C. Ch3/Ch4 sit at ambient (stainless). Ch2 is consistently ~1.5-2 C high.
- Notes: Notes/EXP2/exp2-r4-steel-r5-tube-review.md. Figure: Output/EXP2/R4_Review/.
- (10/6) R5 copper tube (Runs/R5/Tube.txt): same 5-col CSV format. Converted to R5/Tube_Dformat.txt (and R4/Steel_Dformat.txt),
  verified identical. R5 = 16.9 min, mean dt 5.53 s, NOT steady (Ch1 +0.5 C/min at end; last 45.4/40.6/36.0/33.5 C).
- (10/6) R5/Tube2.txt = Tube.txt plus more data (first 184 rows identical, runs to 27.9 min, 304 samples). Converted to
  R5/Tube2_Dformat.txt. Still not fully steady at the end (slopes 0.1-0.3 C/min; last 45.8/41.1/36.3/34.0 C).
- (10/6) R6/Bronze2.txt (brass rerun; same 5-col CSV) converted to R6/Bronze2_Dformat.txt.
- (10/6) R7/Aluminum2.txt (aluminum rerun; same 5-col CSV) converted to R7/Aluminum2_Dformat.txt.

## 2026-10-06 — EXP2 video report template built (cowork session)
- EXP2's group report is the Recorded Video Presentation. Requirements pulled from Canvas/Lab Report Guidelines (2026FS).pdf:
  ~8 min nominal, PowerPoint voice-over narration strongly recommended, parallels a summary report (abstract-size content
  spoken, not written out), one style for the deck, ~1 slide/min, no large tables, slide numbers in footer, and the typical
  order cover -> intro (purpose/objective) -> optional background -> results -> conclusion -> recommendations (if any) ->
  questions -> optional blank end slide. Lecture 08-24 adds: use PowerPoint's recorder; 08-31: follow the naming convention
  in the Canvas assignment header (experiment, day, group, type).
- Template (structure only, no content): Lab Data/EXP2/Report/EXPT2_Video_Report_Template.pptx — 14 slides + 1 hidden
  checklist slide, 15 reusable layouts, per-slide speaker notes with guideline purpose + target time (totals 8:00) +
  narrator/script lines. Bottom-right corner of every slide kept clear for the PowerPoint recorder's webcam.
- (Template notes not carried into this package; see the pptx itself.)

## 2026-10-06 (later) — EXP2 requirements vs. video template; template v2 (cowork session)
- Sources re-checked: Canvas/EXP2 (Experiment_2.docx, HeatTransferFAQs.docx, Heat Transfer Equations for Thin Rod.pdf,
  NX Heat Transfer presentation), the 09-21 transcript + notes, the group's 09-23 notes, and the 09-23 recording summary in
  Notes/ (still no 09-23 transcript file in Transcripts/).
- v1 template gaps: no NX-model slots, only two generic results slides, theory marked optional, no per-rod transient,
  no model-tuning or sensor-cross-check slot. v2 fixes this: Lab Data/EXP2/Report/EXPT2_Video_Report_Template_v2.pptx
  (v1 left in place; it was open in PowerPoint). Order: Cover, Abstract, Purpose/Objective/Theory, Setup + NX model,
  one slide per rod (Cu, Al, brass, stainless: NX contour + steady-state profile + transient + key numbers),
  all-rods comparison + model tuning, Conclusions & Recommendations, References, Questions, blank, Appendix A
  (thermistor vs TC), Appendix B (extra data), hidden checklist. Notes total 8:00.
- Conflicts flagged: transient per rod is REQUIRED per Canvas (9/26 update), though the 09-23 summary called it
  optional. The thin-rod handout labels k as a "convective" coefficient (k is conductivity, W/m-K). The FAQ now says
  samples are "very close to 5 s" (older note said ~7 s); measured R4-R7 spacing is 5.53-5.54 s.
- Data per rod (last-3-min slopes, steady = all channels <0.1 C/min): Cu R1 near steady (Ch4 +0.16); Al has NO steady
  run (R2 heater end cooling, Ch1 -0.66 C/min; R7 still rising +0.34 C/min at 18 min, and R7 Ch2 reads 2.7 C ABOVE Ch1);
  brass R6 steady (R3 too short); stainless R4 steady; Cu tube R5/Tube2 not steady and not one of the 4 presented rods.
