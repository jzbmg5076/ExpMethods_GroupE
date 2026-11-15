# EXP 1 — Moments of Inertia: Day 1 Data Review

Rectangular plate only. Reviewed 2026-09-08 against `EXP1\Lab\LabData\EXPT1(Phillps)`,
the two MATLAB model scripts, the Aug 31 lecture, the Exp1 FAQ, and the four lab photos.
Revised after confirming the actual motions used in each run.

---

## 0. TL;DR

The three runs were named by the **direction the plate was pushed**, not by the axis it
rotates about:

| Run | Motion used | Rotation axis | MOI it could give |
|---|---|---|---|
| X | pushed into the table | the long 12.9 in edge | Iyy = 10.87 |
| Y | swung side to side | the face normal | Ixx = 62.36 |
| Z | twisted | the vertical axis | Izz = 51.65 |

Result: **the Y run is provably empty of inertia information, and the X and Z runs recorded
the same 1.688 Hz motion as each other — which fits no clean linear mode of the rig.**

| File pair | Verdict |
|---|---|
| `ArduinoDataY2` + `Ytest1` (Y run, 0.921 Hz) | **No Ixx** — parallelogram, plate never rotates. But it is a clean measurement of the chain length: **11.53 in**. |
| `ArduinoDataX` + `test2settled` (X run, 1.688 Hz) | Ambiguous. Should have been 0.83 Hz. |
| `Zdata2` (Z run, 1.688 Hz) | Ambiguous. Torsion should have been 1.41–1.59 Hz. Best case gives Izz ≈ 46, about 11% low. |
| `Arduinoplot.m` (0.682 Hz, sensor remounted) | Contaminated by a large impact burst. |

---

## 1. The Y run cannot work, for a geometric reason

Two equal, parallel chains running from a rigid beam to a rigid plate form a
**parallelogram four-bar linkage**. Swung in the plane containing both chains — which is
exactly "side to side" along the long edge — the plate translates along an arc and **does
not rotate at all**. Its mass distribution cancels out of the equation of motion completely:

    f = sqrt(g / L) / (2*pi)          <- a simple pendulum, no MOI term anywhere

This is the failure the Exp1 FAQ describes almost word for word: *"Incorrect attachment of
the cable can create a four-bar linkage which will cause the part to translate (or partly
translate) instead of simply rotating around the fulcrum."*

So no amount of processing gets Ixx out of `ArduinoDataY2`. What it does give, cleanly, is
the one number nobody wrote down:

    0.921 Hz  ->  chain length L = 11.53 in

Use that. It is the most reliable single measurement in the whole data set, because a simple
pendulum period depends on nothing but length.

**To actually get Ixx** the plate must be free to rotate about its face normal. Hang it from
a single point — one chain to one corner, or a knife edge — not from two parallel chains.

---

## 2. With L = 11.53 in, the X and Z runs do not add up

| Run | Predicted | Observed |
|---|---|---|
| X — assembly swinging out of plane | 0.832 Hz | **1.688 Hz** |
| X — plate also free to rock on its corner pins (2-DOF) | 0.832 and 3.125 Hz | **1.688 Hz** |
| Z — bifilar torsion, screw spacing 11.4 / 12.0 / 12.9 in | 1.409 / 1.483 / 1.594 Hz | **1.688 Hz** |

Two readings are possible and the data cannot separate them:

**(a) Both runs were dominated by twisting.** Torsion at a 12.9 in screw spacing predicts
1.594 Hz against 1.688 observed — a 6% gap, inside the ±0.27 Hz resolution of a 1.8 s
record. That would make the Z run valid and the X run a contaminated twist:

| Screw spacing D | Izz from 1.688 Hz | vs analytical 51.65 |
|---|---|---|
| 11.4 in | 35.97 | −30.4 % |
| 12.0 in | 39.86 | −22.8 % |
| **12.9 in** | **46.06** | **−10.8 %** |

Against this: a DC accelerometer mounted at the plate's **centre** is nearly blind to pure
torsion about the vertical axis — twisting about vertical does not change the angle between
gravity and any plate axis. Yet `Zdata2` shows a 0.28 g swing on a horizontal sensor axis,
which is a ~8 degree **tilt**, not a twist. That argues against reading (a).

**(b) The chains were going slack and snapping.** The commercial records are trains of
impact transients at 1.617 Hz — one impact per cycle. A pendulum under steady tension does
not do that. The X run is only ±0.05 g, a rattle rather than a swing, and `Zdata2`'s
sensor-x is a humped waveform touching zero rather than a sinusoid. Under this reading the
1.688 Hz is a nonlinear rattling rate and neither run is usable.

### Correction to the earlier version of this document

