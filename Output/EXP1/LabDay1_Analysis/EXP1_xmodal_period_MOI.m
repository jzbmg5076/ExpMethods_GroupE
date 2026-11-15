%% EXP1_xmodal_period_MOI.m
%  Experiment 1 - Moments of Inertia
%  Plot an X-Modal (.MAT) record, extract the oscillation period, and turn
%  that period into a moment of inertia.
%
%  WHY IT WORKS THE WAY IT DOES
%  The commercial IEPE accelerometer is AC-coupled - it physically cannot pass
%  a ~1 Hz pendulum, so there is almost no energy below 2 Hz in these files and
%  the strongest spectral peaks (hundreds of Hz) are the plate RINGING, not the
%  swing. What the sensor does capture cleanly is the chain-link impacts, which
%  repeat at a fixed point in every swing cycle. So the period comes from the
%  spacing of those impact bursts, measured two independent ways.
%
%  Base MATLAB only - no Signal Processing Toolbox required.
%
%  HOW TO USE
%    1. Set PICK to the run you want.
%    2. Fill in the geometry for that run (cord length, spacings, pivot-to-CG).
%       Those numbers, not the signal processing, are what limit your accuracy.
%    3. Run. READ THE DIAGNOSTICS before you believe the MOI.

clear; clc; close all;

%% ======================= PICK A RUN =======================
PICK = 1;

% ---------------- run definitions ----------------
% method:  'compound' - swung about a horizontal pivot line
%          'bifilar'  - twisted about the vertical axis on two cords
%          'simple'   - two parallel cords, swung in the plane containing them.
%                       This is a parallelogram linkage: the plate translates
%                       without rotating, so the period contains NO inertia
%                       information. The script reports the cord length instead.
% axis:    'Ixx' rotation about the face normal (into the table)
%          'Iyy' rotation about the long edge
%          'Izz' rotation about the short/vertical edge

R(1).file='Ytest1.MAT';       R(1).chan=1; R(1).method='compound';   R(1).axis='Ixx';
R(1).note='Y run - swung side to side, in the plane of both chains';
R(1).f_arduino=0.921;         % Hz, from ArduinoDataY2 (leave [] if unknown)

R(2).file='test2settled.MAT'; R(2).chan=1; R(2).method='compound';  R(2).axis='Izz';
R(2).note='X/Z runs - see the Day 1 review, the mode here is still ambiguous';
R(2).f_arduino=1.688;         % Hz, from ArduinoDataX / Zdata2

IN = R(PICK);

%% ======================= PLATE =======================
IN.m_kg = 1.687;      % measured mass [kg]
IN.a_in = 12.9;       % long dimension [in]
IN.b_in = 5.9;        % short dimension [in]
IN.t_in = 0.500;      % thickness [in]

%% ======================= SUSPENSION GEOMETRY - MEASURE THESE =======================
IN.L_in     = 11.53;  % cord length, support point to plate [in]
IN.d_in     = 2.38;   % COMPOUND only: pivot line to CG [in]
IN.aHalf_in = 5.85;   % BIFILAR only: half-spacing of the cords at the TOP [in]
IN.bHalf_in = 5.85;   % BIFILAR only: half-spacing of the cords at the PLATE [in]

% 1-sigma uncertainties, for error propagation
IN.sig_L_in = 0.25;
IN.sig_d_in = 0.10;
IN.sig_s_in = 0.10;
IN.sig_m_kg = 0.005;

%% ======================= IMPACTS PER CYCLE =======================
% Usually 2 (the chain snaps at each end of the swing). Getting this wrong
% changes the MOI by 4x. Set to 0 and the script will pick it for you from the
% envelope autocorrelation and tell you what it chose.
IN.impactsPerCycle = 0;

%% ======================= DETECTION TUNING =======================
IN.envWin_s     = 0.010;   % envelope smoothing window [s]
IN.threshFrac   = 0.18;    % burst threshold as a fraction of the largest burst
IN.refractory_s = 0.25;    % minimum time between accepted bursts [s]

%% ======================= CONSTANTS =======================
g      = 386.0886;                 % gravity [in/s^2]
KG2LBM = 2.20462262185;
IN2SI  = 0.0254^2 / KG2LBM;        % lbm*in^2 -> kg*m^2
m_lbm  = IN.m_kg * KG2LBM;

%% ======================= LOAD =======================
[dt, x] = local_readXModal(IN.file, IN.chan);
fs = 1/dt;  t = (0:numel(x)-1).'*dt;  x = x - mean(x);

fprintf('==================================================================\n');
fprintf(' RUN %d : %s\n', PICK, IN.note);
fprintf(' FILE   : %s  (channel %d)\n', IN.file, IN.chan);
fprintf(' SIGNAL : %.0f Hz, %d pts, %.3f s | rms %.3e g, peak %.3e g, crest %.1f\n', ...
        fs, numel(x), numel(x)*dt, std(x), max(abs(x)), max(abs(x))/std(x));
