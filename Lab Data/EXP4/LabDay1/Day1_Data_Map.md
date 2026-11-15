# EXP4 Lab Day 1 (Tue 10/27/2026) — data file ↔ transcript map

Sources:
- the transcript `Transcripts/InLab/10-27-2026_Lab.docx`. The recording starts at **9:28 AM**, so clock time = 9:28 + recording time.
- the photos in `Lab Data/EXP4/Photos/` (D1_0936 … D1_1019). The photo at 10:19 matches "okay, start it" at 50:12 in the recording, which confirms the clock offset.
- the 7 scope files in `LabDay1/LabDay1/`. The files' own modified times were lost when they were copied, so placement is by transcript order, the scope's file numbering and the scope settings.

Temperatures are as spoken in the recording. **Units confirmed by the group on 11/10:** the meters were switched between °F and °C during the lab. Test 2 is °C, tests 4 and 5 are °F, and the block-heater "degrees of difference" remarks were °F (40+ °F ≈ 20+ °C).

## Timeline

| Clock | Rec. time | What happened |
|---|---|---|
| 9:36–10:05 | ~0:08–0:37 | Station set up: tach on the K'nex frame, scope probe, engine on two balsa sticks (exposed base), thermocouples taped with polyimide 1.25 in from the edge (bottom plate beside the foil heater, top plate near the displacer rod). Photos D1_0936–D1_1005. |
| ~10:06 | 37:55–39:37 | **Built-in foil heater at 5 V.** Starting temps: bottom 22.2 °C, top 23.2 °C. |
| 10:10–10:13 | 42:31–45:16 | Only +0.4 °C in a few minutes. Group decides to switch heaters. |
| 10:14–10:18 | 45:55–50:12 | **Switched to the dual external block heaters** on balsa under the base, set to 9 V. Built-in heater unplugged (photo D1_1019). |
| 10:22–10:50 | 54:32–1:22:18 | Engine barely turns, stalls, won't restart. "30-degree difference" (1:04:55); "tilted all the way back" (1:08:55); "almost 40 degrees of difference" (1:09:58); "was at 120" (1:20:31). **Professor:** it has to be level; why not the built-in heater; it needs about 20° of difference "and you don't quite have 20". |
| ~10:51 | 1:23:20–1:23:31 | Blocks turned up to max: **~11.75 V**. |
| ~11:11 | 1:42:53–1:43:52 | "Saved it." → **data_38_000.bin**. Likely a failed first save: the header shows the display off and frequency 0. |
| ~11:12 | 1:44:35 | **Professor:** go from high to low; it won't start at low voltage (friction). |
| 11:16–11:18 | 1:48:21–1:50:32 | Figuring out the save menu (Utility → Device), then "spinning slightly faster… save it now?" → **TEST 1** |
| 11:21–11:32 | 1:52:59–2:03:49 | Down to **10 V**. Wait for the temperature to stop changing. "For the 10 volts… 53 bottom / 32 top." → **TEST 2** |
| 11:34–11:35 | 2:05:52–2:07:23 | Down to **9.5 V**. "It was stopped… flatline to 9.5." → **TEST 3** (engine nearly stalled) |
| ~11:36 | 2:07:35–2:08:06 | **Blocks removed. Back to the built-in foil heater at max.** "This is the fastest it'll ever go." |
| 11:47–11:51 | 2:19:26–2:23:49 | Wait for steady state ("went up two degrees in the past minute"), then "taking data." → **TEST 4** |
| ~11:54 | 2:25:56 | "Did you lower down to 10? And the temperatures were… 160 and 95." |
| 11:54–12:03 | 2:25:56–2:34:44 | **10 V**. "Now fluctuating, give it another minute." → **TEST 5** |
| 12:03 | 2:34:44–2:35:13 | Down to **9.5 V** "so we can compare it to the other one" (test 3). "Heat was 145.93… probably 148… other one 93." |
| 12:08–12:11 | 2:40:14–2:41:21 | "Do we need six? We need six." "This is test six, right?" → **TEST 6** |
| ~12:12 | 2:43:51 | Done. "We just have to do the top [heating] next lab period." |

