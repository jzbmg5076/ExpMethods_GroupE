%% X-MODAL COMMERCIAL SENSOR -> PERIOD -> MOMENT OF INERTIA (RECTANGULAR PLATE)
% Experiment 1 - Moments of Inertia
%
% Scope: the rectangular plate ONLY, commercial (IEPE / X-Modal) data only.
%
% What this script does:
%   1. Loads an X-Modal .MAT capture and plots it four ways.
%   2. Extracts the oscillation period by THREE independent methods and
%      reports the scatter between them (the professor wants multiple
%      estimates and statistics, not one number).
%   3. Converts a period into a centroidal MOI by the compound-pendulum and
%      bifilar-pendulum equations.
%   4. Compares against the analytical plate model and reports % error.
%   5. Runs an independent geometry check from the plate's ringing.
%
% ---------------------------------------------------------------------------
% UNITS - the professor's number one rule: ONE consistent system.
% This script works in  lbm - inch - second,  with g = 386.088 in/s^2.
% In that system moments of inertia come out in lbm*in^2, which matches
% AddInertiaTensor.m and the format results are expected in.
% Mass must be entered as MASS. If you weighed the plate in kg, convert with
% *2.20462262185. Do NOT enter a weight in lbf as the mass.
% ---------------------------------------------------------------------------
%
% ASSUMPTIONS YOU ARE ACCOUNTABLE FOR (state these in the report):
%   - small angle (sin(theta) ~ theta). Section 4 estimates the swing
%     amplitude so you can defend or reject this.
%   - cables stay straight and taut, single fulcrum line, CG does not rise
%     and fall, all five other DOF constrained.
%   - massless cable/chain.
%   - the pendulum length L is measured to the CG, not to the plate edge and
%     not to the sensor.
%
% Verify the two pendulum equations yourself before you submit anything -
% the professor said explicitly that he does not want them taken on faith.
%
% Author: <your name>            Date: <fill in>
% Data source: EXP1\Lab\LabData\EXPT1(Phillps)\

clear; clc; close all;
script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
    script_dir = pwd;
end
em_root = fileparts(fileparts(fileparts(script_dir))); % ExperimentalMethods root (folder is now 3 levels down: Output/EXP1/LabDay1_Analysis)

%% ===================== 0. WHAT ARE WE ANALYSING? ==========================
CFG.file        = 'Ytest1.MAT';         % 'Ytest1.MAT'      -> the Y run (swung side to side)
                                        % 'test2settled.MAT' -> the X/Z runs (into the
                                        %                      table / twist), and the
                                        %                      noisier of the two
CFG.dataDir     = fullfile(em_root,'Lab Data','EXP1','LabDay1','LabData','EXPT1(Phillps)'); % updated in the Sep 2026 folder reorg
CFG.method      = 'compound';           % 'compound' or 'bifilar'
CFG.impactsPerCycle = 2;                % chain links strike twice per cycle
                                        % (once each end of the swing). Set 1
                                        % if you confirm one strike per cycle.
CFG.targetAxis  = 1;                    % which body axis this run measures:
                                        %   1 = about the long  (12.9 in) axis
                                        %   2 = about the short ( 5.9 in) axis
                                        %   3 = about the plate normal
CFG.gravityDoubling = false;            % TRUE if the sensor axis is aligned
                                        % with gravity, which gives two maxima
                                        % per physical cycle (see lecture).

%% ===================== 1. MEASURED INPUTS =================================
% ---- from MOI_Lab_Data_Collection_Workflow_1.xlsx, Plate Characterization --
P.mass_kg   = 1.687;                    % scale reading  [kg]
P.a         = 12.9;                     % plate LENGTH   [in]
P.b         =  5.9;                     % plate WIDTH    [in]
P.t         = 0.500;                    % plate THICKNESS[in]
% NOTE ON THICKNESS: the workbook logged 0.45. Two independent checks say
% 0.500 is right: (i) 1.687 kg over 12.9 x 5.9 x 0.500 in gives 2705 kg/m^3,
% which is 6061 aluminium exactly, and (ii) Section 7 below recovers 0.48 in
% from the plate's own ringing. Re-measure with calipers to close this out.
% Set P.t = 0.45 and re-run to see how little it matters.

