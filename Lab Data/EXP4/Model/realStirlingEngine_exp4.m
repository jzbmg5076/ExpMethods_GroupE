function realStirlingEngine
% realStirlingEngine.m
clc

% A real Stirling Engine cycle calculator
eng = engineGeometry;

% Temperature(s)
TH = 330;       % K - hot
TC = 295;       % K - cold
TR = (TH+TC)/2; % K - regenerator (estimate)

% Gas Properties
R =    1005; % J/kg-K

% If uncertain then estimate: mass of gas using approximate state 1 lower bound
P0 = 1013000; % Pa - base pressure
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
eng.baseDiameter  = 9.8; % cm - clear base inner diameter
eng.baseThickness =   2.24; % cm - clear base height

eng.displacerDiameter  =  8.40  ; % cm - black foam diameter
eng.displacerThickness =  .89; % cm - black foam thickness
eng.displacerOffset    =  .85; % cm - distance from hot base to midline of displacer neutral position
eng.displacerStroke    =  .824; % cm - full distance swing of displacer (from top to bottom)

eng.pistonDiameter   =    1.62; % cm - clear glass piston
eng.pistonOffset     =      .55; % cm - distance from cold base to bottom of piston in neutral position
eng.pistonStroke     =    .824; % cm  - full distance swing of displacer (from top to bottom)
eng.pistonPhase      =  1.74533; % rad - piston crank angle relative to displacer crank angle
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







