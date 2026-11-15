%% Combined Plate Geometry, Mass Properties, Assembly, and Pendulum Analysis
% Self-contained analysis for the four EXP1 plates, the Plate 1 + Plate 4
% rigid assembly, and the selected
% experimental data sets. No project helper functions are required; all
% geometry, mass-property, plotting, data-import, spectral, and pendulum
% functions are local functions at the end of this file.
%
% Coordinate convention for every plate:
%   x = horizontal in the plate drawing
%   y = vertical in the plate drawing
%   z = through the plate thickness
%
% IMPORTANT SETUP DISTANCES
%   Compound pendulum: the equation requires d, the distance from the
%   pivot axis to the plate CG. If pivot_to_cg_in is NaN, this script uses
%   d = chain_length_in + attachment_to_cg_in. That sum is valid only when
%   the chain and attachment-to-CG distance are collinear.
%
%   Bifilar pendulum: chain_length_in is the vertical cable length L and
%   suspension_radius_in is r, the perpendicular distance from the tested
%   rotation axis to either cable line (half the cable spacing for a
%   symmetric setup).

clear;
clc;
close all;

%% Paths and output controls
script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
    script_dir = pwd;
end
em_root = fileparts(fileparts(fileparts(script_dir))); % ExperimentalMethods root (folder is now 3 levels down: Output/EXP1/<this folder>)
data_dir = fullfile(em_root,'Lab Data','EXP1','LabDay2'); % raw data moved here in the Sep 2026 folder reorg
output_dir = fullfile(script_dir,'combined_output');
if ~exist(output_dir,'dir')
    mkdir(output_dir);
end

save_figures = true;
show_figures = true;
gravity_m_s2 = 9.80665;
kg_m2_to_lbm_in2 = 2.2046226218487757*(100/2.54)^2;

%% Plate inputs - edit thicknesses here when better measurements are known
% Shape, in-plane dimensions, and finished masses are treated as known.
plate_mass_kg = [1.15897386, 4.5350165, 9.052279652, 1.687];
plate_thickness_in = [0.773, .515, .38, 0.50];

% This function stores all four plate outlines, openings, holes, dimensions,
% weights, and thicknesses in one struct array.
plates = build_plate_definitions(plate_mass_kg,plate_thickness_in);

%% Plate 1 + Plate 4 rigid-assembly pose inputs
% The attached NX view shows the notched HDPE plate (Plate 1) rotated over
% the rectangular plate (Plate 4). Plate 4 defines the global coordinate
% frame. Each origin is the [x y z] location of that part's local (0,0,0)
% point in the assembly frame. Positive rotation follows the right-hand
% rule about global +z.
%
% The default moving pose is reconstructed from the supplied NX assembly
% callout and image. Replace it with measured bolt-hole-derived coordinates
% if those become available. The z origin of 0.500 in places Plate 1 on top
% of the 0.500-in rectangular plate.
assembly_setup.name = 'Assembly 5 - Notched HDPE + rectangular plate';
assembly_setup.base_plate_index = 4;
assembly_setup.base_origin_in = [0.0,0.0,0.0];
assembly_setup.base_rotation_deg = 0.0;
assembly_setup.moving_plate_index = 1;
assembly_setup.moving_origin_in = [14.82877,5.00852,0.50000];
assembly_setup.moving_rotation_deg = 162.712;
assembly_setup.nx_reference_cg_in = [5.9335,3.0318,0.5095];
assembly_setup.nx_reference_principal_moi_lbm_in2 = ...
    [24.6165,105.8564,128.8375];

%% Experimental setup inputs
% Replace NaN with measured dimensions. Inputs here are in inches because
% that is how the laboratory setup was discussed; calculations use SI.
%
% The default tested-axis assignments follow the run names and observed
% setup: YData -> plate y axis, IntoTable -> plate x axis, Bifolar -> z.
% Change tested_axis if your setup photograph establishes another axis.

experiments = repmat(empty_experiment(),3,1);

% Aluminum offset rectangular frame: YData1-YData3
experiments(1).label = 'Aluminum frame - YData1 to YData3';
experiments(1).plate_index = 2;
experiments(1).file_stems = {'YData1','YData2','YData3'};
experiments(1).pendulum_type = 'compound';  % 'compound' or 'bifilar'
experiments(1).tested_axis = 'y';           % 'x', 'y', or 'z'
experiments(1).signal_channel = 1;          % UFF time-record channel
experiments(1).frequency_band_hz = [0.35,1.05];
experiments(1).chain_length_in = 9.25;       % 
experiments(1).attachment_to_cg_in = 7.5;  % USER INPUT
experiments(1).pivot_to_cg_in = NaN;        % optional direct d override
experiments(1).suspension_radius_in = NaN;  % unused for compound

% Notched HDPE plate: IntoTable1-IntoTable4
experiments(2).label = 'Notched HDPE plate - IntoTable1 to IntoTable4';
experiments(2).plate_index = 1;
experiments(2).file_stems = { ...
    'IntoTable1','IntoTable2','IntoTable3','IntoTable4'};
experiments(2).pendulum_type = 'compound';  % 'compound' or 'bifilar'
experiments(2).tested_axis = 'x';           % 'x', 'y', or 'z'
experiments(2).signal_channel = 1;
experiments(2).frequency_band_hz = [0.70,1.50];
experiments(2).chain_length_in = 4.25;       % USER INPUT
experiments(2).attachment_to_cg_in = 2.944;  % USER INPUT
experiments(2).pivot_to_cg_in = NaN;        % optional direct d override
experiments(2).suspension_radius_in = NaN;  % unused for compound

% Rectangular plate: Bifolar1-Bifolar3 (original filename spelling)
experiments(3).label = 'Rectangular plate - Bifolar1 to Bifolar3';
experiments(3).plate_index = 4;
experiments(3).file_stems = {'Bifolar1','Bifolar2','Bifolar3'};
experiments(3).pendulum_type = 'bifilar';   % 'compound' or 'bifilar'
experiments(3).tested_axis = 'z';           % 'x', 'y', or 'z'
experiments(3).signal_channel = 1;
% The approximately 3.5 Hz spectral line is the second harmonic. Restricting
% this band to the physical fundamental recovers approximately 1.74 Hz.
experiments(3).frequency_band_hz = [1.10,2.30];
experiments(3).chain_length_in = 8.5;       % USER INPUT: vertical L
experiments(3).attachment_to_cg_in = 2.95;  % unused for bifilar
experiments(3).pivot_to_cg_in = NaN;        % unused for bifilar
experiments(3).suspension_radius_in = 6.2;  % USER INPUT: r = half spacing

% The rigid assembly is available to this same pendulum pipeline as
% plate_index = 5. Add a fourth experiment block only after identifying the
% tested axis, pendulum type, chain length, and pivot-to-CG or bifilar radius
% for the BackupCombined data. Those setup quantities cannot be inferred
% reliably from the filenames alone.

%% Calculate all plate mass properties
for plate_index = 1:numel(plates)
    plates(plate_index).properties = calculate_extruded_plate( ...
        plates(plate_index).solid_polygons_cm, ...
        plates(plate_index).void_polygons_cm, ...
        plates(plate_index).circular_voids_cm, ...
        plates(plate_index).thickness_in*2.54, ...
        plates(plate_index).mass_kg);
end

% Combine the two finished bodies. This rotates each complete centroidal
% tensor into the assembly frame, finds the mass-weighted assembly CG, then
% applies the full three-dimensional parallel-axis theorem before summing.
assembly = combine_rigid_plate_assembly(plates,assembly_setup, ...
    kg_m2_to_lbm_in2);
bodies = [plates;assembly.body];

plate_table = build_plate_table(plates);
body_table = build_plate_table(bodies);
disp(' ');
disp('PLATE MASS PROPERTIES');
disp(plate_table);
writetable(plate_table, ...
    fullfile(output_dir,'plate_mass_properties_lbm_in2.csv'));

disp(' ');
disp('PLATES PLUS RIGID ASSEMBLY MASS PROPERTIES');
disp(body_table);
writetable(body_table,fullfile(output_dir, ...
    'plate_and_assembly_mass_properties_lbm_in2.csv'));

assembly_table = build_assembly_results_table(assembly,assembly_setup);
disp(' ');
disp('RIGID ASSEMBLY TENSOR, PRINCIPAL MOMENTS, AND NX COMPARISON');
disp(assembly_table);
writetable(assembly_table,fullfile(output_dir, ...
    'combined_plate_assembly_results_lbm_in2.csv'));

for plate_index = 1:numel(plates)
    print_inertia_tensor(plates(plate_index));
end

