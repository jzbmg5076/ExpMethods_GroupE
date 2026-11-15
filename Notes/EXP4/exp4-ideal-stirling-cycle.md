# EXP4: Ideal Stirling cycle, processes and assumptions (2026-10-27)

- Standard thermo content. Engine and script details come from `exp4-thermodynamics-kickoff.md`.
- If the README/handout numbers the states or lists the assumptions differently, go with the handout.

## The four processes (state numbering varies by textbook)
- **1→2 Isothermal expansion at T_H:** heat comes in from the hot plate and the gas pushes the piston out. Q_in = W_out = mRT_H ln r.
- **2→3 Constant-volume cooling (regeneration):** the displacer moves the gas from the hot side to the cold side through the regenerator, which stores m·c_v·(T_H − T_C). No work is done.
- **3→4 Isothermal compression at T_C:** heat leaves to the cold plate while the piston compresses the gas. Q_out = W_in = mRT_C ln r.
- **4→1 Constant-volume heating (regeneration):** the gas goes back through the regenerator and picks up the same m·c_v·(T_H − T_C). No work is done.
- r = V_max / V_min, and W_net = mR(T_H − T_C) ln r.
- The regenerator heat is recycled inside the engine, so the only outside heat comes in at T_H and leaves at T_C. That makes η = 1 − T_C/T_H (in kelvin), which is the Carnot efficiency.
- On a P–V diagram the cycle is two isotherm curves joined by two vertical lines. On a T–s diagram it is two horizontal lines joined by two constant-volume curves.
- It is the Carnot cycle with the two isentropic steps replaced by two constant-volume regeneration steps.

## Assumptions
1. **Ideal gas, usually with constant specific heats.** Internal energy then depends only on T, so the heat stored in the regenerator equals the heat it returns.
2. **Fixed mass.** The system is closed and nothing leaks.
3. **Truly isothermal expansion and compression.** Heat transfer is perfect, so the gas sits at exactly T_H or T_C, and the source and sink stay at constant temperature.
4. **Perfect regenerator.** It stores and returns 100% of the heat. This is the assumption that makes η equal Carnot.
5. **Reversible.** No friction and no pressure drop through the passages; the pressure is the same throughout the gas at every instant.
6. **Discontinuous motion.** The processes happen one at a time. The power piston holds still during the constant-volume transfers, which gives the diagram sharp corners.
7. **No dead volume.** All of the gas is in the hot space during expansion and in the cold space during compression.
8. **No heat leaks.** No heat is lost to the room, and none conducts straight from the hot plate to the cold plate through the engine body.

## How this maps to the EXP4 engine and script
- `realStirlingEngine.m` is a Schmidt-type model.
  - **What it keeps:** assumptions 1 and 2, a single uniform pressure, and gas spaces held at fixed temperatures.
  - **What it drops:** assumption 6 (the 90° crank gives smooth sinusoidal motion) and assumption 7 (it includes the regenerator gap and clearance volumes).
  - **Result:** for the same m, T_H, T_C, V_min and V_max, its P–V loop sits inside the ideal Stirling loop. At every V, mRT_C/V ≤ P ≤ mRT_H/V.
- The real engine also breaks these assumptions:
  - **Assumption 3:** at up to ~300 RPM (~5 rev/s) the air doesn't fully reach the plate temperatures. The thermocouples read the plate surfaces, not the gas.
  - **Assumption 4:** there is no dedicated regenerator, only the gap around the foam displacer, so the heater has to re-warm the gas every cycle. This is the biggest reason the actual efficiency is far below Carnot.
  - **Assumption 8:** the exposed vs. insulated base test measures this directly.
  - **Assumption 5:** there is piston friction, and air leaks past the piston.
- **Efficiency with no regeneration**, for the efficiency discussion:
  - η = (T_H − T_C)·ln r / [T_H·ln r + (T_H − T_C)/(k − 1)], with k = 1.4 for air.
  - It falls further below Carnot as r → 1 — the same tension as the "CR closer to 1" flag in the kickoff notes. Real-engine losses such as friction are presumably what favor a low CR there.
- **Lab thinking question:** at the same ΔT the ideal cycle predicts the same work per cycle and the same efficiency for bottom heating and top heating. Any measured difference therefore has to come from the assumptions the real engine breaks. Which ones change when the heater is flipped?