fprintf('==================================================================\n\n');

%% ======================= ENVELOPE AND IMPACT DETECTION =======================
w   = max(3, round(IN.envWin_s*fs));
env = movmean(movmean(abs(x), w), w);
pk  = local_findpeaks(env, IN.threshFrac*max(env), round(IN.refractory_s*fs));
tp  = t(pk);

if numel(tp) < 3
    error(['Only %d bursts found. Lower IN.threshFrac, or this record may not ' ...
           'contain a repeating impact train at all.'], numel(tp));
end
spacing = diff(tp);
sp_mean = mean(spacing);
sp_std  = std(spacing);

%% ======================= PERIOD =======================
% Method 2 first: envelope autocorrelation. Its peak lag IS the full period,
% however many impacts there are per cycle - which is what lets us work out
% impactsPerCycle instead of guessing it.
e   = env - mean(env);
nf  = 2^nextpow2(2*numel(e));
ac  = ifft(abs(fft(e, nf)).^2, 'symmetric');
ac  = ac(1:numel(e));  ac = ac/ac(1);
lag = (0:numel(ac)-1).'*dt;

sel  = lag > max(0.15, 0.4*sp_mean) & lag < min(lag(end), 4*sp_mean);
lagV = lag(sel);
[acPk, iPk] = max(ac(sel));
T_acorr = lagV(iPk);

ratio = T_acorr / sp_mean;              % ~2 -> two impacts per cycle, ~1 -> one
nRec  = max(1, round(ratio));
if IN.impactsPerCycle == 0
    IN.impactsPerCycle = nRec;
    autoPicked = true;
else
    autoPicked = false;
end
T_spacing = IN.impactsPerCycle * sp_mean;

fprintf('--- PERIOD ------------------------------------------------------\n');
fprintf(' bursts detected        : %d\n', numel(tp));
fprintf(' burst spacing          : %.4f +/- %.4f s  (scatter %.1f %%)\n', ...
        sp_mean, sp_std, 100*sp_std/sp_mean);
fprintf(' autocorr peak lag      : %.4f s  (r = %.2f)  = %.2f x the spacing\n', ...
        T_acorr, acPk, ratio);
if autoPicked
    fprintf(' impacts per cycle      : %d  (chosen automatically from that ratio)\n', nRec);
else
    fprintf(' impacts per cycle      : %d  (set by hand; the data suggests %d)\n', ...
            IN.impactsPerCycle, nRec);
    if IN.impactsPerCycle ~= nRec
        fprintf(' >> These disagree. Look at the envelope plot and count bursts per cycle.\n');
    end
end
fprintf(' T from spacing         : %.4f s  -> %.4f Hz\n', T_spacing, 1/T_spacing);
fprintf(' T from autocorrelation : %.4f s  -> %.4f Hz\n', T_acorr, 1/T_acorr);

disagree = 100*abs(T_spacing-T_acorr)/mean([T_spacing T_acorr]);
fprintf(' the two methods differ : %.1f %%\n', disagree);
if disagree > 10
    fprintf(' >> WARNING: >10%% disagreement means the impact train is irregular.\n');
    fprintf(' >>          Treat this period as provisional.\n');
end

T     = T_spacing;
sig_T = max(IN.impactsPerCycle*sp_std/sqrt(numel(spacing)), 0.5*abs(T_spacing-T_acorr));
fprintf(' ADOPTED T              : %.4f +/- %.4f s   (%.4f Hz)\n', T, sig_T, 1/T);

% cross-check against the Arduino for the same run
if ~isempty(IN.f_arduino)
    fprintf(' Arduino, same run      : %.4f Hz  -> commercial/Arduino = %.3f\n', ...
            IN.f_arduino, (1/T)/IN.f_arduino);
    if abs((1/T)/IN.f_arduino - 1) < 0.05
        fprintf(' >> The two sensors agree. This is your sensor cross-validation.\n');
    else
        fprintf(' >> The sensors DISAGREE. Check impacts-per-cycle first: a factor of\n');
        fprintf(' >> 2 or 0.5 here almost always means that setting is wrong.\n');
    end
end
fprintf('\n');

%% ======================= ANALYTICAL REFERENCE =======================
a = IN.a_in; b = IN.b_in; th = IN.t_in;
Iref.Ixx = m_lbm*(a^2 + b^2)/12;     % about the face normal
Iref.Iyy = m_lbm*(b^2 + th^2)/12;    % about the long edge
Iref.Izz = m_lbm*(a^2 + th^2)/12;    % about the short (vertical) edge
I_an = Iref.(IN.axis);
k_an = sqrt(I_an/m_lbm);             % radius of gyration [in]

