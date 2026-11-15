EXP4 Thermodynamics (Stirling engine) - Group E (Nick, John Stafford, Jesus Acosta)
Set up 2026-10-27 by Claude from Canvas/EXP4 (README, FAQ, realStirlingEngine.m) + lectures 10/19 and 10/21.

EXP4_Lab_Guide_GroupE.pdf      Visual game plan (14 pages): plain-version summary, cross-check flags,
                               big picture, how the engine works, the model and its inputs, what to measure
                               (dimension map), setup and wiring, tach/scope settings, heating setups,
                               running a point, expected data shapes, run of show and roles, advice,
                               unknowns, fundamentals, pre-lab checklist.
EXP4_TestPlan_and_RunLog.xlsx  Team tracker: Test Plan, Run Matrix, Engine Geometry (script inputs, sanity
                               checks, copy-ready MATLAB lines), Heater & Power, Ambient (P0), Run Log (one row
                               per steady point), Steady-State Check, Charts (live), Model Runs, Scope & Tach,
                               Equipment, Photos, Issues & Notes. Yellow = fill in; gray = formulas.
Figures/                       All guide figures as PNGs (prep visuals, not data; 03, 04, 09, 10 are illustrative).
LabDay1/  LabDay2/             Raw data and notes from each session.
Scope/                         Tach traces saved from the scope (CSV), named like D1_A03_tach.csv.
Photos/                        Setups, thermocouple spots, tach mount, disassembled engine with a scale.
Model/                         Working copy of realStirlingEngine.m + plots. The original stays in Canvas/EXP4.

Heads-up: the posted script geometry is a placeholder and physically impossible (negative regenerator volume).
Use your measured values, R = 287 (air), TH/TC in kelvin, and P0 = room pressure from the Ambient sheet.
