# Experimental Methods (Fall 2026) — Group E working folder

Context file for AI assistants (Claude, Codex/ChatGPT, etc.) opening this folder. Read this
first, then `MEMORY.md` (running session log, newest first) and the write-ups in `Notes/`.

## The course
Senior mechanical engineering lab course at UC. 5 experiments, each with: pre-lab quiz →
two lab sessions → post-lab quiz → group report + individual report. Report formats rotate
(summary report, recorded video presentation, in-person presentation, formal/abbreviated) —
see `Canvas/Lab Report Guidelines (2026FS).pdf`.

Group E: John Stafford, Jesus Acosta, and a third member.

| Exp | Topic | Status |
|---|---|---|
| EXP1 | Moments of inertia (compound + bifilar pendulums, Arduino MPU-6050 + IEPE/X-Modal, analytical + NX) | Done — summary report submitted |
| EXP2 | Heat transfer in thin rods (Arduino thermistors, fin equation, NX thermal) | Done — recorded video report |
| EXP3 | Structural dynamics / modal testing of 3 plates (hammer + accel/mic, X-Modal, Blevins, NX modal) | Done — in-person presentation |
| EXP4 | Thermodynamics — beta-type Stirling engine (`realStirlingEngine.m` model, tach + scope, buck-converter heater power) | Both lab days done (10/27, 11/10); analysis + report next |
| EXP5 | not started | — |

Where EXP4 stands: `Notes/EXP4/exp4-day2-lab-notes-2026-11-10.md` and
`Notes/EXP4/exp4-day1-status-2026-11-07.md`. Model input issues to fix:
`Notes/EXP4/exp4-model-inputs-review.md`.

## How to help
- Ground every answer in the actual sources here (lecture transcripts, Canvas files, lab data,
  photos) and say which file/timestamp a fact came from. Lecture auto-transcripts garble
  numbers — prefer Canvas docs and slide photos when they conflict.
- Proactively cross-check: flag inconsistencies between data, notes, models and lecture.
- Explain concepts in plain student language and show the worked steps, with the final
  answer clearly labeled.
- Check each Canvas assignment and the professor's instructions for what assistance is
  allowed on graded work.

## Conventions (established — don't re-derive)
- **Lab coordinate frame (EXP1):** X = into the table (plate face normal), Y = along the
  table, Z = vertical. MOIs are named by the **axis of rotation**, not the push direction.
- **Units:** the DMMs were switched between °F and °C during labs — check each reading's unit.
  Thermodynamic temperatures in kelvin.
- **Steady state:** last ~3 min with every channel changing < 0.1 °C/min (EXP2/EXP4).
- **Heater power:** P = V·I from the buck-converter display (EXP4 Day 2), or P = V²/R with R
  metered with the heater disconnected. Use the voltage actually across the heater, not 12 V.
- **Tach (EXP4):** 6 spokes → RPM = 10 × pulse frequency; average over whole revolutions.
- Report charts should come from MATLAB scripts in the folder (the group's rule for EXP3).

## Folder structure
Organized by content type; each holds `EXP1/`, `EXP2/`, ... subfolders.
- **Transcripts/** — `Lectures/MM-DD-YYYY_Lecture.docx` (professor) and
  `InLab/MM-DD-YYYY_Lab.docx` (group's in-lab recordings). Auto-transcribed; speaker labels are
  auto-assigned.
- **Class Notes/** — written notes paired by date with the lecture transcripts;
  `ClassPhotos/MM-DD-YYYY_Lecture_Photos/` holds projector/board photos.
- **Canvas/** — everything the instructor posted: FAQs, READMEs, example code, guidelines.
- **Lab Data/** — raw captured data per experiment (`Lab Data/EXP4/LabDay1`, `LabDay2`,
  `Photos`, `Model`, `Scope`...), plus each experiment's lab guide, test-plan workbook, NX
  models and report files.
- **Output/** — analysis per experiment: MATLAB/Python pipelines, reviews, figures, report
  drafts. Put new analysis deliverables in `Output/EXP<N>/`.
- **Notes/** — per-experiment write-ups (data reviews, model notes, status checks). Detail
  behind the entries in `MEMORY.md`.

Not included in this copy: NX solver outputs (.op2/.dat/.f04/.f06/.log — re-solve the .sim
files in NX), scratch `Sandbox/`, and `OLD/`/archive/backup folders.

## Paths
Scripts that need the folder root take it as an argument or find it from their own location.
Hard-coded paths were replaced with `C:\path\to\ExpMethods_GroupE` — change that to wherever
you cloned this repo (NX journal scripts in `Lab Data/EXP3/NX/_journals/` and a few README
command examples).

## Session log
After any session that changes something here, add an entry at the top of `MEMORY.md`.
