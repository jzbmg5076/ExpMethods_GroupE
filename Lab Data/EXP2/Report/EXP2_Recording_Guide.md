# EXP2 video report recording guide

**Deliverable:** `EXP2_GroupE_Video_Report_Rev3_Final.pptx`. Record slides 1–11. Slides 12–15 are hidden supporting material. The PDF preview includes all 15 slides. The speaker notes contain the suggested narration and per-slide sources. The narration is a working script for the group to adapt into its own spoken wording. No audio or video is embedded yet.

## Course requirements

The [Lab Report Guidelines](../../../Canvas/Lab%20Report%20Guidelines%20%282026FS%29.pdf), page 3, describes the recorded report as slides with voice-over and a nominal duration of about 8 minutes. PowerPoint voice-over is strongly recommended. Abstract-sized content should be spoken rather than written as a long abstract. Page 4 recommends one consistent style, roughly one slide per minute, focused slides, readable figures, no large tables, slide numbers, and a sequence of cover, purpose/objective, optional background, results, conclusions/recommendations, and questions. The supplied guidelines do not state a required video resolution, narrator split, or submission filename. Check the current Canvas assignment header for the final upload name.

The [EXP2 specification](../../../Canvas/EXP2/Experiment_2.docx) requires a transient response for each rod and comparison of experimental, analytical, and numerical results. This deck uses five results slides, one per rod, to keep each transient and profile readable. The 11-slide main talk runs about eight minutes, a little faster than the one-slide-per-minute rule of thumb.

## Timing and suggested presenter split

| Slide | Subject | Presenter | Time | Cumulative |
|---|---|---|---:|---:|
| 1 | Heat transfer in thin metal rods | Nick | 15 s | 0:15 |
| 2 | Lab objectives and experimental method | Nick | 45 s | 1:00 |
| 3 | Analytical model and NX setup | Nick | 55 s | 1:55 |
| 4 | Copper results | John | 55 s | 2:50 |
| 5 | Aluminum results | John | 55 s | 3:45 |
| 6 | Brass results | John | 55 s | 4:40 |
| 7 | Stainless steel results | Jesus | 55 s | 5:35 |
| 8 | Hollow copper tube results | Jesus | 55 s | 6:30 |
| 9 | Model agreement and uncertainty | Jesus | 45 s | 7:15 |
| 10 | Conclusions and recommendations | Jesus | 40 s | 7:55 |
| 11 | Questions | Jesus | 5 s | 8:00 |

Suggested split: Nick 1:55, John 2:45, Jesus 3:20. Change the split if the group prefers. Rehearse once with the actual pauses and transitions, then trim the spoken script to stay close to 8:00. Use PowerPoint’s recording feature and export the recording as a video using recorded timings and narration. Leave the hidden supporting slides out of the main recording. If using a webcam overlay, check its placement so it does not cover a plot, finding, or footer.

## Results that must stay qualified

- The final-window slope criterion is our operational analysis choice: every included channel must have |dT/dt| below 0.1°C/min over the final 180 seconds. It is not an instructor-prescribed guarantee of thermodynamic equilibrium. Brass and stainless pass. Copper Ch1–3 pass but Ch4 fails. Aluminum and the tube fail.
- Raw transient plots preserve recorded temperatures. Profiles subtract the reported baseline offset vector [0.02, 1.41, −0.57, −0.86]°C. Those offsets are not a documented full thermocouple calibration.
- Aluminum uses an assumed +5°C Ch1 scenario in the profile fit. Do not call it a measured calibration. Copper Ch4 is excluded from fitting but remains plotted. Brass NX fitting mixes R6 final data with ambient-adjusted R3 transient targets.
- NX and analytical curves are data-fitted. Their residuals measure calibration agreement and are not held-out validation or independent conductivity measurements. All reported h values depend on assumed library k.
- NX uses lateral and far-end convection. The analytical baseline assumes an insulated tip. The physical heater covers about 1.5in, while the model applies heat on the end face. Stainless NX predicts approximately149°C at that face; that root temperature needs checking against the physical heater/contact model.
- The stationary positions follow the terminal commands and Take2 reconstruction, while some workbook entries conflict. R1 time assumes5.06s/sample. R4–R7 use recorded timestamps. Stainless NX diameter and tube ID also differ from the workbook. See hidden slide13 and MATLAB/README.md.

