# Analytical Plate Models

## Report-ready MOI comparison

Run `plate_moi_comparison_analysis.m` to calculate the four analytical
centroidal inertia tensors and compare them with the NX reference values and
the already-calculated experimental MOIs. The script does not read or fit raw
accelerometer records. Its `experimental_input_mode` can import
`combined_output/pendulum_summary_results_lbm_in2.csv` or use a manually
entered 4-by-3 `[Ixx Iyy Izz]` matrix. Tables, figures, and a MAT file are
written to `combined_output/moi_comparison`; all MOIs use `lbm*in^2`.

## Plate 1 plus Plate 4 rigid assembly

`combined_plate_pendulum_analysis.m` also combines the notched HDPE plate
(Plate 1) with the rectangular stainless-steel plate (Plate 4). The assembly
pose inputs are near the top of the script. The calculation rotates both full
centroidal tensors into one frame, finds the mass-weighted combined CG, applies
the three-dimensional parallel-axis theorem, sums the tensors, and solves for
the principal moments and axes. The combined assembly is body index 5 for any
future pendulum-data configuration. Assembly CSV and PNG outputs are written
to `combined_output`.

This folder contains purely mathematical MATLAB models for the three plates dimensioned in `Plate_measurements.pdf` plus the user-specified `12.9 x 5.9 x 0.45 in` rectangular plate. No pendulum time history, accelerometer, Arduino, XModal, or other experimental data are loaded or fitted.

The current user-provided masses are `1.15897386`, `4.5350165`, `9.052279652`, and `1.687 kg` for Plates 1 through 4. Each script derives the uniform effective density needed for its finished geometry and prescribed mass. It also prints the corresponding force at standard gravity in newtons and pounds-force.

## Running the models

Run everything from MATLAB with:

```matlab
run_all_plate_models
```

Or run an individual model:

```matlab
plate01_notched_solid_model
plate02_offset_rectangular_frame_model
plate03_irregular_window_frame_model
plate04_rectangular_plate_model
```

Run the independent checks with:

```matlab
verify_analytical_plate_models
```

Each plate script prints to the Command Window and creates a text report, MAT result file, and 300 dpi dimensioned PNG in `output`. All dimensions and coordinates shown in the PNG figures are inches.

## Coordinate and unit convention

- The origin is the lower-left corner of the outer bounding box on the bottom face.
- `+x` points right, `+y` points up, and `+z` passes through the thickness.
- PDF planform dimensions are entered in centimeters; thicknesses and Plate 4 dimensions are entered in inches and converted with `1 in = 2.54 cm`.
- CG is printed in centimeters and inches.
- Inertia is printed in `kg*cm^2`, `kg*m^2`, and `lbm*in^2`.
- `IXX`, `IYY`, and `IZZ` are centroidal components about axes parallel to the drawing axes. Principal moments and right-handed principal-axis directions are also printed.

## Geometry and holes

| Model | Major geometry | Holes | Thickness |
|---|---|---|---|
| Plate 1 | 40.2 by 19.9 cm bounding box with the measured 13.3 cm left height, 17.5 cm lower run, 3.6 cm step, and 12.3 cm right run | 16 at 0.184 in diameter | 0.75 in, measured |
| Plate 2 | 60.7 by 30.5 cm outer rectangle minus a 35.6 by 15.4 cm opening at `(17.4, 10.1)` cm | 16 at assumed 0.184 in diameter | 0.50 in, measured |
| Plate 3 | 61.1 by 30.4 cm outer rectangle minus the seven-vertex concave opening labeled in the PDF | 16 at assumed 0.184 in diameter | 0.50 in, explicit assumption |
| Plate 4 | 12.9 by 5.9 in solid rectangle | 12 at 0.180 in diameter | 0.45 in, user supplied |

All holes are exact circular through-voids in the property calculation. Their centers are generated in inches and converted to centimeters for the integrals.

