%% test_steady_state_offline.m
% Offline / dry-run test of check_steady_state.m against a captured
% Arduino dump (Canvas/EXP2/SampleOutput.txt format, or a real dump from
% your own lab run). Use this BEFORE lab to pick a slopeThresh that
% actually separates "still heating" from "flat" in real data, instead
% of guessing a number cold.
%
% Data format (per Canvas/EXP2/SampleOutput.txt and the EXP2 lecture):
% one long row of interleaved readings, T0 T1 T2 T3, T0 T1 T2 T3, ...
% (one group of 4 per sample). NOTE: the Arduino does not log a
% timestamp -- the "5 second" spacing is nominal only; the real loop
% period is closer to ~7s per the FAQ / lecture, so the time axis below
% is an ASSUMPTION, not measured data. If you time an actual run with a
% stopwatch (or once you have the real .ino and can check the loop
% timing), replace dtNominal with your measured average.

clear; clc;

%% ---- sample data (from Canvas/EXP2/SampleOutput.txt) ----
% This is only 11 time samples -- enough to exercise the code, NOT
% enough to actually calibrate a threshold (it's still heating the
% whole way through, never flattens out). Swap this block for a real
% dump once your group has one.
raw = [43.9 40.1 37.3 35.1  45.3 41.6 38.6 36.2  47.5 43.4 40.1 37.3 ...
       49.8 45.3 41.6 38.6  52.4 47.5 43.4 40.1  55.3 49.8 45.3 41.6 ...
       58.5 52.4 47.5 43.4  62.0 55.3 49.8 45.3  65.9 58.5 52.4 47.5 ...
       70.2 62.0 55.3 49.8  75.0 65.9 58.5 52.4];

nChan = 4;
dtNominal = 7;   % seconds -- SEE NOTE ABOVE, this is an assumption

T = reshape(raw, nChan, []).';      % rows = samples, cols = channels
t = (0:size(T,1)-1)' * dtNominal;   % seconds

%% ---- convergence settings (placeholders -- tune these against real data) ----
windowSize     = 5;      % samples in the rolling-slope window (~35s at 7s/sample)
slopeThresh    = 0.05;   % deg C / s -- PLACEHOLDER, not yet calibrated
minConsecutive = 3;      % checks in a row that must pass before declaring steady

%% ---- simulate streaming through the data sample-by-sample ----
consecCount = 0;
convergedAt = [];

fprintf('%6s  %8s  %s\n', 'sample', 't (s)', 'slopes (C/s per channel)');
for n = windowSize:size(T,1)
    [isSteady, slopes] = check_steady_state(t(1:n), T(1:n,:), windowSize, slopeThresh);
    fprintf('%6d  %8.1f  %s\n', n, t(n), mat2str(round(slopes,4)));

    if isSteady
        consecCount = consecCount + 1;
    else
        consecCount = 0;
    end

    if consecCount >= minConsecutive && isempty(convergedAt)
        convergedAt = t(n);
        fprintf('  --> would trigger "D" here, at t = %.1f s\n', convergedAt);
    end
end

if isempty(convergedAt)
    fprintf('\nNever reached steady state in this data set -- expected, this\n');
    fprintf('sample is only %d s long and is still monotonically heating.\n', t(end));
    fprintf('Re-run this against a real, longer dump before trusting slopeThresh.\n');
end

%% ---- plot to sanity-check by eye ----
figure; plot(t, T, '-o'); xlabel('t (s)'); ylabel('Temp (C)');
legend('T0','T1','T2','T3'); title('EXP2 sample data -- steady-state check dry run');
grid on;