## Authentic NX screenshots

No model or contour image is included because NX could not reach `currents.ad.uc.edu`, its university license server. The previous MATLAB cylinder renderings were excluded. The MATLAB curves in the presentation plot exported NX temperatures and are labeled accordingly. They are not screenshots of NX. Once licensing is reachable, use [the capture instructions](Rev3_Support/NX_capture_status.md) to open the final `AI_SIM_TAKE_2` models and saved results, capture geometry and temperature contours in NX, and include the genuine images. Retain legends, units, model identification and hot/cold ends.

## Reproducing the figures

All ten embedded plots were generated in MATLAB R2022b. The supporting folder also includes an optional RMS comparison plot. Open `Rev3_Support/MATLAB/make_exp2_presentation_figures.m`, put that folder on the MATLAB path, and run:

```matlab
make_exp2_presentation_figures('C:\path\to\ExpMethods_GroupE')
```

The CSV and MAT outputs preserve final-window means, slopes and fitted analytical quantities. The embedded NX node CSV files were copied from the earlier export and cross-checked against Take2 report face-temperature extrema. The source README records the processing choices. Raw run files and NX models were left unchanged.

## Suggested narration and sources

### Slide 1: Heat transfer in thin metal rods

Our group studied one-dimensional heat transfer in thin metal rods. We compared experimental temperature histories with the fin equation and Siemens NX simulations, then examined how sensor corrections and boundary assumptions affect confidence in the results.

Sources:

- Canvas/Lab Report Guidelines (2026FS).pdf, pp. 3–4
- Canvas/EXP2/Experiment_2.docx
- Canvas/EXP2/HeatTransferFAQs.docx

### Slide 2: Lab objectives and experimental method

The physical picture is a hot end feeding energy down the rod while the exposed surface loses heat to the room. Each material develops a different temperature profile. We used four thermistors connected to the Arduino, with a thermocouple as a cross-check, and MATLAB to view the measurements in lab. Copper, aluminum, brass, stainless steel, and the hollow copper tube each have a recorded transient response. The measured heater voltage was 4.98 volts and its resistance was 6.1 ohms, giving about 4.07 watts of electrical input. The heat entering a rod is lower because the heater and clamp also lose energy.

Sources:

- Canvas/Lab Report Guidelines (2026FS).pdf, pp. 3–4
- Canvas/EXP2/Experiment_2.docx
- Canvas/EXP2/HeatTransferFAQs.docx
- Lab Data/EXP2/EXP2_TestPlan_and_LabLog.xlsm (unstruck cells only)
- Lab Data/EXP2/InLabTool/EXP2_SteadyStateTool/import_arduino_dump.m

### Slide 3: Analytical model and NX setup

For analysis, we treated each rod as a fin. Conductivity k carries energy along the rod, and the convection coefficient h describes heat loss to room air. The steady equation balances those two effects. Its profile depends mainly on h divided by k, so temperature data alone cannot identify both independently. We held the NX library conductivity fixed and fitted h and heat input Q. NX uses end-face heating and convection on the lateral surface and far tip. The analytical baseline assumes an insulated tip. That differs from the physical heater, which covers about 1.5 inches. We checked the final three minutes of each run against a slope threshold of 0.1 degrees Celsius per minute. A good fit remains conditional on the chosen sensor positions and corrections.

Sources:

- Canvas/Lab Report Guidelines (2026FS).pdf, pp. 3–4
- Canvas/EXP2/Experiment_2.docx
- Canvas/EXP2/HeatTransferFAQs.docx
- Canvas/EXP2/Heat Transfer Equations for Thin Rod.pdf, p. 1
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/EXP2_NX_take2_Final_Report_All_Rods.pdf
- Lab Data/EXP2/EXP2_TestPlan_and_LabLog.xlsm (unstruck cells only)

