# EXP2 — Runs R4 (stainless steel) and R5 (copper tube) data review

Files: `Lab Data/EXP2/Runs/R4/Steel.txt` and `Runs/R5/Tube.txt` (added 10/6/2026). Figure (R4): `Output/EXP2/R4_Review/R4_Steel_review.png`. Companion to `exp2-day1-data-review.md`.

## Why they look "weird": different output format
- Day 1 (R1–R3) files were the Canvas sketch's `D` dump: one long line of `T0 T1 T2 T3 T0 T1 ...`, 1 decimal place, no time.
- R4 and R5 are **one row per sample, comma-separated, 5 columns: `time_s, T0, T1, T2, T3`**, with 2 decimal places and Windows line endings (R4 also has a blank first line). The Canvas `EXPT2_1d` sketch can't produce this, so a modified or different sketch (or logger) was used. Which one isn't documented yet.
- The time column counts seconds from when the Arduino powered up.
- `import_arduino_dump.m` misreads these files: the time column is treated as a temperature, so the channels rotate.
- **Fix used:** the time column was stripped to make `R4/Steel_Dformat.txt` and `R5/Tube_Dformat.txt`, in exactly the Day 1 layout. Both were verified identical to the originals; the originals are untouched. Load them with `'Interval', 5.54` (R4) or `'Interval', 5.53` (R5).

## R4 — stainless steel
- File time runs 1051 → 2922 s: 339 samples over 31.2 min, no gaps.
- **Real sample spacing:** steps are 5 s or 6 s (rounded to whole seconds), **mean 5.54 s**. This is the first measured interval; the 5.06 s assumed for R1–R3 was never measured. It only applies to R1–R3 if they used the same loop timing.
- **First ~5.5 min: everything cools.** All channels start around 26 °C, and Ch3/Ch4 fall to ~23 °C before Ch1 starts rising at ~5.5 min. The rod started warmer than the room, or the heater was switched on late.
- **Steady state:** reached ~10 min after heating starts (3-min window, <0.1 °C/min). Usable.
- **Final (last 3-min mean, Ch1→Ch4):** 33.7, 27.4, 23.8, 23.4 °C. Ch3 and Ch4 sit at about room temperature, which is expected for stainless (k ≈ 15 W/m·K; decay length only ~1.2–1.7 in). Only Ch1 and Ch2 carry profile information.
- Noise is ±0.15 °C. Ch2 again reads ~1.5–2 °C high at the start, consistent with R1 and R2.

## R5 — copper tube (hollow)
- File time runs 3847 → 4859 s (same Arduino power-on session as R4; started ~15 min after R4 ended). 184 samples over 16.9 min, mean spacing 5.53 s, no gaps.
- Ch1 starts rising ~1.4 min in.
- **Not at steady state:** last-3-min slopes are +0.51 / 0.31 / 0.25 / 0.13 °C/min (Ch1→Ch4). Ch1 is still climbing. Last 3-min means: 45.4, 40.6, 36.0, 33.5 °C. The end values are a lower bound on steady state; use this run as transient data.
- Ch2 reads high at the start again (28.0 vs ~26.1–26.8).
- Positions, and whether any sensor was inside the tube, are not logged.

## Sensor spacing guidance (10/6)
Decay length L_c = √(kD/4h), with D ≈ 0.2 in and h ≈ 10–20 W/m²·K:

| Rod | Decay length |
|---|---|
| Copper | 6–9 in |
| Aluminum | 4–6 in |
| Brass | 3.5–4.7 in |
| Stainless | 1.2–1.7 in |

Keep the sensors within ~2 L_c of the heater edge, and space them so neighbors differ by several °C (more than the 1–2 °C channel offsets). One far sensor at ambient can justify the "infinite fin / no tip loss" assumption. Running the same rod twice with the sensors shifted gives more points (the professor's "patches" idea).

## Open
- Sketch/logger used, thermistor positions for R4 and R5, heater and buck-converter voltage, ambient TC reading, and whether the stopwatch started at the first logged line.
