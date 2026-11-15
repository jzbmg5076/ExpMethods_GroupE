function results = analytical_extruded_plate(solid_polygons, void_polygons, ...
    circular_voids_cm, thickness_cm, mass_kg)
%ANALYTICAL_EXTRUDED_PLATE Exact mass properties of a uniform extruded plate.
%
% results = analytical_extruded_plate(solid_polygons, void_polygons,
%     circular_voids_cm, thickness_cm, mass_kg)
%
% Inputs
%   solid_polygons     Cell array of N-by-2 [x y] vertex arrays [cm].
%   void_polygons      Cell array of N-by-2 through-cutout arrays [cm].
%   circular_voids_cm  N-by-3 array [x_center y_center radius] [cm].
%   thickness_cm       Uniform extrusion thickness [cm].
%   mass_kg            Assumed mass of the finished plate [kg].
%
% Coordinate convention
%   x and y lie in the drawing plane. z is through the thickness and the
%   z=0 plane is the bottom face. All returned inertias are about the CG.
%
% Method
%   Exact closed-form polygon area integrals are combined with signed-area
%   subtraction for through-cutouts. Circular holes, when fully located,
%   are also subtracted analytically. The supplied finished mass fixes the
%   uniform areal/volume density. No experimental oscillation data enter.

validateattributes(thickness_cm, {'numeric'}, ...
    {'scalar','real','finite','positive'}, mfilename, 'thickness_cm');
validateattributes(mass_kg, {'numeric'}, ...
    {'scalar','real','finite','positive'}, mfilename, 'mass_kg');

if ~iscell(solid_polygons) || isempty(solid_polygons)
    error('solid_polygons must be a nonempty cell array of vertex arrays.');
end
if ~iscell(void_polygons)
    error('void_polygons must be a cell array (use {} when there are none).');
end
if isempty(circular_voids_cm)
    circular_voids_cm = zeros(0,3);
end
validateattributes(circular_voids_cm, {'numeric'}, ...
    {'2d','real','finite','ncols',3}, mfilename, 'circular_voids_cm');
if any(circular_voids_cm(:,3) <= 0)
    error('Every circular-void radius must be positive.');
end

% Raw planform quantities about the drawing origin:
% [A, integral(x dA), integral(y dA), integral(y^2 dA),
%  integral(x^2 dA), integral(x*y dA)].
raw = zeros(1,6);

for k = 1:numel(solid_polygons)
    raw = raw + polygon_raw_moments(solid_polygons{k});
end

for k = 1:numel(void_polygons)
    raw = raw - polygon_raw_moments(void_polygons{k});
end

for k = 1:size(circular_voids_cm,1)
    xc = circular_voids_cm(k,1);
    yc = circular_voids_cm(k,2);
    r = circular_voids_cm(k,3);
    A = pi*r^2;
    Icentroid = pi*r^4/4;
    circle_raw = [A, A*xc, A*yc, ...
        Icentroid + A*yc^2, Icentroid + A*xc^2, A*xc*yc];
    raw = raw - circle_raw;
end

A_net = raw(1);
if ~(isfinite(A_net) && A_net > 0)
    error('The signed geometry must leave a positive net planform area.');
end

x_cg = raw(2)/A_net;
y_cg = raw(3)/A_net;

Ixx_area_cg = raw(4) - A_net*y_cg^2;
Iyy_area_cg = raw(5) - A_net*x_cg^2;
Ixy_area_cg = raw(6) - A_net*x_cg*y_cg;

if Ixx_area_cg <= 0 || Iyy_area_cg <= 0
    error('The resulting centroidal area moments must be positive.');
end

areal_density = mass_kg/A_net;                   % [kg/cm^2]
volume_density = mass_kg/(A_net*thickness_cm);   % [kg/cm^3]

% Inertia-tensor off-diagonal terms use -integral(x*y dm).
J_thin = [areal_density*Ixx_area_cg, -areal_density*Ixy_area_cg, 0; ...
         -areal_density*Ixy_area_cg,  areal_density*Iyy_area_cg, 0; ...
          0,                           0, ...
          areal_density*(Ixx_area_cg + Iyy_area_cg)];

% A uniform extrusion adds integral(z_cg^2 dm) = m*t^2/12 to the two
% in-plane-axis inertias. It does not change Izz.
J_prism = J_thin;
J_prism(1,1) = J_prism(1,1) + mass_kg*thickness_cm^2/12;
J_prism(2,2) = J_prism(2,2) + mass_kg*thickness_cm^2/12;

