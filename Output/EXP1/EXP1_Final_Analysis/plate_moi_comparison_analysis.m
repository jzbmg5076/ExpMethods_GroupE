%% EXP1 Plate MOI Comparison: Analytical, Experimental, and NX
% EXP1_Final_Analysis copy: step 2 of 3 (run run_exp1_all.m to do everything).
% Change from the original: Plate 1 (HDPE) uses the final NX model values.
% This script is intentionally independent of raw accelerometer processing.
% It uses measured plate mass, geometry, and thickness to calculate the
% analytical centroidal mass moments of inertia, optionally imports already
% calculated experimental MOIs (or accepts manual values), and compares both
% against the NX mass-property callouts.
%
% Coordinate convention:
%   x = horizontal axis in each plate drawing
%   y = vertical axis in each plate drawing
%   z = through-thickness axis
%
% All reported mass moments of inertia are in lbm*in^2.

clear;
clc;
close all;

%% Paths and output controls
script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
    script_dir = pwd;
end
addpath(script_dir);

output_dir = fullfile(script_dir,'combined_output','moi_comparison');
if ~exist(output_dir,'dir')
    mkdir(output_dir);
end

save_figures = true;
show_figures = true;

%% Measured plate inputs (edit these values when measurements change)
% Finished masses and thicknesses. Dimensions used below are the measured
% planform dimensions from the four analytical plate models.
plate_mass_kg = [1.15897386; 4.5350165; 9.052279652; 1.687];
plate_thickness_in = [0.773; 0.515; 0.380; 0.500];

% Plate 1: notched HDPE solid plate [cm]
geometry(1).overall_width_cm = 40.2;
geometry(1).overall_height_cm = 19.9;
geometry(1).left_material_height_cm = 13.3;
geometry(1).left_lower_run_cm = 17.5;
geometry(1).step_height_cm = 3.6;
geometry(1).right_lower_run_cm = 12.3;
geometry(1).hole_diameter_in = 0.184;
geometry(1).hole_edge_offset_in = 0.250;

% Plate 2: aluminum offset rectangular frame [cm]
geometry(2).outer_width_cm = 60.7;
geometry(2).outer_height_cm = 30.5;
geometry(2).left_margin_cm = 17.4;
geometry(2).right_margin_cm = 7.7;
geometry(2).top_margin_cm = 5.0;
geometry(2).bottom_margin_cm = 10.1;
geometry(2).hole_diameter_in = 0.184;
geometry(2).hole_edge_offset_in = 0.250;

% Plate 3: irregular polygon-window frame [cm]
geometry(3).outer_width_cm = 61.1;
geometry(3).outer_height_cm = 30.4;
geometry(3).opening_vertices_cm = [ ...
    8.6,7.6; 20.9,4.4; 21.8,8.1; 32.3,8.1; ...
    52.1,2.7; 55.5,16.1; 13.7,27.2];
geometry(3).hole_diameter_in = 0.184;
geometry(3).hole_edge_offset_in = 0.250;

% Plate 4: rectangular 6061-T651 aluminum plate [in]
geometry(4).length_in = 12.900;
geometry(4).width_in = 5.900;
geometry(4).hole_diameter_in = 0.180;
geometry(4).hole_edge_offset_in = 0.250;

%% Experimental MOI input
% Choose "import" to read already calculated MOIs from the pendulum summary
% CSV. This does NOT read or process raw accelerometer records.
% Choose "manual" to use manual_experimental_moi_lbm_in2 instead.
experimental_input_mode = "import"; % "import" or "manual"
experimental_summary_file = fullfile(fileparts(output_dir), ...
    'pendulum_summary_results_lbm_in2.csv');

% Rows are Plates 1-4; columns are [Ixx Iyy Izz], all in lbm*in^2.
% Enter NaN when a component was not measured.
manual_experimental_moi_lbm_in2 = [ ...
    NaN, NaN, NaN; ... % Plate 1
    NaN, NaN, NaN; ... % Plate 2
    NaN, NaN, NaN; ... % Plate 3
    NaN, NaN, NaN];    % Plate 4

