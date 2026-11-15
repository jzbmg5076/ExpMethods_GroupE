%% Verification Checks for the Analytical Plate Property Engine
% This script uses closed-form identities only. It does not load lab data.

clc;
script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
    script_dir = pwd;
end
addpath(script_dir);

tol = 2e-10;

%% Check 1: rectangular-prism formula used by the pre-lab convention
w = 14.8;
h = 5.9;
t = 0.67;
m = 3.4;
rectangle = [0,0; w,0; w,h; 0,h];
R = analytical_extruded_plate({rectangle},{},zeros(0,3),t,m);
expected = diag([m*(h^2+t^2)/12, ...
                 m*(w^2+t^2)/12, ...
                 m*(w^2+h^2)/12]);
assert(max(abs(R.I_tensor_prism_kg_cm2-expected),[],'all') < tol, ...
    'Rectangular-prism closed-form check failed.');

%% Check 2: translation and polygon-order invariance
shift = [7.2,-3.1];
shifted_reversed = flipud(rectangle + shift);
R_shift = analytical_extruded_plate({shifted_reversed},{},zeros(0,3),t,m);
assert(max(abs(R_shift.I_tensor_prism_kg_cm2-expected),[],'all') < tol, ...
    'Translation/orientation invariance check failed.');
assert(norm(R_shift.CG_cm(1:2) - (R.CG_cm(1:2)+shift)) < tol, ...
    'Translated centroid check failed.');

%% Check 3: source-geometry and circular-hole regression values
hole_diameter_in = 0.184;
edge_offset_in = 0.250;
hole_radius_cm = (hole_diameter_in/2)*2.54;

% Plate 1
P1 = [0,6.6; 17.5,6.6; 27.9,3.6; 27.9,0; ...
      40.2,0; 40.2,19.9; 0,19.9];
P1holes_in = notched_plate_perimeter_holes(40.2/2.54,19.9/2.54, ...
    17.5/2.54,6.6/2.54,27.9/2.54,3.6/2.54, ...
    edge_offset_in,hole_diameter_in/2);
P1holes_cm = P1holes_in*2.54;
R1 = analytical_extruded_plate({P1},{},P1holes_cm,0.75*2.54,1);
assert(size(P1holes_cm,1) == 16);
assert(abs(R1.area_cm2-(631.44-16*pi*hole_radius_cm^2)) < tol);

% Plate 2
P2o = [0,0; 60.7,0; 60.7,30.5; 0,30.5];
P2v = [17.4,10.1; 53.0,10.1; 53.0,25.5; 17.4,25.5];
P2holes_in = rectangular_perimeter_holes(60.7/2.54,30.5/2.54, ...
    5,5,edge_offset_in,hole_diameter_in/2);
P2holes_cm = P2holes_in*2.54;
R2 = analytical_extruded_plate({P2o},{P2v},P2holes_cm,0.5*2.54,1);
assert(size(P2holes_cm,1) == 16);
assert(abs(R2.area_cm2-(1303.11-16*pi*hole_radius_cm^2)) < tol);

% Plate 3
P3o = [0,0; 61.1,0; 61.1,30.4; 0,30.4];
P3v = [8.6,7.6; 20.9,4.4; 21.8,8.1; 32.3,8.1; ...
       52.1,2.7; 55.5,16.1; 13.7,27.2];
P3holes_in = rectangular_perimeter_holes(61.1/2.54,30.4/2.54, ...
    5,5,edge_offset_in,hole_diameter_in/2);
P3holes_cm = P3holes_in*2.54;
R3 = analytical_extruded_plate({P3o},{P3v},P3holes_cm,0.5*2.54,1);
assert(size(P3holes_cm,1) == 16);
assert(abs(R3.area_cm2-(1167.085-16*pi*hole_radius_cm^2)) < tol);

%% Check 4: new symmetric rectangular plate with 12 circular holes
L4 = 12.9*2.54;
W4 = 5.9*2.54;
t4 = 0.45*2.54;
m4 = 1.687;
r4 = (0.18/2)*2.54;
P4 = [0,0; L4,0; L4,W4; 0,W4];
P4holes = rectangular_perimeter_holes(L4,W4,5,3, ...
    0.25*2.54,r4);
R4 = analytical_extruded_plate({P4},{},P4holes,t4,m4);
A4 = L4*W4-size(P4holes,1)*pi*r4^2;
assert(size(P4holes,1) == 12);
assert(abs(R4.area_cm2-A4) < tol);
assert(norm(R4.CG_cm-[L4/2,W4/2,t4/2]) < 1e-10);

circle_area4 = pi*r4^2;
circle_Ic4 = pi*r4^4/4;
Ixx_area4 = L4*W4^3/12-sum(circle_Ic4 + ...
    circle_area4*(P4holes(:,2)-W4/2).^2);
Iyy_area4 = W4*L4^3/12-sum(circle_Ic4 + ...
    circle_area4*(P4holes(:,1)-L4/2).^2);
expected4 = [m4*Ixx_area4/A4+m4*t4^2/12, ...
             m4*Iyy_area4/A4+m4*t4^2/12, ...
             m4*(Ixx_area4+Iyy_area4)/A4];
assert(norm(diag(R4.I_tensor_prism_kg_cm2).'-expected4) < 1e-9);
assert(abs(R4.I_tensor_prism_kg_cm2(1,2)) < 1e-10);

all_results = {R1,R2,R3,R4};
for k = 1:numel(all_results)
    assert(all_results{k}.checks.pass, ...
        'Internal analytical check failed for source plate %d.',k);
end

fprintf('\nAll analytical plate-model checks PASSED.\n');
fprintf('  Rectangle closed form: PASS\n');
fprintf('  Translation/orientation invariance: PASS\n');
fprintf('  Three PDF geometries with circular holes: PASS\n');
fprintf('  New 12-hole rectangular-plate closed form: PASS\n');
fprintf('  Tensor symmetry, positive moments, and axis orthogonality: PASS\n');