### Slide 4: Copper results

Copper shows heat spreading well along the rod. The raw temperature histories flatten at the first three channels, with final slopes below 0.1 degrees Celsius per minute. The tip channel still rises at about 0.16, so we call this a near-steady profile with a tip-channel concern. The NX fit uses the first three corrected stations and excludes the tip. Its reported RMS residual is 0.54 degrees Celsius for those fitted targets. The corrected tip reading is about 33.9 degrees, while NX predicts roughly 37.7. That discrepancy remains visible rather than being hidden by the fit. The fitted heat input is 0.769 watts, well below the heater's electrical input.

Sources:

- Lab Data/EXP2/Runs/R1/Copper.txt
- Lab Data/EXP2/Runs/RunsTerminalComands.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/1_Copper_take2_report.pdf
- Lab Data/EXP2/Report/Rev2_MATLAB/EXP2_Rev2_Figures.m

### Slide 5: Aluminum results

The aluminum rerun continues heating at the end. Its largest final slope is about 0.37 degrees Celsius per minute, so it does not meet our steady-state test. The raw second channel is hotter than the first, despite being farther from the heater. That points to a sensor or contact issue rather than a clean monotonic profile. The Take2 analysis adds five degrees to channel one as an assumed correction. With that assumption, the reported NX RMS residual is 0.73 degrees. This is a sensitivity case, not a verified calibration. We would repeat the run after calibrating the channels and allow more time before interpreting its fitted parameters as steady results.

Sources:

- Lab Data/EXP2/Runs/R7/Aluminum2.txt
- Lab Data/EXP2/Runs/RunsTerminalComands.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/2_Aluminum_take2_report.pdf

### Slide 6: Brass results

The file named Bronze2 is the brass rerun, matching the material inventory. R6 lasts about 25 minutes, and all four final slopes fall below 0.1 degrees Celsius per minute. Its final-window profile is therefore our stable brass measurement. The Take2 simulation fit also includes selected readings from the earlier R3 transient, adjusted for ambient temperature. Those extra targets are shown separately on the profile plot. The report gives a 2.11-degree RMS residual for the mixed target set. The fitted convection coefficient reaches the upper allowed bound of 25. That limit, together with the mixed data, means the fitted coefficient should be treated cautiously.

Sources:

- Lab Data/EXP2/Runs/R6/Bronze2.txt
- Lab Data/EXP2/Runs/R3/Brass.txt
- Lab Data/EXP2/Runs/RunsTerminalComands.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/3_Brass_take2_report.pdf

### Slide 7: Stainless steel results

Stainless shows the steepest temperature decay near the heated end. The downstream sensors stay near ambient, which matches its much lower conductivity compared with copper. All final slopes are below 0.1 degrees Celsius per minute. The NX report gives a 0.42-degree RMS residual at the four fitted targets, but again h reaches its upper bound. The current model uses the PH15-5 stainless library material, whose conductivity varies with temperature. Its end-face heating produces a root temperature near 149 degrees Celsius. That root is a numerical consequence of concentrating heat on the end face, and it needs comparison with the actual heater contact region and material grade.

Sources:

- Lab Data/EXP2/Runs/R4/Steel.txt
- Lab Data/EXP2/Runs/RunsTerminalComands.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/4_Stainless_steel_take2_report.pdf

### Slide 8: Hollow copper tube results

The extended Tube2 file includes nearly 28 minutes of data. All four channels are still rising, and the largest final slope is about 0.31 degrees Celsius per minute. The tube therefore fails the final-window stability check, even though it may have passed a rolling check earlier. The Take2 simulation fits the four corrected final readings with a reported RMS residual of 0.30 degrees. That close fit describes the selected profile, not proof that the experiment reached steady state. The hollow tube also changes cross-sectional area relative to exposed perimeter, so its behavior cannot be attributed to conductivity alone. The next run should continue longer and verify the tube's inner diameter.

