# Chain & Plate Lab

An offline, user-configurable simulator for Experiment 1 in this folder. It computes exact mass properties for polygonal plates with polygonal windows and circular through-holes, combines arbitrarily placed and oriented plates into one rigid assembly, predicts several distinct chain-suspension motions, integrates their nonlinear equations in time, and propagates measurement uncertainty with a seeded Monte Carlo calculation.

## Start

From this directory:

```powershell
node server.mjs
```

Open <http://localhost:5173>. No install, cloud service, or network dependency is needed. To run the physics checks:

```powershell
node --test --test-isolation=none physics.test.mjs
```

The app autosaves the current configuration in the browser. Export a JSON file to keep or share an exact setup, import it later, and export individual Monte Carlo trials as CSV.

## Configure a test

1. Select one of the four source plates, or edit a plate's outer vertices, opening polygons, and through-holes directly. All geometric coordinates and radii are **inches**. A circle entry is `x,y,radius`, not diameter. Measured mass and nominal material density are separate: measured mass controls inertia when selected; density controls it in density mode. The inferred density is always checked against the selected material.
2. Add any number of plates. Each added plate has editable x/y/z translation and roll/pitch/yaw. They are treated as one **rigid** assembly. The calculation rotates each exact centroidal tensor and applies the full 3D parallel-axis theorem. User geometry is validated; self-crossing polygons, openings or holes outside material, and overlapping voids are rejected.
3. Set gravity direction in assembly coordinates. `0,-1,0` means the plate drawing is vertical with y upward. For a compound swing or free hinge, set a horizontal pivot axis. A bifilar twist always uses the gravity direction as its rotation axis.
4. Set stock length and deployed length **per strand**. The default is the user's 23 in metal-chain stock, deployed fully in two strands. Set the measured chain linear density to include chain mass. The default zero is an explicitly flagged unknown, not a claim that the physical chain is massless.
5. Choose the suspension model and attachment hole. For bifilar twist, enter top half-spacing and either bottom half-spacing or select the two bottom holes. The selected-hole midpoint is checked against the assembly CG axis. Enter release angle and a phenomenological viscous damping ratio to see the time history. The displayed finite-angle period is conservative, while the animation includes damping.
6. Optionally enter a measured period. The app inverts the relevant ideal compound or bifilar model to estimate inertia, including finite-angle correction. It will refuse an unphysical negative-inertia result or a four-bar period that contains no inertia information.
7. Set 1σ uncertainty assumptions and run 10 to 10,000 seeded Gaussian trials. Each trial rebuilds the plate/assembly properties and suspension prediction. The UI reports valid trials, rejected geometries, and the 5th/median/95th percentiles of period. The CSV gives every valid trial.

The editor changes numerical geometry, not a picture only. Preset hole positions can be changed or removed. Any polygonal plate, including a concave outline or multiple nonoverlapping windows, is supported. The app uses SI units internally for dynamics and reports inertia in kg·m²; a plate's geometry inputs remain in inches to match the lab sheets.

## Physics

For a uniform extruded plate, the code integrates polygon area and first/second area moments by Green's theorem, subtracts exact circular-hole moments, and adds `m t²/12` to the two in-plane centroidal moments. An arbitrary plate's mass can be set directly or derived from volume and material density. The three-dimensional assembly tensor is

```text
I_C = Σ [R_i I_i R_iᵀ + m_i (||r_i||² 1 − r_i r_iᵀ)]
```

where `r_i` runs from the assembly CG to each plate CG. Principal moments and axes come from a symmetric eigensolver.

The four suspension models are deliberately separate:

| Motion | Model | What can be learned |
| --- | --- | --- |
| Rigid compound swing | Plate and one straight chain rotate together about a horizontal top axis; gravity acts on both masses. The pivot inertia includes plate CG offset, the plate's full axis tensor, and uniform-chain inertia `m_c L²/3`. The nonlinear torque is proportional to `sin θ`. | One plate/assembly axis inertia, if its share of pivot inertia is large enough. |
| Bifilar twist | Two straight, taut strands join symmetric top/bottom anchors. At twist `θ`, their vertical drop is `h(θ)=√(L²−a²−b²+2ab cos θ)`. The ODE includes body/chain rotation, vertical translation, and angle-dependent effective inertia; the small-angle limit reduces to the course equation when chain mass is zero and `a=b`. | Inertia about the vertical axis, if supports are centered and spacing/length are measured. |
| Parallel-chain translation | Two equal parallel strands move as a four-bar; the plate stays parallel to itself. Plate inertia drops out of the oscillation equation. | Chain length or translation dynamics, **not** plate inertia. |
| Chain + free plate hinge | A two-angle, two-mass-matrix model, with chain swing and plate rotation coupled by `mLd cos(q₁−q₂)`. It reports both small-angle normal modes and integrates the full nonlinear equations. | Mode interpretation and placement sensitivity; a single measured frequency is insufficient to determine an axis inertia. |