An earlier draft read 1.688 Hz as the plate rocking about its corner screws and quoted
Iyy ≈ 9.3 lbm-in^2. **That was wrong.** It treated the screw line as a fixed pivot, which
gives 1.64 Hz and looks like a match. But the screw hangs on a chain and is free to move.
Solving the actual two-degree-of-freedom system (chain swing + plate rotation on the pins)
puts that mode at **~3.1 Hz** — in the long-chain limit it tends to sqrt(m*g*d/J)/(2*pi) =
2.82 Hz. It is not 1.688 Hz, and the 9.3 figure should not be used.

---

## 3. Plate properties (confirmed)

The NX material error you already found is confirmed by the numbers: back-solving the
reported NX result (28.0227, 133.5241, 161.2217 lbm-in^2) gives a mass of 9.615 lbm =
4.361 kg, i.e. 7770 kg/m3. Steel. Every one of those NX numbers is **2.59x too large**.

The mass also says the **thickness is 0.500 in, not 0.45**:

| Assumption | Implied density | |
|---|---|---|
| 1.687 kg over 12.9 x 5.9 x 0.45 in | 3006 kg/m3 | matches no material |
| 1.687 kg over 12.9 x 5.9 x **0.50** in | **2705 kg/m3** | 6061-T6 aluminum, exact |

Corrected analytical targets (6061 Al, m = 1.687 kg = 3.719 lbm, 12.9 x 5.9 x 0.500 in),
in your lab convention:

| | lbm-in^2 | kg-m^2 |
|---|---|---|
| Ixx (flat spin, about thickness normal) | **62.36** | 0.01825 |
| Iyy (about the long edge) | **10.87** | 0.00318 |
| Izz (about the vertical short axis) | **51.65** | 0.01512 |

Including thickness changes these by 0.72% / 0.15% / 0% — far below your experimental
error, so the thin-plate approximation is defensible. Say so and quantify it.

### Two bugs in the MATLAB scripts

- `rectangular_plate_moi_models.m` line ~30: `t = 0.45;` -> should be `0.50`. There is also
  a leftover commented `%m = m/350;` worth deleting before anyone runs it by accident.
- `rectangular_frame_plate_moi_models.m` line ~33: `m_total = m_total_kg *1;` with the
  `2.20462262185` conversion commented out. Everything downstream is labelled `lbm*in^2`
  but is actually **kg*in^2** — all frame-plate results are low by a factor of 2.2046.

---

## 4. What is physically in each file

All Arduino files: 3 axes, 2048 samples, 1833 ms, effective rate 1117 Hz. No clipping
anywhere, and the vector magnitude averages 1.01 g — **the MPU-6050 scaling is good.**
All four are distinct captures (verified, not copies).

| File | Dominant freq (x, y, z) | Amplitude | Notes |
|---|---|---|---|
| `ArduinoDataX.txt` | 1.688, 1.620, 1.705 Hz | small, ±0.05–0.10 g | one impact spike at t = 0.59 s |
| `Zdata2.txt` | 1.688, **3.393**, 1.671 Hz | sensor-x 0 -> 0.28 g | cleanest record you have |
| `ArduinoDataY2.txt` | 0.921, 1.006, 0.887 Hz | sensor-z ±0.18 g, smooth | ~10 deg swing amplitude |
| `Arduinoplot.m` | 0.682, 0.852, 1.397 Hz | ±0.6 g, huge burst t = 0.9–1.2 s | sensor remounted; contaminated |

`Zdata2`'s y-axis at **3.393 Hz is exactly 2x** its x and z peaks — the gravity-projection
doubling from lecture. It confirms 1.688 Hz is the real rate, and it is a trap: pick the
wrong axis and you halve the period and quadruple the MOI.

Sensor mounting changed between runs: in `ArduinoDataX`, `ArduinoDataY2` and `Zdata2` the
sensor's +y points down (reads about −1 g), but in `Arduinoplot.m` it is +z. The
accelerometer was remounted or the plate rehung for that capture.

Geometry measured from the photos: chains **~20.8 in** in `IMG_4866` (using the plate's
5.9 in height as scale) — which does **not** match the 11.53 in the Y run implies, so the
chain length was changed at some point during the session and only one value was logged.
From `IMG_4867` the screws sit **~0.57 in below the top edge**, so screw-to-CG is ~2.38 in.

---

## 5. The X-Modal (commercial) data — read in detail

### File structure

Both files are UFF datasets written by *V-Acquisition ver. Beta 1*, four records each:
a header, a units record, and **two data channels**.