Sources:

- Lab Data/EXP2/Runs/R5/Tube2.txt
- Lab Data/EXP2/Runs/RunsTerminalComands.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/5_Copper_tube_take2_report.pdf
- Lab Data/EXP2/EXP2_TestPlan_and_LabLog.xlsm

### Slide 9: Model agreement and uncertainty

The fitted convection coefficients range from about 10.5 to 25 watts per square meter Kelvin. The rod heat inputs range from about 0.77 to 2.19 watts, below the 4.07 watts of electrical heater input. Brass and stainless both reached the imposed upper bound on h, which signals that the fitting assumptions deserve another look. The principal measurement limits are channel offsets, sensor contact, and conflicting station descriptions in the workbook. Continued drift also affects aluminum and the tube. These fits reproduce selected profiles, but they do not independently establish the material conductivity or verify every boundary condition.

Sources:

- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/EXP2_NX_take2_Final_Report_All_Rods.pdf
- Lab Data/EXP2/EXP2_TestPlan_and_LabLog.xlsm (unstruck cells only)
- Lab Data/EXP2/Runs/R1/Copper.txt
- Lab Data/EXP2/Runs/RunsTerminalComands.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/1_Copper_take2_report.pdf
- Lab Data/EXP2/Report/Rev2_MATLAB/EXP2_Rev2_Figures.m
- Lab Data/EXP2/Runs/R7/Aluminum2.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/2_Aluminum_take2_report.pdf
- Lab Data/EXP2/Runs/R6/Bronze2.txt
- Lab Data/EXP2/Runs/R3/Brass.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/3_Brass_take2_report.pdf
- Lab Data/EXP2/Runs/R4/Steel.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/4_Stainless_steel_take2_report.pdf
- Lab Data/EXP2/Runs/R5/Tube2.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/5_Copper_tube_take2_report.pdf
- Lab Data/EXP2/EXP2_TestPlan_and_LabLog.xlsm

### Slide 10: Conclusions and recommendations

The measured temperature histories and axial profiles support the expected fin behavior. Copper carries heat farther along the rod, while stainless loses most of its temperature rise near the heated end. Brass and stainless pass our final-window stability test. Aluminum and the tube still need longer measurements, and copper has a tip-channel concern. Our strongest recommendation is to verify station locations and calibrate all channels at the same known temperature before repeating the runs. The next simulation should represent the heater contact region, compare tip conditions, and use fresh measurements that were not included in the fit.

Sources:

- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/EXP2_NX_take2_Final_Report_All_Rods.pdf
- Lab Data/EXP2/EXP2_TestPlan_and_LabLog.xlsm (unstruck cells only)
- Lab Data/EXP2/Runs/R1/Copper.txt
- Lab Data/EXP2/Runs/RunsTerminalComands.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/1_Copper_take2_report.pdf
- Lab Data/EXP2/Report/Rev2_MATLAB/EXP2_Rev2_Figures.m
- Lab Data/EXP2/Runs/R7/Aluminum2.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/2_Aluminum_take2_report.pdf
- Lab Data/EXP2/Runs/R6/Bronze2.txt
- Lab Data/EXP2/Runs/R3/Brass.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/3_Brass_take2_report.pdf
- Lab Data/EXP2/Runs/R4/Steel.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/4_Stainless_steel_take2_report.pdf
- Lab Data/EXP2/Runs/R5/Tube2.txt
- Lab Data/EXP2/NX/AI_SIM_TAKE_2/Reports/5_Copper_tube_take2_report.pdf
- Lab Data/EXP2/EXP2_TestPlan_and_LabLog.xlsm

### Slide 11: Questions

Thank you. We can discuss the sensor corrections, stability checks, and model assumptions.

Sources:

- Canvas/Lab Report Guidelines (2026FS).pdf, pp. 3–4
- Canvas/EXP2/Experiment_2.docx
- Canvas/EXP2/HeatTransferFAQs.docx
