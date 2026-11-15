# EXP2 steady-state detector (dry-run tool, partially lab-validated)

CFD-style residual convergence, ported to "has the rod stopped heating."
Laptop-side only -- never touches the Arduino sketch.

## Files
- `check_steady_state.m` -- core logic. Per channel, fits a line through
  the last `windowSize` samples (real elapsed time, not assumed 5s
  spacing) and checks |slope| < `slopeThresh`. Declares steady only if
  ALL channels pass simultaneously (the "AND" across channels, same
  idea as ANDing continuity/momentum/energy residuals in a CFD solve).
- `import_arduino_dump.m` -- **use this to load real data.** Takes a
  saved dump file (or pasted dump text) from the Arduino's `D` command
  and returns a table (Sample, Time_s, Ch1..Ch4). Handles the
  `SampleOutput.txt`-style `%` comment lines and the `Ts = [...]`
  wrapper automatically. **Plots by default** -- a time-series of all
  4 channels, colored red (Ch1=T0, nearest heater) through blue
  (Ch4=T3, farthest) so color always means position. Pass
  `'Positions', [d1 d2 d3 d4]` (your measured distances from the Run
  Log sheet) to also get a second plot of the actual steady-state
  T(x) curve along the rod. Pass it straight into `check_steady_state`:
  `[isSteady, slopes] = check_steady_state(T.Time_s, [T.Ch1 T.Ch2 T.Ch3 T.Ch4], 5, 0.05);`
  The sample interval is a stated assumption (default 5.06s, matching
  the 9/26 Canvas update), not measured -- override it with `'Interval'`
  once you've timed a real run on the Calibration sheet.
- `test_steady_state_offline.m` -- runs the check-logic against
  Canvas/EXP2/SampleOutput.txt's sample data, sample-by-sample, printing
  the slope at each step. **Verified working** (ran the same math in
  Python to check the logic 2026-09-22 -- it correctly never declares
  steady on this data, because the sample data is monotonically heating
  the whole way through; slopes come out ~0.17-0.6 C/s in that snippet,
  which is why the 0.05 C/s placeholder threshold is plausible as a
  "flat" cutoff but NOT confirmed against real steady rod data). Mostly
  superseded by `import_arduino_dump.m` now that you can load your own
  data instead of the hardcoded Canvas snippet -- kept as a worked
  example.
- `monitor_live_serial.m` -- **confirmed broken as designed, do not use
  as-is.** It was built to parse a continuous, timestamped Serial print
  ("hh:mm:ss.mmm -> Temperature: ...") glimpsed on the lecture
  projector. The actual `EXPT2_1d.txt` on Canvas (confirmed 2026-09-28)
  never prints per-loop at all -- it only updates the LCD every loop and
  prints to Serial when you send it `D` (dump the whole buffer so far)
  or `C` (clear). There is no live stream for this script to listen to,
  so it will sit there parsing nothing. If you want a live in-lab
  monitor, it would need to be rewritten to send `D` itself on a timer
  and re-run `check_steady_state` against the growing buffer each time
  -- ask if you want that built. Until then, the safe fallback is what
  the workbook already has you doing: watch the LCD / send `D`
  yourself and paste the last 5 samples into the Steady-State Check
  sheet.

## Before trusting this in lab
1. ~~Get the real `.ino`~~ -- done, it's `Canvas/EXP2/ArduinoCode/EXPT2_1d.txt`,
   confirmed to only stream on `D`/`C` (see above).
2. Once you have a real transient data set (not the 11-sample Canvas
   snippet), load it with `import_arduino_dump.m` and look at what the
   slope actually settles to once a rod visibly flattens out.
   Set `slopeThresh` from that number, not from the placeholder here.
3. Decide `windowSize` / `minConsecutive` together with your real
   ~5s sample spacing (confirmed by the 9/26 Canvas update, not the
   ~7s the lecture originally estimated) -- tune against real data.
4. If you build the live `D`-polling version of `monitor_live_serial.m`,
   still treat it as backup automation, not a replacement for watching
   the screen.

Not yet moved to `Output/EXP2/` since `monitor_live_serial.m` still
hasn't been run against real hardware -- move the folder there once
your group has real lab data to validate against.