%% Draw all plate geometries, dimensions, holes, and CG locations
geometry_figure = draw_all_plate_geometry(plates,show_figures);
if save_figures
    exportgraphics(geometry_figure, ...
        fullfile(output_dir,'combined_plate_geometry_lbm_in2.png'), ...
        'Resolution',300);
end

assembly_figure = draw_plate_assembly(plates,assembly,assembly_setup, ...
    show_figures);
if save_figures
    exportgraphics(assembly_figure,fullfile(output_dir, ...
        'combined_plate_assembly_geometry_lbm_in2.png'),'Resolution',300);
end

%% Parse the selected experimental records and extract frequency/period
run_rows = struct([]);
plot_cache = cell(numel(experiments),1);
run_count = 0;

for experiment_index = 1:numel(experiments)
    experiment = experiments(experiment_index);
    validate_experiment_configuration(experiment,numel(bodies));
    plot_cache{experiment_index} = cell(numel(experiment.file_stems),1);

    for file_index = 1:numel(experiment.file_stems)
        stem = experiment.file_stems{file_index};
        data_file = locate_experiment_file(data_dir,stem);
        [time_s,channels,sample_rate_hz] = load_uff_time_records(data_file);

        if experiment.signal_channel > size(channels,2)
            error(['%s contains %d usable time channels, but channel %d ' ...
                'was requested.'],data_file,size(channels,2), ...
                experiment.signal_channel);
        end

        signal = channels(:,experiment.signal_channel);
        spectral = estimate_fundamental_frequency(time_s,signal, ...
            experiment.frequency_band_hz);

        run_count = run_count + 1;
        run_rows(run_count).Experiment = string(experiment.label);
        run_rows(run_count).Plate = string(bodies(experiment.plate_index).name);
        run_rows(run_count).Dataset = string(stem);
        run_rows(run_count).DataFile = string(data_file);
        run_rows(run_count).PendulumType = string(experiment.pendulum_type);
        run_rows(run_count).TestedAxis = string(experiment.tested_axis);
        run_rows(run_count).SignalChannel = experiment.signal_channel;
        run_rows(run_count).SampleRate_Hz = sample_rate_hz;
        run_rows(run_count).Frequency_Hz = spectral.frequency_hz;
        run_rows(run_count).Period_s = 1/spectral.frequency_hz;
        run_rows(run_count).PeakToMedian_dB = spectral.peak_to_median_db;

        plot_cache{experiment_index}{file_index} = struct( ...
            'stem',stem,'time_s',time_s,'signal',signal, ...
            'frequency_hz',spectral.frequency_hz, ...
            'spectrum_frequency_hz',spectral.plot_frequency_hz, ...
            'spectrum_power',spectral.plot_power);
    end
end

run_table = struct2table(run_rows);
disp(' ');
disp('INDIVIDUAL EXPERIMENTAL RUNS');
disp(run_table(:,{'Dataset','Plate','PendulumType','TestedAxis', ...
    'Frequency_Hz','Period_s','PeakToMedian_dB'}));
writetable(run_table,fullfile(output_dir,'experimental_run_results.csv'));

%% Average replicates and evaluate the pendulum equations
summary_rows = repmat(empty_summary_row(),numel(experiments),1);
for experiment_index = 1:numel(experiments)
    experiment = experiments(experiment_index);
    member = run_table.Experiment == string(experiment.label);
    frequencies_hz = run_table.Frequency_Hz(member);
    periods_s = run_table.Period_s(member);
    plate = bodies(experiment.plate_index);
    axis_index = axis_number(experiment.tested_axis);
    analytical_inertia_kg_m2 = ...
        plate.properties.I_tensor_prism_kg_cm2(axis_index,axis_index)*1e-4;

    physics = evaluate_pendulum(experiment,plate.mass_kg, ...
        analytical_inertia_kg_m2,mean(frequencies_hz),gravity_m_s2);

    summary_rows(experiment_index).Experiment = string(experiment.label);
    summary_rows(experiment_index).Plate = string(plate.name);
    summary_rows(experiment_index).PendulumType = ...
        string(experiment.pendulum_type);
    summary_rows(experiment_index).TestedAxis = ...
        string(experiment.tested_axis);
    summary_rows(experiment_index).RunCount = numel(frequencies_hz);
    summary_rows(experiment_index).MeanFrequency_Hz = mean(frequencies_hz);
    summary_rows(experiment_index).StdFrequency_Hz = std(frequencies_hz);
    summary_rows(experiment_index).MeanPeriod_s = mean(periods_s);
    summary_rows(experiment_index).StdPeriod_s = std(periods_s);
    summary_rows(experiment_index).AnalyticalInertia_lbm_in2 = ...
        analytical_inertia_kg_m2*kg_m2_to_lbm_in2;
    summary_rows(experiment_index).ChainLength_in = ...
        experiment.chain_length_in;
    summary_rows(experiment_index).PivotToCG_in = physics.pivot_to_cg_in;
    summary_rows(experiment_index).SuspensionRadius_in = ...
        experiment.suspension_radius_in;
    summary_rows(experiment_index).PredictedFrequency_Hz = ...
        physics.predicted_frequency_hz;
    summary_rows(experiment_index).PredictedPeriod_s = ...
        physics.predicted_period_s;
    summary_rows(experiment_index).ExperimentalInertia_lbm_in2 = ...
        physics.experimental_inertia_kg_m2*kg_m2_to_lbm_in2;
    summary_rows(experiment_index).InertiaDifference_percent = ...
        physics.inertia_difference_percent;
    summary_rows(experiment_index).SetupStatus = string(physics.status);
end

summary_table = struct2table(summary_rows);
disp(' ');
disp('EXPERIMENT SUMMARY AND PENDULUM RESULTS');
disp(summary_table);
writetable(summary_table, ...
    fullfile(output_dir,'pendulum_summary_results_lbm_in2.csv'));

%% Draw measured time records and spectra
signal_figure = draw_experimental_results(experiments,plot_cache,show_figures);
if save_figures
    exportgraphics(signal_figure, ...
        fullfile(output_dir,'experimental_frequency_analysis_lbm_in2.png'), ...
        'Resolution',300);
end

%% Save the complete MATLAB result set
results_file = fullfile(output_dir,'combined_plate_pendulum_results.mat');
save(results_file,'plates','assembly','assembly_setup','bodies', ...
    'experiments','plate_table','body_table','assembly_table','run_table', ...
    'summary_table','gravity_m_s2','kg_m2_to_lbm_in2');

fprintf('\nCombined analysis complete.\n');
fprintf('Results folder: %s\n',output_dir);
fprintf('MATLAB results: %s\n',results_file);
if any(ismissing(summary_table.SetupStatus) | ...
        contains(summary_table.SetupStatus,'REQUIRED'))
    fprintf(['NOTE: Experimental frequencies and periods were calculated. ' ...
        'Rows marked SETUP INPUT REQUIRED need the NaN setup distances ' ...
        'replaced near the top of this script.\n']);
end

%% Local functions

function experiment = empty_experiment()
experiment = struct( ...
    'label','', ...
    'plate_index',NaN, ...
    'file_stems',{{}}, ...
    'pendulum_type','', ...
    'tested_axis','', ...
    'signal_channel',1, ...
    'frequency_band_hz',[NaN,NaN], ...
    'chain_length_in',NaN, ...
    'attachment_to_cg_in',NaN, ...
    'pivot_to_cg_in',NaN, ...
    'suspension_radius_in',NaN);
end

function row = empty_summary_row()
row = struct( ...
    'Experiment',"",'Plate',"",'PendulumType',"",'TestedAxis',"", ...
    'RunCount',NaN,'MeanFrequency_Hz',NaN,'StdFrequency_Hz',NaN, ...
    'MeanPeriod_s',NaN,'StdPeriod_s',NaN, ...
    'AnalyticalInertia_lbm_in2',NaN,'ChainLength_in',NaN, ...
    'PivotToCG_in',NaN,'SuspensionRadius_in',NaN, ...
    'PredictedFrequency_Hz',NaN,'PredictedPeriod_s',NaN, ...
    'ExperimentalInertia_lbm_in2',NaN, ...
    'InertiaDifference_percent',NaN,'SetupStatus',"");
end

function plates = build_plate_definitions(masses_kg,thicknesses_in)
validateattributes(masses_kg,{'numeric'},{'vector','numel',4,'positive'});
validateattributes(thicknesses_in,{'numeric'}, ...
    {'vector','numel',4,'positive'});
cm_per_in = 2.54;

template = struct('id',NaN,'key','','name','','material','', ...
    'mass_kg',NaN,'thickness_in',NaN,'thickness_note','', ...
    'solid_polygons_cm',{{}},'void_polygons_cm',{{}}, ...
    'circular_voids_cm',zeros(0,3),'dimensions',struct(), ...
    'geometry_note','','properties',struct());
