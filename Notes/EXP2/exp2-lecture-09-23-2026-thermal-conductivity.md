# Thermal Conductivity Lab Briefing (EXP2 kickoff lecture)

**Date:** Wednesday, Sept 23, 2026 3:35PM  
**Duration:** 47:44  
**Course:** Experimental Methods  
**Topic:** Thermal Conductivity Lab Setup and Requirements

---

## Corrections (confirmed by the group, 2026-09-23, cross-checked against the Canvas EXP2 FAQ and the 9/21 lecture photos)

This doc was auto-generated from the lecture recording and had two errors, now fixed below and corrected in place:

1. **Rod dimensions.** The four solid rods (copper, aluminum, stainless steel, brass) are **0.2" diameter × 12" long**, not 0.3". The 0.3" figure belongs only to the hollow copper tube (0.3" × 12"). The two cross-sections are close but not identical by coincidence — the tube's larger OD with a thin wall roughly matches the solid rod's metal cross-sectional area, which is presumably the point of including it.
2. **Power supply readout.** The supply does **not** display current or power directly — confirmed by the group, matches the Canvas FAQ. Current can't be measured in line with the heater (would damage the meter). Input power must be estimated by disconnecting the heater, metering its resistance in isolation, then computing P = V²/R at the 12V supply voltage.

---

## Summary Keywords

Heating element, Steady state, NX model, Thermal conductivity, Transient data, Copper tube, Aluminum rod, Stainless steel, Brass rod, Heat flux, Temperature measurement, Thermistor resistance, Voltage control, Convection fan, Thermal sensors

---

## Key Equipment & Setup

### Heating Element
- 12V heater (80°C and 120°C variants), resistive
- Input power **cannot be read directly off the supply** — no current/power display. Estimate power via P = V²/R: disconnect the heater, meter its resistance across the screw terminals (hot or cold), then compute at 12V. Not all of that power reaches the rod — flag this as a source of energy-balance error.
- Max temperature achievable: ~120°C

### Test Materials
- **Solid rods:** Copper, Aluminum, Stainless Steel, Brass — **0.2" diameter × 12" long** (confirmed twice independently against 9/21 lecture photos)
- **Hollow tube:** Copper tube, **0.3" diameter × 12" long** (cross-sectional area of the tube wall is nearly identical to the solid copper rod's cross-section)
- Titanium excluded this year to reduce material testing burden

### Temperature Measurement
- **Thermistors** (4 channels) used with voltage divider circuit — 10kΩ series resistor + 10kΩ NTC thermistor per channel, on analog inputs A0–A3
- 10-bit ADC inputs measure voltage across thermistor in divider circuit
- Thermistor resistance changes with temperature; calculated using the Beta thermistor equation (RT0 = 10000, B = 3977)
- Temperature accuracy: ±0.1°C (code-calculated values)
- Data capture: nominal 5s loop delay, but real capture-to-capture interval is closer to ~7s once LCD refresh overhead is accounted for — measure actual elapsed time rather than assuming a clean 5s grid when reducing data

### Forced Convection Option
- Low-speed fan available for testing different flow conditions
- Can run tests with:
  - No air flow (natural convection)
  - Low-speed parallel flow (away from heating element)
  - Counter-flow (back up the length)
- Silicon tubing connectors (nearly 2" length) - no hose clamps needed

### Arduino Data Logging
- Real-time temperature display available
- Can read values manually and record in table, OR let code dump formatted data
- Output format supports easy data use for plotting

---

## Lab Requirements & Experimental Plan

### Main Objective
**Validate NX thermal models against physical measurements** - match your steady-state model to lab data

### Transient Data Collection
- **One transient data set per material** (not required for validation, but useful)
- Run heating element at full power, measure warm-up time to steady state
- Shows comparative warm-up rates between materials
- Helps estimate waiting time for reaching steady state at different temperatures
- Data interval: 5-7 seconds capture rate is sufficient (not necessary to sample every 1 second)

### Steady-State Measurements
- Capture temperature gradient along rod at steady state
- Plot temperature vs. position at steady state
- This is what you'll compare to NX model predictions
- Can test at multiple temperatures to calibrate/validate model

### NX Model Approach
- Use provided NX steady-state model as starting point (given values are "totally unrealistic" - meant for structure only)
- **Option 1:** Adjust input power (given value provided) down to realistic levels
- **Option 2:** Change to heat flux boundary condition
- **Option 3:** Use imposed temperature boundary condition
- Match measured temperature gradient to model predictions by adjusting:
  - Input power level
  - Heat flux value
  - Boundary conditions (adiabatic end? allow flow out sides/end?)
  - Thermal properties: K (conductivity) and C (convection coefficient)

### Model Validation Strategy
- Don't waste effort on transient NX models - steady state only
- Primary variables to adjust: power/heat flux and convection coefficient
- Use experimental data to identify actual thermal conductivity within nominal range
- Compare experimental gradient to model-predicted gradient
- Comment on differences (perfect match unlikely) and how you adjusted properties

### Sensor Usage Requirements
- **Must use each sensor type at least once** - no excluding methods entirely
- Can prefer some sensors over others
- Can't claim a method doesn't work just because you didn't succeed with it
- Distinguish between "method doesn't work" vs. "we weren't successful with this sensor"

### Temperature Range & Constraints
- Minimum: Room temperature baseline
- Maximum: Limited by heater (~120°C max, less if not insulated)
- Can use different temperatures on same rod for calibration purposes
- Thermal properties (K, C) don't change significantly in this temperature range

---

## Data Collection Tips

- Data doesn't need to be captured every 1 second (too much, unnecessary work)
- Every 5-7 seconds is reasonable for materials with this conductivity range
- Can down-sample to every 15 seconds if preferred
- Watch for slow development of temperature down the rod length during transient phase
- Record ambient temperature for reference (use thermistor in air or thermal couple)

---

## Schedule & Important Notes

- **No lab tomorrow (9/24) or Friday (9/25)**
- **Lab begins Monday 9/28**
- Two Monday holidays in semester required two open days: used Tue, Wed, Thu, Fri for group scheduling
- Instructor unavailable Tue-Fri 10:10AM-2:00PM for endowed professorship events

### File Naming Convention for Submissions
Format: `EXP_TEST_PT_[TYPE]_[NAME]` where:
- TEST = E (one section), B, T, or S
- PT = Full (FULL), Summary (SUM), Slides (SLD), Video (VID), Abbreviated brief video (ABR)
- [NAME] = LastName-LastName (alphabetical for groups)

Examples of inconsistent naming that require manual re-sorting:
- Thursday vs THU
- Different group names each submission
- Capitalization variations

---

## Key Takeaways

1. One transient dataset per rod material
2. Steady-state temperature gradient is primary comparison to NX model
3. Adjust power, heat flux, or boundary conditions to match model to data
4. Use measured data to calibrate thermal properties (K, C) within realistic ranges
5. Comment on differences between model and experiment
6. Thermal properties constant across your temperature range - don't vary K by temperature
7. Data collection every 5-7 seconds is adequate - don't oversample
8. Must use each sensor type at least once
9. Lab setup begins Monday with assigned groups and time slots
10. Rods are 0.2" dia (solid) / 0.3" dia (hollow copper), both 12" long — not all 0.3" as originally transcribed
11. Power supply has no current/power readout — compute input power via P = V²/R from a disconnected resistance measurement