- Every nominal perimeter center is `0.250 in` from its adjacent outer edge, as directed by the user.
- Plates 2 and 3 use the visible 16-hole rectangular-perimeter pattern: five positions on each edge, with corner positions counted once.
- Plate 1 uses the 16 visible holes. Its top, left, and right locations are regular; locations around the lower horizontal edge, slope, step, and bottom edge are approximated from the photograph because every center is not dimensioned.
- The PDF gives `0.184 in` diameter for Plate 1. Plates 2 and 3 appear to use the same hardware, so `0.184 in` is carried over as an editable assumption.
- Plate 4 uses the user-provided `0.180 in` diameter and the 12-hole layout visible in the lab photographs: five holes on each long edge and one additional midpoint hole on each short edge.

Plate 1 has a visibly curved lower transition, but the PDF gives no radius, center, sagitta, spline, or intermediate coordinate. The model uses a straight chord from `(17.5, 6.6)` to `(27.9, 3.6)` cm. Page 5 does not repeat Plate 3 thickness, so its script uses the adjacent frame value of `0.50 in` and labels it as an assumption.

## Analytical method

The code evaluates exact shoelace area, first-moment, second-area-moment, and area-product integrals for every polygon. Openings and circular holes are subtracted. The prescribed finished mass fixes the uniform density. For a uniform extrusion:

```text
Ixx = sigma*Integral((y-yCG)^2 dA) + m*t^2/12
Iyy = sigma*Integral((x-xCG)^2 dA) + m*t^2/12
Izz = sigma*Integral(((x-xCG)^2 + (y-yCG)^2) dA)
Ixy tensor entry = -sigma*Integral((x-xCG)*(y-yCG) dA)
```

Principal moments and axes are the eigenvalues and orthonormal eigenvectors of the symmetric centroidal tensor. Reports include symmetry, orthogonality, positivity, and extrusion-identity checks. Course pendulum equations are printed only for context and are not evaluated because pivot-to-CG distance, cable length, and suspension radius were not supplied.

## Current finite-thickness results

These results include all modeled circular holes and use the current user-provided masses. Inertias below are `kg*cm^2`.

| Plate | CG `[x y z]` cm | `IXX` | `IYY` | `IZZ` |
|---|---|---:|---:|---:|
| 1 Notched solid | `[21.9944 11.7871 0.9525]` | 29.1751 | 159.4890 | 187.9631 |
| 2 Offset rectangular frame | `[28.3052 14.1749 0.6350]` | 444.2611 | 1711.3628 | 2154.4048 |
| 3 Irregular window frame | `[30.4639 15.8067 0.6350]` | 960.3586 | 3619.6525 | 4577.5777 |
| 4 Rectangular plate | `[16.3830 7.4930 0.5715]` | 31.6166 | 150.7402 | 181.9896 |

## NX comparison

`run_all_plate_models` also runs `compare_with_nx_models.m` and writes `output/nx_comparison_results.txt`. The mapping is Plate 1 to NX Model 3, Plate 2 to NX Model 2, Plate 3 to NX Model 4, and Plate 4 to NX Model 1.

NX uses assigned CAD materials and more detailed geometry. Its mass is inferred from the uniform-extrusion identity:

```text
m = 6*(IXX + IYY - IZZ)/t^2
```

For comparison only, NX inertia is divided by inferred NX mass and MATLAB inertia is divided by the user-provided mass. Both are reported on a common `1.000 kg` basis. This compares mass distribution rather than material density; inferred NX masses are not claims about physical lab weights.

| Match | MATLAB normalized IXX, IYY, IZZ | NX normalized IXX, IYY, IZZ | Symmetric percent difference |
|---|---|---|---|
| Plate 1 / NX Model 3 | 25.1733, 137.6122, 162.1807 | 25.0171, 137.4768, 162.2251 | 0.622%, 0.098%, 0.027% |
| Plate 2 / NX Model 2 | 97.9624, 377.3664, 475.0600 | 93.9944, 358.4750, 452.2006 | 4.134%, 5.135%, 4.931% |
| Plate 3 / NX Model 4 | 106.0903, 399.8609, 505.6823 | 106.1104, 399.8929, 505.7344 | 0.019%, 0.008%, 0.010% |
| Plate 4 / NX Model 1 | 18.7413, 89.3540, 107.8776 | 18.3539, 87.4538, 105.5948 | 2.089%, 2.149%, 2.139% |