P.holeDia   = 0.18;                     % perimeter holes [in] - neglected;
                                        % they remove ~0.4% of the volume.
P.material  = 'AL 6061-T6511 (stamped on the plate, see IMG_4867)';

% ---- suspension geometry -------------------------------------------------
G.chainLen  = 18.757;   % beam/fulcrum to the plate attachment screw   [in]
G.pivotToCG = 21.5;     % "Table to Accelerometer" from the workbook.  [in]
                        % The accelerometer sits at the plate centre, i.e. at
                        % the CG, so this IS the pivot-to-CG distance L.
                        % Cross-check: 18.757 + b/2 = 21.71 in. Consistent.
G.topHalfSpacing    = NaN;  % bifilar: half the spacing of the UPPER cable
                            % attachment points                        [in]
G.botHalfSpacing    = NaN;  % bifilar: half the spacing of the LOWER
                            % (plate) attachment points                [in]
G.bifilarCableLen   = G.chainLen;  % bifilar: cable length             [in]
% >>> MEASURE AND FILL THE TWO SPACINGS. The bifilar MOI scales as
% (a*b), so a 10% spacing error is a 20% MOI error. Leaving them NaN
% simply skips the bifilar branch.

% ---- constants -----------------------------------------------------------
C.g       = 386.088;            % [in/s^2]
C.kg2lbm  = 2.20462262185;
C.in2m    = 0.0254;

P.mass = P.mass_kg * C.kg2lbm;  % [lbm]

%% ===================== 2. LOAD THE X-MODAL RECORD =========================
fpath = fullfile(CFG.dataDir, CFG.file);
if ~isfile(fpath), fpath = CFG.file; end
assert(isfile(fpath), 'Cannot find %s. cd to EXP1\\Lab first.', CFG.file);

if exist('readXModalData','file') == 2
    [dt, X] = readXModalData(fpath);            % the script from lab
else
    uf = load(fpath);                            % same thing, inlined
    dt = uf.UFCELLS{3}.AbscissaIncrement;
    X  = uf.UFCELLS{3}.DataValues;
end
X  = double(X(:));
fs = 1/dt;
N  = numel(X);
tv = (0:N-1)'*dt;
Trec = N*dt;

% X-Modal wrote these files with units code 9, "British (lbf, g*s^2, F)".
% In that system the ordinate is already in g. No conversion needed.
fprintf('--- %s ---\n', CFG.file);
fprintf('fs = %.0f Hz | N = %d | record = %.3f s\n', fs, N, Trec);
fprintf('rms = %.3e g | peak = %.3e g | crest factor = %.1f\n', ...
        std(X), max(abs(X)), max(abs(X))/std(X));
fprintf('FREQUENCY RESOLUTION FLOOR = 1/Trec = %.4f Hz\n', 1/Trec);
fprintf('  -> no period from this record is better than +/- %.3f Hz.\n', 0.5/Trec);

% How much of the signal actually lives in the pendulum band? An IEPE sensor
% is AC-coupled and rolls off long before 1 Hz, so this is usually tiny - which
% tells you up front that you must use the impact-spacing method, not the
% waveform itself.
Xa0 = X - mean(X);
Ff  = abs(fft(Xa0)); frf = (0:numel(X)-1)'*fs/numel(X);
half = frf <= fs/2;  Ff = Ff(half); frf = frf(half);
Elo = sum(Ff(frf<2).^2);  Etot = sum(Ff.^2);
fprintf('ENERGY BELOW 2 Hz = %.2f %% of the record\n', 100*Elo/Etot);
lowBandUsable = (100*Elo/Etot) > 5;
if ~lowBandUsable
    fprintf(['  -> essentially no pendulum signal in the waveform. This is expected:\n' ...
             '     an IEPE accelerometer cannot pass ~1 Hz. Use the impact-spacing\n' ...
             '     method below and treat the zero-crossing/FFT estimates as invalid.\n']);
