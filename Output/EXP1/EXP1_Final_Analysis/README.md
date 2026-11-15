# EXP1 Final Analysis

Everything in the Experiment 1 summary report comes out of this folder.

## How to run
Open this folder in MATLAB and type:

    run_exp1_all

It runs three steps in order. Nothing else is needed; the raw lab files are
read from `EXP1/Lab/LabDay2` (this folder must stay inside `EXP1`).

| Step | Script | What it does | Output folder |
|---|---|---|---|
| 1 | `combined_plate_pendulum_analysis.m` | Plate outlines -> CG and Ixx/Iyy/Izz (holes removed, density set from the weighed mass); assembly combination with the parallel axis theorem; reads the commercial-sensor .MAT files and finds each run's frequency; pendulum equations -> experimental inertia and predicted frequency | `combined_output/` |
| 2 | `plate_moi_comparison_analysis.m` | NX values scaled to the weighed masses; MATLAB vs NX vs test tables and bar charts | `combined_output/moi_comparison/` |
| 3 | `exp1_report_outputs.m` | Reads the Arduino .txt files; paired Arduino + commercial bifilar result; uncertainty and pivot-distance sensitivity; density check; principal-axis angles; report tables, run log, sample calculations; report figures | `report_outputs/` |

## Report item -> file
| Report item | File in `report_outputs/` |
|---|---|
| Table 1 (configurations, density check) | `Table1_configurations.csv` |
| Table 3 (test matrix, axis mapping, geometry) | `Table3_test_matrix.csv` |
| Table 5 (frequencies and periods, both sensors) | `Table5_frequencies.csv` |
| Table 6 (final CG, principal axes, Ixx/Iyy/Izz) | `Table6_final_mass_properties.csv` |
| Table 7 (MATLAB vs NX vs test, uncertainty, frequency check) | `Table7_comparison.csv` |
| Table 8 (assembly, NX vs MATLAB) | `Table8_assembly.csv` |
| Uncertainty and sensitivity (the 47% / 6.6% numbers) | `TableA_uncertainty_sensitivity.csv` |
| Run log including excluded runs | `TableA2_run_log.csv` |
| Worked sample calculations | `sample_calculations.txt` |
| Every number quoted in the text | `report_numbers_summary.txt` |
| Signal processing figure | `Fig_signal_processing_YData1.png` |
| Arduino vs commercial twisting-test figure | `Fig_bifilar_sensor_check.png` |
| Comparison figure | `Fig_moi_comparison.png` |

Step 1 and 2 figures (plate geometry, assembly drawing, all time records and
spectra, MOI bar charts) are in `combined_output/` and `combined_output/moi_comparison/`.

## Inputs you might edit
- Masses, thicknesses, chain lengths, pivot distances: top of step 1.
- NX values: step 2 (plates) and step 1 `assembly_setup` (assembly).
- Measurement uncertainties (0.25 in lengths, 0.125 in radius), Arduino
  record length (1.833 s), handbook densities: top of step 3.

## Changes from the original scripts in Analytical_Plate_Models
- Plate 4 (Config 1) labeled 6061-T651 aluminum (was "stainless steel"; label only).
- Step 1 compares the assembly to the final NX model (23.4476 / 100.5195 / 122.5171).
- Step 2 uses the final NX model for the HDPE plate (9.9802 / 54.5123 / 64.2381).
- Step 3 is new. The originals are untouched.

Helper functions used by step 2: `analytical_extruded_plate.m`,
`notched_plate_perimeter_holes.m`, `rectangular_perimeter_holes.m`.
