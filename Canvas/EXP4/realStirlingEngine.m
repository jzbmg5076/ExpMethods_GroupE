function realStirlingEngine
% realStirlingEngine.m
clc

% A real Stirling Engine cycle calculator
eng = engineGeometry;

% Temperature(s)
TH = 900;       % K - hot
TC = 373;       % K - cold
TR = (TH+TC)/2; % K - regenerator (estimate)

% Gas Properties
R =    2077; % J/kg-K
m = 0.00016; % kg

% If uncertain then estimate: mass of gas using approximate state 1 lower bound
P0 = 1200000; % Pa - base pressure
displacerAngle = 180; % 135 - degrees
ang = displacerAngle * pi / 180;

VH = hotVolume(eng,ang);
VC = coldVolume(eng,ang);
VR = regeneratorVolume(eng,ang);

m = (P0 / R) * (VH/TH + VC/TC + VR / TR); % grams - mass of gas

% Solve cycle
P = [];
V = [];

for displacerAngle = 0:360
    ang = displacerAngle * pi / 180;

    VH = hotVolume(eng,ang);
    VC = coldVolume(eng,ang);
    VR = regeneratorVolume(eng,ang);

    V(end+1) = VH + VC + VR;
    P(end+1) = (m * R) / (VH/TH + VC/TC + VR / TR);
end

plot(V*1e6,P/1000)

CR = max(V) / min(V)

end


%================
% Engine Geometry
function [eng] = engineGeometry
eng.baseDiameter  = 3.2; % cm - clear base inner diameter
eng.baseThickness =   2; % cm - clear base height

eng.displacerDiameter  =    8; % cm - black foam diameter
eng.displacerThickness =  0.1; % cm - black foam thickness
eng.displacerOffset    =  2.8; % cm - distance from hot base to midline of displacer neutral position
eng.displacerStroke    =  1.3; % cm - full distance swing of displacer (from top to bottom)

eng.pistonDiameter   =    3.2; % cm - clear glass piston
eng.pistonOffset     =      1; % cm - distance from cold base to bottom of piston in neutral position
eng.pistonStroke     =    1.3; % cm  - full distance swing of displacer (from top to bottom)
eng.pistonPhase      =  -pi/2; % rad - piston crank angle relative to displacer crank angle
end

%================
% Hot Volume
function [vol] = hotVolume(eng, ang)
hotArea   = pi * eng.baseDiameter^2 / 4; % cm^2
hotHeight = eng.displacerOffset + eng.displacerStroke/2 * cos(ang) - eng.displacerThickness/2;

vol = hotArea * hotHeight;
vol = vol / 1e6; % m^3
end

%================
% Cold Volume
function [vol] = coldVolume(eng, ang)
coldArea1   = pi * eng.baseDiameter^2 / 4; % cm^2
coldHeight1 = eng. baseThickness - (eng.displacerOffset + eng.displacerStroke/2 * cos(ang) + eng.displacerThickness/2); % cm

coldArea2   = pi * eng.pistonDiameter^2 / 4; % cm^2
coldHeight2 = eng.pistonOffset + eng.pistonStroke/2 * cos(ang+eng.pistonPhase); % cm

vol = coldArea1 * coldHeight1 +  coldArea2 * coldHeight2;
vol = vol / 1e6; % m^3
end

%================
% Regenerator Volume
function [vol] = regeneratorVolume(eng, ang) %#ok<INUSD> 
baseArea          = pi * eng.baseDiameter^2 / 4; % cm^2
regeneratorArea   = pi * eng.displacerDiameter^2 / 4; % cm^2

vol = (baseArea - regeneratorArea) * eng.displacerThickness;
vol = vol / 1e6; % m^3
end







