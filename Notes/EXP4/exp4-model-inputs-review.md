# EXP4: review of Group E's realStirlingEngine_exp4.m inputs (2026-11-10)

- **File:** `Lab Data/EXP4/Model/realStirlingEngine_exp4.m` (added 11/9). Only the inputs differ from Canvas/EXP4/realStirlingEngine.m; the code is unchanged.
- **How it was checked:** the file's logic was run through a line-by-line Python port.

## Inputs as filed
| Input | Value |
|---|---|
| TH / TC | 330 / 295 K |
| R | 1005 J/kg·K |
| P0 | 1,013,000 Pa |
| base | Ø 9.8 cm, height 2.24 cm |
| displacer | Ø 8.40 cm, thickness 0.89 cm, offset 0.85 cm, stroke 0.824 cm |
| piston | Ø 1.62 cm, offset 0.55 cm, stroke 0.824 cm |
| phase | +1.74533 rad (+100°) |

## Results as filed
- CR = 1.0142. This matches the "1.01" another group quoted in the 10/27 lab.
- V = 119.9–121.6 cm³.
- P = 1012–1076 kPa.
- ∮P dV = −77.6 mJ per cycle.

## Issues
1. **P0 is 10× too high.** 1,013,000 Pa is 10 atm; room pressure is 101,325 Pa. The P axis and any work scale with it. Fixed: P = 101–108 kPa, |W| ≈ 7.8 mJ per cycle.
2. **R = 1005 is c_p of air, not its gas constant (287).**
   - R cancels out of P, so the plot doesn't change.
   - It does change the gas mass m: 0.041 g vs. the correct 0.144 g.
   - The mass comment says "grams", but m is in kg.
3. **The phase sign is flipped relative to the posted script's convention (−π/2, piston lags).**
   - With +100° the plotted loop has the identical shape, but it runs the other way. ∮P dV comes out negative (heat-pump direction).
   - Use −1.74533 for positive work: +7.76 mJ.
   - Also double-check whether 100° was measured or assumed.
4. **The displacer offset is marginal.** 0.85 − 0.412 − 0.445 = −0.007 cm, so the displacer dips 0.07 mm into the hot plate at 180° — exactly state 1, where m is evaluated. Re-measure the bottom clearance or use offset ≥ 0.86. The effect is tiny.
5. **The temperatures are placeholders.**
   - 295 K is room temperature, but the measured top plate was ~305–308 K.
   - Day 1 measured points: test 2: 326/305 K; test 4: 344/308 K; test 5: 338/307 K.
   - Run one case per test.

## Ideal-cycle preview (P0 = 101.3 kPa, R = 287, phase −90°, 330/295 K)
- Ideal Stirling cycle with the same m, TH, TC, Vmin and Vmax: W = mR(TH − TC)·ln CR = 1.436e-4 × 287 × 35 × ln 1.0142 ≈ **20.3 mJ**.
- The script (Schmidt-type) model gives ≈ 7.9 mJ, about 39% of ideal.
- Loss reasons: sinusoidal motion, the 17.8 cm³ annular regenerator dead volume, and the small piston (swept 1.70 cm³ vs. 45.7 cm³ displacer swept).
