# EXP4 Thermodynamics (Stirling engine) — kickoff notes (2026-10-26; script + lab game plan added 10/27)

- Sources read:
  - `Transcripts/Lectures/10-19-26_Lecture.docx`: EXP4 starts at ~07:53.
  - `Transcripts/Lectures/10_21_26-Lecture.docx`: the 10/21 Q&A. The header says Oct 26 6:11 PM, which looks like the upload time. EXP4 starts late in the ~06:02 segment.
  - `Canvas/EXP4/[README]Thermodynamics.docx`, `Canvas/EXP4/[FAQ]Thermodynamics.docx`, `Canvas/Equipment_FAQ.docx`
  - `Canvas/EXP4/realStirlingEngine.m` (behavior checked with a line-by-line Python port).
- Lab Day 1 was Tue 10/27. Lab Day 2 was Tue 11/10.

## Lab game plan deliverables (built 2026-10-27, EXP3-kickoff format)
In `Lab Data/EXP4/`:

### `EXP4_Lab_Guide_GroupE.pdf`
A 14-page visual guide with 11 figures. Sections: plain-version summary and cross-check flags; big picture and run matrix; how the engine works (cutaway, crank timing, P-V loops); the model and its inputs, with a dimension map naming the 9 lengths and the phase; setup and wiring; tach and scope traces, good vs. bad; heating setups A, B, C and the flipped option; running a point (steady-state rule, stall point, time budget); expected data shapes; run of show and roles; professor's advice, unknowns, fundamentals, pre-lab checklist.

### `EXP4_TestPlan_and_RunLog.xlsx`
14 sheets and 4060 formulas, recalculated with 0 errors.
- Read Me, Test Plan, and Run Matrix (counts the kept Run Log rows).
- Engine Geometry: 3 readings per length; the script's volumes, and CR in closed form: CR = (V̄ + A_p·s_p/2)/(V̄ − A_p·s_p/2); four PASS/FAIL sanity checks; copy-ready `eng.*` MATLAB lines. With the posted values it reproduces CR 1.754 and a regenerator volume of −4.22 cm³.
- Heater & Power: R cold and hot, plus a P = V²/R planning table.
- Ambient: corrects sea-level pressure to station pressure to give P0.
- Run Log: computes P, ΔT, temperatures in K, RPM = 10f and the Carnot limit. Chart helper cells are set to −1 so those points stay off the charts.
- Steady-State Check: shows STEADY when the last 2 intervals (at least 3 min) are under 0.1 °C/min and 1 %/min RPM.
- Charts: 3 live scatter plots. Model Runs: looks up T and RPM by Point ID. Scope & Tach: checklist, USB save steps, f→RPM table. Equipment, Photos (shot list), Issues & Notes.

### Run plan
- A: bottom heat, exposed base. Find the stall point, then 3–5 power steps.
- B: bottom heat, insulated base. Same steps, then match A's base temperature to estimate the power lost to open air.
- C: top heat. Reverse at A's ΔT values (Day 2).
- D: orientation (optional).
- R: repeats.

The planning geometry in the guide is illustrative, not the real engine: a 10 cm chamber, a 9.6 × 1.2 cm displacer and a 1.8 cm piston. It gives CR ≈ 1.04 and a loop spanning a few kPa around room pressure.

## What it is
- One beta-type Stirling engine per station, with a 12 V foil heater mounted on the base.
- The limit is about 100 °C. A little over that starts melting the displacer.
- It is not self-starting: flick it in its running direction. Heating the top instead makes it run the other way.
- There is no separate analytical or NX model. The MATLAB script `realStirlingEngine.m` is the model, and groups may modify it or write their own.
- Main objective (README): characterize the engine against the idealized real Stirling cycle.
- Listed results:
  - steady-state speed vs. average electric power
  - steady-state top and bottom temperatures vs. power
  - exposed vs. insulated base (match temperatures to estimate the power lost to open air)
  - the resulting cycle vs. the ideal Stirling cycle, and efficiency vs. Carnot
- Stretch goal: effective engine power and efficiency.
- Lecture emphasis: bottom-heated vs. top-heated at the same ΔT. Does reverse run at the same speed? "Don't assume."
- Optional: does orientation matter?
- Not asked for: spin-up time, speed variation within a cycle, gas pressure.

