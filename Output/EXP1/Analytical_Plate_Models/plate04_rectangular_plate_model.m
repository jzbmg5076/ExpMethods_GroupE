%% Plate 4 - Rectangular Plate Analytical Model
% Exact rectangular-prism minus circular-hole area integrals.
% Dimensions and mass were supplied by the user; the 12-hole arrangement
% follows the rectangular plate visible in the EXP1 lab photographs.

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

%% User-provided inputs [in, kg]
length_in = 12.900;
width_in = 5.900;
thickness_in = 0.450;
mass_kg = 1.687;
hole_diameter_in = 0.180;
hole_edge_offset_in = 0.250;
cm_per_in = 2.54;

outer_in = [0,0; length_in,0; length_in,width_in; 0,width_in];

% Five holes are used on each long edge and one additional midpoint hole
% is used on each short edge. Corner holes are counted only once: 12 total.
circular_voids_in = rectangular_perimeter_holes(length_in,width_in,5,3, ...
    hole_edge_offset_in,hole_diameter_in/2);

outer_cm = outer_in*cm_per_in;
circular_voids_cm = circular_voids_in*cm_per_in;
thickness_cm = thickness_in*cm_per_in;
solid_polygons = {outer_cm};
void_polygons = {};

%% Closed-form center of gravity and inertias
plate_results = analytical_extruded_plate(solid_polygons,void_polygons, ...
    circular_voids_cm,thickness_cm,mass_kg);

info.name = 'Plate 4 - Rectangular Plate';
info.source = ['User dimensions plus the rectangular plate shown in ' ...
    'EXP1/Lab/LabData photographs'];
info.geometry_note = sprintf(['Uniform %.3f by %.3f by %.3f in rectangular ' ...
    'prism with all circular holes treated as through-holes.'], ...
    length_in,width_in,thickness_in);
info.holes_note = sprintf(['Included: %d through-holes, diameter %.3f in. ' ...
    'Five centers lie along each long edge and one additional center lies ' ...
    'at the midpoint of each short edge; nominal edge offset is %.3f in.'], ...
    size(circular_voids_in,1),hole_diameter_in,hole_edge_offset_in);

report_file = fullfile(output_dir,'plate04_rectangular_plate_results.txt');
write_plate_report(plate_results,info,report_file);
data_file = fullfile(output_dir,'plate04_rectangular_plate_results.mat');
save(data_file,'plate_results','info','outer_in','circular_voids_in');

%% Dimensioned analytical figure (all displayed lengths are inches)
title_lines = { ...
    'Plate 4 - Rectangular Plate', ...
    sprintf(['Analytical footprint | m = %.3f kg ' ...
    '(W = %.3f lbf at standard g) | t = %.3f in'], ...
    mass_kg,plate_results.weight_lbf_standard_g,thickness_in), ...
    sprintf('%d x dia %.3f in holes | nominal center offset %.3f in', ...
    size(circular_voids_in,1),hole_diameter_in,hole_edge_offset_in)};

[fig,ax] = draw_plate_footprint({outer_in},{},plate_results,title_lines, ...
    [-1.8,14.4,-1.4,7.2],'in',circular_voids_in);

dimension_color = [0.08,0.28,0.62];
draw_linear_dimension(ax,[0,width_in],[length_in,width_in],0.65, ...
    sprintf('%.3f in length',length_in),dimension_color);
draw_linear_dimension(ax,[length_in,0],[length_in,width_in],-0.75, ...
    sprintf('%.3f in width',width_in),dimension_color);

text(ax,3.15,4.25, ...
    sprintf('RECTANGULAR PLATE\n%.3f x %.3f x %.3f in', ...
    length_in,width_in,thickness_in), ...
    'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'FontWeight','bold','Color',[0.20,0.20,0.20], ...
    'BackgroundColor','white','Margin',2);
text(ax,length_in/2,0.55, ...
    sprintf('hole centers: %.3f in from outer edges',hole_edge_offset_in), ...
    'HorizontalAlignment','center','FontSize',9, ...
    'Color',[0.25,0.25,0.25],'BackgroundColor','white','Margin',1);

figure_file = fullfile(output_dir,'plate04_rectangular_plate_geometry.png');
exportgraphics(fig,figure_file,'Resolution',300);
fprintf('Saved dimensioned figure: %s\n',figure_file);
fprintf('Saved text results:      %s\n',report_file);
fprintf('Saved MATLAB results:    %s\n',data_file);