end
fprintf('\n');

%% ===================== 3. PLOTS ===========================================
Xac  = X - mean(X);
Xlp  = lowpassSafe(Xac, fs, 5);            % pendulum band
env  = envelopeSafe(Xac, fs, 15);          % impact envelope

figure('Name','X-Modal record','Color','w','Position',[80 80 1150 780]);

subplot(4,1,1);
plot(tv, X*1e3, 'LineWidth', 0.4); grid on
title(sprintf('%s  -  raw record (%.2f s @ %.0f Hz)', CFG.file, Trec, fs), ...
      'Interpreter','none');
ylabel('accel [milli-g]'); xlabel('time [s]'); xlim([0 Trec]);

subplot(4,1,2);
plot(tv, Xlp*1e3, 'LineWidth', 1.0); grid on
title('low-pass < 5 Hz  -  this is where a pendulum signal WOULD live');
ylabel('accel [milli-g]'); xlabel('time [s]'); xlim([0 Trec]);

subplot(4,1,3);
[pkT, pkV] = findImpacts(env, dt, 0.18, 0.25);
plot(tv, env*1e3, 'LineWidth', 1.0); grid on; hold on
plot(pkT, pkV*1e3, 'o', 'MarkerSize', 6, 'LineWidth', 1.2);
title(sprintf('impact envelope  -  %d bursts detected', numel(pkT)));
ylabel('envelope [milli-g]'); xlabel('time [s]'); xlim([0 Trec]);