## Equipment and key settings
- Buck converter (ZK-12KX) with voltage and current limiting, set by hand. Its display shows output V and A.
- Two DMMs with thermocouples. Use polyimide tape on hot surfaces, and foil tape only where it stays cool.
- Dual 12 V 80 °C heaters available for top heating.
- IR tach on a 9 V transformer, mounted with K'nex, binder clips and painter's tape, with a ~½ in gap.
  - 6 spokes give 6 pulses per revolution, so RPM = (f ÷ 6) × 60 = 10f.
  - Top speed is ~300 RPM, so expect ~30 Hz.
- Scope hookup: ground clip to tach ground, tip to signal; shared grounds; DC coupling, probe and channel at ×1; trigger on the rising edge; read frequency with cursors; test the tach before mounting it.
- The disassembled engines by the central column are for interior dimensions.
- The Styrofoam bowl and the two stands give the exposed vs. insulated configurations. Silicone insulation worked worse than foam.
- Never put heaters on K'nex; use balsa. Keep the 12 V and 9 V supplies separate.

## realStirlingEngine.m — what it actually does
- It's a Schmidt-type model: three gas spaces (hot, cold, regenerator) at fixed temperatures, sharing one pressure, P = mR / (VH/TH + VC/TC + VR/TR).
- It steps the displacer crank angle from 0 to 360° and plots P (kPa) vs. total V (cm³). It prints CR = max V / min V.
- It does **not** compute work, power, efficiency or the ideal cycle.
- Geometry inputs (`engineGeometry`, all in cm). The posted values are not our engine:
  - `baseDiameter` 3.2: inner diameter of the clear chamber ring
  - `baseThickness` 2: chamber height between the plates
  - `displacerDiameter` 8: black foam displacer
  - `displacerThickness` 0.1
  - `displacerOffset` 2.8: hot plate to displacer midline at mid-stroke
  - `displacerStroke` 1.3: full travel
  - `pistonDiameter` 3.2: glass piston
  - `pistonOffset` 1: cold plate to the bottom of the piston at mid-stroke
  - `pistonStroke` 1.3 (its comment wrongly says "displacer")
  - `pistonPhase` −π/2 rad: the piston lags the displacer by 90°
- Volumes:
  - hot = base area × (offset + stroke/2·cos θ − thickness/2)
  - cold = base area × the gap above the displacer, **plus the piston-cylinder volume**, so the air under the power piston counts as cold
  - regenerator = (base area − displacer area) × displacer thickness, constant
- Temperatures are in **kelvin** (posted TH = 900 K, TC = 373 K). TR = (TH + TC)/2.
- Gas: R = 2077 J/kg·K is helium's value; air's is 287. P0 = 1.2 MPa is for a pressurized engine. State 1 is at a displacer angle of 180° (the comment offers 135°).
- Quirks:
  - The estimate line `m = (P0/R)*(...)` always overwrites the typed `m = 0.00016`. To type in a mass, comment the estimate out.
  - The mass comment says "grams", but the result is in kg.
  - With the estimate active, R cancels out of P (changing R from 2077 to 287 changes P by 0, and the printed mass from 1.7e-5 to 1.2e-4 kg).
  - The posted geometry is impossible: the displacer is wider than the base (regenerator volume −4.22 cm³) and sits above the 2 cm lid. The posted run gives CR 1.754 and P from 942 to 7146 kPa, which is meaningless.
- Sanity checks for measured numbers: baseDiameter > displacerDiameter; displacerOffset ± (stroke/2 + thickness/2) stays within 0 to baseThickness; pistonOffset > pistonStroke/2.
- Modeling top heating needs edits: swap the hot and cold assignments. The air under the piston then becomes hot-side air.

## Power method (carried over from EXP2)
- P = V²/R with R measured with the heater disconnected (cold and hot), or P = V·I read directly off the buck converter display.
- Measure the actual voltage across the heater — the buck output, not the 12 V supply.

## Open questions (from kickoff)
1. Is the ideal-cycle comparison required, and will the professor add that plot to the script? The posted script has none.
2. How does he want efficiency evaluated? The script has no work calculation.
3. EXP4 report format — check Canvas.
4. Group decisions: which state is state 1 (where P0 applies); surface thermocouples standing in for gas temperatures; whether to model top heating.

## Flags
- The professor says a compression ratio closer to 1 makes this engine better, but the ideal-cycle net work grows with ln(CR). This is presumably real-engine behavior (small ΔT, friction). Open thinking question.
- Both EXP4 lectures also opened with EXP3 validation advice: a thickness sensitivity study, an added-mass check for the accelerometer, and Blevins interpolation caveats.
