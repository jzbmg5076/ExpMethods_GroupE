%% Run All Four Analytical Plate Models
% Generates all console/text results and all dimensioned PNG figures.

clc;
close all;

model_dir = fileparts(mfilename('fullpath'));
if isempty(model_dir)
    model_dir = pwd;
end

model_files = { ...
    'plate01_notched_solid_model.m', ...
    'plate02_offset_rectangular_frame_model.m', ...
    'plate03_irregular_window_frame_model.m', ...
    'plate04_rectangular_plate_model.m'};

for model_index = 1:numel(model_files)
    fprintf('\n\nRunning %s\n',model_files{model_index});
    run(fullfile(model_dir,model_files{model_index}));
end

fprintf('\nRunning NX comparison (both model sets normalized to 1 kg)\n');
run(fullfile(model_dir,'compare_with_nx_models.m'));

fprintf('\nAll four analytical plate models and the NX comparison completed.\n');
fprintf('Outputs are in: %s\n',fullfile(model_dir,'output'));
