%% Plate 2 - Offset Rectangular Frame Analytical Model
% Exact outer-rectangle minus offset-rectangle area integrals.
% Measurements are from page 4 of Plate_measurements.pdf.

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
mass_kg = 4.5350165;     % User-provided finished-plate mass [kg]
thickness_in = 0.500;     % Measured [in]
cm_per_in = 2.54;
thickness_cm = cm_per_in*thickness_in;

outer_width_cm = 60.7;
outer_height_cm = 30.5;
left_margin_cm = 17.4;
right_margin_cm = 7.7;
top_margin_cm = 5.0;
bottom_margin_cm = 10.1;

opening_width_cm = outer_width_cm - left_margin_cm - right_margin_cm;
opening_height_cm = outer_height_cm - top_margin_cm - bottom_margin_cm;

outer_cm = [0,0; outer_width_cm,0; ...
    outer_width_cm,outer_height_cm; 0,outer_height_cm];
opening_cm = [ ...
    left_margin_cm,                  bottom_margin_cm; ...
    left_margin_cm+opening_width_cm, bottom_margin_cm; ...
    left_margin_cm+opening_width_cm, bottom_margin_cm+opening_height_cm; ...
    left_margin_cm,                  bottom_margin_cm+opening_height_cm];

solid_polygons = {outer_cm};
void_polygons = {opening_cm};
hole_diameter_in = 0.184;  % Assumed equal to the measured Plate-1 holes
hole_edge_offset_in = 0.250; % User-directed nominal center-to-edge offset
circular_voids_in = rectangular_perimeter_holes( ...
    outer_width_cm/cm_per_in,outer_height_cm/cm_per_in,5,5, ...
    hole_edge_offset_in,hole_diameter_in/2);
circular_voids_cm = circular_voids_in*cm_per_in;

%% Closed-form center of gravity and inertias
plate_results = analytical_extruded_plate(solid_polygons, void_polygons, ...
    circular_voids_cm, thickness_cm, mass_kg);

info.name = 'Plate 2 - Offset Rectangular Frame';
info.source = 'Plate_measurements.pdf page 4';
info.geometry_note = sprintf(['Opening = %.1f by %.1f cm, located from the ' ...
    'measured left/bottom margins.'],opening_width_cm,opening_height_cm);
info.holes_note = sprintf(['Included: %d evenly spaced perimeter holes. ' ...
    'Diameter %.3f in is carried from Plate 1; centers use the user-directed ' ...
    'nominal %.3f in edge offset.'],size(circular_voids_in,1), ...
    hole_diameter_in,hole_edge_offset_in);

report_file = fullfile(output_dir,'plate02_offset_rectangular_frame_results.txt');
write_plate_report(plate_results,info,report_file);
data_file = fullfile(output_dir,'plate02_offset_rectangular_frame_results.mat');
save(data_file,'plate_results','info','outer_cm','opening_cm', ...
    'circular_voids_cm');

%% Dimensioned analytical figure
outer_in = outer_cm/cm_per_in;
opening_in = opening_cm/cm_per_in;
solid_polygons_in = {outer_in};
void_polygons_in = {opening_in};
outer_width_in = outer_width_cm/cm_per_in;
outer_height_in = outer_height_cm/cm_per_in;
left_margin_in = left_margin_cm/cm_per_in;
right_margin_in = right_margin_cm/cm_per_in;
top_margin_in = top_margin_cm/cm_per_in;
bottom_margin_in = bottom_margin_cm/cm_per_in;
opening_width_in = opening_width_cm/cm_per_in;
opening_height_in = opening_height_cm/cm_per_in;

title_lines = { ...
    'Plate 2 - Offset Rectangular Frame', ...
    sprintf(['Analytical footprint | m = %.3f kg ' ...
    '(W = %.3f lbf at standard g) | t = %.3f in'], ...
    mass_kg,plate_results.weight_lbf_standard_g,thickness_in), ...
    sprintf('%d x dia %.3f in holes | nominal center offset %.3f in', ...
    size(circular_voids_in,1),hole_diameter_in,hole_edge_offset_in)};
[fig,ax] = draw_plate_footprint(solid_polygons_in,void_polygons_in, ...
    plate_results,title_lines,[-8.0,69.0,-5.5,36.5]/cm_per_in,'in', ...
    circular_voids_in);

dimension_color = [0.08,0.28,0.62];
draw_linear_dimension(ax,[0,outer_height_in], ...
    [outer_width_in,outer_height_in],3.1/cm_per_in, ...
    sprintf('%.3f in overall',outer_width_in),dimension_color);
draw_linear_dimension(ax,[outer_width_in,0], ...
    [outer_width_in,outer_height_in],-3.4/cm_per_in, ...
    sprintf('%.3f in overall',outer_height_in),dimension_color);

y_mid_opening = bottom_margin_in + opening_height_in/2;
x_mid_opening = left_margin_in + opening_width_in/2;
draw_linear_dimension(ax,[0,y_mid_opening], ...
    [left_margin_in,y_mid_opening],0, ...
    sprintf('%.3f in left',left_margin_in),dimension_color);
draw_linear_dimension(ax,[left_margin_in+opening_width_in,y_mid_opening], ...
    [outer_width_in,y_mid_opening],0, ...
    sprintf('%.3f in right',right_margin_in),dimension_color);
draw_linear_dimension(ax,[x_mid_opening,0], ...
    [x_mid_opening,bottom_margin_in],0, ...
    sprintf('%.3f in bottom',bottom_margin_in),dimension_color);
draw_linear_dimension(ax,[x_mid_opening,bottom_margin_in+opening_height_in], ...
    [x_mid_opening,outer_height_in],0, ...
    sprintf('%.3f in top',top_margin_in),dimension_color);

text(ax,x_mid_opening,y_mid_opening, ...
    sprintf('OPENING\n%.3f x %.3f in',opening_width_in,opening_height_in), ...
    'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'FontWeight','bold','Color',[0.20,0.20,0.20], ...
    'BackgroundColor','white','Margin',2);

figure_file = fullfile(output_dir,'plate02_offset_rectangular_frame_geometry.png');
exportgraphics(fig,figure_file,'Resolution',300);
fprintf('Saved dimensioned figure: %s\n',figure_file);
fprintf('Saved text results:      %s\n',report_file);
fprintf('Saved MATLAB results:    %s\n',data_file);
