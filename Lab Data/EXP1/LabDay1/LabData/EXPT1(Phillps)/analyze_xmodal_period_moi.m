%% Analyze the commercial X-Modal recordings from Experiment 1
% This script:
%   1. loads both saved X-Modal channels from each MAT file,
%   2. plots the raw signals, vibration envelopes, spectra, and envelope
%      autocorrelations,
%   3. estimates the mechanical period from the repeating envelope, and
%   4. optionally calculates MOI after the correct pendulum geometry is set.
%
% The commercial accelerometer mainly recorded short, high-frequency
% vibration bursts. The pendulum period is therefore estimated from the
% repetition of the burst envelope, not from the 585 Hz or 2.84 kHz
% structural/sensor ringing seen in the raw signal spectrum.

clear; close all; clc;

%% User settings
dataFolder = fileparts(mfilename('fullpath'));

files = ["test2settled.MAT", "Ytest1.MAT"];
runNames = ["X run: motion into the table", ...
            "Y run: motion side to side"];

% Search limits for one COMPLETE mechanical cycle [minimum maximum], s.
% These deliberately exclude the prominent half-cycle burst spacing.
% Adjust them if video or a manual stopwatch gives different limits.
periodSearchRange_s = [1.00 1.80; ... % test2settled / probable X run
                       0.80 1.40];    % Ytest1 / Y run

% Envelope construction parameters.
rmsWindow_s    = 0.010;  % short RMS window follows each impact/ringing burst
smoothWindow_s = 0.050;  % smooths the envelope before period estimation
maxAcfLag_s    = 2.50;

saveFigures = true;
figureFolder = fullfile(dataFolder, "XModal_Figures");

%% Optional MOI calculation
% Select "none", "compound", or "bifilar" independently for each run.
% Leave a run as "none" until its physical motion and dimensions are known.
testType = ["none", "none"];

mass_kg = 1.687;
g_mps2 = 9.80665;

% Compound pendulum: distance from the FIXED pivot axis to the CG.
pivotToCG_m = [NaN, NaN];

% Bifilar pendulum: vertical cord length and half-spacings measured from the
% rotation axis to a cord at the top and bottom. For equal spacing, a = b.
cordLength_m       = [NaN, NaN];
topHalfSpacing_m   = [NaN, NaN];
bottomHalfSpacing_m = [NaN, NaN];

%% Load, plot, and estimate periods
nRuns = numel(files);
period_s = NaN(nRuns, 1);
frequency_Hz = NaN(nRuns, 1);
channelPeriods_s = NaN(nRuns, 2);
channelDifference_pct = NaN(nRuns, 1);