%% NX reference values from Experiment1_Model_MomentOFInertias.pdf
% The rows below are ordered to match analytical Plates 1-4:
%   Plate 1 -> NX page/model 3
%   Plate 2 -> NX page/model 2
%   Plate 3 -> NX page/model 4
%   Plate 4 -> NX page/model 1
% Values are centroidal [Ixx Iyy Izz] in native NX lbm*in^2.
nx_model_number = [3; 2; 4; 1];
nx_cg_in = [ ...
     8.6587, 2.0423, 0.3865; ...
    10.9483, 5.6674, 0.2500; ...
    11.9932, 6.2228, 0.2500; ...
     6.4507, 2.9501, 0.2250];
nx_native_moi_lbm_in2 = [ ...
      9.9802,   54.5123,   64.2381; ... % final NX model (FinalIrregularShape_NX_Config2.png)
    153.1160,  583.9527,  736.6308; ...
    419.2048, 1579.8359, 1997.9787; ...
      9.7186,   46.3077,   55.9135];

%% Calculate analytical plate mass properties
plates = build_plate_geometry(geometry,plate_mass_kg,plate_thickness_in);
plate_count = numel(plates);
analytical_moi_lbm_in2 = zeros(plate_count,3);
analytical_cg_in = zeros(plate_count,3);
area_cm2 = zeros(plate_count,1);

for plate_index = 1:plate_count
    plates(plate_index).properties = analytical_extruded_plate( ...
        plates(plate_index).solid_polygons_cm, ...
        plates(plate_index).void_polygons_cm, ...
        plates(plate_index).circular_voids_cm, ...
        2.54*plates(plate_index).thickness_in, ...
        plates(plate_index).mass_kg);
    analytical_moi_lbm_in2(plate_index,:) = diag( ...
        plates(plate_index).properties.I_tensor_prism_lbm_in2).';
    analytical_cg_in(plate_index,:) = plates(plate_index).properties.CG_in;
    area_cm2(plate_index) = plates(plate_index).properties.area_cm2;
end

%% Import or assign experimental MOIs
switch lower(experimental_input_mode)
    case "import"
        experimental_moi_lbm_in2 = import_experimental_moi( ...
            experimental_summary_file,plate_count);
        experimental_source = "Imported from " + string(experimental_summary_file);
    case "manual"
        validateattributes(manual_experimental_moi_lbm_in2,{'numeric'}, ...
            {'size',[plate_count,3]},mfilename, ...
            'manual_experimental_moi_lbm_in2');
        experimental_moi_lbm_in2 = manual_experimental_moi_lbm_in2;
        experimental_source = "Manual matrix in this script";
    otherwise
        error('experimental_input_mode must be "import" or "manual".');
end

%% Put NX and measured plates on the same mass basis
% NX native inertias include the masses implied by the CAD materials. For a
% uniform prismatic extrusion, Ixx + Iyy - Izz = m*t^2/6. The relation is
% used to infer the native NX mass from the rounded callouts. Scaling each
% NX tensor to the corresponding measured mass gives a geometry-only MOI
% comparison with the analytical and experimental values.
kg_to_lbm = 2.2046226218487757;
nx_thickness_in = 2*nx_cg_in(:,3);
nx_inferred_mass_lbm = 6*(nx_native_moi_lbm_in2(:,1) + ...
    nx_native_moi_lbm_in2(:,2) - nx_native_moi_lbm_in2(:,3))./ ...
    nx_thickness_in.^2;
nx_inferred_mass_kg = nx_inferred_mass_lbm/kg_to_lbm;
measured_mass_lbm = plate_mass_kg*kg_to_lbm;
nx_moi_at_measured_mass_lbm_in2 = nx_native_moi_lbm_in2.* ...
    (measured_mass_lbm./nx_inferred_mass_lbm);