%% ======================= SANITY CHECK =======================
% Predict what this configuration SHOULD do, using the analytical MOI. If the
% measurement is far off, the plate was not moving the way you assumed, and no
% amount of arithmetic downstream will fix that.
L = IN.L_in;  d = IN.d_in;
fprintf('--- SANITY CHECK ------------------------------------------------\n');
f_pred = NaN;
switch lower(IN.method)
    case 'compound'
        f_pred = sqrt(g*d/(k_an^2 + d^2))/(2*pi);
        f_ceil = sqrt(g/(2*k_an))/(2*pi);
        fprintf(' predicted f, this setup : %.3f Hz  (T = %.3f s)\n', f_pred, 1/f_pred);
        fprintf(' ceiling for a compound pendulum of this plate, ANY pivot\n');
        fprintf('   distance              : %.3f Hz\n', f_ceil);
        if 1/T > f_ceil
            fprintf(' >> IMPOSSIBLE: %.3f Hz is above that ceiling. Whatever oscillated,\n', 1/T);
            fprintf(' >> it was not this plate as a compound pendulum. Do not report an MOI.\n');
        end
    case 'bifilar'
        f_pred = (sqrt(IN.aHalf_in*IN.bHalf_in)/k_an)*sqrt(g/L)/(2*pi);
        fprintf(' predicted f, this setup : %.3f Hz  (T = %.3f s)\n', f_pred, 1/f_pred);
    case 'simple'
        f_pred = sqrt(g/L)/(2*pi);
        fprintf(' predicted f for a simple pendulum of cord %.2f in : %.3f Hz\n', L, f_pred);
end
fprintf(' measured f              : %.3f Hz\n', 1/T);
if ~isnan(f_pred)
    fprintf(' measured / predicted    : %.2f x\n', (1/T)/f_pred);
    if abs((1/T)/f_pred - 1) > 0.20
        fprintf(' >> More than 20%% off. Either the geometry above is wrong, or the\n');
        fprintf(' >> plate was in a different mode than IN.method assumes.\n');
    end
end
fprintf('\n');

%% ======================= MOI =======================
fprintf('--- RESULT ------------------------------------------------------\n');
switch lower(IN.method)

    case 'simple'
        % Parallelogram suspension: the plate translates, it does not rotate.
        % No MOI is recoverable. What you do get is an excellent cord length.
        L_meas = g*T^2/(4*pi^2);
        sig_L  = 2*L_meas*sig_T/T;
        fprintf(' This configuration carries NO moment-of-inertia information.\n');
        fprintf(' Two equal parallel cords form a parallelogram linkage, so the\n');
        fprintf(' plate swings without rotating and its mass distribution cancels\n');
        fprintf(' out of the equation of motion entirely.\n\n');
        fprintf(' What it DOES give you, very accurately, is the cord length:\n');
        fprintf('   L = g*T^2/(4*pi^2) = %.3f +/- %.3f in\n', L_meas, sig_L);
        fprintf('\n To measure %s, hang the plate from a SINGLE point (one cord to a\n', IN.axis);
        fprintf(' corner, or a knife edge) so it is free to rotate about its face normal.\n');
        J = NaN; sig_J = NaN;

    case 'compound'
        % Jcg = m*( g*d*T^2/(4*pi^2) - d^2 )
        term1 = g*d*T^2/(4*pi^2);
        J     = m_lbm*(term1 - d^2);
        dJdT  = m_lbm*g*d*2*T/(4*pi^2);
        dJdd  = m_lbm*(g*T^2/(4*pi^2) - 2*d);
        sig_J = sqrt((dJdT*sig_T)^2 + (dJdd*IN.sig_d_in)^2 + ...
                     ((J/m_lbm)*IN.sig_m_kg*KG2LBM)^2);
        share = (term1 - d^2)/term1;
        fprintf(' g*d*T^2/(4pi^2) = %.3f in^2   vs   d^2 = %.3f in^2\n', term1, d^2);
        fprintf(' the plate is %.1f %% of the total swing inertia\n', 100*share);
        fprintf(' a 1 %% error in T becomes a %.0f %% error in J\n', 2*term1/(term1-d^2));
        if term1 <= d^2
            fprintf(' >> NEGATIVE MOI. Those two terms are nearly equal, so noise flipped\n');
            fprintf(' >> the sign. The pivot is far too far from the CG. Shorten the cord.\n');
        elseif share < 0.05
            fprintf(' >> POORLY CONDITIONED - move the pivot much closer to the CG.\n');
        end

    case 'bifilar'
        % J = m*g*aHalf*bHalf*T^2 / (4*pi^2*L)
        J   = m_lbm*g*IN.aHalf_in*IN.bHalf_in*T^2/(4*pi^2*L);
        rel = sqrt((2*sig_T/T)^2 + (IN.sig_s_in/IN.aHalf_in)^2 + ...
                   (IN.sig_s_in/IN.bHalf_in)^2 + (IN.sig_L_in/L)^2 + ...
                   (IN.sig_m_kg/IN.m_kg)^2);
        sig_J = rel*J;
        fprintf(' a 1 %% error in T becomes a 2 %% error in J - well conditioned.\n');
        fprintf(' The cord spacing dominates the uncertainty (it enters squared).\n');
