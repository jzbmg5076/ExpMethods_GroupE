function holes = rectangular_perimeter_holes(width, height, nx, ny, ...
    edge_offset, radius)
%RECTANGULAR_PERIMETER_HOLES Evenly spaced circular holes around a rectangle.
%   Output rows are [x_center, y_center, radius]. The four corner holes are
%   counted once. All inputs and outputs use the same length unit.

validateattributes(width,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(height,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(nx,{'numeric'},{'scalar','integer','>=',2});
validateattributes(ny,{'numeric'},{'scalar','integer','>=',2});
validateattributes(edge_offset,{'numeric'}, ...
    {'scalar','real','finite','positive'});
validateattributes(radius,{'numeric'},{'scalar','real','finite','positive'});

if edge_offset <= radius
    error('edge_offset must exceed radius so each hole remains inside the edge.');
end
if 2*edge_offset >= width || 2*edge_offset >= height
    error('edge_offset is too large for the requested rectangle.');
end

x = linspace(edge_offset,width-edge_offset,nx).';
y = linspace(edge_offset,height-edge_offset,ny).';

bottom = [x, repmat(edge_offset,nx,1)];
top = [x, repmat(height-edge_offset,nx,1)];
if ny > 2
    side_y = y(2:end-1);
    left = [repmat(edge_offset,ny-2,1), side_y];
    right = [repmat(width-edge_offset,ny-2,1), side_y];
else
    left = zeros(0,2);
    right = zeros(0,2);
end

centers = [bottom; top; left; right];
holes = [centers, repmat(radius,size(centers,1),1)];
end