J_thin = (J_thin + J_thin.')/2;
J_prism = (J_prism + J_prism.')/2;

[principal_thin, axes_thin] = principal_system(J_thin);
[principal_prism, axes_prism] = principal_system(J_prism);

kgcm2_to_lbmin2 = 2.2046226218487757*(1/2.54)^2;

checks.tensor_symmetry_error = norm(J_prism - J_prism.', 'fro');
checks.axes_orthogonality_error = norm(axes_prism*axes_prism.' - eye(3), 'fro');
checks.axes_determinant = det(axes_prism);
checks.thin_perpendicular_axis_error = abs(J_thin(3,3) ...
    - J_thin(1,1) - J_thin(2,2));
checks.prism_extrusion_identity_error = abs(J_prism(3,3) ...
    - J_prism(1,1) - J_prism(2,2) + mass_kg*thickness_cm^2/6);
checks.positive_principal_moments = all(principal_prism > 0);
checks.pass = checks.tensor_symmetry_error < 1e-10 && ...
    checks.axes_orthogonality_error < 1e-10 && ...
    abs(checks.axes_determinant - 1) < 1e-10 && ...
    checks.thin_perpendicular_axis_error < 1e-9 && ...
    checks.prism_extrusion_identity_error < 1e-9 && ...
    checks.positive_principal_moments;

results.mass_kg = mass_kg;
results.weight_N_standard_g = mass_kg*9.80665;
results.weight_lbf_standard_g = mass_kg*2.2046226218487757;
results.thickness_cm = thickness_cm;
results.thickness_in = thickness_cm/2.54;
results.area_cm2 = A_net;
results.volume_cm3 = A_net*thickness_cm;
results.areal_density_kg_cm2 = areal_density;
results.volume_density_kg_cm3 = volume_density;
results.CG_cm = [x_cg, y_cg, thickness_cm/2];
results.CG_in = results.CG_cm/2.54;
results.I_tensor_thin_kg_cm2 = J_thin;
results.I_tensor_prism_kg_cm2 = J_prism;
results.I_tensor_thin_lbm_in2 = J_thin*kgcm2_to_lbmin2;
results.I_tensor_prism_lbm_in2 = J_prism*kgcm2_to_lbmin2;
results.I_principal_thin_kg_cm2 = principal_thin;
results.I_principal_prism_kg_cm2 = principal_prism;
results.I_principal_thin_lbm_in2 = principal_thin*kgcm2_to_lbmin2;
results.I_principal_prism_lbm_in2 = principal_prism*kgcm2_to_lbmin2;
results.principal_axes_thin_rows = axes_thin;
results.principal_axes_prism_rows = axes_prism;
results.thin_to_prism_percent_difference = ...
    abs(principal_prism - principal_thin)./principal_prism*100;
results.raw_planform_integrals = raw;
results.centroidal_area_moments_cm4 = ...
    [Ixx_area_cg, Iyy_area_cg, Ixy_area_cg];
results.checks = checks;
end

function raw = polygon_raw_moments(vertices)
% Return positive-orientation raw moments for one simple polygon.
validateattributes(vertices, {'numeric'}, ...
    {'2d','real','finite','ncols',2}, mfilename, 'polygon vertices');

if size(vertices,1) >= 2 && all(vertices(1,:) == vertices(end,:))
    vertices(end,:) = [];
end
if size(vertices,1) < 3
    error('Each polygon must contain at least three distinct vertices.');
end

x = vertices(:,1);
y = vertices(:,2);
xn = x([2:end,1]);
yn = y([2:end,1]);
cross_term = x.*yn - xn.*y;

A = 0.5*sum(cross_term);
Qx = (1/6)*sum((x + xn).*cross_term);
Qy = (1/6)*sum((y + yn).*cross_term);
Ixx = (1/12)*sum((y.^2 + y.*yn + yn.^2).*cross_term);
Iyy = (1/12)*sum((x.^2 + x.*xn + xn.^2).*cross_term);
Ixy = (1/24)*sum((2*x.*y + x.*yn + xn.*y + 2*xn.*yn) ...
    .*cross_term);

if abs(A) < 100*eps(max(1,max(abs(vertices),[],'all')^2))
    error('A polygon has zero or numerically negligible area.');
end
if A < 0
    A = -A;
    Qx = -Qx;
    Qy = -Qy;
    Ixx = -Ixx;
    Iyy = -Iyy;
    Ixy = -Ixy;
end

raw = [A, Qx, Qy, Ixx, Iyy, Ixy];
end

function [principal_moments, axes_rows] = principal_system(J)
% Return sorted moments and deterministic right-handed axis rows.
[V,D] = eig(J);
[principal_moments, order] = sort(diag(D), 'ascend');
V = V(:,order);

% Eigenvector signs are arbitrary. Select repeatable signs, then enforce a
% right-handed triad. Flipping an eigenvector does not change its axis.
for k = 1:3
    [~, idx] = max(abs(V(:,k)));
    if V(idx,k) < 0
        V(:,k) = -V(:,k);
    end
end
if det(V) < 0
    V(:,1) = -V(:,1);
end

axes_rows = V.';
end