The time trace uses fixed-step fourth-order Runge–Kutta integration and user-entered viscous damping. Conservative finite-amplitude periods for compound/four-bar use the exact elliptic-integral correction; bifilar periods use energy quadrature with the angle-dependent effective mass. The Monte Carlo distribution uses these finite-amplitude conservative periods, so it does **not** include uncertainty in unmeasured impacts or damping.

## Source choices and unresolved measurements

The app is based on the material in `EXP1/Basic_Info`, `EXP1/Exp1_FAQ.docx`, `EXP1/ClassNotes_Aug_31.pdf`, `EXP1/Pendulum Models.pdf`, `EXP1/Lab/LabData/Plate_measurements.pdf`, the lab photographs, the workbook, `EXP1/Lab/EXP1_Day1_Data_Review.md`, and the four `EXP1/Analytical_Plate_Models` scripts/reports. The preset geometry follows those analytical scripts, including their explicitly labeled approximations. Its centers of gravity and finite-thickness inertias for Plates 1–3 reproduce those reports to floating-point precision. The rectangular preset defaults to 0.50 in because the later Day 1 review reconciles the 1.687 kg mass with aluminum; the earlier workbook and MATLAB report used 0.45 in. Both values are possible inputs.

| Item | What the folder says | How the app handles it |
| --- | --- | --- |
| Chain length | Workbook: 18.757 in for one setup; photo estimate: ~20.8 in; Y-run period implies ~11.53 in for a different setup. | 23 in per-strand stock is the requested starting value. Deployed length is editable and must be entered for **each** physical run. None of the old lengths is silently fitted. |
| Chain mass | No weighed mass or linear density found. | Input starts at zero and produces a visible warning. Measure chain mass/length to enable its gravitational and inertial terms. |
| Rectangle thickness | Workbook / older analytical file: 0.45 in. Later Day 1 analysis: 0.50 in inferred from aluminum density and mass. | Defaults to 0.50 in; thickness is editable. With exact 12-hole geometry, this gives `[31.6597, 150.7833, 181.9896] kg·cm²`, slightly below the no-hole approximation in the Day 1 review. |
| Plate 1 boundary | Lower transition has no measured curve radius/profile; several hole centers are photo estimates. | Uses the source straight-chord approximation and flags it. |
| Plates 2–3 holes | Diameter 0.184 in transferred from Plate 1. Plate 3 thickness 0.50 in is assumed. | Preset assumptions remain editable and visible. |
| Plate 3 material | Preset mass 9.052 kg and assumed thickness imply ~6122 kg/m³, unlike nominal stainless; NX assigned material/geometry differs. | Uses the supplied finished mass, reports effective density, and warns against treating the material label as confirmed. |
| Old motion data | Day 1 review identifies the Y run as four-bar translation (0.921 Hz) and questions the X/Z 1.688 Hz interpretation. X-Modal's AC coupling attenuates ~1 Hz tilt and its impact bursts cannot by themselves establish plate MOI. | Old signals are **not** automatically treated as calibration targets. The user can enter a period only after selecting the motion and geometry for that run. |

## Validation and limits

`physics.test.mjs` checks the source plate mass properties, corrected rectangle, 3D assembly parallel-axis behavior, four-bar independence from plate inertia and its 0.921 Hz / 11.53 in reference, bifilar course-equation limit, time integration, period inversion, seeded Monte Carlo reproducibility, and invalid overlapping holes.

This is a high-fidelity **rigid-body suspension model**, not a discrete-link contact simulator or finite-element solver. It assumes uniform density within each plate, rigid inter-plate joints, straight taut chain strands, fixed upper anchors, ideal lower hinges unless the rigid mode is chosen, no cable stretch, and a simple viscous damping law. A chain that goes slack and snaps, shifts pivot links, rubs on screws, or excites plate bending needs measured link dimensions, friction/contact data, and a different event-driven multibody solver. The simulator flags suspect geometry and identifiability rather than manufacturing a precise answer from absent parameters. The rendered apparatus is a schematic; all reported numbers come from the mass-property and dynamics code, not from its drawing.