%% Build comparison and percent-difference tables
plate_short_name = ["P1 Notched HDPE"; "P2 Aluminum frame"; ...
    "P3 Irregular frame"; "P4 Rectangle"];
axis_name = ["Ixx"; "Iyy"; "Izz"];

row_count = plate_count*numel(axis_name);
Plate = strings(row_count,1);
NXModel = zeros(row_count,1);
Axis = strings(row_count,1);
Analytical_lbm_in2 = zeros(row_count,1);
NXNative_lbm_in2 = zeros(row_count,1);
NXScaledToMeasuredMass_lbm_in2 = zeros(row_count,1);
Experimental_lbm_in2 = NaN(row_count,1);

row = 0;
for plate_index = 1:plate_count
    for axis_index = 1:3
        row = row+1;
        Plate(row) = plate_short_name(plate_index);
        NXModel(row) = nx_model_number(plate_index);
        Axis(row) = axis_name(axis_index);
        Analytical_lbm_in2(row) = ...
            analytical_moi_lbm_in2(plate_index,axis_index);
        NXNative_lbm_in2(row) = ...
            nx_native_moi_lbm_in2(plate_index,axis_index);
        NXScaledToMeasuredMass_lbm_in2(row) = ...
            nx_moi_at_measured_mass_lbm_in2(plate_index,axis_index);
        Experimental_lbm_in2(row) = ...
            experimental_moi_lbm_in2(plate_index,axis_index);
    end
end

SignedRelative_Analytical_vs_NX_pct = 100*(Analytical_lbm_in2 - ...
    NXScaledToMeasuredMass_lbm_in2)./NXScaledToMeasuredMass_lbm_in2;
SymmetricDifference_Analytical_vs_NX_pct = symmetric_percent_difference( ...
    Analytical_lbm_in2,NXScaledToMeasuredMass_lbm_in2);
SignedRelative_Experimental_vs_Analytical_pct = 100*( ...
    Experimental_lbm_in2-Analytical_lbm_in2)./Analytical_lbm_in2;
SymmetricDifference_Experimental_vs_Analytical_pct = ...
    symmetric_percent_difference(Experimental_lbm_in2,Analytical_lbm_in2);
SignedRelative_Experimental_vs_NX_pct = 100*(Experimental_lbm_in2 - ...
    NXScaledToMeasuredMass_lbm_in2)./NXScaledToMeasuredMass_lbm_in2;
SymmetricDifference_Experimental_vs_NX_pct = ...
    symmetric_percent_difference(Experimental_lbm_in2, ...
    NXScaledToMeasuredMass_lbm_in2);

comparison_table = table(Plate,NXModel,Axis,Analytical_lbm_in2, ...
    NXNative_lbm_in2,NXScaledToMeasuredMass_lbm_in2, ...
    Experimental_lbm_in2);
percent_table = table(Plate,NXModel,Axis, ...
    SignedRelative_Analytical_vs_NX_pct, ...
    SymmetricDifference_Analytical_vs_NX_pct, ...
    SignedRelative_Experimental_vs_Analytical_pct, ...
    SymmetricDifference_Experimental_vs_Analytical_pct, ...
    SignedRelative_Experimental_vs_NX_pct, ...
    SymmetricDifference_Experimental_vs_NX_pct);

mass_table = table(plate_short_name,nx_model_number,plate_mass_kg, ...
    measured_mass_lbm,nx_inferred_mass_kg,nx_inferred_mass_lbm, ...
    plate_thickness_in,nx_thickness_in,area_cm2, ...
    'VariableNames',{'Plate','NXModel','MeasuredMass_kg', ...
    'MeasuredMass_lbm','NXInferredMass_kg','NXInferredMass_lbm', ...
    'MeasuredThickness_in','NXThickness_in','AnalyticalArea_cm2'});