for runIndex = 1:nRuns
    fullName = fullfile(dataFolder, files(runIndex));
    assert(isfile(fullName), "File not found: %s", fullName);

    uf = load(fullName);
    assert(isfield(uf, "UFCELLS") && numel(uf.UFCELLS) >= 4, ...
        "%s does not have the expected X-Modal UFCELLS structure.", files(runIndex));

    dt_s = uf.UFCELLS{3}.AbscissaIncrement;
    fs_Hz = 1 / dt_s;
    x = [double(uf.UFCELLS{3}.DataValues(:)), ...
         double(uf.UFCELLS{4}.DataValues(:))];
    x = x - mean(x, 1);
    time_s = (0:size(x, 1)-1)' * dt_s;

    envelope = zeros(size(x));
    acf = zeros(round(maxAcfLag_s * fs_Hz) + 1, 2);
    acfLag_s = (0:size(acf, 1)-1)' / fs_Hz;

    for channelIndex = 1:2
        envelope(:, channelIndex) = localRmsEnvelope( ...
            x(:, channelIndex), fs_Hz, rmsWindow_s, smoothWindow_s);
        acf(:, channelIndex) = localNormalizedAcf( ...
            envelope(:, channelIndex), size(acf, 1)-1);
        channelPeriods_s(runIndex, channelIndex) = localBestAcfPeriod( ...
            acfLag_s, acf(:, channelIndex), periodSearchRange_s(runIndex, :));
    end

    % Averaging the two normalized autocorrelations makes the estimate less
    % dependent on one sensor channel's individual structural resonance.
    combinedAcf = mean(acf, 2, "omitnan");
    period_s(runIndex) = localBestAcfPeriod( ...
        acfLag_s, combinedAcf, periodSearchRange_s(runIndex, :));
    frequency_Hz(runIndex) = 1 / period_s(runIndex);
    channelDifference_pct(runIndex) = 100 * abs(diff(channelPeriods_s(runIndex, :))) ...
        / mean(channelPeriods_s(runIndex, :));

    fprintf("\n%s\n", runNames(runIndex));
    fprintf("  File: %s\n", files(runIndex));
    fprintf("  Samples: %d, sample rate: %.0f Hz, duration: %.3f s\n", ...
        size(x, 1), fs_Hz, time_s(end) + dt_s);
    fprintf("  Channel 1 candidate period: %.4f s\n", channelPeriods_s(runIndex, 1));
    fprintf("  Channel 2 candidate period: %.4f s\n", channelPeriods_s(runIndex, 2));
    fprintf("  Combined period estimate:   %.4f s (%.4f Hz)\n", ...
        period_s(runIndex), frequency_Hz(runIndex));
    fprintf("  Difference between channel estimates: %.2f%%\n", ...
        channelDifference_pct(runIndex));
    if channelDifference_pct(runIndex) > 5
        warning('%s', "The channel period estimates differ by more than 5%. " + ...
            "Treat this run's combined period as a candidate and verify it " + ...
            "against the setup geometry or video.");
    end

    fig = figure("Color", "w", "Name", runNames(runIndex));
    tiledlayout(fig, 2, 2, "TileSpacing", "compact", "Padding", "compact");

    nexttile;
    plot(time_s, x, "LineWidth", 0.7);
    grid on;
    xlabel("Time (s)"); ylabel("Recorded amplitude");
    title("Raw X-Modal channels");
    legend("Channel 1", "Channel 2", "Location", "best");

    nexttile;
    plot(time_s, localScale01(envelope), "LineWidth", 1.0);
    grid on;
    xlabel("Time (s)"); ylabel("Normalized RMS envelope");
    title("Envelope of vibration bursts");
    legend("Channel 1", "Channel 2", "Location", "best");

    nexttile;
    hold on;
    for channelIndex = 1:2
        [psd, f_Hz] = localOneSidedPsd(x(:, channelIndex), fs_Hz);
        semilogy(f_Hz, psd, "LineWidth", 0.8);
    end
    hold off; grid on;
    xlim([0, fs_Hz/2]);
    xlabel("Frequency (Hz)"); ylabel("PSD (amplitude^2/Hz)");
    title("Raw-signal spectrum");
    legend("Channel 1", "Channel 2", "Location", "best");

    nexttile;
    plot(acfLag_s, acf, "LineWidth", 0.8); hold on;
    plot(acfLag_s, combinedAcf, "k", "LineWidth", 1.5);
    xline(period_s(runIndex), "--r", ...
        sprintf("T = %.3f s", period_s(runIndex)), "LineWidth", 1.2);
    xline(period_s(runIndex)/2, ":", "T/2", "LineWidth", 1.0);
    xline(periodSearchRange_s(runIndex, 1), ":k", "HandleVisibility", "off");
    xline(periodSearchRange_s(runIndex, 2), ":k", "HandleVisibility", "off");
    hold off; grid on;
    xlim([0 maxAcfLag_s]); ylim([-0.4 1.05]);
    xlabel("Lag (s)"); ylabel("Normalized autocorrelation");
    title("Period from envelope autocorrelation");
    legend("Channel 1", "Channel 2", "Combined", "Location", "best");

    sgtitle(sprintf("%s | %s", runNames(runIndex), files(runIndex)), ...
        "Interpreter", "none");

    if saveFigures
        if ~isfolder(figureFolder)
            mkdir(figureFolder);
        end
        exportgraphics(fig, fullfile(figureFolder, ...
            sprintf("%s_xmodal_analysis.png", erase(files(runIndex), ".MAT"))), ...
            "Resolution", 180);
    end
end

%% Period summary
equivalentSimpleLength_m = g_mps2 * (period_s / (2*pi)).^2;
equivalentSimpleLength_in = equivalentSimpleLength_m / 0.0254;
results = table(files(:), runNames(:), channelPeriods_s(:, 1), channelPeriods_s(:, 2), ...
    channelDifference_pct, period_s, frequency_Hz, equivalentSimpleLength_in, ...
    'VariableNames', {'File', 'Run', 'Channel1Period_s', 'Channel2Period_s', ...
                      'ChannelDifference_pct', 'CombinedPeriod_s', ...
                      'CombinedFrequency_Hz', 'EquivalentSimpleLength_in'});
