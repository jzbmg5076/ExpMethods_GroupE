# EXP4 (Stirling engine) — Day 1 status (2026-11-07, units confirmed 11/10)

Sources:
- the lectures from 10/19 and 10/21
- the Day 1 recording `Transcripts/InLab/10-27-2026_Lab.docx`. It starts at 9:28 AM.
- 13 Day 1 photos in `Lab Data/EXP4/Photos/dAY1/`, named D1_HHMM by clock time.

The full timeline and file map are in `Lab Data/EXP4/LabDay1/Day1_Data_Map.md`.

## Day 1 in one paragraph
- **Setup:** exposed base on two balsa sticks. Tach on a K'nex frame aimed across the 6 flywheel spokes. Thermocouples taped with polyimide 1.25 in from the edge: the bottom one beside (not on) the small off-center foil heater, the top one near the displacer rod.
- **First attempt:** started on the built-in foil heater at 5 V (bottom 22.2 °C / top 23.2 °C), but it barely warmed.
- **Block heaters:** switched to the dual external block heaters on balsa under the base. The engine barely ran and was tilted at one point. The professor said: keep it level, use the built-in heater, it needs about 20 °C of difference, and go high to low.
- **Tests 1–3:** blocks at 11.75, 10 and 9.5 V.
- **Tests 4–6:** back on the built-in heater at max, then 11.7, 10 and 9.5 V.
- **Day 2:** the group planned top heating.

## File ↔ test
| Test | File | Heater | V | RPM | Temps (bottom/top), as spoken | °C / K | ΔT °C |
|---|---|---|---|---|---|---|---|
| — | data_38_000.bin | blocks | ~11.75 | — | failed first save, ~11:11 | — | — |
| 1 | data_38_001test1 | blocks | ~11.75 | ~46 | not at save (earlier "~40° diff", °F) | — | ~22 (est.) |
| 2 | data_2t10v | blocks | 10 | ~40 | 53 / 32 °C | 326.2 / 305.2 K | 21 |
| 3 | data_38_003t9.5 | blocks | 9.5 | ~21, erratic, nearly stalled | — | — | — |
| 4 | datat4.11.7 | built-in foil | 11.7 | ~111 | 160 / 95 °F | 71.1/35.0 °C = 344.3/308.2 K | 36.1 |
| 5 | data_t5_10v | built-in foil | 10 | ~74 | ~148 / 93 °F | 64.4/33.9 °C = 337.6/307.0 K | 30.6 |
| 6 | data_t6-9.5v | built-in foil | 9.5 | ~71 | — | — | — |

- **Temperature placement:** the group read off the temperatures of the test just finished at each step-down. Test 2's reading is explicitly labeled "for the 10 volts".
- **Units (confirmed 11/10):**
  - The meters were switched between °F and °C during the lab.
  - Test 2 is °C; tests 4 and 5 are °F.
  - The block-heater "degrees of difference" remarks were °F: 40+ °F ≈ 20+ °C, which matches the professor's ~20 °C needed to run.
- **Tach:** RPM = 10 × pulse frequency. Pulse periods repeat every 6 pulses (uneven spokes), so average over whole revolutions.
- **Buck converter (ZK-12KX):** its display shows output V and A (photo D1_0959_02), so P = V·I can be read directly. Day 1 has volts only.

## Still missing after Day 1
1. Temperatures for tests 1, 3 and 6. None were spoken in the recording.
2. Heater power: buck amps (Day 2 photos have two readings), or heater resistance for V²/R.
3. Model inputs: see `exp4-model-inputs-review.md`. The group's dimensions give CR 1.014; fix P0 (×10), R (287) and the phase sign.
4. Not done on Day 1: insulated base (bowl), top heating, orientation — Day 2 covered the first two.