% NX page/model 3 places y=0 at the raised left lower edge, 6.6 cm above
% the analytical bounding-box origin. Register that callout before forming
% a CG delta. The other three models already share the analytical origin.
nx_cg_common_in = nx_cg_in;
plate1_origin_shift_in = (geometry(1).overall_height_cm - ...
    geometry(1).left_material_height_cm)/2.54;
nx_cg_common_in(1,2) = nx_cg_common_in(1,2)+plate1_origin_shift_in;
cg_delta_in = analytical_cg_in-nx_cg_common_in;
cg_table = table(plate_short_name,nx_model_number, ...
    analytical_cg_in(:,1),analytical_cg_in(:,2),analytical_cg_in(:,3), ...
    nx_cg_in(:,1),nx_cg_in(:,2),nx_cg_in(:,3), ...
    nx_cg_common_in(:,1),nx_cg_common_in(:,2),nx_cg_common_in(:,3), ...
    cg_delta_in(:,1),cg_delta_in(:,2),cg_delta_in(:,3), ...
    'VariableNames',{'Plate','NXModel','AnalyticalCG_X_in', ...
    'AnalyticalCG_Y_in','AnalyticalCG_Z_in','NXCalloutCG_X_in', ...
    'NXCalloutCG_Y_in','NXCalloutCG_Z_in','NXRegisteredCG_X_in', ...
    'NXRegisteredCG_Y_in','NXRegisteredCG_Z_in','AnalyticalMinusNX_X_in', ...
    'AnalyticalMinusNX_Y_in','AnalyticalMinusNX_Z_in'});

disp(' ');
disp('MASS BASIS');
disp(mass_table);
disp(' ');
disp('MOI SOURCE VALUES [lbm*in^2]');
disp(comparison_table);
disp(' ');
disp('PERCENT DIFFERENCES');
disp(percent_table);

writetable(mass_table,fullfile(output_dir, ...
    'plate_mass_basis_comparison.csv'));
writetable(cg_table,fullfile(output_dir, ...
    'plate_cg_comparison.csv'));
writetable(comparison_table,fullfile(output_dir, ...
    'plate_moi_source_values_lbm_in2.csv'));
writetable(percent_table,fullfile(output_dir, ...
    'plate_moi_percent_differences.csv'));

%% Report-ready plots
value_figure = draw_moi_comparison(plate_short_name, ...
    analytical_moi_lbm_in2,nx_moi_at_measured_mass_lbm_in2, ...
    experimental_moi_lbm_in2,show_figures);
percent_figure = draw_percent_comparison(plate_short_name, ...
    reshape(SymmetricDifference_Analytical_vs_NX_pct,3,[]).', ...
    reshape(SymmetricDifference_Experimental_vs_Analytical_pct,3,[]).', ...
    reshape(SymmetricDifference_Experimental_vs_NX_pct,3,[]).', ...
    show_figures);

if save_figures
    exportgraphics(value_figure,fullfile(output_dir, ...
        'plate_moi_analytical_experimental_nx.png'),'Resolution',300);
    exportgraphics(percent_figure,fullfile(output_dir, ...
        'plate_moi_percent_differences.png'),'Resolution',300);
end

%% Save all MATLAB results
results_file = fullfile(output_dir,'plate_moi_comparison_results.mat');
save(results_file,'plates','geometry','plate_mass_kg','plate_thickness_in', ...
    'analytical_moi_lbm_in2','experimental_moi_lbm_in2', ...
    'nx_native_moi_lbm_in2','nx_moi_at_measured_mass_lbm_in2', ...
    'nx_inferred_mass_kg','nx_cg_in','nx_cg_common_in','comparison_table', ...
    'percent_table', ...
    'mass_table','cg_table','experimental_source');

fprintf('\nPlate MOI comparison complete.\n');
fprintf('Experimental source: %s\n',experimental_source);
fprintf('Results folder: %s\n',output_dir);
fprintf('MATLAB results: %s\n',results_file);

