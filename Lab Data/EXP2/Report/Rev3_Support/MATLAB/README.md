# MATLAB figures and data review

Run `make_exp2_presentation_figures(workspaceRoot)` in MATLAB. The root is the ExperimentalMethods directory; the default is the original Windows folder (edit to your own path). All PNG plots here are exported by MATLAB. No NX contours or CAD geometry are drawn here. NX profile curves use existing exported nodal-temperature CSV files, with face-temperature extrema cross-checked against the current Take2 individual reports. These curves are not screenshots from NX.

## Sources and processing

- Raw temperatures: Runs R1/Copper.txt, R7/Aluminum2.txt, R6/Bronze2.txt, R4/Steel.txt, and R5/Tube2.txt.
- Copper sampling interval: assumed 5.06 seconds, because its dump has no timestamps. Other runs use measured timestamps. Time zero is recording start, not a verified heater-switch event.
- Four station positions: RunsTerminalComands.txt and Take2 reports. Use as the reported reconstruction; workbook/command discrepancies require confirmation.
- Final-window mean: last 180 seconds, with no assertion that all runs reached equilibrium.
- Reported offset vector [0.02, 1.41, -0.57, -0.86] °C is subtracted for profiles. Raw transients preserve recorded readings.
- Aluminum profile: additional assumed +5 °C on Ch1 to reproduce Take2. The unshifted corrected Ch1 is shown separately. This is a scenario correction, not a measured calibration value.
- Copper Ch4 stays visible but is omitted from analytical fitting, as in Take2.
- Brass R3 points [35.88,30.94] °C at [4.2,6.8] in reproduce the Take2 report's ambient-adjusted transient targets. They are not steady-state data. The analytical curve fits only final R6 values; the NX fit used six combined targets.
- Analytical curve: constant-k insulated-tip fin equation, descriptive fit to adjusted final means. NX Take2: 3D SOL153, end-face heat input, lateral plus far-end convection. The tip boundary conditions differ. Neither fitted curve is an independent validation experiment.
- NX h/Q/k/RMS values are from AI_SIM_TAKE_2/Reports, dated 2026-10-09. RMS plot uses authoritative report residuals at original calibration targets; binned curve interpolation would give slightly different values.

## Defensible conclusions

Final 3-minute maximum channel drift: copper 0.163, aluminum 0.367, brass 0.092, stainless 0.063, copper tube 0.306 °C/min. With <0.1 °C/min for all channels, only brass and stainless satisfy the terminal window criterion. Copper Ch1–3 pass, but Ch4 does not. First qualifying windows (as in Rev2) do not imply the remainder of a run stayed steady; do not quote those as confirmed steady-state times.

Take2 fitted h (W/m²K) / rod Q (W): copper 10.49/0.769; aluminum 18.74/1.337; brass 25/1.372; stainless 25/1.472; tube 18.86/2.186. Heater electrical estimate is 4.98²/6.1=4.066 W; rod Q is a model fit, not a direct calorimetric measurement.

NX materials are Copper_C10100 k387; Aluminum_2014 k154–161; brass k116; stainless S/Steel_PH15-5 k16.0–17.9 W/mK. Stainless k17 in the analytical script is representative; it is not measured. Old AISI304 summaries are stale.

Take2 face temperatures: copper51.2, aluminum71.2, brass72.2, stainless149.2, tube62.5 °C. Stainless's predicted face temperature exceeds the reported approximately120 °C heater limit. Good residuals at downstream sensors do not validate the heater boundary.

Steady profiles constrain h/k. Reporting h assumes the library k; reporting k requires an independently specified h. No independent alloy-k measurements or formal sensor uncertainty propagation are available in these fits. Curvature estimates amplify sensor errors: the three-point aluminum result is negative even after +5°C, and brass exceeds the lecture h range. Treat these as diagnostics, not physical material properties.

Current NX report plots and Rev2 MATLAB 'fig03_NX' geometry views are not authentic NX viewport screenshots. User requested genuine screenshots; these are deliberately not substituted.
