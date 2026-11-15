# EXP3 Lab Day 1 (Tue 10/13/2026) — in-lab transcript notes

Source: `Transcripts/InLab/10-13-2026_Lab.docx` (9:25 AM, 2 h 46 min). Speaker labels are auto-assigned. Off-topic banter is omitted. Clarifications from the group (same day) are marked **[group]**.

## Instructor briefing (opening ~10 min, plus a few later remarks)
- **Comparison set for the rectangle:** full modal with the accelerometer, full modal with the mic, and a full NX model (plus Blevins). **Other two plates:** one full experimental modal with either sensor, plus NX. No analytical model for the non-rectangular plates.
- **Wiring:** hammer on channel 1, accelerometer or mic on channel 2. The two sensors can't be used at the same time.
- **Bandwidth:** the 16k and 32k options are crossed off as unnecessary.
- **X-Modal quick start:** Test Setup → hammer; about 800 lines is fine; 5 impacts per average (3 is OK if careful); ~5 s accept/reject delay; reject double hits; ignore damping and beta.
- **Trigger level:** lower it from the default (~1.5% to ~10%, garbled). Don't hit hard enough to overload.
- **Channel setup:** enter point number and direction for each hit. Plate is x-y with z up; accelerometer arrow up = +Z; hammer hitting down = −Z.
- **Hammer:** tap lightly. Tip stiffness sets the frequency range (soft = narrow, low band). The force spectrum should hold within 1–2 orders of magnitude across the band; a soft tip is only good to about 500 Hz.
- **Saving:** save with a .mat extension to use the data outside X-Modal. The data manager holds the FRF and coherence (coherence = measure of linearity).
- **Plates:** aluminum vs stainless barely changes frequency. The rectangle must be metal; plastic is discouraged.
- **If testing goes poorly:** pick subsets that still build the story.
- **Later (~2:24):** "If you've got a structural and an acoustic set for your rectangular plate… you're probably in good shape."

## Group E plate set **[group]**
| Plate | Shape | Material | Status after Day 1 |
|---|---|---|---|
| P1 | Rectangle (~12.9 × 5.9 × 0.378 in, 3.733 kg = 8.230 lb) | Stainless steel | Accel full grid done; mic full grid done (centered — modes 2/4 missing) |
| P2 | L-shaped plate | Aluminum | Dimensions + weight measured; not tested on Day 1 |
| P3 | Rectangular cut-out (frame) plate | Aluminum | Dimensions + weight measured; not tested on Day 1 |

## What Group E did on Day 1
- Steel rectangle re-measured. **Mass 8.230 lb = 3.733 kg.**
- **Supports [group]: balls at the four corners.**
- **Accelerometer:** "one inch in and one inch over" — at (1, 1) in, not grid point 1.
- **Grid:** 3 × 5; x = 0.75, 3.6, 6.45, 9.3, 12.15 in. Hit in a snake path.
- **Hammer tip:** soft tip first; switched to the harder **white tip** (cleaner data).
- **Acquisition:** ~800 lines; 5 averages per point; saved as .mat.
- **Coherence:** points 1, 2, 5 and 6 flagged and retaken near the end.
- **Mic:** K'nex stand; plate top ~3.8 in above the table. Chose **~1 in above the plate center (pt 8)** after comparing at one hit location. Missing modes not checked at the time.
- **NX:** version mismatch between personal and lab laptops; exported STEP files.

## Notes on the corner supports
- Corners are where all four target modes move the most, so corner balls are not the textbook "support on nodal lines" choice.
- Even so, test frequencies matched free-free NX within ≤0.7% and the bounce mode sits at ~39 Hz (11× below mode 1): the balls are soft enough. Good point for the report.
- Hits near a supported corner could make the plate rock on the ball (non-linear contact → lower coherence). May explain point 1's ~0.92 (hypothesis).
- If NX springs are added, put them at the 4 corners (the Canvas spring tutorial uses corner nodes).
