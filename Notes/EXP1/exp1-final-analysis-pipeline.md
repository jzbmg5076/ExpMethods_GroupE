# EXP1 Final Analysis pipeline (22 Sep 2026)

Folder: Output/EXP1/EXP1_Final_Analysis/ — run `run_exp1_all` in MATLAB.
1. combined_plate_pendulum_analysis.m (copy; Plate 4 labeled 6061 Al; final NX assembly 23.4476/100.5195/122.5171; saves plot_cache)
2. plate_moi_comparison_analysis.m (copy; HDPE uses final NX 9.9802/54.5123/64.2381, CG z 0.3865)
3. exp1_report_outputs.m (new): Arduino sine-fit frequencies, paired bifilar, uncertainty (±0.25 in lengths, ±0.125 in radius, SEM of period), sensitivity, density check, principal-axis angles, report Tables 1/3/5/6/7/8, run log, sample calcs, 3 report figures -> report_outputs/
Helpers copied: analytical_extruded_plate.m, notched_plate_perimeter_holes.m, rectangular_perimeter_holes.m. Originals in Analytical_Plate_Models untouched.
Step 3 verified in GNU Octave against the existing step 1/2 CSVs; steps 1–2 only had label/NX-value edits and still need a MATLAB run.
Code-vs-report differences: frame length-only sensitivity is 6.2% (6.6% is total); NX scaled Config 2 = 9.983 (report 9.980 = native).