## File ↔ test map

| Test | File | Heater | Buck V | Scope Δt / window | Pulse f | RPM | Temps spoken (bottom / top) | °C equivalent | ΔT °C |
|---|---|---|---|---|---|---|---|---|---|
| — | data_38_000.bin | blocks | ~11.75 | 200 µs / 2 s | 0 | — | — | — | — |
| 1 | data_38_001test1.csv | blocks | ~11.75 | 200 µs / 2 s | 4.60 Hz | ~46 | none at save (earlier, °F: "~40° diff", "120") | ~49 °C bottom (pre-steady); ΔT ≈ 22 °C | ~22 (est.) |
| 2 | data_2t10v.csv | blocks | 10 | 200 µs / 2 s | 4.04 Hz | ~40 | 53 / 32 °C | 53 / 32 °C (326.2 / 305.2 K) | **21** |
| 3 | data_38_003t9.5.csv | blocks | 9.5 | 400 µs / 4 s | 2.14 Hz (erratic) | ~21 | not stated | — | — |
| 4 | datat4.11.7.csv | built-in foil | 11.7 | 100 µs / 1 s | 11.10 Hz | ~111 | 160 / 95 °F (read at the step to 10 V) | 71.1 / 35.0 °C (344.3 / 308.2 K) | **36.1** |
| 5 | data_t5_10v.csv | built-in foil | 10 | 100 µs / 1 s | 7.42 Hz | ~74 | ~148 (145.9?) / 93 °F (read at the step to 9.5 V) | 64.4 / 33.9 °C (337.6 / 307.0 K) | **30.6** |
| 6 | data_t6-9.5v.csv | built-in foil | 9.5 | 100 µs / 1 s | 7.05 Hz | ~71 | not stated | — | — |

RPM = 10 × pulse frequency (6 spokes). The pulse frequency comes from my edge count and matches the scope's own Frequency readout on tests 4–6.

### How the files were placed
- **Scope numbering:** 000 → 001 → (002, renamed "2t10v") → 003. The scope numbers files in order of saving, so tests 1–3 are the first saves, and tests 4–6 were renamed before or after saving.
- **Timebase settings:** tests 1–2 at 200 µs; test 3 slowed to 400 µs (4 s window) to catch the nearly stalled engine; tests 4–6 sped up to 100 µs because the engine was faster. These settings follow the heater changes.
- **Voltages in the names** match the spoken setpoints. "11.7" in test 4's name agrees with "11.75 is about what we're gonna get" at max.

### How the temperatures were placed (check with John and Jesus)
- Test 2 is unambiguous: "for the **10 volts**, it was 53 / 32". It was said right before stepping down to 9.5 V. So the group read off the temps of the test just finished at each step-down.
- Applying the same pattern:
  - "160 and 95", asked with "did you lower down to 10?", belongs to **test 4 (max)**.
  - "148 / 93", said while setting 9.5 V, belongs to **test 5 (10 V)**.
  - The other reading would be 160/95 = test 5 and 148/93 = test 6. That puts nearly the same temperature on 10 V and 9.5 V but a 5 °C ΔT gap, which fits the speeds (74 vs 71 RPM) worse.
  - The first reading also scales better with power (11.7² / 10² = 1.37× power → 36 vs 31 °C ΔT).
- Tests 3 and 6 have no spoken temperatures. Test 1 only has the earlier, pre-steady comments.

### Units note (confirmed by the group on 11/10)
- The meters were switched between °F and °C during the lab.
- **Test 2: °C. Tests 4 and 5: °F.**
- The block-heater remarks were °F: "almost 40 degrees of difference" is about 22 °C, which matches the professor's "it takes about 20 [°C] and you don't quite have 20".
- The model takes kelvin: K = (°F − 32)/1.8 + 273.15.
- On Day 2, write the unit next to every reading.

## Gaps this leaves for Day 1
- Temperatures for tests 1, 3 and 6.
- Buck current for every test. The display shows A (photo D1_0959_02), but it wasn't read out.
- Engine dimensions and heater size/position were not measured.
