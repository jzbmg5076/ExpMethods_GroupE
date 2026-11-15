# EXP2 — NX thermal models (summary of both takes)

## Take 2 — face-only heating, anchored (2026-10-09) — CURRENT
Folder: Lab Data/EXP2/NX/AI_SIM_TAKE_2 (reports in /Reports). Partner .prt + materials; SOL 153; QBDY3 heat flux on heated end face only; convection on lateral + far end; positions from heated face (see Runs/RunsTerminalComands.txt).

| Rod | Run | Material (k) | Ta °C | h W/m²K | q Btu/s·in² | Q W | RMS/worst °C | face T °C |
|---|---|---|---|---|---|---|---|---|
| Copper | R1 (Ch4 tip excluded) | Copper_C10100 (387) | 26.14 | 10.49 | 0.024802 | 0.769 | 0.54/0.69 | 51 |
| Aluminum | R7, Ch1 +5 °C | Aluminum_2014 (154–161) | 27.16 | 18.74 | 0.041139 | 1.337 | 0.73/0.90 | 71 |
| Brass | R6 + R3 Ch1/Ch2 (as rise over R3 tip) | Brass (116) | 27.27 | 25 (cap; free fit ~45) | 0.041615 | 1.372 | 2.11/3.36 | 72 |
| Steel | R4 | S/Steel_PH15-5 (16–18) | 24.23 | 25 (cap) | 0.044642 | 1.472 | 0.42/0.63 | 149 |
| Tube (new part, OD .3142 ID .2358) | R5 | Copper_C10100 (387) | 26.82 | 18.86 | 0.062304 | 2.186 | 0.30/0.51 | 62 |

Mass vs lab: Cu −3.3%, Al −6.7%, Brass +3.6%, Steel −1.2%, Tube −4.8%.
NX gotcha: ctrl+A inside an NX dialog field selects ALL faces into the selection — use End+Backspace instead. Verify load faces from the .dat file.

Note: NX solver outputs (.op2/.dat/.f06/.log) are not included in this package (too large for GitHub). Re-solve the .sim files in NX to regenerate them.

## Take 1 — all 5 rods (2026-10-08) — superseded by Take 2
Write-up: `Output/EXP2/NX_AllRods_Fit/SUMMARY.md` (+ plot `EXP2_AllRods_NX_vs_Data.png`). The Take 1 model files were in `Lab Data/EXP2/NX/OLD/`, which is not included in this package.
- Mesh CTETRA(4) at 0.06 in (tube 0.03 in). SOL 153 steady heat transfer. Heat flux on the heated end face; convection on the outer lateral surface. NX reports in °F/inch units.
- Steady values = mean of the last 3 minutes. Channel offsets from the isothermal start subtracted: Ch1 +0.02, Ch2 +1.41, Ch3 −0.57, Ch4 −0.86 °C. Ambient = pre-heat mean of all channels (stainless: far channel, 24.23 °C). k held at NX library value; h and Q least-squares fitted at thermistor points (h capped 5–25 W/m²K).

| Rod | Run used | h (W/m²K) | Q (W) | Fit (data → NX) | Heated-end T |
|---|---|---|---|---|---|
| Copper | R1 | 10.5 | 0.77 | Ch1–3 within 0.75 °C; tip Ch4 excluded | 51 °C |
| Aluminum | R2 | 13.0 | 0.68 | worst error 1.9 °C | 53 °C |
| Brass | R6 | 25 (cap) | 1.44 | worst error 2.7 °C | 74 °C |
| Stainless | R4 | 25 (cap) | 1.51 | worst error 0.65 °C | 156 °C — unrealistic |
| Cu tube | R5 | 18.9 | 2.17 | worst error 0.54 °C | 61 °C |

Open items from Take 1: stainless heated-end temperature (heat really enters over the 1.5 in under the clamp — needs a split-face heated band); aluminum R7 has Ch1 reading below Ch2; brass R6 profile not fin-shaped; tube R5 not fully steady and NX ID 0.230 in vs 0.2365 in measured.

## Video report deck (Rev2 analysis, 2026-10-09)
Final deck is `Lab Data/EXP2/Report/EXP2_GroupE_Video_Report_Rev4_Final.pptx` (see `EXP2_Recording_Guide_Rev4.md`). Rev2-era requirements: every plot made by MATLAB code; plain student look; only Canvas equations (steady + transient thin-rod eqs, FAQ simplifications, P=V²/R, 3-pt central difference) plus RMS; NX thermal gradient visuals; focus = what NX and analytical (Excel sheet) say h/k are, and whether NX matches experiment and analytical.

Analytical = Excel Calculations sheet method (3-pt central diff at 2nd sensor → m² → h/k → h with handbook k) with corrected inputs + MATLAB least-squares fit of the same steady eq (tip loss ignored) to all sensors.
Excel sheet input issues found (sheet not edited): spacing Cu 1 in (should be 2.5), Al 2.6 (R7 is 1.0), tube 2.5 (2.0), steel 2.5 (1.5); T_fluid 21.1 for all (measured 24.2–27.3); tube/steel temperature columns swapped; Al uses R2.

Results: h NX / h fit / k implied (using NX h): Cu 10.5/10.6/384; tube 18.9/19.3/379; Al 18.7/18.9/153; brass 25cap/39.5/73 (handbook 116); SS 25cap/42.6/10 (handbook 17). Excel 3-pt h: 31.9, 34.2, negative, 146, 49.8 (too noise-sensitive).
NX vs exp RMS: 0.54, 0.30, 0.72, 2.14, 0.41 °C. NX vs analytical: 0.03, 0.01, 0.06, 0.94, 0.46 °C.
