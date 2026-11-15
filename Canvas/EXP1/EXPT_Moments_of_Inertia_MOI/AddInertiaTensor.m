% Add Inertia Tensors
% Combine two MOI bodies into one MOI
clc

% Body #1
% coordinates in local body 1

mass_1 = 4.4; % lbm

CGx_1  = 7.25; % inch
CGy_1  = 3.00; % inch
CGz_1  = 0.25; % inch

Jxx_1  = 13.26; % lbm in^2
Jyy_1  = 77.02; % lbm in^2
Jzz_1  = 90.10; % lbm in^2

PAx_1  = [1.0, 0.0, 0.0]; % enter as righthand rule unit vectors
PAy_1  = [0.0, 1.0, 0.0]; %
PAz_1  = [0.0, 0.0, 1.0]; %


% Body #2
% coordinates in local body 2

mass_2 = 4.4; % lbm

CGx_2  = 7.25; % inch
CGy_2  = 3.00; % inch
CGz_2  = 0.25; % inch

Jxx_2  = 13.26; % lbm in^2
Jyy_2  = 77.02; % lbm in^2
Jzz_2  = 90.10; % lbm in^2

PAx_2  = [1.0, 0.0, 0.0]; % enter as righthand rule unit vectors
PAy_2  = [0.0, 1.0, 0.0]; %
PAz_2  = [0.0, 0.0, 1.0]; %


% Connection
% coordinates relative to body 1

ORGx_2 =  6.0; % inch
ORGy_2 =  0.0; % inch
ORGz_2 =  0.5; % inch

ROTz_2 =   90; % deg


% Assembly

M_1  = mass_1;
CG_1 = [ CGx_1  CGy_1  CGz_1 ];
J_1  = [ Jxx_1  0.0  0.0 ; 0.0  Jyy_1  0.0 ; 0.0  0.0  Jzz_1 ];
PA_1 = [PAx_1'  PAy_1'  PAz_1' ];

M_2  = mass_2;
CG_2 = [ CGx_2  CGy_2  CGz_2 ];
J_2  = [ Jxx_2  0.0  0.0 ; 0.0  Jyy_2  0.0 ; 0.0  0.0  Jzz_2 ];
PA_2 = [ PAx_2'  PAy_2'  PAz_2' ];

ORG_2 = [ ORGx_2  ORGy_2  ORGz_2 ];
ROT   = [ cos(ROTz_2 * pi/180) sin(ROTz_2 * pi/180) 0 ; -sin(ROTz_2 * pi/180) cos(ROTz_2 * pi/180) 0 ; 0 0 1 ];

% CG processing

CG_21 = CG_2 * ROT + ORG_2;

M_3 = M_1 + M_2;
CG_3  = (M_1 * CG_1 + M_2 * CG_21) / M_3;

% MOI tensor processing

dCG_1  = CG_1  - CG_3;
dCG_21 = CG_21 - CG_3;

J_10 = PA_1 * J_1 * PA_1';

PA_21 = ROT' * PA_2;
J_20  = PA_21 * J_2 * PA_21';

J_13 = J_10 + M_1 * ((dCG_1  * dCG_1')  * eye(3) - dCG_1'  * dCG_1);
J_23 = J_20 + M_2 * ((dCG_21 * dCG_21') * eye(3) - dCG_21' * dCG_21);

J_30  = J_13 + J_23;

[PA_3, J_3] = eig(J_30);

% Results

mass_3 = M_3

CGx_3 = CG_3(1)
CGy_3 = CG_3(2)
CGz_3 = CG_3(3)

Jxx_3 = J_3(1,1)
Jyy_3 = J_3(2,2)
Jzz_3 = J_3(3,3)

PAx_3 = PA_3(:,1)'
PAy_3 = PA_3(:,2)'
PAz_3 = PA_3(:,3)'
