# Experiment 3 objectives — lecture evidence review

Reviewed 2026-10-25. Study/reference notes, not submitted report prose. Requirements below come from the instructor's recordings and Canvas objective document; recommendations and interpretations are labeled separately. Transcript wording contains speech-recognition errors, so technical names are normalized rather than quoted literally.

## Concept: what the experiment is testing

Experiment 3 is structural dynamics/model validation. When a plate is struck, it can deform in several characteristic patterns, each associated with a natural frequency. The task is to establish which patterns occur and whether theoretical predictions, NX predictions, and physical measurements describe the same behavior. Frequency agreement by itself does not establish that two results describe the same mode.

The second theme is measurement across two physical domains: an accelerometer senses structural acceleration through contact; a microphone senses pressure fluctuations in the air produced by the vibrating plate. The microphone hears contributions from across the structure, not only the patch directly below it. The purpose is to see whether the acoustic measurements identify corresponding structural modes, and to understand discrepancies or missing modes. [L5 09:30–14:36, 24:29–29:39; L7 08:19–13:39, 35:10–40:29]

## Answer: explicit objectives and scope

1. Select **three plates**, all different shapes, comprising **at least two materials**. One must be a **metallic rectangle**. Using all metal is recommended; HDPE is discouraged because its heavy damping and nonlinear behavior make testing harder. This is a recommendation, not a ban on every nonmetallic plate. [R paragraphs 9, 13–18; L5 09:30–14:36; L7 01:00–06:30]
2. Identify **natural frequencies and mode shapes for the first four out-of-plane elastic deformation modes**. The Oct 5 clarification says vertical/out-of-plane motion is of interest, rather than lateral/in-plane modes. Rigid-body bouncing/rocking of the entire plate is not one of these deformation modes. Examine roughly the first six elastic candidates to avoid overlooking a required mode; six is a search recommendation, not a replacement for the four-mode objective. [L5 19:18–24:29; L7 19:34–26:02, 26:02–31:30]
3. Obtain **one analytical/Blevins solution for the rectangle**. Use its actual dimensions and material properties and make a defensible approximation/interpolation for the aspect ratio. Match the appropriate deformation pattern. Do not assume NX is correct and adjust coefficients merely to force agreement. Analytical solutions for the irregular shapes are explicitly not required. [L5 00:56–05:30; L7 18:03–26:02, 26:02–31:30, 32:58–34:53]
4. Obtain **three NX modal models**, one per plate. Match the actual geometry, material and support idealization closely enough to justify the comparison. For the rectangle, compare analytical, NX, accelerometer and microphone results. For the other shapes, compare NX against the experimental observations. [L5 19:30–24:29, 29:39–30:43; L7 35:10–40:29]
5. Perform tests with **both the accelerometer and microphone**, with the detailed minimum coverage below. The two response sensors are used in separate runs with the hammer, not simultaneously. [L7 14:50–16:55, 35:10–40:29]
6. **Validate the modeling** by correlating corresponding shapes and frequencies, explaining differences using engineering evidence, and discussing measurement/model limitations. The instructor does not establish a universal acceptable percent-error threshold in these objective discussions. [R paragraph 13; L5 29:39–30:43; L7 35:10–40:29]

## Worked breakdown: the six-test matrix

The Oct 7 explanation at **35:10–40:29** is the clearest statement of test coverage.

| Plate | Accelerometer | Microphone | Required model comparisons |
|---|---|---|---|
| Metallic rectangle | Full modal survey | Full modal survey, using the same impact points | Blevins + NX + both experimental methods |
| Either of the other two plates | Full survey if this is the chosen full-survey sensor; otherwise partial | Full survey if this is the chosen full-survey sensor; otherwise partial | NX + both experimental methods |
| Third plate | Partial survey | Partial survey | NX + both experimental methods |

Total: **three full modal surveys, three partial surveys, three NX models, one analytical solution**. A partial survey is approximately **4–6 deliberately selected points**, sufficient to distinguish candidate modes and compare relative motion/phase at those points with NX. It is not simply a list of resonance frequencies.

Full-survey grids such as **3 × 5** or **3 × 6** are examples, not a universal fixed requirement. Cover the plate rather than clustering all points in a small central patch. More points increase testing time approximately in proportion to point count. [L5 09:30–14:36, 24:29–29:39; L7 35:10–46:34]

## What makes the validation convincing

### Match shapes before comparing frequencies

Mode order can change with aspect ratio or modeling details, especially for nearby modes. Match the bending/twisting pattern, nodal lines, and which regions move together or opposite one another. Do not equate the first listed NX result with the first measured elastic mode without examining it. [L5 00:56–05:30, 14:36–19:18; L7 26:02–31:30, 35:10–40:29]

### Distinguish support motion from plate deformation

The analytical ideal is free-free. Real tennis/racquetball supports are compliant but not perfectly free. The NX tutorial's fixed-face/cantilever constraint must be removed for the free-free comparison. An unconstrained three-dimensional NX model has six rigid-body modes near zero before elastic modes. The instructor suggests requesting about 12 modes, rather than accidentally returning only rigid-body modes. Soft-spring support modeling is provided to represent realistic supports; exact spring-stiffness matching is raised as an engineering decision, not specified as a numerical acceptance requirement. Adding mass is a tutorial option if needed, not a separate mandatory experiment. [L5 05:33–09:21, 19:30–24:29]