end

if ~isnan(J)
    fprintf('\n %s experimental = %.2f +/- %.2f lbm*in^2  = %.5f +/- %.5f kg*m^2\n', ...
            IN.axis, J, sig_J, J*IN2SI, sig_J*IN2SI);
    fprintf(' %s analytical   = %.2f lbm*in^2  = %.5f kg*m^2\n', ...
            IN.axis, I_an, I_an*IN2SI);
    fprintf(' error vs analytical = %+.1f %%   (uncertainty band %+.1f %% to %+.1f %%)\n', ...
            100*(J-I_an)/I_an, 100*(J-sig_J-I_an)/I_an, 100*(J+sig_J-I_an)/I_an);
end
fprintf('==================================================================\n');

%% ======================= PLOTS =======================
figure('Color','w','Position',[60 60 1150 840]);

subplot(3,1,1);
plot(t, x, 'Color',[0.18 0.44 0.81], 'LineWidth',0.4); grid on; box off;
xlabel('time (s)'); ylabel('acceleration (g)'); xlim([0 t(end)]);
title(sprintf('%s ch%d - raw record (%.0f Hz, %.2f s)', IN.file, IN.chan, fs, ...
      numel(x)*dt), 'Interpreter','none');

subplot(3,1,2); hold on; grid on; box off;
plot(t, env, 'Color',[0.18 0.55 0.44], 'LineWidth',1.2);
plot([0 t(end)], IN.threshFrac*max(env)*[1 1], ':', 'Color',[0.55 0.58 0.64]);
plot(tp, env(pk), 'o', 'MarkerSize',6, 'LineWidth',1.2, ...
     'MarkerEdgeColor',[0.85 0.51 0.17], 'MarkerFaceColor','w');
xlabel('time (s)'); ylabel('envelope (g)'); xlim([0 t(end)]);
title(sprintf(['%d impact bursts, spacing %.4f +/- %.4f s, %d per cycle ' ...
      '-> T = %.4f s (%.3f Hz)'], numel(tp), sp_mean, sp_std, ...
      IN.impactsPerCycle, T, 1/T));
legend({'envelope','threshold','detected impacts'}, 'Location','northwest', 'Box','off');

subplot(3,1,3);
nfp = 2^nextpow2(numel(x));
F   = abs(fft(x.*local_hann(numel(x)), nfp));
fr  = (0:nfp/2).'*fs/nfp;
semilogy(fr, F(1:nfp/2+1), 'Color',[0.18 0.44 0.81], 'LineWidth',0.4);
grid on; box off; xlim([0 min(4000, fs/2)]);
xlabel('frequency (Hz)'); ylabel('magnitude');
title(['spectrum - the large peaks are the PLATE RINGING after each impact ' ...
       '(structural modes). They are not the pendulum frequency; that comes ' ...
       'from the envelope above.']);

%% ======================= LOCAL FUNCTIONS =======================
function [dt, x] = local_readXModal(fname, chan)
% X-Modal .MAT export: UFCELLS{3} is channel 1, UFCELLS{4} is channel 2.
    S = load(fname);
    if ~isfield(S, 'UFCELLS')
        error('%s has no UFCELLS field - is it an X-Modal export?', fname);
    end
    uf = S.UFCELLS;  idx = 2 + chan;
    if numel(uf) < idx
        error('Channel %d is not in %s (only %d data records).', chan, fname, numel(uf)-2);
    end
    dt = double(uf{idx}.AbscissaIncrement);
    x  = double(uf{idx}.DataValues(:));
end

function idx = local_findpeaks(y, minHeight, minDist)
% Local maxima above minHeight and at least minDist samples apart.
% Base-MATLAB stand-in for findpeaks.
    y = y(:); n = numel(y); idx = [];
    cand = find(y(2:n-1) > y(1:n-2) & y(2:n-1) >= y(3:n) & y(2:n-1) > minHeight) + 1;
    if isempty(cand), return; end
    [~, ord] = sort(y(cand), 'descend');
    cand = cand(ord);
    for kk = 1:numel(cand)
        if isempty(idx) || all(abs(cand(kk) - idx) >= minDist)
            idx(end+1) = cand(kk); %#ok<AGROW>
        end
    end
    idx = sort(idx(:));
end

function wv = local_hann(n)
    wv = 0.5 - 0.5*cos(2*pi*(0:n-1).'/(n-1));
end