%% Local functions
function plates = build_plate_geometry(g,masses_kg,thicknesses_in)
cm_per_in = 2.54;
template = struct('name','','mass_kg',NaN,'thickness_in',NaN, ...
    'solid_polygons_cm',{{}},'void_polygons_cm',{{}}, ...
    'circular_voids_cm',zeros(0,3),'properties',struct());
plates = repmat(template,4,1);

% Plate 1
p = g(1);
y_left_bottom = p.overall_height_cm-p.left_material_height_cm;
x_step = p.overall_width_cm-p.right_lower_run_cm;
outer = [0,y_left_bottom; p.left_lower_run_cm,y_left_bottom; ...
    x_step,p.step_height_cm; x_step,0; p.overall_width_cm,0; ...
    p.overall_width_cm,p.overall_height_cm; 0,p.overall_height_cm];
holes_in = notched_plate_perimeter_holes( ...
    p.overall_width_cm/cm_per_in,p.overall_height_cm/cm_per_in, ...
    p.left_lower_run_cm/cm_per_in,y_left_bottom/cm_per_in, ...
    x_step/cm_per_in,p.step_height_cm/cm_per_in, ...
    p.hole_edge_offset_in,p.hole_diameter_in/2);
plates(1) = make_plate('Plate 1 - Notched HDPE solid plate',masses_kg(1), ...
    thicknesses_in(1),{outer},{},holes_in*cm_per_in);

% Plate 2
p = g(2);
opening_width = p.outer_width_cm-p.left_margin_cm-p.right_margin_cm;
opening_height = p.outer_height_cm-p.top_margin_cm-p.bottom_margin_cm;
outer = [0,0; p.outer_width_cm,0; p.outer_width_cm,p.outer_height_cm; ...
    0,p.outer_height_cm];
opening = [p.left_margin_cm,p.bottom_margin_cm; ...
    p.left_margin_cm+opening_width,p.bottom_margin_cm; ...
    p.left_margin_cm+opening_width,p.bottom_margin_cm+opening_height; ...
    p.left_margin_cm,p.bottom_margin_cm+opening_height];
holes_in = rectangular_perimeter_holes( ...
    p.outer_width_cm/cm_per_in,p.outer_height_cm/cm_per_in,5,5, ...
    p.hole_edge_offset_in,p.hole_diameter_in/2);
plates(2) = make_plate('Plate 2 - Aluminum offset rectangular frame', ...
    masses_kg(2),thicknesses_in(2),{outer},{opening},holes_in*cm_per_in);

% Plate 3
p = g(3);
outer = [0,0; p.outer_width_cm,0; p.outer_width_cm,p.outer_height_cm; ...
    0,p.outer_height_cm];
holes_in = rectangular_perimeter_holes( ...
    p.outer_width_cm/cm_per_in,p.outer_height_cm/cm_per_in,5,5, ...
    p.hole_edge_offset_in,p.hole_diameter_in/2);
plates(3) = make_plate('Plate 3 - Irregular polygon-window frame', ...
    masses_kg(3),thicknesses_in(3),{outer},{p.opening_vertices_cm}, ...
    holes_in*cm_per_in);

% Plate 4
p = g(4);
outer_in = [0,0; p.length_in,0; p.length_in,p.width_in; 0,p.width_in];
holes_in = rectangular_perimeter_holes(p.length_in,p.width_in,5,3, ...
    p.hole_edge_offset_in,p.hole_diameter_in/2);
plates(4) = make_plate('Plate 4 - Rectangular plate',masses_kg(4), ...
    thicknesses_in(4),{outer_in*cm_per_in},{},holes_in*cm_per_in);
end

function plate = make_plate(name,mass_kg,thickness_in,solids,voids,holes)
plate = struct('name',name,'mass_kg',mass_kg, ...
    'thickness_in',thickness_in,'solid_polygons_cm',{solids}, ...
    'void_polygons_cm',{voids},'circular_voids_cm',holes, ...
    'properties',struct());
