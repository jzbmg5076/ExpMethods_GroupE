%% Rectangular Plate Moment of Inertia Models
% Experiment 1 - Moments of Inertia
%
% This script compares two analytical models of a uniform rectangular plate:
%   1. Thin plate: thickness is neglected in Ixx and Iyy.
%   2. Rectangular prism: measured thickness is included.
%
% Coordinate convention from the Experiment 1 pre-lab figure:
%   - x is along the plate length (b)
%   - y is along the plate width  (a)
%   - z is through the plate thickness (t)
%   - The reference origin is fixed at the plate corner at x-minimum,
%     y-minimum, and z-minimum: r_origin = [0 0 0] in.
%
% Use mass in lbm and all dimensions in inches. The resulting moments of
% inertia are in lbm*in^2. Do not enter weight in lbf as the mass input.

clear; clc;

%% Inputs - replace these example values with measurements from the lab
m = 1.687 * 2.20462262185;  % Plate mass [lbm], measured with scale (not weight in lbf)
a = 5.9;  % Plate width in y direction [in]
b = 12.9;  % Plate length in x direction [in]
t = 0.5; % Plate thickness in z direction [in]

%% Input checks
if ~isscalar(m) || ~isscalar(a) || ~isscalar(b) || ~isscalar(t) || ...
        any(~isfinite([m, a, b, t])) || any([m, a, b, t] <= 0)
    error('Mass and all three dimensions must be positive scalar values.');
end

% A fixed corner origin is sufficient for this individual rectangular plate.
% A shared assembly origin can be introduced later for the two-plate model.
r_origin = [0, 0, 0];  % [in]

%% Center of gravity and principal-axis directions
% Although the thin-plate inertia calculation neglects thickness, this uses
% the physical plate's mid-plane so both models report CG in the same frame.
%m = m/350;
r_CG = r_origin + [b/2, a/2, t/2];
principal_axes = eye(3);  % Rows are unit vectors for x, y, and z axes

%% Analytical moment-of-inertia models about the CG
% Thin-plate model: t is treated as zero only in the inertia equations.
I_thin = [m/12 * a^2, ...
          m/12 * b^2, ...
          m/12 * (a^2 + b^2)];

% Rectangular-prism model: use all measured dimensions.
I_prism = [m/12 * (a^2 + t^2), ...
           m/12 * (b^2 + t^2), ...
           m/12 * (a^2 + b^2)];

% In this plate-aligned coordinate system, the inertia tensors are diagonal.
I_tensor_thin = diag(I_thin);
I_tensor_prism = diag(I_prism);

%% Compare the model choices
percent_difference = abs(I_prism - I_thin) ./ I_prism * 100;

%% Display results
fprintf('\nRectangular Plate Analytical MOI Results\n');
fprintf('----------------------------------------\n');
fprintf('Units: mass in lbm; length in in; MOI in lbm*in^2\n');
fprintf('Fixed corner origin [x y z] [in]: [%g  %g  %g]\n', r_origin);
fprintf('CG location [x y z] [in]:          [%g  %g  %g]\n\n', r_CG);

results_table = table( ...
    [I_thin(1); I_prism(1)], ...
    [I_thin(2); I_prism(2)], ...
    [I_thin(3); I_prism(3)], ...
    'VariableNames', {'Ixx', 'Iyy', 'Izz'}, ...
    'RowNames', {'Thin_plate', 'Rectangular_prism'});
disp(results_table)

comparison_table = table( ...
    percent_difference(1), percent_difference(2), percent_difference(3), ...
    'VariableNames', {'Ixx_percent', 'Iyy_percent', 'Izz_percent'});
fprintf('Absolute percent difference: thin plate versus rectangular prism\n');
disp(comparison_table)

fprintf('Principal-axis unit vectors (rows correspond to x, y, z):\n');
disp(principal_axes)

%% Save useful variables for later comparisons with NX and experimental data
results = struct();
results.mass = m;
results.dimensions = [a, b, t];
results.reference_origin = r_origin;
results.CG = r_CG;
results.principal_axes = principal_axes;
results.I_thin = I_thin;
results.I_prism = I_prism;
results.I_tensor_thin = I_tensor_thin;
results.I_tensor_prism = I_tensor_prism;
results.percent_difference = percent_difference;

% Interpretation hint:
% If the thin-vs-prism difference is much smaller than the uncertainty in
% your experimental MOI estimate, the thin-plate approximation is likely
% adequate. State and justify that decision in the report.