### Use measurements that can actually see the modes

For accelerometer testing, a mode is missed if the fixed response sensor is on its nodal line; an impact on a nodal line also does not excite that mode effectively. Corners are useful starting candidates, but not every corner is active in every mode of every shape. Use preliminary impacts at several locations and try reference-sensor placements before collecting the full grid. [L5 19:30–29:39; L7 40:29–46:34]

Microphone location and height are test decisions because acoustic cancellation/coupling and room noise affect observability. Oct 5 suggests exploring roughly **1–6 inches** from the surface; this is a starting range, not a mandated exact height. A microphone hears other groups and background conversation as well as the plate. Explain how the chosen placement produced usable information. [L5 14:36–19:18, 24:29–29:39; L7 08:19–13:39]

### Get the physical inputs and data quality right

Measure geometry, particularly thickness, and check material properties and mass. A density adjustment that repairs a mass mismatch does not necessarily repair a thickness error, because stiffness changes differently from mass. The Oct 7 spoken discussion of exponents is rough and self-correcting; do not treat each spoken exponent as a separate formula. [L7 35:10–40:29]

Plan point locations, roles, averaging, frequency range, record length and handling of noise before committing to the full survey. Oct 5 distinguishes increasing sampling rate/range from increasing record length to improve frequency spacing. The impact must supply useful energy through the frequencies being analyzed. Windowing and fitting settings must be assessed rather than accepted blindly. [L5 05:33–09:21, 30:53–35:30]

The Oct 13 lab guidance suggests about 800 lines and normally five impacts per averaged point; three careful impacts can be acceptable. Record point number and direction, reject poor hits, and save FRFs/coherence for assessment. These are implementation suggestions and checks, not additional objectives or a universal coherence threshold. [B13 00:00–08:30]

### Explain why the evidence supports the conclusion

The Oct 7 reporting feedback emphasizes engineering reasoning, evidence behind assertions, actual analysis, and conclusions supported by the presented results. This was feedback on earlier work; it does not independently set Experiment 3's report format, due date or exact slide count. [L7 40:29–46:34, 46:34–52:38, 52:38 onward]

**Suggested organization, not an instructor-prescribed table:** For each of the first four target modes, show the identified shape, analytical frequency where applicable, NX frequency, measured accelerometer/microphone frequency, a defined percent difference, and an explanation of discrepancies/missing evidence. Relative to NX, one clearly labeled measure is `100 × (f_measured − f_NX) / f_NX`; the choice of reference must be stated. Use shape images/animations or selected point-motion evidence alongside the frequency table.

## Explicit exclusions and optional techniques

- **Damping estimates are not requested.** The instructor explicitly says this in the Oct 5 windowing discussion and the Oct 13 lab guidance. [L5 30:53–35:30; B13 02:22–06:38]
- Analytical solutions for the nonrectangular plates are not requested. [L7 32:58–34:53]
- Six full spatial surveys are not requested; use the three-full/three-partial matrix. [L7 35:10–40:29]
- Green's functions/acoustic field-theory derivations, lasers, strain gauges, output-only testing and research-level simultaneous sensor fusion are explanatory background, not assigned methods. [L7 08:19–14:50]
- The X-Modal fitting tools/automatic selection tool may be used; if a broad fit is poor, smaller frequency bands and different fitting settings are suggested. Data still need engineering checks. [L5 29:39–30:43, 37:27–44:23]

## Cross-check: later note about no P2/P3 microphone tests

The class MEMORY entry dated Oct 25 records the group's decision that microphone tests were not needed on plates 2 and 3. **That differs from the explicit Oct 7 lecture matrix**, which requires partial checks with the other sensor on the second plate and partial checks with both sensors on the third.

The available Oct 13 lab transcript does not clearly document a waiver. At 00:00 it gives a shortened recap; at 08:30 it allows adapting subsets if tests are difficult, provided the work can be justified. At **2:24:00**, the instructor says that having structural and acoustic data for the rectangle puts the group in good shape. In context, this is day-one progress guidance, not an unambiguous cancellation of the other tests. An exception could have been given separately; this review cannot establish that none exists. Preserve the distinction between the documented lecture requirement and any later group-specific permission.

## Source key

- **L5:** [October 5 lecture](<C:/path/to/ExpMethods_GroupE/Transcripts/Lectures/10-05-2026_lecture.docx>). Times are elapsed recording timestamps; long transcript blocks are cited as ranges.
- **L7:** [October 7 lecture](<C:/path/to/ExpMethods_GroupE/Transcripts/Lectures/10-07-2026_Lecture.docx>).
- **B13:** [October 13 in-lab recording](<C:/path/to/ExpMethods_GroupE/Transcripts/InLab/10-13-2026_Lab.docx>). Used for implementation clarifications and the possible-waiver cross-check; this is not a classroom lecture.
- **R:** [Canvas Structural Dynamics README](<C:/path/to/ExpMethods_GroupE/Canvas/EXP3/[README]StructuralDynamics.docx>). Paragraph numbers refer to the document XML's nonempty paragraph sequence, which here matches paragraphs 1–18.

Older available lecture transcripts were searched for Experiment 3 references; the October 5 and 7 recordings contain the substantive Experiment 3 objective statements. No later classroom lecture transcript was present in Transcripts/Lectures at review time.