end

function experimental = import_experimental_moi(filename,plate_count)
experimental = NaN(plate_count,3);
if ~isfile(filename)
    warning(['Experimental summary file was not found. Experimental MOIs ' ...
        'will remain NaN: %s'],filename);
    return
end

T = readtable(filename,'TextType','string');
required = ["Plate","TestedAxis","ExperimentalInertia_lbm_in2"];
if ~all(ismember(required,string(T.Properties.VariableNames)))
    error('Experimental summary is missing one or more required columns.');
end

for row = 1:height(T)
    token = regexp(T.Plate(row),'Plate\s+(\d+)','tokens','once');
    if isempty(token)
        warning('Could not identify a plate number in row %d.',row);
        continue
    end
    plate_index = str2double(token{1});
    if plate_index<1 || plate_index>plate_count
        warning('Ignoring out-of-range plate number in row %d.',row);
        continue
    end
    axis_text = lower(strtrim(T.TestedAxis(row)));
    axis_index = find(axis_text == ["x","y","z"],1);
    if isempty(axis_index)
        warning('Ignoring unknown tested axis in row %d.',row);
        continue
    end
    experimental(plate_index,axis_index) = ...
        T.ExperimentalInertia_lbm_in2(row);
end
end

function value = symmetric_percent_difference(a,b)
value = 200*abs(a-b)./(abs(a)+abs(b));
value((a==0 & b==0) | isnan(a) | isnan(b)) = NaN;
end

function fig = draw_moi_comparison(names,analytical,nx_scaled,experimental,show)
visibility = 'off';
if show
    visibility = 'on';
end
fig = figure('Color','white','Visible',visibility, ...
    'Position',[50,50,1500,930]);
layout = tiledlayout(fig,2,2,'TileSpacing','compact','Padding','compact');
title(layout,{ ...
    'Centroidal Mass Moment of Inertia Comparison', ...
    'NX values scaled to each measured plate mass'}, ...
    'FontSize',16,'FontWeight','bold');
axis_labels = {'I_{xx}','I_{yy}','I_{zz}'};

for k = 1:numel(names)
    ax = nexttile(layout,k);
    values = [analytical(k,:).',nx_scaled(k,:).',experimental(k,:).'];
    bar(ax,values,'grouped');
    grid(ax,'on');
    ax.XTick = 1:3;
    ax.XTickLabel = axis_labels;
    ylabel(ax,'MOI [lbm\cdotin^2]');
    title(ax,names(k),'Interpreter','none');
    if k==1
        legend(ax,{'Analytical','NX at measured mass','Experimental'}, ...
            'Location','northwest');
    end
end
end

function fig = draw_percent_comparison(names,analytical_nx, ...
    experimental_analytical,experimental_nx,show)
visibility = 'off';
if show
    visibility = 'on';
end
fig = figure('Color','white','Visible',visibility, ...
    'Position',[70,70,1500,930]);
layout = tiledlayout(fig,2,2,'TileSpacing','compact','Padding','compact');
title(layout,'Symmetric Percent Differences by Plate and Axis', ...
    'FontSize',16,'FontWeight','bold');
axis_labels = {'I_{xx}','I_{yy}','I_{zz}'};

for k = 1:numel(names)
    ax = nexttile(layout,k);
    values = [analytical_nx(k,:).',experimental_analytical(k,:).', ...
        experimental_nx(k,:).'];
    bar(ax,values,'grouped');
    grid(ax,'on');
    ax.XTick = 1:3;
    ax.XTickLabel = axis_labels;
    ylabel(ax,'Symmetric difference [%]');
    title(ax,names(k),'Interpreter','none');
    if k==1
        legend(ax,{'Analytical vs NX','Experimental vs Analytical', ...
            'Experimental vs NX'},'Location','northwest');
    end
end
end
