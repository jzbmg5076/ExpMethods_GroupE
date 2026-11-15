# EXP4 (Stirling engine) — Day 2 lab notes, Tue 2026-11-10

Sources:
- Transcript: `Transcripts/InLab/11-10-2026_Lab.docx`. Recording starts at 9:24 AM, and the times below are recording time. Speaker 2 is a Group E member who did most of the data calls; Speaker 1 is the professor.
- 4 photos in `Lab Data/EXP4/Photos/DAY2/`. Matched to the tests by what they show (no timestamps).
- Day 2 data CSVs: `Lab Data/EXP4/LabDay2/LabDay2/`.
- Day 1 context: `exp4-day1-status-2026-11-07.md`.

## Test ↔ file map (from the CSV names)
| Test | File | Config | V |
|---|---|---|---|
| t1 | 11.64-t1.csv | A (inverted, top heat) | 11.64 |
| t2 | t2-11v.csv | A | 11 |
| t3 | t3-10.51v.csv | A | 10.51 |
| t4 | t4-9.99v.csv and t4-9.98v-.csv | A | ~9.99 |
| T5 | T5-11.62V.csv | B (upright on foam bowl, insulated bottom) | 11.62 |
| T6 | T6-10.0V.csv | B | 10.0 |
| T7 | T7-8.5V.csv | B | 8.5 |
| T8 | T8-7V.csv | B | 7 |

There are two t4 files. At 1:23:55 the group said "the one with the dash at the end, that's the new one", so `t4-9.98v-.csv` is the one to use.

## Photo log (Photos/DAY2)
| # | File | What it shows | Matches |
|---|---|---|---|
| 1 | D2_01_t1_buck_11.64V_0.40A.jpg | Buck converter (ZK-12KX V4) reading **OUT 11.64 V, 0.40 A**. OUT LED green and CC LED off, so it's in constant-voltage mode. | **t1**. P = 11.64 × 0.40 = **4.66 W**, R ≈ 29.1 Ω |
| 2 | D2_02_t1_inverted_topheat_setup.jpg | Engine **inverted** in the K'nex frame, resting on balsa sticks. Foil heater (polyimide-taped) on the up-facing plate, with a thermocouple taped beside it. Flywheel hangs underneath. | Config A (t1–t4) |
| 3 | D2_03_t1_meters_106F_77F.jpg | Both meters: **left 106 °F / 41 °C**, **right 77 °F / 25 °C**. ΔT ≈ 16 °C. | t1, early warm-up. Lines up with "4 minutes, 78 on top and 107 bottom" at 28:00 |
| 4 | D2_04_T5_upright_foambowl_buck_11.62V_0.51A.jpg | Engine **upright on the foam bowl**, with the built-in heater wired underneath. Scope shows tach pulses. Buck reads **11.62 V, 0.51 A**. | **T5**. P = **5.93 W**, R ≈ 22.8 Ω |

**Cross-check flag:** at nearly the same voltage, config A (t1) draws 0.40 A and config B (T5) draws 0.51 A — an apparent heater resistance of 29 Ω vs 23 Ω. Possible reasons: a different heater element in the circuit; the element's resistance changes with temperature; photo 4's display was still settling. Resolve before using V²/R.

## Professor's instructions at the start (00:18)
- Last lab day; whatever data you get is what you have.
- **Goal:** correlate the real engine with the analytical model (basically the ideal gas law applied to the right geometry, with idealized reservoirs).
- Look at **performance vs ΔT**, and also absolute/average temperature where runs differ.
- Check whether the engine **runs the same when reversed** (heat on top, same ΔT).
- To run it reversed, press both heaters onto the top with wood blocks or weights. Binder clips work but act as **fins** and pull heat out.
- Power supplies: white transformer → tachometer; big black 12 V → heating elements; small black → oscilloscope (5 V only; plug nothing else into it).

## Timeline
**Config A: inverted, top heat, foil heater (t1–t4, ≈04:51–1:21)**
- 04:51 — Plan was "top heat, bottom insulated". The group ran it upside down because another group said that worked.
- 24:39 — t1 at 11.64 V. At 1 min: 100 bottom / 75 top. At 2 min: 104 / 76.
- 28:00 — At 4 min: **107 bottom / 78 top** (°F: 41.7 / 25.6 °C, ΔT ≈ 16 °C). "Bottom"/"top" are thermocouple labels; the hot reading is the heated plate.
- 31:12–31:37 — ΔT was about 30 °F, below the ~20 °C (≈40 °F) the professor said is needed to run.
- 34:20–36:40 — Hand-spun to start; spin direction agreed (counterclockwise discussed).
- 42:24 — Temperatures held flat for about 4 min. 46:19 — Top settling at 80–81 °F.
- 46:55 — **t1 save** ("at almost 23 minutes").
- 48:56 — Turned down to **11 V** (t2). 59:16 — **t2 save**.
- 1:02:09 — Turned down for t3. "10.21 volts" was said at 38 min of run time, but the file is named **10.51 V** — use the file name.
- 1:10:42–1:11:37 — At 48 min: **112 bottom / 86 top (°F)** = 44.4 / 30.0 °C, ΔT ≈ 14.4 °C. The top read low because it was being fanned; its real steady value was about 87.
- 1:21:34 — **t4** saved (~9.99 V).

**Config B: upright, insulated bottom (foam bowl), built-in heater (T5–T8, ≈1:24–end)**
- 1:24–1:25 — Switched to the bowl. Used only the built-in heater, not the two silver block heaters, so the styrofoam wouldn't burn.
- 1:43:30 — Still heating up on the bottom heater (T5, 11.62 V).
- 1:51:51 — "Took us 20-something minutes to get steady on the last one; almost there."
- 1:54:20 — Confirmed config B is the insulated-bottom case.
- 2:15:46 — "8.5" volts (T7).
- 2:43:55 — Data went **up to T8** (7 V).

## Heater resistance (end of lab, 2:34–2:39)
- The group tried to measure heater resistance (unplug, meter across the two leads; the reading changes with temperature).
- The readings in the recording ("about six", "21", "eight") are mixed in with other groups' talk. **Treat the resistance as not recorded.** Use the buck converter's V and A (P = V·I) — available for t1 and T5 from the photos.

## Analysis guidance overheard (2:28)
- **Steady-state heater temperature vs electrical power** (P = V²/R or V·I), one point per voltage step.
- **Temperature/ΔT vs electrical power.**
- **Thermodynamic-cycle comparison** (ideal model vs actual).
- Possibly estimate **engine power and effective efficiency**.

Another group said at 1:33:42 that inverted ran about the same as upright for them, at ΔT ≈ 30 (units not stated).

## Still open
1. **Temperatures for T5–T8.** None were spoken clearly in the recording. Check whether the CSVs include temperature columns.
2. **Buck amps for each step.** Only t1 and T5 have them (photos).
3. Confirm whether the **0.40 A vs 0.51 A** difference means a different heater.
