%% Plate 1 - Notched Solid Plate Analytical Model
% Exact polygon area integrals; no experimental time-history data.
% Measurements are from page 3 of Plate_measurements.pdf.

close all;

script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
    script_dir = pwd;
end
addpath(script_dir);
output_dir = fullfile(script_dir,'output');
if ~exist(output_dir,'dir')
    mkdir(output_dir);
end

%% User and measurement inputs
mass_kg = 1.15897386;      % User-provided finished-plate mass [kg]
thickness_in = 0.750;     % Measured [in]
cm_per_in = 2.54;
thickness_cm = cm_per_in*thickness_in;

width_cm = 40.2;
overall_height_cm = 19.9;
left_material_height_cm = 13.3;
left_lower_run_cm = 17.5;
step_height_cm = 3.6;
right_lower_run_cm = 12.3;

% Derived bounding-box coordinates. The photographed curved/sloping lower
% transition has no radius or spline coordinates in the source, so the
% analytical boundary is the straight chord between its measured endpoints.
y_left_bottom_cm = overall_height_cm - left_material_height_cm; % 6.6 cm
x_step_cm = width_cm - right_lower_run_cm;                       % 27.9 cm

outer_cm = [ ...
     0.0,               y_left_bottom_cm; ...
     left_lower_run_cm, y_left_bottom_cm; ...
     x_step_cm,         step_height_cm; ...
     x_step_cm,         0.0; ...
     width_cm,          0.0; ...
     width_cm,          overall_height_cm; ...
     0.0,               overall_height_cm];

solid_polygons = {outer_cm};
void_polygons = {};
hole_diameter_in = 0.184;  % Measured on PDF page 3 [in]
hole_edge_offset_in = 0.250; % User-directed nominal center-to-edge offset [in]
circular_voids_in = notched_plate_perimeter_holes( ...
    width_cm/cm_per_in,overall_height_cm/cm_per_in, ...
    left_lower_run_cm/cm_per_in,y_left_bottom_cm/cm_per_in, ...
    x_step_cm/cm_per_in,step_height_cm/cm_per_in, ...
    hole_edge_offset_in,hole_diameter_in/2);
circular_voids_cm = circular_voids_in*cm_per_in;

%% Closed-form center of gravity and inertias
plate_results = analytical_extruded_plate(solid_polygons, void_polygons, ...
    circular_voids_cm, thickness_cm, mass_kg);

info.name = 'Plate 1 - Notched Solid Plate';
info.source = 'Plate_measurements.pdf page 3';
info.geometry_note = ['Lower transition represented by a straight chord ' ...
    'because no curve radius/profile was supplied.'];
info.holes_note = sprintf(['Included: %d through-holes, diameter %.3f in. ' ...
    'Centers follow the photograph with a nominal %.3f in edge offset; ' ...
    'lower notch/slope locations are explicitly approximate.'], ...
    size(circular_voids_in,1),hole_diameter_in,hole_edge_offset_in);

report_file = fullfile(output_dir,'plate01_notched_solid_results.txt');
write_plate_report(plate_results,info,report_file);
data_file = fullfile(output_dir,'plate01_notched_solid_results.mat');
save(data_file,'plate_results','info','outer_cm','circular_voids_cm');

%% Dimensioned analytical figure
outer_in = outer_cm/cm_per_in;
solid_polygons_in = {outer_in};
void_polygons_in = {};
width_in = width_cm/cm_per_in;
overall_height_in = overall_height_cm/cm_per_in;
left_material_height_in = left_material_height_cm/cm_per_in;
left_lower_run_in = left_lower_run_cm/cm_per_in;
step_height_in = step_height_cm/cm_per_in;
right_lower_run_in = right_lower_run_cm/cm_per_in;
y_left_bottom_in = y_left_bottom_cm/cm_per_in;
x_step_in = x_step_cm/cm_per_in;

title_lines = { ...
    'Plate 1 - Notched Solid Plate', ...
    sprintf(['Analytical footprint | m = %.3f kg ' ...
    '(W = %.3f lbf at standard g) | t = %.3f in'], ...
    mass_kg,plate_results.weight_lbf_standard_g,thickness_in), ...
    sprintf('%d x dia %.3f in holes | nominal center offset %.3f in', ...
    size(circular_voids_in,1),hole_diameter_in,hole_edge_offset_in)};
[fig,ax] = draw_plate_footprint(solid_polygons_in,void_polygons_in, ...
    plate_results,title_lines,[-6.5,47.0,-5.0,25.0]/cm_per_in,'in', ...
    circular_voids_in);

dimension_color = [0.08,0.28,0.62];
draw_linear_dimension(ax,[0,overall_height_in],[width_in,overall_height_in], ...
    3.0/cm_per_in,sprintf('%.3f in overall',width_in),dimension_color);
draw_linear_dimension(ax,[width_in,0],[width_in,overall_height_in], ...
    -3.2/cm_per_in,sprintf('%.3f in overall',overall_height_in),dimension_color);
draw_linear_dimension(ax,[0,y_left_bottom_in],[0,overall_height_in], ...
    2.5/cm_per_in,sprintf('%.3f in',left_material_height_in),dimension_color);
draw_linear_dimension(ax,[0,y_left_bottom_in], ...
    [left_lower_run_in,y_left_bottom_in],-2.3/cm_per_in, ...
    sprintf('%.3f in',left_lower_run_in),dimension_color);
draw_linear_dimension(ax,[x_step_in,0],[x_step_in,step_height_in], ...
    -1.5/cm_per_in,sprintf('%.3f in',step_height_in),dimension_color);
draw_linear_dimension(ax,[x_step_in,0],[width_in,0], ...
    -2.4/cm_per_in,sprintf('%.3f in',right_lower_run_in),dimension_color);

plot(ax,[left_lower_run_in,x_step_in], ...
    [y_left_bottom_in,step_height_in],'-','Color',[0.50,0.16,0.08], ...
    'LineWidth',2.4);
text(ax,22.5/cm_per_in,6.4/cm_per_in,'straight-chord approximation', ...
    'Color',[0.50,0.16,0.08],'FontAngle','italic', ...
    'HorizontalAlignment','center','BackgroundColor','white','Margin',1);
text(ax,1.0/cm_per_in,1.2/cm_per_in, ...
    sprintf('Derived offset: %.3f - %.3f = %.3f in', ...
    overall_height_in,left_material_height_in,y_left_bottom_in), ...
    'Color',[0.22,0.22,0.22],'FontSize',9,'BackgroundColor','white','Margin',1);

figure_file = fullfile(output_dir,'plate01_notched_solid_geometry.png');
exportgraphics(fig,figure_file,'Resolution',300);
fprintf('Saved dimensioned figure: %s\n',figure_file);
fprintf('Saved text results:      %s\n',report_file);
fprintf('Saved MATLAB results:    %s\n',data_file);
