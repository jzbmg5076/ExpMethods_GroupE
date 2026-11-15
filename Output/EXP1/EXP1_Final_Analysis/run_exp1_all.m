function run_exp1_all()
%RUN_EXP1_ALL  Runs the complete EXP1 analysis and regenerates every report item.
%   Step 1: combined_plate_pendulum_analysis.m
%           plate geometry and analytical mass properties, assembly
%           combination, commercial-sensor frequencies, pendulum inertias
%           -> combined_output/
%   Step 2: plate_moi_comparison_analysis.m
%           NX comparison (NX scaled to the weighed masses) and bar charts
%           -> combined_output/moi_comparison/
%   Step 3: exp1_report_outputs.m
%           Arduino frequencies, paired bifilar result, uncertainties,
%           sensitivity, density check, principal-axis angles, report
%           tables, sample calculations, and report figures
%           -> report_outputs/
%
%   Usage: open this folder in MATLAB and type  run_exp1_all
%   (Each step starts with "clear", so the steps are called one by one
%   and the folder is looked up again each time.)

fprintf('\n===== STEP 1 of 3: combined_plate_pendulum_analysis =====\n');
run(fullfile(fileparts(mfilename('fullpath')),'combined_plate_pendulum_analysis.m'));
fprintf('\n===== STEP 2 of 3: plate_moi_comparison_analysis =====\n');
run(fullfile(fileparts(mfilename('fullpath')),'plate_moi_comparison_analysis.m'));
fprintf('\n===== STEP 3 of 3: exp1_report_outputs =====\n');
run(fullfile(fileparts(mfilename('fullpath')),'exp1_report_outputs.m'));
fprintf('\nAll EXP1 steps finished. Report items are in report_outputs.\n');
end
