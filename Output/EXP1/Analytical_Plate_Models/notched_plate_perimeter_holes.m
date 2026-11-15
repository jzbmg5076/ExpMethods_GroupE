function holes = notched_plate_perimeter_holes(width, overall_height, ...
    left_lower_run, y_left_bottom, x_step, step_height, ...
    edge_offset, radius)
%NOTCHED_PLATE_PERIMETER_HOLES Approximate the 16 visible Plate-1 holes.
%   Output rows are [x_center, y_center, radius]. The pattern follows the
%   photograph while using the requested nominal center-to-edge offset.
%   All inputs and outputs use the same length unit.

top_x = linspace(edge_offset,width-edge_offset,5).';
top = [top_x, repmat(overall_height-edge_offset,5,1)];

right_y = linspace(edge_offset,overall_height-edge_offset,5).';
right_without_top = [repmat(width-edge_offset,4,1), right_y(1:4)];

left_bottom_x = linspace(edge_offset,left_lower_run-edge_offset,3).';
left_bottom = [left_bottom_x, ...
    repmat(y_left_bottom+edge_offset,3,1)];

% One hole follows the photographed sloping segment. Offset its center
% inward (toward the material) by edge_offset along the segment normal.
slope_start = [left_lower_run,y_left_bottom];
slope_end = [x_step,step_height];
slope_vector = slope_end-slope_start;
inward_normal = [-slope_vector(2),slope_vector(1)];
inward_normal = inward_normal/norm(inward_normal);
slope_center = slope_start + 0.82*slope_vector + ...
    edge_offset*inward_normal;

step_center = [x_step+edge_offset,step_height/2];
bottom_center = [(x_step+width)/2,edge_offset];
left_center = [edge_offset,(y_left_bottom+overall_height)/2];

centers = [top; right_without_top; left_bottom; slope_center; ...
    step_center; bottom_center; left_center];
holes = [centers, repmat(radius,size(centers,1),1)];

if size(holes,1) ~= 16
    error('The Plate-1 approximation must contain exactly 16 holes.');
end
end