disp(" ");
disp(results);

%% Optional MOI calculations
% Compound pendulum about a fixed horizontal pivot:
%   I_CG = m*g*d*T^2/(4*pi^2) - m*d^2
%
% Bifilar pendulum for small rotation:
%   I_CG = m*g*a*b*T^2/(4*pi^2*L)
%
% The formulas return mass moment of inertia about the tested CG axis.
kgm2_to_lbm_in2 = 3417.171898;

for runIndex = 1:nRuns
    switch lower(testType(runIndex))
        case "none"
            fprintf("%s: MOI not calculated (testType is none).\n", files(runIndex));

        case "compound"
            d = pivotToCG_m(runIndex);
            assert(isfinite(d) && d > 0, ...
                "Enter a positive pivotToCG_m value for %s.", files(runIndex));
            moi_kgm2 = mass_kg * g_mps2 * d * period_s(runIndex)^2 / (4*pi^2) ...
                       - mass_kg * d^2;
            localPrintMoi(files(runIndex), moi_kgm2, kgm2_to_lbm_in2);

        case "bifilar"
            L = cordLength_m(runIndex);
            a = topHalfSpacing_m(runIndex);
            b = bottomHalfSpacing_m(runIndex);
            assert(all(isfinite([L a b])) && all([L a b] > 0), ...
                "Enter positive bifilar L, a, and b values for %s.", files(runIndex));
            moi_kgm2 = mass_kg * g_mps2 * a * b * period_s(runIndex)^2 ...
                       / (4*pi^2 * L);
            localPrintMoi(files(runIndex), moi_kgm2, kgm2_to_lbm_in2);

        otherwise
            error("Unknown testType '%s'. Use none, compound, or bifilar.", ...
                testType(runIndex));
    end
end

%% Local functions
function envelope = localRmsEnvelope(x, fs, rmsWindow_s, smoothWindow_s)
    nRms = max(3, round(rmsWindow_s * fs));
    nSmooth = max(3, round(smoothWindow_s * fs));
    envelope = sqrt(movmean(x.^2, nRms, "Endpoints", "shrink"));
    envelope = movmean(envelope, nSmooth, "Endpoints", "shrink");
end

function acf = localNormalizedAcf(x, maxLag)
    x = x(:) - mean(x);
    n = numel(x);
    nfft = 2^nextpow2(2*n - 1);
    fullAcf = real(ifft(abs(fft(x, nfft)).^2));
    maxLag = min(maxLag, n - 1);
    acf = fullAcf(1:maxLag+1);
    overlap = (n:-1:n-maxLag)';
    acf = acf ./ overlap;
    acf = acf / acf(1);
end

function period = localBestAcfPeriod(lags, acf, limits)
    inRange = lags >= limits(1) & lags <= limits(2);
    localPeak = [false; acf(2:end-1) > acf(1:end-2) & ...
                       acf(2:end-1) >= acf(3:end); false];
    candidates = find(inRange & localPeak);
    if isempty(candidates)
        candidates = find(inRange);
    end
    [~, best] = max(acf(candidates));
    period = lags(candidates(best));
end

function scaled = localScale01(x)
    lower = min(x, [], 1);
    span = max(x, [], 1) - lower;
    span(span == 0) = 1;
    scaled = (x - lower) ./ span;
end

function [psd, f] = localOneSidedPsd(x, fs)
    x = x(:) - mean(x);
    n = numel(x);
    window = 0.5 - 0.5*cos(2*pi*(0:n-1)'/(n-1));
    transform = fft(x .* window);
    psd = abs(transform(1:floor(n/2)+1)).^2 / (fs * sum(window.^2));
    if numel(psd) > 2
        psd(2:end-1) = 2 * psd(2:end-1);
    end
    f = (0:floor(n/2))' * fs / n;
end

function localPrintMoi(filename, moi_kgm2, conversion)
    fprintf("%s experimental MOI:\n", filename);
    fprintf("  %.8g kg*m^2\n", moi_kgm2);
    fprintf("  %.4f lbm*in^2\n", moi_kgm2 * conversion);
    if moi_kgm2 <= 0
        warning('%s', "The calculated MOI is non-positive. Check the selected period, " + ...
            "pivot distance, test model, and units.");
    end
end
