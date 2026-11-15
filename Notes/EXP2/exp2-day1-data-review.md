# EXP2 (Heat Transfer) — Lab Day 1 (Mon 9/28/2026) data review

Sources checked: `Lab Data/EXP2/EXP2_Day1_Runs1_2_3_LabLog.xlsm` (re-read 9/29 after the group's update), `Runs/R1–R3/*.txt` (Arduino D-dumps), `Runs/RunsTerminalComands.txt`, `InLabTool/`, `Canvas/EXP2/ArduinoCode/EXPT2_1d.txt`, and the lab transcript (secondary only). Figure: `Output/EXP2/Day1_Review/EXP2_Day1_runs_review.png`.

**Workbook validity (per the group, 9/29):** sheets or cells with strikethrough are NOT used. Struck out: Checklist, Equipment, the Run Log headers, and the Calibration "% diff" columns. The live sheets are Rod Specs, Sheet1 (thermocouple, "TC", readings every 5 min), Calibration (measured resistances plus heater R), Issues & Notes, and Test Plan/Read Me. The Run Log and TC Cross-Check both just point to "Runs + Sheet1".

## Setup facts (from Issues & Notes, 9/29 update)
- The heater clamps the first **1.5 in** of the rod.
- The thermistors were placed starting from the free (far) end and working back toward the heater: 2.5 in spacing (R1) and 2.6 in (R2, R3). The logged positions are measured from the heated end of the rod, so Ch4 sits right at the tip.
  - Distance from the heater edge: Cu 2.75 / 5.25 / 7.75 / 10.25 in; Al and brass 2.7 / 5.3 / 7.9 / 10.5 in.
- The TC readings in Sheet1 were taken at T0 (the Ch1 location), plus a few at the heater. Ambient was measured with the TC, but the value isn't written down.
- **Heater power (confirmed by the group, 10/1):** the heater was fed through the **buck converter**.
  - **4.98 V** was measured across it **under load** (heater connected and running), so this is the right voltage to use.
  - **6.1 Ω** was measured **cold**.
  - **P = 4.98² / 6.1 ≈ 4.1 W**, I ≈ 0.82 A. The earlier 23.6 W assumed a full 12 V and is wrong.
  - The workbook's Calibration sheet (B13) still says 12 V.
  - Hot vs. cold resistance: if the element's resistance rises when hot, the real power is a bit below 4.1 W. A plain resistance wire changes only ~1–2% over a ~40 °C rise. A self-regulating ("80 °C / 120 °C" rated, PTC-type) heater rises sharply, but mainly near its rated temperature, and the heater only reached ~58–63 °C. Either way, treat 4.1 W as the upper bound. On Day 2 the hot R can be read right after switching the heater off (the FAQ allows hot or cold).
  - Plausibility check: the copper conduction between Ch1 and Ch2 at steady state is k·A·ΔT/Δx ≈ 400 × 1.93e-5 m² × (2.4 K / 0.0635 m) ≈ 0.3 W, so only a fraction of the ~4 W reaches the rod. That's consistent, and it's an upper bound for the NX heat load.

## Runs (5.06 s/sample assumed — interval never timed)
| Run | Rod | Samples / duration | End state (last 3-min mean, Ch1→Ch4, °C) | Steady? |
|---|---|---|---|---|
| R1 | Copper (solid) | 334 / ~28 min | 43.0, 40.6, 38.2, 33.1 | Yes, from ~18 min (3-min window, <0.1 °C/min) |
| R2 | Aluminum | 284 / ~24 min | 37.8, 33.4, 32.3, 28.3 | Quasi. Ch1 peaked ~41 °C at 15 min, then fell ~4 °C; the TC at T0 also fell 49→44 °C, so the heater end really cooled |
| R3 | Brass (file named "Bronze") | 154 / ~13 min | 34.5, 31.0, 26.6, 25.1 | No. Ch1 still rising +1.4 °C/min, and the rod started non-uniform |

## TC at T0 vs thermistor Ch1 (TC − Ch1, °C)
The TC times are approximate, and the TC stopwatch may have started *after* Arduino logging and heating began. TC-clock offsets of 0–3 min were tested (TC reading at t compared with Arduino at t + offset):

| Run | Early readings (5–10 min) | Near-steady readings (15+ min) |
|---|---|---|
| R1 Cu | −1 to +3 (timing-sensitive; rod rising 1–2 °C/min) | **+2 to +4** at every offset |
| R2 Al | +9.5 to +10 at 10 min | **+5 to +8** at every offset |
| R3 Brass | +1 to +5 | — (run ended) |

- Conclusion that holds regardless of timing: once the rod is near steady, the thermistors read low vs. the TC, by ~2–4 °C on Cu and ~5–8 °C on Al. R2's 49.4 °C TC reading exceeds anything Ch1 recorded in the whole run (max ~41 °C), so no timing shift can explain that gap.
- Early (heating) readings can't be used for the cross-check without knowing the offset. Use the near-steady readings.
- A late start on the TC clock makes the R1 30-min and R3 15-min readings fall even further past the end of the Arduino record. So those were taken after the dump, and they are **not** evidence of a longer sample interval. The interval is still unverified but not contradicted.
- The Issues note "no more than 13 degrees" fits °C (the worst gap is ~10 °C, which is 18 °F).

## Other flags
1. **The steady-state tool threshold is wrong.** The default of 0.05 °C/s (= 3 °C/min) declares "steady" at 0.3 min in every run. Use a ~3-min window and <0.1 °C/min instead. Sample noise is ±0.2–0.4 °C.
2. **Channel offsets and tip channel.** Near ambient at the start, Ch2 reads ~2 °C above the others. The calibration resistances imply Ch4 reads ~1.9 °C low and Ch1 ~0.9 °C low, if all four were metered at the same temperature (only A0 has a temperature noted, 70 °F). Both Cu and Al show a steep Ch3→Ch4 drop. A fin's gradient should flatten at the tip, so the tip thermistor's contact or offset is suspect.
3. **Rod Specs:** the column header was changed to "Googled h (W/m-K)" with copper = 15. h is the air-side convection coefficient in W/m²·K, and it isn't a property of the rod material. k (W/m·K) is the material property, and that column is empty.
4. **Cross-checks that pass:** the rod weights match handbook densities. R2's temperature drop fits aluminum, not stainless.

## For Day 2
- Do an isothermal check: all 4 thermistors plus the TC together at room temperature and one warm point.
- Start the stopwatch at the same moment the Arduino buffer is cleared (`C`). Take TC readings at the same spot as a thermistor, and write down the elapsed time for each one.
- Write down the ambient value and which heater was used. Keep the buck converter at the same setting, and re-read its voltage under load for each run. Also read the heater's resistance hot, right after switching it off.
- Write down the clock time at `C` and `D` to get the real sample interval.
- Run brass to steady state (>25 min). Stainless and the copper tube are still untested.