plates = repmat(template,4,1);

% Plate 1 - notched HDPE solid plate
width_cm = 40.2;
height_cm = 19.9;
left_material_height_cm = 13.3;
left_lower_run_cm = 17.5;
step_height_cm = 3.6;
right_lower_run_cm = 12.3;
y_left_bottom_cm = height_cm-left_material_height_cm;
x_step_cm = width_cm-right_lower_run_cm;
outer_cm = [0,y_left_bottom_cm; left_lower_run_cm,y_left_bottom_cm; ...
    x_step_cm,step_height_cm; x_step_cm,0; width_cm,0; ...
    width_cm,height_cm; 0,height_cm];
hole_diameter_in = 0.184;
edge_offset_in = 0.250;
holes_in = notched_perimeter_holes(width_cm/cm_per_in, ...
    height_cm/cm_per_in,left_lower_run_cm/cm_per_in, ...
    y_left_bottom_cm/cm_per_in,x_step_cm/cm_per_in, ...
    step_height_cm/cm_per_in,edge_offset_in,hole_diameter_in/2);
plates(1).id = 1;
plates(1).key = 'plate01_notched_solid';
plates(1).name = 'Plate 1 - Notched HDPE solid plate';
plates(1).material = 'HDPE';
plates(1).mass_kg = masses_kg(1);
plates(1).thickness_in = thicknesses_in(1);
plates(1).thickness_note = 'Editable measured/assumed thickness input';
plates(1).solid_polygons_cm = {outer_cm};
plates(1).void_polygons_cm = {};
plates(1).circular_voids_cm = holes_in*cm_per_in;
plates(1).dimensions = struct('overall_width_cm',width_cm, ...
    'overall_height_cm',height_cm, ...
    'left_material_height_cm',left_material_height_cm, ...
    'left_lower_run_cm',left_lower_run_cm, ...
    'step_height_cm',step_height_cm, ...
    'right_lower_run_cm',right_lower_run_cm, ...
    'hole_diameter_in',hole_diameter_in, ...
    'hole_edge_offset_in',edge_offset_in);
plates(1).geometry_note = ['Lower curved/sloping transition is represented ' ...
    'by the straight chord between its measured endpoints.'];

% Plate 2 - aluminum offset rectangular frame
outer_width_cm = 60.7;
outer_height_cm = 30.5;
left_margin_cm = 17.4;
right_margin_cm = 7.7;
top_margin_cm = 5.0;
bottom_margin_cm = 10.1;
opening_width_cm = outer_width_cm-left_margin_cm-right_margin_cm;
opening_height_cm = outer_height_cm-top_margin_cm-bottom_margin_cm;
outer_cm = [0,0; outer_width_cm,0; outer_width_cm,outer_height_cm; ...
    0,outer_height_cm];
opening_cm = [left_margin_cm,bottom_margin_cm; ...
    left_margin_cm+opening_width_cm,bottom_margin_cm; ...
    left_margin_cm+opening_width_cm,bottom_margin_cm+opening_height_cm; ...
    left_margin_cm,bottom_margin_cm+opening_height_cm];
hole_diameter_in = 0.184;
edge_offset_in = 0.250;
holes_in = rectangular_perimeter_holes(outer_width_cm/cm_per_in, ...
    outer_height_cm/cm_per_in,5,5,edge_offset_in,hole_diameter_in/2);
plates(2).id = 2;
plates(2).key = 'plate02_offset_rectangular_frame';
plates(2).name = 'Plate 2 - Aluminum offset rectangular frame';
plates(2).material = 'Aluminum';
plates(2).mass_kg = masses_kg(2);
plates(2).thickness_in = thicknesses_in(2);
plates(2).thickness_note = 'Editable measured/assumed thickness input';
plates(2).solid_polygons_cm = {outer_cm};
plates(2).void_polygons_cm = {opening_cm};
plates(2).circular_voids_cm = holes_in*cm_per_in;
plates(2).dimensions = struct('overall_width_cm',outer_width_cm, ...
    'overall_height_cm',outer_height_cm, ...
    'left_margin_cm',left_margin_cm,'right_margin_cm',right_margin_cm, ...
    'top_margin_cm',top_margin_cm,'bottom_margin_cm',bottom_margin_cm, ...
    'opening_width_cm',opening_width_cm, ...
    'opening_height_cm',opening_height_cm, ...
    'hole_diameter_in',hole_diameter_in, ...
    'hole_edge_offset_in',edge_offset_in);
plates(2).geometry_note = 'Outer rectangle minus the measured offset opening.';

% Plate 3 - irregular polygon-window frame
outer_width_cm = 61.1;
outer_height_cm = 30.4;
outer_cm = [0,0; outer_width_cm,0; outer_width_cm,outer_height_cm; ...
    0,outer_height_cm];
opening_cm = [8.6,7.6; 20.9,4.4; 21.8,8.1; 32.3,8.1; ...
    52.1,2.7; 55.5,16.1; 13.7,27.2];
hole_diameter_in = 0.184;
edge_offset_in = 0.250;
holes_in = rectangular_perimeter_holes(outer_width_cm/cm_per_in, ...
    outer_height_cm/cm_per_in,5,5,edge_offset_in,hole_diameter_in/2);
plates(3).id = 3;
plates(3).key = 'plate03_irregular_window_frame';
plates(3).name = 'Plate 3 - Irregular polygon-window frame';
plates(3).material = 'Stainless steel';
plates(3).mass_kg = masses_kg(3);
plates(3).thickness_in = thicknesses_in(3);
plates(3).thickness_note = ['Thickness was not independently measured; ' ...
    '0.500 in is the current editable assumption.'];
plates(3).solid_polygons_cm = {outer_cm};
plates(3).void_polygons_cm = {opening_cm};
plates(3).circular_voids_cm = holes_in*cm_per_in;
plates(3).dimensions = struct('overall_width_cm',outer_width_cm, ...
    'overall_height_cm',outer_height_cm, ...
    'opening_vertices_cm',opening_cm, ...
    'hole_diameter_in',hole_diameter_in, ...
    'hole_edge_offset_in',edge_offset_in);
plates(3).geometry_note = ...
    'Outer rectangle minus the seven-vertex concave opening.';

% Plate 4 - rectangular plate
length_in = 12.900;
width_in = 5.900;
hole_diameter_in = 0.180;
edge_offset_in = 0.250;
outer_in = [0,0; length_in,0; length_in,width_in; 0,width_in];
holes_in = rectangular_perimeter_holes(length_in,width_in,5,3, ...
    edge_offset_in,hole_diameter_in/2);
plates(4).id = 4;
plates(4).key = 'plate04_rectangular_plate';
plates(4).name = 'Plate 4 - Rectangular plate';
plates(4).material = 'Stainless steel';
plates(4).mass_kg = masses_kg(4);
plates(4).thickness_in = thicknesses_in(4);
plates(4).thickness_note = 'Editable measured/assumed thickness input';
plates(4).solid_polygons_cm = {outer_in*cm_per_in};
plates(4).void_polygons_cm = {};
plates(4).circular_voids_cm = holes_in*cm_per_in;
plates(4).dimensions = struct('length_in',length_in,'width_in',width_in, ...
    'hole_diameter_in',hole_diameter_in, ...
    'hole_edge_offset_in',edge_offset_in);
plates(4).geometry_note = 'Rectangular plate with 12 perimeter holes.';
end

function holes = notched_perimeter_holes(width,height,left_lower_run, ...
    y_left_bottom,x_step,step_height,edge_offset,radius)
top_x = linspace(edge_offset,width-edge_offset,5).';
top = [top_x,repmat(height-edge_offset,5,1)];
right_y = linspace(edge_offset,height-edge_offset,5).';
right_without_top = [repmat(width-edge_offset,4,1),right_y(1:4)];
left_bottom_x = linspace(edge_offset,left_lower_run-edge_offset,3).';
left_bottom = [left_bottom_x,repmat(y_left_bottom+edge_offset,3,1)];
slope_start = [left_lower_run,y_left_bottom];
slope_end = [x_step,step_height];
slope_vector = slope_end-slope_start;
inward_normal = [-slope_vector(2),slope_vector(1)];
inward_normal = inward_normal/norm(inward_normal);
slope_center = slope_start+0.82*slope_vector+edge_offset*inward_normal;
step_center = [x_step+edge_offset,step_height/2];
bottom_center = [(x_step+width)/2,edge_offset];
left_center = [edge_offset,(y_left_bottom+height)/2];
centers = [top;right_without_top;left_bottom;slope_center; ...
    step_center;bottom_center;left_center];
