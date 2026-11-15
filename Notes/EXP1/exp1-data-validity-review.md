# EXP 1 — Moments of Inertia: which Day 1 + Day 2 data is valid

Reviewed 2026-09-17. Sources: every Day 1 and Day 2 data file (Arduino .txt, X-Modal .MAT), the
Day 2 lab transcript (`Lab2Transcript.docx`), the 14 Sep reflection lecture, the Exp1 FAQ, the
Day 2 photos (EXIF-timestamped), and the analytical/NX outputs in `EXP1\Analytical_Plate_Models`.
Lab frame: **x = into the table (plate face normal), y = along the table, z = vertical.**
MOIs are named by the **axis of rotation**, not the direction of motion.

Figure + per-run table saved to `EXP1\Lab\Data_Validity_Review\` (`EXP1_Day2_valid_runs.png`,
`EXP1_run_validity.csv`). (In this package: `Output/EXP1/Data_Validity_Review/`.)

---

## 1. Verdict

| Axis (lab) | Best run | Plate / method / sensor | Measured | Model | Verdict |
|---|---|---|---|---|---|
| **Ixx** (face normal) | `YData1-3` | Al offset frame (Plate 2), V-hang, swung **along** the table, compound, X-Modal | 0.6996 Hz → **735 ± 50 lbm·in²** | 736 (analytical) | **Valid** (−0.2 %) |
| **Izz** (vertical) | `Bifolar1-3` | Rectangle (6061), bifilar twist, **Arduino + X-Modal on the same swings** | 1.744 Hz → **52.6 ± 2 lbm·in²** (L = 8.75 in) | 51.5 | **Valid** (+2 %) |
| **Iyy** (along table) | `IntoTable1-4` | HDPE notched (Plate 1), two chains, swung into the table, X-Modal | 1.127 Hz, very repeatable | 9.97 | **Weak** — frequency agrees, MOI not resolvable |

Instructor's minimum spec (14 Sep lecture): ≥1 Arduino, ≥1 commercial, ≥1 compound, ≥1 bifilar,
≥1 each of Ixx/Iyy/Izz, and one successful measurement per plate (3) + the assembly.

- Covered: Arduino ✓, commercial ✓, compound ✓, bifilar ✓, Ixx ✓, Izz ✓, rectangle ✓, Al frame ✓.
- Weak / open: **Iyy**, **HDPE** (frequency only), **assembly** (no logged geometry, composition, or photo).

## 2. Instructor comments that decide validity

- **Day 1 X-Modal was corrupted by the Windows "Voice Clarity" audio filter** on the 485B39
  conditioner. "Remember all those little spikes and then ring down? That's the ring down from their
  digital filter." He turned it off on every PC before Day 2. → `test2settled` / `Ytest1` are not pendulum
  data. This also downgrades the earlier claim (Day 1 review §5) that the 587/1630/2840 Hz ringing
  validates plate thickness: filter ringing and plate ringing can't be separated in those files.
- **Long cables kill the Jcg term.** When m·L² is 2–3 orders of magnitude above Jcg, the compound
  pendulum becomes a simple pendulum and Jcg can't be extracted. "You're going to need L to be relatively short."
- **Bifilar: sensor on the edge**, sensitive to the motion. Compound: position doesn't matter, direction does.
- **Hang parallel to a principal axis** or it wobbles (non-symmetric plates: use NX to find the axes).
- Weigh the part; if mass and model disagree, thickness is the likely error. **NX HDPE density is ~40 % off.**
- Principal-axis labels from NX come out in arbitrary order; map them to your frame yourself.

## 3. Day 2 reconstruction (15 Sep; X-Modal clock ≈ transcript start 09:26)

| Time | Files | Plate | Rig | Motion | Notes |
|---|---|---|---|---|---|
| 09:51–10:01 | `IntoTable1-4` | HDPE notched (photos 4978/4979) | two chains, separate clamps → top corners, "legs 4–4.5 in" | into table | IEPE face-mounted at centre; X-Modal **window on** |
| 10:43–10:45 | `YData1-3` | Al offset frame (photos 4980–4985) | **V**: two chains to one bolt ≈ 9.5 in above top edge | along table (in-plane) | sensor re-oriented after instructor's "which way does that transducer measure?" at t≈1:16 |
| 11:14–11:25 | `Bifolar1-3` + `Bifolar1-3Arduino` | Rectangle (photos 4986/4987) | vertical chains on corner bolts, r = 6.2 in, L ≈ 8.5–9 in | twist | both sensors, same swings; IEPE **arrow up**; windowing turned off by run 3 |
| 11:57–12:00 | `BackupCombined1-2`, `…BottomPosition1-3` | Assembly | "same orientation as before", chains unchanged | into table | sensor top vs bottom; **no photo, no mass/geometry in files** |
| 12:09–12:15 | `PlasticX1-5` | HDPE, flipped notch-up (photos 4988–4990) | chains ≈4 in and ≈5.5 in to corners at different heights | into table | plate hangs tilted |

X-Modal "window on" = a Hann window was applied to the saved time block (confirmed: Hann fits best).
Frequency is unaffected; amplitude/damping are not readable from those files. Say so in the report.
Day 2 Arduino files lack the "% Capture" line; the 1833 ms capture is confirmed because Arduino and
X-Modal agree run-for-run within 0.5 %.

## 4. The valid runs

### Ixx — Al offset frame, V-hang (compound)
- f = 0.7027 / 0.6995 / 0.6966 Hz (Hann-windowed damped-sine fit); de-windowing gives 0.692–0.718, so
  quote **f = 0.700 ± 0.005 Hz**. Model prediction 0.699 Hz.
- m = 4.535 kg = 9.998 lbm. d = apex height 9.54 in (tape, IMG_4985) + CG 5.58 in below the heavy
  (top) edge = **15.12 in**. Jcg = m·d·(g/ω² − d).
- **J = 735 ± 50 lbm·in² = 0.215 kg·m²** vs analytical 736 (−0.2 %). Jcg is 24 % of the total, so
  ±0.25 in in d → ±26 and ±0.001 Hz → ±9 lbm·in².
- If the tape zero was the chain hole rather than the plate edge, d = 14.87 → 760 (+3 %).
- NX Model 2 must be mass-reconciled first: it implies 4.767 kg; scaled to 4.535 kg it gives 701 (−5 %),
  plus a 0.21 in CG offset — the NX opening geometry differs from the measured drawing.
- Frequency rules out an out-of-plane swing (that would be 0.78 Hz).

### Izz — Rectangle, bifilar
- Arduino (sensor x, tangential): 1.7234 / 1.7462 / 1.7629 Hz, R² 0.993–0.998.
- X-Modal: 3.459 / 3.475 / 3.525 Hz = **2 ×** (1.729 / 1.737 / 1.763). The IEPE arrow pointed up, so it saw
  the plate's vertical bounce, which happens twice per twist cycle. Arduino z shows the same 2f.
- J = m·g·r²/(ω²·L), m = 3.719 lbm, r = 6.20 in (corner holes 0.25 in from the ends):
  L = 8.5 → 54.1 (+5 %); **8.75 → 52.6 (+2 %)**; 9.0 → 51.1 (−1 %). Model 51.5 (≈51.9 if the plate
  hangs tilted ~10° off the bolts, which the Arduino's 0.18 g DC offset suggests).
- Chain length is the biggest uncertainty (transcript: "like nine… eight and a half"; photo 4987 suggests
  the two chains differ by ~1 in). Report L as 8.5–9.0 in and carry it as the error bar.

## 5. Why the into-the-table runs can't give Iyy

- **HDPE IntoTable:** f = 1.1273 ± 0.003 Hz over 4 runs. Equivalent simple-pendulum length 7.70 in; the
  plate needs d = 7.15 in to match the model, and legs 4–4.5 in + hole-to-CG 2.94 in give 6.94–7.44.
  So it's consistent, but Jcg is only 7 % of the total: legs 4.0 / 4.25 / 4.5 in → Iyy = 13.3 / 9.2 / 4.8
  (+34 % / −8 % / −52 %). Doubling Iyy only moves f by 3 %. Chain-snap spikes and a second peak near
  3.3 Hz show the two separate clamps are not one fulcrum. Use as a *consistency check*, not a measurement.
- **PlasticX:** the two chains go to corners at different heights, so the plate hangs tilted and the swing
  axis isn't a principal axis — the "two peaks per cycle" wobble (second mode ~2.7 Hz). Geometry not logged.
- **Assembly:** 0.898–0.913 Hz over 5 runs (top vs bottom sensor agree within ~1.5 %). Equivalent length
  12.0 in with ~8.5 in chains → also ill-conditioned. Needs composition, mass, chain length, attach holes
  and CG to be usable even as a check.
- **Day 1 rectangle, pushed into the table (`ArduinoDataX`) — not a valid Iyy.** Its dominant 1.65 Hz
  matches the twist run (`Zdata2`, 1.689 Hz, whose vertical channel shows the bifilar 2f signature), not a
  swing. The real swing is a weak 0.87 Hz component, 1.6 cycles long, with Jcg = 1.6 % of the total —
  back-solving gives a negative Iyy. This corrects the Day 2 rig plan, which listed it as usable.
- Day 1 `ArduinoDataY2` (four-bar) contains no inertia; it measures the chain length (L = 11.1 in).
- Day 1 `Zdata2` is a genuine twist record but its chain length/spacing weren't logged; with L = 11.1 in it
  gives 44–48 lbm·in² (−8 to −15 %). Supporting evidence only.

## 6. What to do for the report (due Tue 22 Sep, 9 AM; post-lab quiz due Fri 18 Sep)

1. Claim Ixx (Al frame) and Izz (rectangle) as the validated measurements, with the uncertainty math above.
   The Izz run alone covers Arduino + commercial + bifilar; the Ixx run covers compound + commercial.
2. For Iyy, present the HDPE IntoTable frequency agreement **with** the conditioning argument (the instructor's
   own point), and state it as a limitation. The honest framing earns more than a forced number.
3. If any lab time is available: hang the rectangle from a **rod through the two top holes** (d = 2.70 in,
   Jcg = 29 % of the total, predicted 1.61 Hz). Five 20-second swings would close the Iyy gap.
4. Assembly: confirm which two plates, the mass, and the rig; build it in NX and combine with
   `AddInertiaTensor.m`; then use the 0.90 Hz as a forward check. Check the "no common CG or axes" rule —
   the transcript suggests the CGs were aligned when assembling.
5. Model fixes still outstanding: NX Model 1 (rectangle) is still steel (scale by 1.687/4.468 until fixed);
   NX Model 3 (HDPE) has t = 0.5 in vs 0.75 measured; `plate04` analytical still uses t = 0.45 in (≤0.2 % effect).

## 7. Open questions

- Was the assembly the rectangle + HDPE? (The rectangle went missing right after the assembly was weighed.)
- Tape zero for the V-hang apex height: plate edge or chain hole? (Changes Ixx by 3 %.)
- Bifilar chain length as written down (8.5 or 9 in, and were both chains equal?).
- Assembly mass and chain/attachment geometry, if anyone wrote them down.