subplot(4,1,4);
Nf = 2^nextpow2(N);
wnd = 0.5 - 0.5*cos(2*pi*(0:N-1)'/(N-1));   % Hann, inlined (no toolbox)
F  = abs(fft(Xac.*wnd, Nf));
fr = (0:Nf/2)'*fs/Nf;  F = F(1:Nf/2+1);
semilogy(fr, F, 'LineWidth', 0.4); grid on
xlim([0 min(4000, fs/2)]);
title('magnitude spectrum  -  sharp lines here are STRUCTURAL ringing, not the pendulum');
xlabel('frequency [Hz]'); ylabel('|X(f)|');

%% ===================== 4. PERIOD - THREE INDEPENDENT ESTIMATES ============
% The professor wants multiple estimates so you can quote a standard
% deviation. These three fail in different ways, which is the point.
fprintf('=============== PERIOD ESTIMATES ===============\n');
Test = struct('name',{},'T',{},'sd',{},'n',{},'note',{});

% ---- (a) impact-burst spacing (best method for THIS data) ----------------
if numel(pkT) >= 3
    d  = diff(pkT);
    Ta = mean(d)*CFG.impactsPerCycle;
    sa = std(d) *CFG.impactsPerCycle;
    Test(end+1) = struct('name','impact spacing','T',Ta,'sd',sa,'n',numel(d), ...
        'note',sprintf('%d gaps, %d impacts/cycle assumed', numel(d), CFG.impactsPerCycle));
end

% ---- (b) zero-crossing of the low-passed signal --------------------------
zc = find(Xlp(1:end-1) < 0 & Xlp(2:end) >= 0);
if numel(zc) >= 3
    zt = (zc + (-Xlp(zc))./(Xlp(zc+1)-Xlp(zc)))*dt;   % linear interpolation
    Tb = mean(diff(zt)); sb = std(diff(zt));
    if lowBandUsable, nb = 'ok'; else, nb = 'INVALID - no low-frequency content'; end
    Test(end+1) = struct('name','zero crossings','T',Tb,'sd',sb,'n',numel(zt)-1,'note',nb);
end

% ---- (c) FFT peak in the pendulum band -----------------------------------
band = fr > 0.2 & fr < 5;
[~,ib] = max(F(band)); frb = fr(band); fpk = frb(ib);
if lowBandUsable
    nc = sprintf('resolution-limited to +/- %.3f Hz', 0.5/Trec);
else
    nc = 'INVALID - no low-frequency content';
end
Test(end+1) = struct('name','FFT peak 0.2-5 Hz','T',1/fpk,'sd',NaN,'n',1,'note',nc);

for k = 1:numel(Test)
    fprintf('  %-18s T = %7.4f s   f = %6.4f Hz', Test(k).name, Test(k).T, 1/Test(k).T);
    if ~isnan(Test(k).sd), fprintf('   sd = %.4f s (n=%d)', Test(k).sd, Test(k).n); end
    fprintf('   [%s]\n', Test(k).note);
end

% ---- pick the period to carry forward ------------------------------------
T = Test(1).T;  T_sd = Test(1).sd;        % impact spacing by default
if CFG.gravityDoubling
    T = 2*T;  T_sd = 2*T_sd;
    fprintf('\n  ** gravity-doubling correction applied: T doubled **\n');
end
fprintf('\n  ADOPTED: T = %.4f s  (f = %.4f Hz)\n', T, 1/T);
if ~isnan(T_sd) && T_sd/T > 0.10
    fprintf(['  ** the impact spacing scatters by %.0f%% of the period. The bursts are\n' ...
             '     not landing at a repeatable phase, so this period is weak evidence.\n' ...
             '     Repeat the run before you build a result on it. **\n'], 100*T_sd/T);
end
fprintf('\n');

% ---- small-angle check ---------------------------------------------------
% A horizontal sensor axis reads g*sin(theta); a peak reading of A g implies
% theta ~ asin(A). This is only valid if the sensor axis really is horizontal.
ampG = max(abs(Xlp));
if lowBandUsable
    theta_deg = asind(min(ampG,1));
    fprintf('  swing amplitude implied by the low-passed signal: ~%.1f deg\n', theta_deg);
    fprintf('  small-angle error in T at that amplitude: ~%.2f %%\n', ...
            100*((1 + (1/16)*(theta_deg*pi/180)^2) - 1));
    fprintf('  (the professor asked you to judge +/-2 deg vs +/-20 deg - this is the number)\n\n');
else
    fprintf(['  small-angle check CANNOT be done from this record: the low-passed\n' ...
             '  amplitude is only %.4f milli-g, which is filter noise, not tilt.\n' ...
             '  Get the swing amplitude from the Arduino (it is DC-coupled and does\n' ...
             '  measure tilt) or from a photo/video of the release position.\n\n'], ampG*1e3);
end

%% ===================== 5. MOMENT OF INERTIA ===============================
% Body axes (state this in the report, with a figure):
%   1 = about the LONG  (a = 12.9 in) in-plane axis
%   2 = about the SHORT (b =  5.9 in) in-plane axis
%   3 = about the plate NORMAL (through the thickness)
J_thin  = [ P.mass/12*P.b^2,          P.mass/12*P.a^2,          P.mass/12*(P.a^2+P.b^2) ];
J_prism = [ P.mass/12*(P.b^2+P.t^2),  P.mass/12*(P.a^2+P.t^2),  P.mass/12*(P.a^2+P.b^2) ];
lbl = {'about long (12.9 in) axis','about short (5.9 in) axis','about plate normal'};

% which analytical axis does this test target? used only for the ceiling check
switch lower(CFG.method)
    case 'compound', J_prism_pre = J_prism(CFG.targetAxis);
    otherwise,       J_prism_pre = J_prism(3);
end

fprintf('=============== EXPERIMENTAL MOI ===============\n');
m = P.mass;  g = C.g;
J_exp = NaN;

switch lower(CFG.method)
case 'compound'
    % Compound pendulum, small angle:
    %   T = 2*pi*sqrt( (Jcg + m*L^2) / (m*g*L) )
    %   Jcg = m*g*L*T^2/(4*pi^2) - m*L^2
    L  = G.pivotToCG;
    J_exp = m*g*L*T^2/(4*pi^2) - m*L^2;

    % --- conditioning: is this measurement even capable of seeing Jcg? ---
    % The FAQ tells you to compare the size of the Jcg term against the
    % other terms. Do it numerically, do not eyeball it.
    term1 = m*g*L*T^2/(4*pi^2);        % = Jcg + m*L^2
    share = J_exp/term1;               % fraction of the total that is Jcg
    amp   = 2/max(share,eps);          % % MOI error per 1% error in T
    fprintf('  compound pendulum, L = %.3f in, T = %.4f s\n', L, T);
    fprintf('  Jcg = %.2f lbm*in^2\n', J_exp);
    fprintf('  Jcg is %.2f%% of the total (Jcg + m*L^2)\n', 100*share);
    if share > 0
        fprintf('  sensitivity: a 1%% error in T becomes a %.0f%% error in Jcg\n', amp);
    end

    % --- is the measured frequency even POSSIBLE for this plate? ---------
    % f = sqrt(g*L/(k^2+L^2))/(2*pi) is maximised at L = k, giving
    % f_max = sqrt(g/(2*k))/(2*pi). A measured frequency above f_max cannot
    % be a compound-pendulum swing of this plate at ANY cable length, so the
    % record has caught a different mode. This test needs no geometry at all.
    kk = sqrt(J_prism_pre/m);
    fmax = sqrt(g/(2*kk))/(2*pi);
    fprintf('  ceiling check: the fastest this plate can swing about this axis is\n');
    fprintf('                 %.3f Hz (at L = k = %.2f in). Measured %.3f Hz.\n', fmax, kk, 1/T);
    if 1/T > fmax
        warning(['Measured frequency is ABOVE the ceiling. This record is not a ' ...
            'compound-pendulum swing of this plate at any cable length - you have ' ...
            'caught a different mode (torsion, a local rocking motion, or slack ' ...
            'chain snapping). Do not report an MOI from it.']);
    end
    % --- the length/period consistency test -----------------------------
    % Jcg > 0 requires  L < g*T^2/(4*pi^2). That bound is just the simple-
    % pendulum length for this period, and it is a hard limit: if your
    % measured L exceeds it, the period and the length cannot both be right.
    Lcrit = g*T^2/(4*pi^2);
    fprintf('  consistency: with T = %.4f s the equation only gives Jcg > 0 for\n', T);
    fprintf('               L < %.2f in.  You entered L = %.2f in.\n', Lcrit, L);
    if L > Lcrit
        fprintf(['               -> THESE DISAGREE. Either the cable was shorter on this\n' ...
                 '                  run than the %.3f in logged in the workbook, or the\n' ...
                 '                  motion captured was not a swing about that pivot.\n' ...
                 '                  Re-measure the cable for THIS run before going further.\n'], G.chainLen);
    end
    fprintf('  for a well-conditioned test, aim for L close to k = %.2f in\n', sqrt(J_prism_pre/m));

    if J_exp <= 0
        warning(['NEGATIVE Jcg. g*L*T^2/(4*pi^2) came out smaller than L^2, ' ...
            'which is physically impossible. The cable is far too long for ' ...
            'this plate - Jcg is a tiny difference of two large numbers and ' ...
            'noise has flipped the sign. Shorten the pivot-to-CG distance ' ...
            'or use the bifilar test.']);
    elseif share < 0.05
        warning('Jcg is under 5%% of the total. This configuration cannot give a defensible MOI.');
    end

case 'bifilar'
    % Bifilar pendulum, small angle, general (unequal) half-spacings a and b:
    %   Jcg = m*g*a*b*T^2 / (4*pi^2*Lc)
    % With equal half-spacings r this reduces to m*g*r^2*T^2/(4*pi^2*Lc).
    a_ = G.topHalfSpacing;  b_ = G.botHalfSpacing;  Lc = G.bifilarCableLen;
    if any(isnan([a_ b_ Lc]))
        fprintf('  bifilar half-spacings not entered - skipping.\n');
    else
        J_exp = m*g*a_*b_*T^2/(4*pi^2*Lc);
        fprintf('  bifilar, a = %.3f in, b = %.3f in, Lc = %.3f in, T = %.4f s\n', a_, b_, Lc, T);
        fprintf('  Jcg = %.2f lbm*in^2\n', J_exp);
        fprintf('  sensitivity: a 1%% error in T becomes a 2%% error in Jcg\n');
        fprintf('               a 1%% error in either spacing is also ~1%% in Jcg\n');
    end
otherwise
    error('CFG.method must be ''compound'' or ''bifilar''.');
end

% ---- propagate the period scatter into the MOI ---------------------------
if ~isnan(J_exp) && ~isnan(T_sd) && T_sd > 0
    if strcmpi(CFG.method,'compound')
        dJ = 2*(m*g*G.pivotToCG*T/(4*pi^2))*T_sd;
    else
        dJ = 2*J_exp*(T_sd/T);
    end
    fprintf('  period scatter +/- %.4f s  ->  Jcg = %.2f +/- %.2f lbm*in^2\n', T_sd, J_exp, dJ);
end
fprintf('\n');

%% ===================== 6. ANALYTICAL COMPARISON ===========================
fprintf('=============== ANALYTICAL MODEL ===============\n');
fprintf('  mass = %.4f lbm (%.3f kg), plate %.1f x %.1f x %.3f in\n', ...
        m, P.mass_kg, P.a, P.b, P.t);
fprintf('  implied density = %.0f kg/m^3   (6061 Al = 2700, stainless = 7900)\n', ...
        P.mass_kg/(P.a*P.b*P.t*C.in2m^3));
for k = 1:3
    fprintf('  J%d %-28s thin %8.3f | prism %8.3f lbm*in^2 | thickness effect %5.2f%%\n', ...
        k, lbl{k}, J_thin(k), J_prism(k), 100*abs(J_prism(k)-J_thin(k))/J_prism(k));
end
if ~isnan(J_exp) && J_exp > 0
    % Compare against the axis you DECLARED this run measures (CFG.targetAxis).
    % Never pick the closest analytical value after the fact - that lets the
    % data choose its own answer and is not a validation.
    kt = CFG.targetAxis;
    fprintf('\n  this run was declared to measure J%d (%s)\n', kt, lbl{kt});
    fprintf('  experimental : %8.2f lbm*in^2\n', J_exp);
    fprintf('  analytical   : %8.2f (prism) / %8.2f (thin)\n', J_prism(kt), J_thin(kt));
    fprintf('  %% error vs prism model : %+.1f %%\n', 100*(J_exp-J_prism(kt))/J_prism(kt));
    fprintf('  %% error vs thin  model : %+.1f %%\n', 100*(J_exp-J_thin(kt))/J_thin(kt));
    [~,kbest] = min(abs(J_prism - J_exp));
    if kbest ~= kt
        fprintf(['  ** note: the result actually sits closest to J%d (%s).\n' ...
                 '     Either CFG.targetAxis is set wrong for this run, or the plate\n' ...
                 '     rotated about a different axis than you intended. Resolve it\n' ...
                 '     from the setup, not by relabelling the answer. **\n'], kbest, lbl{kbest});
    end
    fprintf('\n  NOTE: the thin-vs-prism difference is far smaller than your\n');
    fprintf('  experimental error, so either analytical model is defensible.\n');
    fprintf('  Say so explicitly and quote both numbers.\n');
end
fprintf('\n');

%% ===================== 7. INDEPENDENT GEOMETRY CHECK FROM THE RINGING =====
% The chain impacts excite the plate's free-free bending modes. Those
% frequencies depend on thickness and material and NOT on the suspension,
% so they are a completely independent check on the plate you modelled.
%   f_n = (lambda_n^2 / 2*pi) * sqrt( E*I / (rho*A*L^4) )
fprintf('=============== MODAL CROSS-CHECK ===============\n');
E   = 68.9e9;  rho = 2700;                 % 6061-T6, SI
lam2 = [22.373 61.673 120.903];            % free-free beam eigenvalues
h   = P.t*C.in2m;
spans = { 'across the 12.9 in span', P.a*C.in2m, P.b*C.in2m ; ...
          'across the 5.9 in span',  P.b*C.in2m, P.a*C.in2m };
for s = 1:2
    Ls = spans{s,2};  w = spans{s,3};
    I  = w*h^3/12;  A = w*h;
    fn = lam2/(2*pi)*sqrt(E*I/(rho*A*Ls^4));
    fprintf('  bending %-26s predicted modes: %6.0f %6.0f %6.0f Hz\n', spans{s,1}, fn(1), fn(2), fn(3));
end
% measured, from the spectrum in Section 3
fmeas = [587 1630 2840];
fprintf('  measured sharp lines in these files:              %6.0f %6.0f %6.0f Hz\n', fmeas);
tsolve = fmeas(1)*2*pi*(P.a*C.in2m)^2/(lam2(1)*sqrt(E/(12*rho)))/C.in2m;
fprintf('  thickness implied by the 587 Hz line: %.3f in\n', tsolve);
fprintf('  (frequency scales linearly with thickness, so this is a strong check.\n');
fprintf('   A 0.45 cm = 0.177 in plate would ring at ~217 Hz, not 587 Hz.)\n\n');

%% ===================== 8. SAVE ============================================
R = struct('file',CFG.file,'method',CFG.method,'fs',fs,'Trec',Trec, ...
           'periodEstimates',Test,'T_adopted',T,'T_sd',T_sd, ...
           'J_experimental_lbm_in2',J_exp, ...
           'J_thin_lbm_in2',J_thin,'J_prism_lbm_in2',J_prism, ...
           'plate',P,'geometry',G);
save(sprintf('results_%s.mat', strrep(CFG.file,'.MAT','')), 'R');
fprintf('Saved results_%s.mat\n', strrep(CFG.file,'.MAT',''));

fprintf(['\nSTILL MISSING BEFORE THESE NUMBERS ARE REPORTABLE:\n' ...
    '  - bifilar top and bottom cable half-spacings\n' ...
    '  - the cable length actually used on EACH run (it changed during the session)\n' ...
    '  - repeat trials, so the standard deviation is over trials, not over one record\n' ...
    '  - a longer capture; 5.12 s of a ~1 Hz motion is about 5 cycles\n']);

%% ===================== LOCAL FUNCTIONS ====================================
function y = lowpassSafe(x, fs, fc)
% Low-pass without requiring the Signal Processing Toolbox.
    if exist('butter','file') == 2 && exist('filtfilt','file') == 2
        [b,a] = butter(4, fc/(fs/2), 'low');
        y = filtfilt(b,a,x);
    else
        n = numel(x); Nf = 2^nextpow2(n);
        Xf = fft(x, Nf); f = (0:Nf-1)'*fs/Nf; f(f>fs/2) = fs - f(f>fs/2);
        Xf(f > fc) = 0;
        y = real(ifft(Xf)); y = y(1:n);
    end
end

function e = envelopeSafe(x, fs, fsm)
% Amplitude envelope. Uses hilbert if available, else a moving RMS.
    if exist('hilbert','file') == 2
        e = abs(hilbert(x));
    else
        w = max(3, round(fs/200));
        e = sqrt(movmean(x.^2, w))*sqrt(2);
    end
    e = lowpassSafe(e, fs, fsm);
end

function [pt, pv] = findImpacts(env, dt, hfrac, minSep)
% Local maxima of the envelope above hfrac of the max, at least minSep apart.
    thr = hfrac*max(env);
    sep = max(1, round(minSep/dt));
    pt = []; pv = [];
    if exist('findpeaks','file') == 2
        [pv, loc] = findpeaks(env, 'MinPeakHeight', thr, 'MinPeakDistance', sep);
        pt = (loc-1)*dt;  pv = pv(:);  pt = pt(:);
        return
    end
    i = 2;
    while i < numel(env)-1
        if env(i) > thr && env(i) >= env(i-1) && env(i) >= env(i+1)
            pt(end+1,1) = (i-1)*dt;  pv(end+1,1) = env(i);   %#ok<AGROW>
            i = i + sep;
        else
            i = i + 1;
        end
    end
end