holes = [centers,repmat(radius,size(centers,1),1)];
assert(size(holes,1)==16,'The notched plate must contain 16 holes.');
end

function holes = rectangular_perimeter_holes(width,height,nx,ny, ...
    edge_offset,radius)
validateattributes(width,{'numeric'},{'scalar','positive'});
validateattributes(height,{'numeric'},{'scalar','positive'});
if edge_offset <= radius || 2*edge_offset >= min(width,height)
    error('The requested rectangular hole offset is invalid.');
end
x = linspace(edge_offset,width-edge_offset,nx).';
y = linspace(edge_offset,height-edge_offset,ny).';
bottom = [x,repmat(edge_offset,nx,1)];
top = [x,repmat(height-edge_offset,nx,1)];
side_y = y(2:end-1);
left = [repmat(edge_offset,numel(side_y),1),side_y];
right = [repmat(width-edge_offset,numel(side_y),1),side_y];
holes = [[bottom;top;left;right], ...
    repmat(radius,2*nx+2*max(ny-2,0),1)];
end

function results = calculate_extruded_plate(solid_polygons,void_polygons, ...
    circular_voids_cm,thickness_cm,mass_kg)
validateattributes(thickness_cm,{'numeric'},{'scalar','finite','positive'});
validateattributes(mass_kg,{'numeric'},{'scalar','finite','positive'});
raw = zeros(1,6);
for k = 1:numel(solid_polygons)
    raw = raw+polygon_raw_moments(solid_polygons{k});
end
for k = 1:numel(void_polygons)
    raw = raw-polygon_raw_moments(void_polygons{k});
end
for k = 1:size(circular_voids_cm,1)
    xc = circular_voids_cm(k,1);
    yc = circular_voids_cm(k,2);
    radius = circular_voids_cm(k,3);
    area = pi*radius^2;
    centroidal_area_inertia = pi*radius^4/4;
    raw = raw-[area,area*xc,area*yc, ...
        centroidal_area_inertia+area*yc^2, ...
        centroidal_area_inertia+area*xc^2,area*xc*yc];
end
area_cm2 = raw(1);
if area_cm2 <= 0
    error('The signed plate geometry does not leave positive material area.');
end
x_cg_cm = raw(2)/area_cm2;
y_cg_cm = raw(3)/area_cm2;
Ixx_area_cm4 = raw(4)-area_cm2*y_cg_cm^2;
Iyy_area_cm4 = raw(5)-area_cm2*x_cg_cm^2;
Ixy_area_cm4 = raw(6)-area_cm2*x_cg_cm*y_cg_cm;
areal_density = mass_kg/area_cm2;
J_thin = [areal_density*Ixx_area_cm4,-areal_density*Ixy_area_cm4,0; ...
    -areal_density*Ixy_area_cm4,areal_density*Iyy_area_cm4,0; ...
    0,0,areal_density*(Ixx_area_cm4+Iyy_area_cm4)];
