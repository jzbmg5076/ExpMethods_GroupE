%% Rectangular Frame Plate Moment of Inertia Models
% Experiment 1 - Moments of Inertia
%
% Analytical model of the measured plate shown in Plate_measurements.pdf.
% The plate is modeled as a uniform outer rectangular prism with an offset
% rectangular opening removed. The small circular perimeter holes are not
% included because their center coordinates are not dimensioned.
%
% Coordinate system:
%   x: along the 60.7 cm outer length, positive to the right
%   y: along the 30.5 cm outer height, positive upward
%   z: through the thickness
%   origin: lower-left-bottom corner of the outer rectangle
%
% Calculations use lbm and inches so inertia is reported in lbm*in^2.

clear; clc;

%% Measured inputs
% The mass below is carried over from the supplied plate measurement.
% Replace it if this frame plate has a different measured mass.
m_total_kg = 9.99816;               % measured net plate mass [kg]
m_total = m_total_kg *1; %2.20462262185; % [lbm]

cm_to_in = 1 / 2.54;

L_outer = 60.7 * cm_to_in; % outer x dimension [in]
W_outer = 30.5 * cm_to_in; % outer y dimension [in]

margin_left   = 17.4 * cm_to_in; % [in]
margin_right  =  7.7 * cm_to_in; % [in]
margin_top    =  5.0 * cm_to_in; % [in]
margin_bottom = 10.1 * cm_to_in; % [in]

% The PDF annotation reads 0.5 in. If the intended measurement was 0.5 cm,
% change this line to: thickness = 0.5 * cm_to_in;
thickness = 0.5; % [in]

L_opening = L_outer - margin_left - margin_right;
W_opening = W_outer - margin_top - margin_bottom;

%% Input and geometry checks
values = [m_total, L_outer, W_outer, thickness, margin_left, ...
          margin_right, margin_top, margin_bottom, L_opening, W_opening];

if any(~isfinite(values)) || any(values <= 0)
    error('Mass, dimensions, thickness, and margins must be positive.');
end

if abs(margin_left + L_opening + margin_right - L_outer) > 1e-10 || ...
   abs(margin_bottom + W_opening + margin_top - W_outer) > 1e-10
    error('Opening dimensions and margins do not close to the outer dimensions.');
end

%% Component volumes, effective density, and masses
% The effective density makes the analytical geometry reproduce the measured
% net mass. This avoids assuming a library material density.
V_outer = L_outer * W_outer * thickness;
V_opening = L_opening * W_opening * thickness;
V_net = V_outer - V_opening;

rho_effective = m_total / V_net; % [lbm/in^3]
m_outer = rho_effective * V_outer;
m_opening = rho_effective * V_opening;

%% Component centroids and net center of gravity
r_outer = [L_outer/2, W_outer/2, thickness/2];
r_opening = [margin_left + L_opening/2, ...
             margin_bottom + W_opening/2, ...
             thickness/2];

r_CG = (m_outer*r_outer - m_opening*r_opening) / m_total;

%% Centroidal tensors for the two analytical models
% Thin model: thickness is neglected only in the centroidal inertia terms.
J_outer_thin = diag([m_outer/12 * W_outer^2, ...
                     m_outer/12 * L_outer^2, ...
                     m_outer/12 * (L_outer^2 + W_outer^2)]);

J_opening_thin = diag([m_opening/12 * W_opening^2, ...
                       m_opening/12 * L_opening^2, ...
                       m_opening/12 * (L_opening^2 + W_opening^2)]);

% Prism model: measured thickness is included.
J_outer_prism = diag([m_outer/12 * (W_outer^2 + thickness^2), ...
                      m_outer/12 * (L_outer^2 + thickness^2), ...
                      m_outer/12 * (L_outer^2 + W_outer^2)]);

J_opening_prism = diag([m_opening/12 * (W_opening^2 + thickness^2), ...
                        m_opening/12 * (L_opening^2 + thickness^2), ...
                        m_opening/12 * (L_opening^2 + W_opening^2)]);

%% Shift component tensors to the net CG and subtract the opening
d_outer = r_outer - r_CG;
d_opening = r_opening - r_CG;

P_outer = (d_outer*d_outer')*eye(3) - d_outer'*d_outer;
P_opening = (d_opening*d_opening')*eye(3) - d_opening'*d_opening;

J_thin = J_outer_thin + m_outer*P_outer ...
         - (J_opening_thin + m_opening*P_opening);

J_prism = J_outer_prism + m_outer*P_outer ...
          - (J_opening_prism + m_opening*P_opening);

% Remove insignificant numerical asymmetry before the eigenvalue solution.
J_thin = (J_thin + J_thin') / 2;
J_prism = (J_prism + J_prism') / 2;

%% Principal moments and principal-axis directions
% MATLAB returns eigenvectors as columns. They are transposed below so each
% row of principal_axes is one right-hand-rule unit vector, matching the
% format of rectangular_plate_moi_models.m.
[V_thin, D_thin] = eig(J_thin);
[I_principal_thin, order_thin] = sort(diag(D_thin));
principal_axes_thin = V_thin(:,order_thin)';

[V_prism, D_prism] = eig(J_prism);
[I_principal_prism, order_prism] = sort(diag(D_prism));
principal_axes_prism = V_prism(:,order_prism)';

percent_difference = abs(I_principal_prism - I_principal_thin) ...
                     ./ I_principal_prism * 100;

%% Display results
fprintf('\nOffset Rectangular Frame Analytical MOI Results\n');
fprintf('------------------------------------------------\n');
fprintf('Mass: %.6f kg = %.6f lbm\n', m_total_kg, m_total);
fprintf('Outer dimensions [L W t]: [%.6f  %.6f  %.6f] in\n', ...
        L_outer, W_outer, thickness);
fprintf('Opening dimensions [L W]: [%.6f  %.6f] in\n', ...
        L_opening, W_opening);
fprintf('Effective density: %.6f lbm/in^3\n', rho_effective);
fprintf('CG from lower-left-bottom outer corner [x y z]:\n');
fprintf('[%.6f  %.6f  %.6f] in\n\n', r_CG);

fprintf('Inertia tensor about CG, rectangular-prism model [lbm*in^2]:\n');
disp(J_prism)

principal_results = table(I_principal_thin, I_principal_prism, ...
    percent_difference, ...
    'VariableNames', {'Thin_plate', 'Rectangular_prism', 'Percent_difference'}, ...
    'RowNames', {'I1', 'I2', 'I3'});
fprintf('Principal moments of inertia [lbm*in^2]:\n');
disp(principal_results)

fprintf('Prism-model principal-axis unit vectors (one axis per row):\n');
disp(principal_axes_prism)

%% Save useful variables for comparison with NX and experiments
results = struct();
results.mass_kg = m_total_kg;
results.mass_lbm = m_total;
results.outer_dimensions_in = [L_outer, W_outer, thickness];
results.opening_dimensions_in = [L_opening, W_opening, thickness];
results.opening_lower_left_in = [margin_left, margin_bottom, 0];
results.reference_origin_in = [0, 0, 0];
results.CG_in = r_CG;
results.effective_density_lbm_in3 = rho_effective;
results.I_tensor_thin_lbm_in2 = J_thin;
results.I_tensor_prism_lbm_in2 = J_prism;
results.I_principal_thin_lbm_in2 = I_principal_thin;
results.I_principal_prism_lbm_in2 = I_principal_prism;
results.principal_axes_thin = principal_axes_thin;
results.principal_axes_prism = principal_axes_prism;
results.percent_difference = percent_difference;
results.small_perimeter_holes_included = false;