| | `test2settled.MAT` | `Ytest1.MAT` |
|---|---|---|
| created | 08 Sep 2026, **10:46:10** | 08 Sep 2026, **11:51:45** |
| sample rate | 8000 Hz | 8000 Hz |
| points / duration | 40 960 / 5.120 s | 40 960 / 5.120 s |
| ch1 rms / peak | 8.24e-5 / 1.52e-3 g | 4.16e-5 / 8.79e-4 g |
| ch2 rms / peak | 1.82e-6 / 1.65e-5 g | 2.10e-6 / 2.32e-5 g |

Units record: code 9, "British (lbf, g*s^2, F)" — the length unit is g·s², so the
**ordinate is already in g**, no conversion needed. `readXModalData.m` pulls
`UFCELLS{3}` — that is ch1, the right one.

Two things to note:

- **Channel 2 is 20–45x smaller than channel 1** and has a low crest factor. It looks
  like an unconnected or unterminated input, not a second sensor. Confirm which BNC was
  actually live and stop saving the dead one.
- **Peak amplitude is only ~1.5 milli-g.** For a steel chain snapping against a screw
  that is implausibly small, which says the channel sensitivity in X-Modal was probably
  left at a default rather than set to the sensor's 100 mV/g. **Frequencies are
  unaffected; amplitudes are not trustworthy.** Record the sensor model, serial and
  sensitivity on Day 2 and set them in the software.

The 65 minutes between the two timestamps also fixes the running order:
`test2settled` came first, `Ytest1` an hour later.

### What is actually in the records

Neither file contains a pendulum signal — there is essentially no energy below 2 Hz
(0.0–0.6 %), because an IEPE accelerometer is AC-coupled and cannot pass ~1 Hz, and
because the sensor sits at the plate's centre where the tangential acceleration is
smallest. What the records *do* contain is a **train of impact transients**: the chain
links snapping against the screws once per half-cycle, each impact ringing the plate.

That gives two genuinely usable results.

### Result 1 — the period, from the impact spacing

| File | Impact spacing | Implied period | Matching Arduino run | Agreement |
|---|---|---|---|---|
| `Ytest1.MAT` | 0.543 s (7 bursts) | T = 1.081 s -> **0.925 Hz** | `ArduinoDataY2` at 0.921 Hz | **0.4 %** |
| `test2settled.MAT` | 0.618 s (6 bursts, irregular) | **1.617 Hz** | `ArduinoDataX` / `Zdata2` at ~1.688 Hz | 4 % |

The impacts are half-cycle events, so the spacing doubles to give the period. This is
a legitimate cross-sensor check and it confirms the file pairing: `Ytest1` goes with
the Y run, `test2settled` with the X/Z runs. Do **not** read the period off the
strongest spectral peak — that is structural ringing at hundreds of Hz.

### Result 2 — the record settles the thickness question

Three sharp resonances appear in both files. Compare them with the free-free bending
modes of the plate, f = (lambda^2 / 2*pi) * sqrt(E*I / (rho*A*L^4)), for a 0.500 in
6061 plate:

| Mode | Predicted | Measured | Error |
|---|---|---|---|
| 1st bending across the 12.9 in span | 614 Hz | **587 Hz** | −4.4 % |
| 2nd bending across the 12.9 in span | 1693 Hz | **1630 Hz** | −3.7 % |
| 1st bending across the 5.9 in span | 2936 Hz | **2840 Hz** | −3.3 % |

Three modes, two directions, one free parameter, and a consistent ~4 % offset — which
is what you expect from a beam idealisation of a plate with fourteen holes drilled
through it. Solving each measured frequency for thickness gives **t = 0.478 and
0.484 in**.

This is decisive because f scales linearly with t. A 0.45 cm (0.177 in) plate would
put those modes at **217 Hz and 1039 Hz**. They are not there. And the inference is
almost material-independent, because sqrt(E/rho) is nearly the same for aluminium and
steel (5051 vs 4943 m/s): assuming stainless instead gives t = 0.488 / 0.494 in.

So the plate is **0.48–0.50 in thick**, and combined with the measured 1.687 kg that
forces a density near 2700 kg/m3 — aluminium. Consistent with the AL 6061-T6511 stamp
in `IMG_4867`. Three independent lines of evidence agree; use **t = 0.500 in, 6061**.

The 587 Hz mode rings for tens of milliseconds after each impact with very light
damping, which is exactly how an impacted free-free metal plate behaves. The commercial
sensor is working correctly — it is measuring structural vibration, which is what an
IEPE accelerometer is for. It was simply pointed at the wrong physics for a 1 Hz
pendulum.

### What to change on Day 2

1. Move the sensor to a **corner**, sensitive axis tangential to the motion.
2. Set the channel sensitivity to the sensor's actual mV/g and record model + serial.
3. Drop the sample rate — 8000 Hz for a 1 Hz phenomenon is 4000x oversampled. Use the
   lowest rate and longest block X-Modal offers.