J_prism = J_thin;
J_prism(1,1) = J_prism(1,1)+mass_kg*thickness_cm^2/12;
J_prism(2,2) = J_prism(2,2)+mass_kg*thickness_cm^2/12;
J_prism = (J_prism+J_prism.')/2;
[V,D] = eig(J_prism);
[principal,order] = sort(diag(D),'ascend');
V = V(:,order);
for k = 1:3
    [~,idx] = max(abs(V(:,k)));
    if V(idx,k)<0
        V(:,k) = -V(:,k);
    end
end
if det(V)<0
    V(:,1) = -V(:,1);
end
results.mass_kg = mass_kg;
results.weight_N = mass_kg*9.80665;
results.thickness_cm = thickness_cm;
results.thickness_in = thickness_cm/2.54;
results.area_cm2 = area_cm2;
results.volume_cm3 = area_cm2*thickness_cm;
results.effective_density_kg_cm3 = mass_kg/results.volume_cm3;
results.CG_cm = [x_cg_cm,y_cg_cm,thickness_cm/2];
results.CG_in = results.CG_cm/2.54;
results.I_tensor_thin_kg_cm2 = J_thin;
results.I_tensor_prism_kg_cm2 = J_prism;
results.I_tensor_prism_kg_m2 = J_prism*1e-4;
results.I_tensor_prism_lbm_in2 = ...
    results.I_tensor_prism_kg_m2*2.2046226218487757*(100/2.54)^2;
results.principal_inertia_kg_cm2 = principal;
results.principal_axes_rows = V.';
results.perpendicular_axis_error_kg_cm2 = abs( ...
    J_thin(3,3)-J_thin(1,1)-J_thin(2,2));
results.tensor_symmetry_error = norm(J_prism-J_prism.','fro');
end

function raw = polygon_raw_moments(vertices)
if size(vertices,1)>=2 && all(vertices(1,:)==vertices(end,:))
    vertices(end,:) = [];
end
if size(vertices,1)<3
    error('Every polygon must have at least three vertices.');
end
x = vertices(:,1);
y = vertices(:,2);
xn = x([2:end,1]);
yn = y([2:end,1]);
cross_term = x.*yn-xn.*y;
area = 0.5*sum(cross_term);
Qx = sum((x+xn).*cross_term)/6;
Qy = sum((y+yn).*cross_term)/6;
Ixx = sum((y.^2+y.*yn+yn.^2).*cross_term)/12;
Iyy = sum((x.^2+x.*xn+xn.^2).*cross_term)/12;
Ixy = sum((2*x.*y+x.*yn+xn.*y+2*xn.*yn).*cross_term)/24;
if area<0
    area = -area;
    Qx = -Qx;
    Qy = -Qy;
    Ixx = -Ixx;
    Iyy = -Iyy;
    Ixy = -Ixy;
end
raw = [area,Qx,Qy,Ixx,Iyy,Ixy];
end

function assembly = combine_rigid_plate_assembly(plates,setup, ...
    kg_m2_to_lbm_in2)
%COMBINE_RIGID_PLATE_ASSEMBLY Combine two rigid bodies in a common frame.
% The operation follows the instructor's AddInertiaTensor.m workflow:
% rotate each centroidal tensor, find the mass-weighted assembly CG, shift
% each tensor with the 3-D parallel-axis theorem, sum, and diagonalize.

indices = [setup.base_plate_index,setup.moving_plate_index];
if any(indices<1) || any(indices>numel(plates)) || indices(1)==indices(2)
    error('Assembly plate indices must identify two different plates.');
end

origins_in = [setup.base_origin_in;setup.moving_origin_in];
angles_deg = [setup.base_rotation_deg;setup.moving_rotation_deg];
if ~isequal(size(origins_in),[2,3]) || any(~isfinite(origins_in),'all')
    error('Each assembly origin must be a finite [x y z] vector in inches.');
end

mass_lbm = zeros(2,1);
cg_global_in = zeros(2,3);
J_global_cg_lbm_in2 = zeros(3,3,2);
components = repmat(struct('plate_index',NaN,'name','', ...
    'origin_in',zeros(1,3),'rotation_deg',NaN, ...
    'R_local_to_global',eye(3),'mass_lbm',NaN, ...
    'cg_local_in',zeros(1,3),'cg_global_in',zeros(1,3), ...
    'J_global_cg_lbm_in2',zeros(3)),2,1);

for component_index = 1:2
    p = plates(indices(component_index));
    R = rotation_z_deg(angles_deg(component_index));
    mass_lbm(component_index) = p.mass_kg*2.2046226218487757;
    cg_local = p.properties.CG_in(:);
    cg_global = origins_in(component_index,:).' + R*cg_local;
    J_local = p.properties.I_tensor_prism_lbm_in2;
    J_global = R*J_local*R.';

    cg_global_in(component_index,:) = cg_global.';
    J_global_cg_lbm_in2(:,:,component_index) = (J_global+J_global.')/2;
    components(component_index).plate_index = indices(component_index);
    components(component_index).name = p.name;
    components(component_index).origin_in = origins_in(component_index,:);
    components(component_index).rotation_deg = angles_deg(component_index);
    components(component_index).R_local_to_global = R;
    components(component_index).mass_lbm = mass_lbm(component_index);
    components(component_index).cg_local_in = cg_local.';
    components(component_index).cg_global_in = cg_global.';
    components(component_index).J_global_cg_lbm_in2 = J_global;
end

total_mass_lbm = sum(mass_lbm);
assembly_cg_in = sum(mass_lbm.*cg_global_in,1)/total_mass_lbm;
J_assembly = zeros(3);
for component_index = 1:2
    d = (cg_global_in(component_index,:)-assembly_cg_in).';
    J_shift = mass_lbm(component_index)*(dot(d,d)*eye(3)-d*d.');
    J_assembly = J_assembly + ...
        J_global_cg_lbm_in2(:,:,component_index)+J_shift;
    components(component_index).offset_from_assembly_cg_in = d.';
    components(component_index).parallel_axis_term_lbm_in2 = J_shift;
end
J_assembly = (J_assembly+J_assembly.')/2;

[V,D] = eig(J_assembly);
[principal_moi,order] = sort(diag(D),'ascend');
V = V(:,order);
for axis_index = 1:3
    [~,largest_component] = max(abs(V(:,axis_index)));
    if V(largest_component,axis_index)<0
        V(:,axis_index) = -V(:,axis_index);
    end
end
if det(V)<0
    V(:,1) = -V(:,1);
end

% Store a fifth body record compatible with the pendulum-analysis loop.
body = plates(1);
body.id = 5;
body.key = 'assembly05_notched_hdpe_plus_rectangle';
body.name = setup.name;
body.material = 'HDPE + stainless steel';
body.mass_kg = total_mass_lbm/2.2046226218487757;
body.thickness_in = NaN;
body.thickness_note = ['Nonuniform two-layer assembly; see component ' ...
    'origins and rotations in assembly_setup.'];
body.solid_polygons_cm = {};
body.void_polygons_cm = {};
body.circular_voids_cm = zeros(0,3);
for component_index = 1:2
    p = plates(indices(component_index));
    origin_xy_cm = 2.54*origins_in(component_index,1:2);
    angle = angles_deg(component_index);
    for polygon_index = 1:numel(p.solid_polygons_cm)
        body.solid_polygons_cm{end+1} = transform_planar_points( ...
            p.solid_polygons_cm{polygon_index},angle,origin_xy_cm);
    end
    for polygon_index = 1:numel(p.void_polygons_cm)
        body.void_polygons_cm{end+1} = transform_planar_points( ...
            p.void_polygons_cm{polygon_index},angle,origin_xy_cm);
    end
    holes = p.circular_voids_cm;
    if ~isempty(holes)
        centers = transform_planar_points(holes(:,1:2),angle,origin_xy_cm);
        body.circular_voids_cm = [body.circular_voids_cm; ...
            centers,holes(:,3)];
    end
end
body.dimensions = setup;
body.geometry_note = ['Rigid assembly calculated from complete component ' ...
    'tensors using tensor rotation and the 3-D parallel-axis theorem.'];
body.properties = struct();
body.properties.mass_kg = body.mass_kg;
body.properties.weight_N = body.mass_kg*9.80665;
body.properties.weight_lbf_standard_g = body.mass_kg*2.2046226218487757;
body.properties.thickness_cm = NaN;
body.properties.thickness_in = NaN;
body.properties.area_cm2 = sum(arrayfun(@(p) p.properties.area_cm2, ...
    plates(indices)));
body.properties.volume_cm3 = sum(arrayfun(@(p) p.properties.volume_cm3, ...
    plates(indices)));
body.properties.effective_density_kg_cm3 = ...
    body.mass_kg/body.properties.volume_cm3;
body.properties.CG_in = assembly_cg_in;
body.properties.CG_cm = 2.54*assembly_cg_in;
body.properties.I_tensor_prism_lbm_in2 = J_assembly;
body.properties.I_tensor_prism_kg_m2 = J_assembly/kg_m2_to_lbm_in2;
body.properties.I_tensor_prism_kg_cm2 = ...
    body.properties.I_tensor_prism_kg_m2*1e4;
body.properties.principal_inertia_lbm_in2 = principal_moi;
body.properties.principal_inertia_kg_cm2 = ...
    principal_moi/kg_m2_to_lbm_in2*1e4;
body.properties.principal_axes_rows = V.';
body.properties.tensor_symmetry_error = norm(J_assembly-J_assembly.','fro');

assembly.body = body;
assembly.components = components;
assembly.mass_lbm = total_mass_lbm;
assembly.mass_kg = body.mass_kg;
assembly.CG_in = assembly_cg_in;
assembly.I_tensor_cg_lbm_in2 = J_assembly;
assembly.principal_moi_lbm_in2 = principal_moi.';
assembly.principal_axes_columns = V;
assembly.principal_axes_rows = V.';
assembly.checks.mass_error_lbm = abs(total_mass_lbm-sum(mass_lbm));
assembly.checks.first_moment_error_lbm_in = norm(sum( ...
    mass_lbm.*(cg_global_in-assembly_cg_in),1));
assembly.checks.tensor_symmetry_error = norm(J_assembly-J_assembly.','fro');
assembly.checks.positive_principal_moments = all(principal_moi>0);
assembly.checks.pass = assembly.checks.mass_error_lbm<1e-12 && ...
    assembly.checks.first_moment_error_lbm_in<1e-10 && ...
    assembly.checks.tensor_symmetry_error<1e-10 && ...
    assembly.checks.positive_principal_moments;
if ~assembly.checks.pass
    error('The rigid-assembly mass-property verification checks failed.');
end
end

function R = rotation_z_deg(angle_deg)
c = cosd(angle_deg);
s = sind(angle_deg);
R = [c,-s,0;s,c,0;0,0,1];
end

function transformed = transform_planar_points(points,angle_deg,origin_xy)
R2 = rotation_z_deg(angle_deg);
transformed = (R2(1:2,1:2)*points.').'+origin_xy;
end

function table_out = build_assembly_results_table(assembly,setup)
J = assembly.I_tensor_cg_lbm_in2;
P = assembly.principal_moi_lbm_in2;
A = assembly.principal_axes_rows;
nxP = setup.nx_reference_principal_moi_lbm_in2;
nxCG = setup.nx_reference_cg_in;
signed_principal_difference = 100*(P-nxP)./nxP;
symmetric_principal_difference = 200*abs(P-nxP)./(abs(P)+abs(nxP));

weight_N = assembly.mass_kg*9.80665;
weight_lbf = assembly.mass_kg*2.2046226218487757;
table_out = table(string(setup.name),assembly.mass_kg,assembly.mass_lbm, ...
    weight_N,weight_lbf, ...
    assembly.CG_in(1),assembly.CG_in(2),assembly.CG_in(3), ...
    J(1,1),J(2,2),J(3,3),J(1,2),J(1,3),J(2,3), ...
    P(1),P(2),P(3), ...
    A(1,1),A(1,2),A(1,3),A(2,1),A(2,2),A(2,3), ...
    A(3,1),A(3,2),A(3,3), ...
    nxCG(1),nxCG(2),nxCG(3),nxP(1),nxP(2),nxP(3), ...
    signed_principal_difference(1),signed_principal_difference(2), ...
    signed_principal_difference(3),symmetric_principal_difference(1), ...
    symmetric_principal_difference(2),symmetric_principal_difference(3), ...
    'VariableNames',{'Assembly','Mass_kg','Mass_lbm','Weight_N', ...
    'Weight_lbf','CG_X_in','CG_Y_in','CG_Z_in','Ixx_lbm_in2', ...
    'Iyy_lbm_in2','Izz_lbm_in2', ...
    'Ixy_lbm_in2','Ixz_lbm_in2','Iyz_lbm_in2','PrincipalI1_lbm_in2', ...
    'PrincipalI2_lbm_in2','PrincipalI3_lbm_in2','PrincipalAxis1_X', ...
    'PrincipalAxis1_Y','PrincipalAxis1_Z','PrincipalAxis2_X', ...
    'PrincipalAxis2_Y','PrincipalAxis2_Z','PrincipalAxis3_X', ...
    'PrincipalAxis3_Y','PrincipalAxis3_Z','NX_CG_X_in','NX_CG_Y_in', ...
    'NX_CG_Z_in','NX_PrincipalI1_lbm_in2','NX_PrincipalI2_lbm_in2', ...
    'NX_PrincipalI3_lbm_in2','SignedDifferenceI1_percent', ...
    'SignedDifferenceI2_percent','SignedDifferenceI3_percent', ...
    'SymmetricDifferenceI1_percent','SymmetricDifferenceI2_percent', ...
    'SymmetricDifferenceI3_percent'});
end

function table_out = build_plate_table(plates)
n = numel(plates);
Plate = strings(n,1);
Material = strings(n,1);
Mass_kg = zeros(n,1);
Thickness_in = zeros(n,1);
Area_cm2 = zeros(n,1);
CG_X_in = zeros(n,1);
CG_Y_in = zeros(n,1);
CG_Z_in = zeros(n,1);
Ixx_lbm_in2 = zeros(n,1);
Iyy_lbm_in2 = zeros(n,1);
Izz_lbm_in2 = zeros(n,1);
Ixy_lbm_in2 = zeros(n,1);
HoleCount = zeros(n,1);
for k = 1:n
    p = plates(k);
    Plate(k) = string(p.name);
    Material(k) = string(p.material);
    Mass_kg(k) = p.mass_kg;
    Thickness_in(k) = p.thickness_in;
    Area_cm2(k) = p.properties.area_cm2;
    CG_X_in(k) = p.properties.CG_in(1);
    CG_Y_in(k) = p.properties.CG_in(2);
    CG_Z_in(k) = p.properties.CG_in(3);
    J = p.properties.I_tensor_prism_lbm_in2;
    Ixx_lbm_in2(k) = J(1,1);
    Iyy_lbm_in2(k) = J(2,2);
    Izz_lbm_in2(k) = J(3,3);
    Ixy_lbm_in2(k) = J(1,2);
    HoleCount(k) = size(p.circular_voids_cm,1);
end
table_out = table(Plate,Material,Mass_kg,Thickness_in,Area_cm2, ...
    CG_X_in,CG_Y_in,CG_Z_in,Ixx_lbm_in2,Iyy_lbm_in2,Izz_lbm_in2, ...
    Ixy_lbm_in2,HoleCount);
end

function print_inertia_tensor(plate)
J = plate.properties.I_tensor_prism_lbm_in2;
fprintf('\n%s\n',plate.name);
fprintf('  mass = %.9f kg, thickness = %.4f in\n', ...
    plate.mass_kg,plate.thickness_in);
fprintf('  CG [x y z] = [%.6f %.6f %.6f] in\n', ...
    plate.properties.CG_in);
fprintf('  centroidal inertia tensor [lbm*in^2]:\n');
fprintf('    [% .9e % .9e % .9e]\n',J(1,:));
fprintf('    [% .9e % .9e % .9e]\n',J(2,:));
fprintf('    [% .9e % .9e % .9e]\n',J(3,:));
end

function fig = draw_all_plate_geometry(plates,show_figures)
visibility = 'off';
if show_figures
    visibility = 'on';
end
fig = figure('Color','white','Visible',visibility, ...
    'Position',[40,40,1600,1050]);
layout = tiledlayout(fig,2,2,'TileSpacing','compact','Padding','compact');
title(layout,'Four Plate Geometries, Dimensions, Holes, and Centers of Gravity', ...
    'FontSize',16,'FontWeight','bold');
for k = 1:numel(plates)
    ax = nexttile(layout,k);
    draw_one_plate(ax,plates(k));
end
end

function draw_one_plate(ax,plate)
hold(ax,'on');
cm_per_in = 2.54;
edge_color = [0.08,0.16,0.28];
material_color = [0.78,0.86,0.95];
all_vertices_in = zeros(0,2);
for k = 1:numel(plate.solid_polygons_cm)
    v = plate.solid_polygons_cm{k}/cm_per_in;
    all_vertices_in = [all_vertices_in;v]; %#ok<AGROW>
    patch(ax,v(:,1),v(:,2),material_color,'EdgeColor',edge_color, ...
        'LineWidth',1.8);
end
for k = 1:numel(plate.void_polygons_cm)
    v = plate.void_polygons_cm{k}/cm_per_in;
    patch(ax,v(:,1),v(:,2),'white','EdgeColor',edge_color, ...
        'LineWidth',1.8);
end
holes_in = plate.circular_voids_cm/cm_per_in;
for k = 1:size(holes_in,1)
    rectangle(ax,'Position',[holes_in(k,1)-holes_in(k,3), ...
        holes_in(k,2)-holes_in(k,3),2*holes_in(k,3),2*holes_in(k,3)], ...
        'Curvature',[1,1],'FaceColor','white','EdgeColor',edge_color, ...
        'LineWidth',0.9);
end
cg = plate.properties.CG_in(1:2);
plot(ax,cg(1),cg(2),'p','MarkerSize',12,'MarkerFaceColor',[0.82,0.12,0.16], ...
    'MarkerEdgeColor','white');
text(ax,cg(1)+0.2,cg(2)+0.2,sprintf('CG (%.3f, %.3f) in',cg), ...
    'Color',[0.65,0.05,0.08],'FontWeight','bold','FontSize',8, ...
    'BackgroundColor','white','Margin',1);

width_in = max(all_vertices_in(:,1))-min(all_vertices_in(:,1));
height_in = max(all_vertices_in(:,2))-min(all_vertices_in(:,2));
x0 = min(all_vertices_in(:,1));
y0 = min(all_vertices_in(:,2));
x1 = max(all_vertices_in(:,1));
y1 = max(all_vertices_in(:,2));
draw_dimension(ax,[x0,y1],[x1,y1],0.65, ...
    sprintf('%.3f in overall',width_in));
draw_dimension(ax,[x1,y0],[x1,y1],-0.75, ...
    sprintf('%.3f in overall',height_in));

if plate.id==3
    opening = plate.void_polygons_cm{1}/cm_per_in;
    for vertex_index = 1:size(opening,1)
        text(ax,opening(vertex_index,1),opening(vertex_index,2), ...
            sprintf(' (%.2f,%.2f)',opening(vertex_index,1), ...
            opening(vertex_index,2)),'FontSize',6.5, ...
            'Color',[0.55,0.10,0.10],'BackgroundColor','white','Margin',0.5);
    end
end

note = geometry_dimension_note(plate);
text(ax,x0,y0-0.55,note,'FontSize',7.5,'Interpreter','none', ...
    'VerticalAlignment','top','Color',[0.18,0.18,0.18]);
xlim(ax,[x0-1.0,x1+1.7]);
ylim(ax,[y0-1.15,y1+1.15]);
axis(ax,'equal');
grid(ax,'on');
box(ax,'on');
ax.GridAlpha = 0.12;
xlabel(ax,'x [in]');
ylabel(ax,'y [in]');
title(ax,{plate.name,sprintf('m = %.4f kg | t = %.3f in | %d holes', ...
    plate.mass_kg,plate.thickness_in,size(holes_in,1))}, ...
    'FontWeight','bold','FontSize',10);
end

function note = geometry_dimension_note(plate)
d = plate.dimensions;
switch plate.id
    case 1
        note = sprintf(['left material height %.3f in | left run %.3f in | ' ...
            'step %.3f in | right run %.3f in | hole dia %.3f in'], ...
            d.left_material_height_cm/2.54,d.left_lower_run_cm/2.54, ...
            d.step_height_cm/2.54,d.right_lower_run_cm/2.54, ...
            d.hole_diameter_in);
    case 2
        note = sprintf(['opening %.3f x %.3f in | margins L/R/T/B = ' ...
            '%.3f/%.3f/%.3f/%.3f in | hole dia %.3f in'], ...
            d.opening_width_cm/2.54,d.opening_height_cm/2.54, ...
            d.left_margin_cm/2.54,d.right_margin_cm/2.54, ...
            d.top_margin_cm/2.54,d.bottom_margin_cm/2.54, ...
            d.hole_diameter_in);
    case 3
        note = sprintf(['seven labeled opening vertices | hole dia %.3f in | ' ...
            'edge offset %.3f in'],d.hole_diameter_in,d.hole_edge_offset_in);
    case 4
        note = sprintf('rectangle %.3f x %.3f in | hole dia %.3f in | edge offset %.3f in', ...
            d.length_in,d.width_in,d.hole_diameter_in,d.hole_edge_offset_in);
end
end

function draw_dimension(ax,p1,p2,offset,label_text)
color = [0.08,0.28,0.62];
d = p2-p1;
span = norm(d);
u = d/span;
n = [-u(2),u(1)];
q1 = p1+offset*n;
q2 = p2+offset*n;
tick = max(0.08,0.02*span);
plot(ax,[p1(1),q1(1)],[p1(2),q1(2)],'-','Color',color,'LineWidth',0.8);
plot(ax,[p2(1),q2(1)],[p2(2),q2(2)],'-','Color',color,'LineWidth',0.8);
plot(ax,[q1(1),q2(1)],[q1(2),q2(2)],'-','Color',color,'LineWidth',1.0);
plot(ax,q1(1)+[-1,1]*tick*n(1),q1(2)+[-1,1]*tick*n(2), ...
    '-','Color',color,'LineWidth',1.0);
plot(ax,q2(1)+[-1,1]*tick*n(1),q2(2)+[-1,1]*tick*n(2), ...
    '-','Color',color,'LineWidth',1.0);
rotation = atan2d(d(2),d(1));
if rotation>90
    rotation = rotation-180;
elseif rotation<-90
    rotation = rotation+180;
end
label_offset = 0.18*sign(offset);
if label_offset==0
    label_offset = 0.18;
end
label_position = (q1+q2)/2+label_offset*n;
text(ax,label_position(1),label_position(2),label_text, ...
    'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'Rotation',rotation,'FontSize',7.5,'FontWeight','bold', ...
    'Color',color,'BackgroundColor','white','Margin',0.5);
end

function fig = draw_plate_assembly(plates,assembly,setup,show_figures)
visibility = 'off';
if show_figures
    visibility = 'on';
end
fig = figure('Color','white','Visible',visibility, ...
    'Position',[80,80,1250,820]);
ax = axes(fig);
hold(ax,'on');
axis(ax,'equal');
grid(ax,'on');
box(ax,'on');
xlabel(ax,'global x [in]');
ylabel(ax,'global y [in]');

colors = [0.32,0.58,0.82;0.72,0.76,0.80];
edge_colors = [0.05,0.20,0.38;0.25,0.25,0.25];
handles = gobjects(2,1);
all_points = zeros(0,2);
for component_index = 1:2
    component = assembly.components(component_index);
    p = plates(component.plate_index);
    origin_xy = component.origin_in(1:2);
    angle = component.rotation_deg;
    for polygon_index = 1:numel(p.solid_polygons_cm)
        xy = transform_planar_points( ...
            p.solid_polygons_cm{polygon_index}/2.54,angle,origin_xy);
        h = patch(ax,xy(:,1),xy(:,2),colors(component_index,:), ...
            'FaceAlpha',0.62,'EdgeColor',edge_colors(component_index,:), ...
            'LineWidth',1.8);
        if polygon_index==1
            handles(component_index) = h;
        end
        all_points = [all_points;xy]; %#ok<AGROW>
    end
    for polygon_index = 1:numel(p.void_polygons_cm)
        xy = transform_planar_points( ...
            p.void_polygons_cm{polygon_index}/2.54,angle,origin_xy);
        patch(ax,xy(:,1),xy(:,2),'white','FaceAlpha',0.92, ...
            'EdgeColor',edge_colors(component_index,:),'LineWidth',1.2);
    end
    holes = p.circular_voids_cm/2.54;
    if ~isempty(holes)
        centers = transform_planar_points(holes(:,1:2),angle,origin_xy);
        theta = linspace(0,2*pi,60);
        for hole_index = 1:size(holes,1)
            x = centers(hole_index,1)+holes(hole_index,3)*cos(theta);
            y = centers(hole_index,2)+holes(hole_index,3)*sin(theta);
            patch(ax,x,y,'white','FaceAlpha',0.95, ...
                'EdgeColor',edge_colors(component_index,:),'LineWidth',0.8);
        end
    end
    cg = component.cg_global_in;
    plot(ax,cg(1),cg(2),'o','MarkerSize',8,'LineWidth',1.8, ...
        'MarkerFaceColor',colors(component_index,:), ...
        'MarkerEdgeColor',edge_colors(component_index,:));
    label_offset = [0.35,0.35];
    horizontal_alignment = 'left';
    if component_index==2
        label_offset = [-0.35,0.28];
        horizontal_alignment = 'right';
    end
    text(ax,cg(1)+label_offset(1),cg(2)+label_offset(2), ...
        sprintf('P%d CG',component.plate_index), ...
        'FontSize',9,'FontWeight','bold','Color',edge_colors(component_index,:), ...
        'HorizontalAlignment',horizontal_alignment,'VerticalAlignment','bottom');
end

cg = assembly.CG_in;
plot(ax,cg(1),cg(2),'p','MarkerSize',15,'LineWidth',1.8, ...
    'MarkerFaceColor',[0.92,0.28,0.18],'MarkerEdgeColor','white');
cg_label_position = [min(all_points(:,1))+0.35,max(all_points(:,2))-0.55];
plot(ax,[cg(1),cg_label_position(1)],[cg(2),cg_label_position(2)], ...
    '-','Color',[0.65,0.08,0.05],'LineWidth',1.0);
text(ax,cg_label_position(1),cg_label_position(2), ...
    sprintf('Assembly CG (%.4f, %.4f, %.4f) in',cg), ...
    'FontWeight','bold','Color',[0.65,0.08,0.05], ...
    'BackgroundColor','white','Margin',1,'VerticalAlignment','bottom');

% Draw the two principal directions with the largest in-plane projections.
V = assembly.principal_axes_columns;
[~,axis_order] = sort(vecnorm(V(1:2,:),2,1),'descend');
axis_colors = [0.12,0.55,0.20;0.55,0.16,0.72];
axis_scale = 3.0;
for k = 1:2
    eigen_index = axis_order(k);
    direction = V(1:2,eigen_index);
    direction = direction/norm(direction);
    quiver(ax,cg(1),cg(2),axis_scale*direction(1), ...
        axis_scale*direction(2),0,'LineWidth',2.1, ...
        'MaxHeadSize',0.35,'Color',axis_colors(k,:));
    text(ax,cg(1)+axis_scale*direction(1), ...
        cg(2)+axis_scale*direction(2),sprintf(' principal %d',eigen_index), ...
        'FontWeight','bold','Color',axis_colors(k,:));
end

padding = 1.0;
xlim(ax,[min(all_points(:,1))-padding,max(all_points(:,1))+padding]);
ylim(ax,[min(all_points(:,2))-padding,max(all_points(:,2))+padding]);
legend(ax,handles,{plates(setup.base_plate_index).name, ...
    plates(setup.moving_plate_index).name},'Location','best', ...
    'Interpreter','none');

P = assembly.principal_moi_lbm_in2;
nxP = setup.nx_reference_principal_moi_lbm_in2;
title(ax,{setup.name, ...
    sprintf(['m = %.4f lbm | moving pose = [%.4f %.4f %.4f] in, ' ...
    '%.3f deg'],assembly.mass_lbm,setup.moving_origin_in, ...
    setup.moving_rotation_deg), ...
    sprintf(['Analytical principal MOI = [%.4f %.4f %.4f] lbm*in^2 | ' ...
    'NX reference = [%.4f %.4f %.4f]'],P,nxP)}, ...
    'FontWeight','bold');
end

function validate_experiment_configuration(experiment,plate_count)
validateattributes(experiment.plate_index,{'numeric'}, ...
    {'scalar','integer','>=',1,'<=',plate_count});
validatestring(experiment.pendulum_type,{'compound','bifilar'});
validatestring(experiment.tested_axis,{'x','y','z'});
validateattributes(experiment.frequency_band_hz,{'numeric'}, ...
    {'vector','numel',2,'positive','increasing'});
validateattributes(experiment.signal_channel,{'numeric'}, ...
    {'scalar','integer','positive'});
end

function data_file = locate_experiment_file(data_dir,stem)
candidates = { ...
    fullfile(data_dir,'TestsWithDotMAT',[stem,'.MAT']), ...
    fullfile(data_dir,[stem,'.MAT']), ...
    fullfile(data_dir,stem), ...
    fullfile(data_dir,[stem,'.rpt'])};
data_file = '';
for k = 1:numel(candidates)
    if isfile(candidates{k})
        data_file = candidates{k};
        break;
    end
end
if isempty(data_file)
    error('Could not find experimental record %s under %s.',stem,data_dir);
end
[~,~,extension] = fileparts(data_file);
if ~strcmpi(extension,'.MAT')
    error(['The preferred parsed MAT copy for %s was not found. ' ...
        'Create/resave the UFF record as a MAT file first.'],stem);
end
end

function [time_s,channels,sample_rate_hz] = load_uff_time_records(data_file)
loaded = load(data_file);
if ~isfield(loaded,'UFCELLS') || ~iscell(loaded.UFCELLS)
    error('%s does not contain the expected UFCELLS variable.',data_file);
end
records = {};
increments = [];
for k = 1:numel(loaded.UFCELLS)
    item = loaded.UFCELLS{k};
    if isstruct(item) && isfield(item,'DataValues') && ...
            isfield(item,'AbscissaIncrement') && ...
            isnumeric(item.DataValues) && ~isempty(item.DataValues) && ...
            isfinite(item.AbscissaIncrement) && item.AbscissaIncrement>0
        records{end+1} = double(item.DataValues(:)); %#ok<AGROW>
        increments(end+1) = double(item.AbscissaIncrement); %#ok<AGROW>
    end
end
if isempty(records)
    error('%s contains no usable uniformly sampled time records.',data_file);
end
record_lengths = cellfun(@numel,records);
if any(record_lengths~=record_lengths(1))
    error('Time channels in %s have inconsistent lengths.',data_file);
end
if max(abs(increments-increments(1)))>100*eps(increments(1))
    error('Time channels in %s have inconsistent sample intervals.',data_file);
end
channels = zeros(record_lengths(1),numel(records));
for k = 1:numel(records)
    channels(:,k) = records{k};
end
dt_s = increments(1);
sample_rate_hz = 1/dt_s;
time_s = (0:record_lengths(1)-1).'*dt_s;
end

function spectral = estimate_fundamental_frequency(time_s,signal,band_hz)
signal = double(signal(:));
time_s = double(time_s(:));
valid = isfinite(signal) & isfinite(time_s);
signal = signal(valid);
time_s = time_s(valid);
if numel(signal)<100
    error('At least 100 valid samples are required for frequency analysis.');
end
dt = median(diff(time_s));
sample_rate_hz = 1/dt;
sample_index = (0:numel(signal)-1).';
trend = polyfit(sample_index,signal,1);
signal_detrended = signal-polyval(trend,sample_index);
window = 0.5-0.5*cos(2*pi*sample_index/(numel(signal)-1));
windowed = signal_detrended.*window;
nfft = 2^nextpow2(16*numel(signal));
transform = fft(windowed,nfft);
power = abs(transform(1:floor(nfft/2)+1)).^2/sum(window.^2);
frequency_hz = (0:floor(nfft/2)).'*sample_rate_hz/nfft;
in_band = frequency_hz>=band_hz(1) & frequency_hz<=band_hz(2);
if nnz(in_band)<3
    error('The configured frequency band contains too few FFT bins.');
end
band_indices = find(in_band);
[peak_power,local_index] = max(power(in_band));
peak_index = band_indices(local_index);
delta = 0;
if peak_index>1 && peak_index<numel(power)
    a = log(max(power(peak_index-1),realmin));
    b = log(max(power(peak_index),realmin));
    c = log(max(power(peak_index+1),realmin));
    denominator = a-2*b+c;
    if abs(denominator)>eps
        delta = 0.5*(a-c)/denominator;
        delta = max(-0.5,min(0.5,delta));
    end
end
frequency_peak_hz = ((peak_index-1)+delta)*sample_rate_hz/nfft;
median_power = median(power(in_band));
peak_to_median_db = 10*log10(peak_power/max(median_power,realmin));
plot_band = frequency_hz<=max(6,1.25*band_hz(2));
plot_power = power(plot_band);
plot_power = plot_power/max(plot_power);
spectral.frequency_hz = frequency_peak_hz;
spectral.peak_to_median_db = peak_to_median_db;
spectral.plot_frequency_hz = frequency_hz(plot_band);
spectral.plot_power = plot_power;
end

function index = axis_number(axis_name)
switch lower(axis_name)
    case 'x'
        index = 1;
    case 'y'
        index = 2;
    case 'z'
        index = 3;
    otherwise
        error('Axis must be x, y, or z.');
end
end

function physics = evaluate_pendulum(experiment,mass_kg,J_cg_kg_m2, ...
    measured_frequency_hz,gravity_m_s2)
inch_to_m = 0.0254;
physics.pivot_to_cg_in = NaN;
physics.predicted_frequency_hz = NaN;
physics.predicted_period_s = NaN;
physics.experimental_inertia_kg_m2 = NaN;
physics.inertia_difference_percent = NaN;
physics.status = 'SETUP INPUT REQUIRED';
omega_measured = 2*pi*measured_frequency_hz;

switch lower(experiment.pendulum_type)
    case 'compound'
        d_in = experiment.pivot_to_cg_in;
        if ~isfinite(d_in) && isfinite(experiment.chain_length_in) && ...
                isfinite(experiment.attachment_to_cg_in)
            d_in = experiment.chain_length_in+experiment.attachment_to_cg_in;
        end
        physics.pivot_to_cg_in = d_in;
        if isfinite(d_in) && d_in>0
            d_m = d_in*inch_to_m;
            physics.predicted_frequency_hz = (1/(2*pi))*sqrt( ...
                mass_kg*gravity_m_s2*d_m/(J_cg_kg_m2+mass_kg*d_m^2));
            physics.predicted_period_s = 1/physics.predicted_frequency_hz;
            physics.experimental_inertia_kg_m2 = ...
                mass_kg*gravity_m_s2*d_m/omega_measured^2-mass_kg*d_m^2;
            physics.inertia_difference_percent = 100*( ...
                physics.experimental_inertia_kg_m2-J_cg_kg_m2)/J_cg_kg_m2;
            if physics.experimental_inertia_kg_m2<=0
                physics.status = 'CHECK SETUP: INFERRED INERTIA IS NONPOSITIVE';
            else
                physics.status = 'COMPLETE';
            end
        end
    case 'bifilar'
        L_in = experiment.chain_length_in;
        r_in = experiment.suspension_radius_in;
        if isfinite(L_in) && L_in>0 && isfinite(r_in) && r_in>0
            L_m = L_in*inch_to_m;
            r_m = r_in*inch_to_m;
            physics.predicted_frequency_hz = (1/(2*pi))*sqrt( ...
                mass_kg*gravity_m_s2*r_m^2/(J_cg_kg_m2*L_m));
            physics.predicted_period_s = 1/physics.predicted_frequency_hz;
            physics.experimental_inertia_kg_m2 = ...
                mass_kg*gravity_m_s2*r_m^2/(omega_measured^2*L_m);
            physics.inertia_difference_percent = 100*( ...
                physics.experimental_inertia_kg_m2-J_cg_kg_m2)/J_cg_kg_m2;
            physics.status = 'COMPLETE';
        end
end
end

function fig = draw_experimental_results(experiments,plot_cache,show_figures)
visibility = 'off';
if show_figures
    visibility = 'on';
end
fig = figure('Color','white','Visible',visibility, ...
    'Position',[70,50,1500,1100]);
layout = tiledlayout(fig,numel(experiments),2, ...
    'TileSpacing','compact','Padding','compact');
title(layout,'Experimental Pendulum Time Records and Frequency Extraction', ...
    'FontSize',16,'FontWeight','bold');
colors = lines(7);
for experiment_index = 1:numel(experiments)
    experiment = experiments(experiment_index);
    cache = plot_cache{experiment_index};
    ax_time = nexttile(layout,2*experiment_index-1);
    hold(ax_time,'on');
    ax_spectrum = nexttile(layout,2*experiment_index);
    hold(ax_spectrum,'on');
    legends = cell(numel(cache),1);
    selected_frequencies_hz = zeros(numel(cache),1);
    for run_index = 1:numel(cache)
        item = cache{run_index};
        selected_frequencies_hz(run_index) = item.frequency_hz;
        signal = item.signal(:);
        sample_index = (0:numel(signal)-1).';
        trend = polyfit(sample_index,signal,1);
        signal = signal-polyval(trend,sample_index);
        scale = std(signal);
        if scale<=0
            scale = 1;
        end
        plot_step = max(1,ceil(numel(signal)/5000));
        selected = 1:plot_step:numel(signal);
        plot(ax_time,item.time_s(selected), ...
            signal(selected)/scale+2.7*(run_index-1), ...
            'Color',colors(run_index,:),'LineWidth',0.8);
        plot(ax_spectrum,item.spectrum_frequency_hz,item.spectrum_power, ...
            'Color',colors(run_index,:),'LineWidth',1.2);
        xline(ax_spectrum,item.frequency_hz,':', ...
            'Color',colors(run_index,:),'LineWidth',0.9);
        legends{run_index} = sprintf('%s: %.4f Hz, %.4f s', ...
            item.stem,item.frequency_hz,1/item.frequency_hz);
    end
    grid(ax_time,'on');
    box(ax_time,'on');
    xlabel(ax_time,'Time [s]');
    ylabel(ax_time,'Normalized signal + offset');
    title(ax_time,{experiment.label, ...
        sprintf('%s pendulum | tested %s axis | channel %d', ...
        experiment.pendulum_type,experiment.tested_axis, ...
        experiment.signal_channel)},'FontSize',10,'Interpreter','none');
    legend(ax_time,legends,'Location','best','FontSize',7, ...
        'Interpreter','none');

    xlim(ax_spectrum,[0,max(6,1.25*experiment.frequency_band_hz(2))]);
    ylim(ax_spectrum,[0,1.05]);
    xline(ax_spectrum,experiment.frequency_band_hz(1),'--', ...
        'Color',[0.3,0.3,0.3]);
    xline(ax_spectrum,experiment.frequency_band_hz(2),'--', ...
        'Color',[0.3,0.3,0.3]);
    grid(ax_spectrum,'on');
    box(ax_spectrum,'on');
    xlabel(ax_spectrum,'Frequency [Hz]');
    ylabel(ax_spectrum,'Normalized spectral power');
    title(ax_spectrum,sprintf( ...
        'Spectrum | selected fundamental = %.4f +/- %.4f Hz', ...
        mean(selected_frequencies_hz),std(selected_frequencies_hz)), ...
        'FontSize',10);
end
end