4. Stop recording the dead channel 2, or find out what it was supposed to be.
5. Keep one deliberate impact record. The modal result above is real, defensible data
   and it validates your geometry independently of any pendulum — worth a paragraph in
   the report.

---

## 6. Record length

Every Arduino capture is **1.833 s** — 1.6 to 3 cycles. FFT resolution is 0.546 Hz, so any
period carries about ±0.27 Hz before anything else goes wrong.

The sketch hard-codes 2048 samples and runs I2C flat out. One line inside the capture loop:

```c
delay(9);          // ~10 ms per sample -> ~100 Hz
```

2048 samples at ~100 Hz = a **20 second record**, resolution 0.05 Hz, still ~100 samples per
cycle. Highest-value change available for Day 2.

---

## 7. Day 2 priorities

1. **Rebuild the suspension so each push excites one identifiable mode.** Two parallel
   chains cannot give Ixx at all. Use a single fulcrum — cables into a vee, or a knife edge
   — so the plate rotates instead of translating.
2. **Measure and log, per test**: chain length (hook to screw), screw spacing, screw-to-CG
   distance, and which motion was initiated. Those four numbers are the entire ambiguity in
   §2.
3. Add `delay(9)` to the Arduino capture loop -> 20 s records instead of 1.8 s.
4. Move the commercial accelerometer off the plate centre to a **corner**, sensitive axis
   tangential to the motion, and drop X-Modal to its lowest sample rate.
5. Watch for slack chain. If you hear or see the links snapping, the record is a rattle, not
   a pendulum. Add tension or switch to cable.
6. Fix `t = 0.50` in `rectangular_plate_moi_models.m`; fix the kg/lbm bug in
   `rectangular_frame_plate_moi_models.m`; rebuild NX with Aluminum 6061 and verify NX
   reports 1.687 kg.
7. Pick one axis convention, put it in a figure, use it everywhere.
8. Five repeats per configuration, logged in the Experiment Log sheet as you go.

Do 1–3 first and re-run the rectangle end to end. If it closes to a few percent against the
analytical model, the process is validated and the other plates go quickly.

---

## 9. The analysis script

`EXP1\Lab\xmodal_rect_plate_moi.m` — X-Modal data -> plots -> period -> MOI, for the
rectangular plate only. Run it from `EXP1\Lab`.

Working units are **lbm - inch - second, g = 386.088 in/s^2**, so MOI comes out in
lbm*in^2, matching `AddInertiaTensor.m`. Enter mass as mass; if you weighed in kg the
script converts.

Set five things at the top and run:

```matlab
CFG.file        = 'Ytest1.MAT';   % or 'test2settled.MAT'
CFG.method      = 'compound';     % or 'bifilar'
CFG.targetAxis  = 1;              % 1 = about the 12.9 in axis, 2 = about the 5.9 in
                                  % axis, 3 = about the plate normal
CFG.impactsPerCycle = 2;
CFG.gravityDoubling = false;      % true if the sensor axis is along gravity
```

Then fill `G.topHalfSpacing` / `G.botHalfSpacing` from calipers to unlock the bifilar
branch, and correct `G.pivotToCG` per run.

It reports the period three ways (impact spacing, zero crossings, FFT peak), states the
0.195 Hz resolution floor, and marks the last two INVALID automatically when there is no
energy below 2 Hz — which is the case for both of these files. It also runs four checks
that are easy to skip by hand:

- **Ceiling check** — the fastest this plate can swing about the declared axis, at *any*
  cable length, is sqrt(g/2k)/2pi. A measured frequency above that is not a compound
  pendulum, no geometry required.
- **Length/period consistency** — Jcg > 0 requires L < g*T^2/(4*pi^2). For `Ytest1`
  (T = 1.0855 s) that bound is 11.52 in against the 21.5 in logged. They cannot both be
  right; the script says so instead of returning a number.
- **Conditioning** — prints Jcg as a fraction of the total and the resulting error
  amplification, which is the FAQ's "compare the significance of the Jcg term" done
  numerically.
- **Declared vs closest axis** — compares against the axis you *declared*, and flags it
  if the answer happens to sit closer to a different one. It never silently relabels.

What it produces today: `Ytest1` gives **T = 1.0855 s, f = 0.9212 Hz** from the impact
spacing, matching the Arduino's 0.921 Hz. The compound branch returns a negative Jcg and
explains why; the bifilar branch with a 5.85 in half-spacing gives 78.2 lbm*in^2 against
an analytical 51.65 — so the spacings and the per-run cable length are what stand between
you and a reportable number.
