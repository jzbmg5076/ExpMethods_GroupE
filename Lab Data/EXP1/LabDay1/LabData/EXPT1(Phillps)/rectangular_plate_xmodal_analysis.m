%% Rectangular plate - X-Modal period, frequency, and MOI analysis
% Experiment 1: Moments of Inertia
%
% Lab coordinate convention (from the lab notes and observed motion):
%   x = into/out of the table (through the plate thickness)
%   y = along the table edge (along the 12.9 in plate dimension)
%   z = vertical (along the 5.9 in plate dimension)
%
% Recorded commercial runs:
%   test2settled.MAT : X displacement, into/out of the table.
%                     Rotation is about y, so this can estimate Iyy with
%                     the compound-pendulum equation.
%   Ytest1.MAT       : Y displacement, side to side. With two equal,
%                     parallel suspension chains this is principally a
%                     translating (four-bar/simple-pendulum) mode. Its
%                     period does not determine plate MOI.
%
% The IEPE commercial accelerometer is AC coupled. The raw spectra are
% dominated by high-frequency ringing after small chain/fixture events.
% Therefore, the mechanical period is extracted from the repeating RMS
% envelope, not from the largest raw FFT peak.
%
% Base MATLAB only; no Signal Processing Toolbox is required.

clear; close all; clc;

%% Files and output controls
dataFolder = fileparts(mfilename('fullpath'));
saveOutputs = true;
outputFolder = fullfile(dataFolder, 'XModal_Figures');

%% Rectangular-plate measurements from the lab workbook
mass_kg = 1.687;
plateLengthY_in = 12.9;
plateHeightZ_in = 5.9;
plateThicknessX_in = 0.45;

% Suspension measurements entered in MOI_Lab_Data_Collection_Workflow_1.
chainLength_in = 18.757;
pivotToAccelerometer_in = 21.5;

% The commercial accelerometer appears close to the plate CG in the setup
% photos. The X-run compound calculation therefore uses the recorded
% table/pivot-to-accelerometer distance as pivot-to-CG distance. Change this
% value if a direct pivot-axis-to-CG measurement becomes available.
pivotToCG_X_in = pivotToAccelerometer_in;

%% Run definitions
% The period bounds select one COMPLETE mechanical cycle. They deliberately
% exclude the much higher structural ringing frequencies.
runs(1).file = 'test2settled.MAT';
runs(1).name = 'X run: into/out of table';
runs(1).motion = 'Compound-pendulum candidate about y';
runs(1).targetAxis = 'Iyy';
runs(1).primaryChannel = 1;
runs(1).periodBounds_s = [1.25, 1.75];
runs(1).method = 'compound';

runs(2).file = 'Ytest1.MAT';
runs(2).name = 'Y run: side to side';
runs(2).motion = 'Parallel-chain translation';
runs(2).targetAxis = 'Ixx';
runs(2).primaryChannel = 1;
runs(2).periodBounds_s = [0.85, 1.25];
runs(2).method = 'simple';

%% Processing settings
rmsWindow_s = 0.010;
envelopeSmooth_s = 0.050;
maxAcfLag_s = 2.5;

%% Constants and analytical reference
g_mps2 = 9.80665;
in_to_m = 0.0254;
kgm2_to_lbm_in2 = 3417.171898;

Ly = plateLengthY_in * in_to_m;
Lz = plateHeightZ_in * in_to_m;
Lx = plateThicknessX_in * in_to_m;

% Rectangular-prism mass moments about the CG in the LAB coordinates.
Ianalytical_kgm2.Ixx = mass_kg * (Ly^2 + Lz^2) / 12;
Ianalytical_kgm2.Iyy = mass_kg * (Lx^2 + Lz^2) / 12;
Ianalytical_kgm2.Izz = mass_kg * (Lx^2 + Ly^2) / 12;

fprintf('\nRECTANGULAR PLATE - X-MODAL ANALYSIS\n');
fprintf('Lab axes: x through thickness, y along 12.9 in edge, z vertical\n');
fprintf('Mass %.4f kg; dimensions x/y/z = %.3f/%.3f/%.3f in\n', ...
    mass_kg, plateThicknessX_in, plateLengthY_in, plateHeightZ_in);
fprintf('Analytical Ixx/Iyy/Izz = %.3f / %.3f / %.3f lbm*in^2\n\n', ...
    Ianalytical_kgm2.Ixx * kgm2_to_lbm_in2, ...
    Ianalytical_kgm2.Iyy * kgm2_to_lbm_in2, ...
    Ianalytical_kgm2.Izz * kgm2_to_lbm_in2);

%% Analyze each X-Modal record
nRuns = numel(runs);
period_s = NaN(nRuns, 1);
frequency_Hz = NaN(nRuns, 1);
channelPeriod_s = NaN(nRuns, 2);
channelRms = NaN(nRuns, 2);
experimentalMOI_kgm2 = NaN(nRuns, 1);
analyticalMOI_kgm2 = NaN(nRuns, 1);
percentError = NaN(nRuns, 1);
equivalentSimpleLength_in = NaN(nRuns, 1);
quality = strings(nRuns, 1);

for runIndex = 1:nRuns
    run = runs(runIndex);
    filePath = fullfile(dataFolder, run.file);
    assert(isfile(filePath), 'Missing X-Modal file: %s', filePath);

    S = load(filePath);
    assert(isfield(S, 'UFCELLS') && numel(S.UFCELLS) >= 4, ...
        '%s does not have the expected X-Modal UFCELLS structure.', run.file);

    dt_s = double(S.UFCELLS{3}.AbscissaIncrement);
    fs_Hz = 1 / dt_s;
    signal = [double(S.UFCELLS{3}.DataValues(:)), ...
              double(S.UFCELLS{4}.DataValues(:))];
    signal = signal - mean(signal, 1);
    time_s = (0:size(signal, 1)-1)' * dt_s;
    duration_s = size(signal, 1) * dt_s;
    channelRms(runIndex, :) = sqrt(mean(signal.^2, 1));

    nRms = max(3, round(rmsWindow_s * fs_Hz));
    nSmooth = max(3, round(envelopeSmooth_s * fs_Hz));
    envelope = sqrt(movmean(signal.^2, nRms, 1, 'Endpoints', 'shrink'));
    envelope = movmean(envelope, nSmooth, 1, 'Endpoints', 'shrink');

    maxLag = min(round(maxAcfLag_s * fs_Hz), size(signal, 1)-1);
    acfLag_s = (0:maxLag)' / fs_Hz;
    acf = NaN(maxLag+1, 2);
    for channelIndex = 1:2
        acf(:, channelIndex) = localNormalizedAcf(envelope(:, channelIndex), maxLag);
        channelPeriod_s(runIndex, channelIndex) = localBestAcfPeriod( ...
            acfLag_s, acf(:, channelIndex), run.periodBounds_s);
    end

    period_s(runIndex) = channelPeriod_s(runIndex, run.primaryChannel);
    frequency_Hz(runIndex) = 1 / period_s(runIndex);
    equivalentSimpleLength_in(runIndex) = ...
        g_mps2 * (period_s(runIndex)/(2*pi))^2 / in_to_m;

    periodDifference_pct = 100 * abs(diff(channelPeriod_s(runIndex, :))) ...
        / mean(channelPeriod_s(runIndex, :));
    rmsRatio = max(channelRms(runIndex, :)) / min(channelRms(runIndex, :));

    fprintf('%s\n', run.name);
    fprintf('  File: %s\n', run.file);
    fprintf('  %d samples at %.0f Hz; duration %.3f s\n', ...
        size(signal, 1), fs_Hz, duration_s);
    fprintf('  Channel 1 period: %.4f s; channel 2 period: %.4f s\n', ...
        channelPeriod_s(runIndex, 1), channelPeriod_s(runIndex, 2));
    fprintf('  Adopted period: %.4f s; frequency: %.4f Hz\n', ...
        period_s(runIndex), frequency_Hz(runIndex));
    fprintf('  Channel-period difference: %.2f%%; RMS amplitude ratio: %.1f\n', ...
        periodDifference_pct, rmsRatio);

    switch run.method
        case 'compound'
            d_m = pivotToCG_X_in * in_to_m;
            experimentalMOI_kgm2(runIndex) = mass_kg * ...
                (g_mps2*d_m*period_s(runIndex)^2/(4*pi^2) - d_m^2);
            analyticalMOI_kgm2(runIndex) = Ianalytical_kgm2.(run.targetAxis);
            percentError(runIndex) = 100 * ...
                (experimentalMOI_kgm2(runIndex) - analyticalMOI_kgm2(runIndex)) ...
                / analyticalMOI_kgm2(runIndex);

            firstTerm_m2 = g_mps2*d_m*period_s(runIndex)^2/(4*pi^2);
            moiTerm_m2 = firstTerm_m2 - d_m^2;
            periodCondition = abs(2*firstTerm_m2/moiTerm_m2);

            fprintf('  Compound input d = %.3f in (logged table/pivot to accelerometer)\n', ...
                pivotToCG_X_in);
            fprintf('  Experimental %s = %.5g kg*m^2 = %.3f lbm*in^2\n', ...
                run.targetAxis, experimentalMOI_kgm2(runIndex), ...
                experimentalMOI_kgm2(runIndex)*kgm2_to_lbm_in2);
            fprintf('  Analytical   %s = %.5g kg*m^2 = %.3f lbm*in^2\n', ...
                run.targetAxis, analyticalMOI_kgm2(runIndex), ...
                analyticalMOI_kgm2(runIndex)*kgm2_to_lbm_in2);
            fprintf('  Signed error versus analytical = %+.1f%%\n', percentError(runIndex));
            fprintf('  Conditioning: a 1%% period error produces about %.0f%% MOI error\n', ...
                periodCondition);

            if experimentalMOI_kgm2(runIndex) <= 0
                quality(runIndex) = 'Reject: non-positive compound MOI';
            elseif periodDifference_pct > 5 || periodCondition > 20
                quality(runIndex) = 'Provisional: geometry/conditioning dominates';
            else
                quality(runIndex) = 'Usable compound estimate';
            end

        case 'simple'
            fprintf('  Equivalent simple-pendulum length = %.3f in\n', ...
                equivalentSimpleLength_in(runIndex));
            fprintf(['  MOI is not calculated: two parallel chains allow primarily\n' ...
                     '  translational motion, so mass distribution cancels from T.\n']);
            quality(runIndex) = 'Period usable; MOI not identifiable from this motion';
    end
    fprintf('  Assessment: %s\n\n', quality(runIndex));

    %% Four-panel diagnostic plot
    fig = figure('Color', 'w', 'Position', [70 60 1200 820], ...
        'Name', run.name);
    tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    nexttile;
    plot(time_s, signal, 'LineWidth', 0.6);
    grid on; box off; xlim([0, time_s(end)]);
    xlabel('Time (s)'); ylabel('Recorded amplitude (export units)');
    title('Raw X-Modal channels');
    legend('Channel 1', 'Channel 2', 'Location', 'best');

    nexttile;
    plot(time_s, localScale01(envelope), 'LineWidth', 1.0);
    grid on; box off; xlim([0, time_s(end)]); ylim([0, 1.05]);
    xlabel('Time (s)'); ylabel('Normalized RMS envelope');
    title(sprintf('Repeating vibration envelope: T = %.3f s, f = %.3f Hz', ...
        period_s(runIndex), frequency_Hz(runIndex)));
    legend('Channel 1', 'Channel 2', 'Location', 'best');

    nexttile; hold on;
    for channelIndex = 1:2
        [psd, spectrumFrequency_Hz] = localOneSidedPsd(signal(:, channelIndex), fs_Hz);
        semilogy(spectrumFrequency_Hz, psd, 'LineWidth', 0.7);
    end
    hold off; grid on; box off;
    xlim([0, fs_Hz/2]);
    xlabel('Frequency (Hz)'); ylabel('PSD (export units^2/Hz)');
    title('Raw spectrum: large peaks are structural ringing');
    legend('Channel 1', 'Channel 2', 'Location', 'best');

    nexttile;
    plot(acfLag_s, acf, 'LineWidth', 0.9); hold on;
    xline(period_s(runIndex), '--k', sprintf('Adopted T = %.3f s', period_s(runIndex)), ...
        'LineWidth', 1.2);
    xline(run.periodBounds_s(1), ':', 'HandleVisibility', 'off');
    xline(run.periodBounds_s(2), ':', 'HandleVisibility', 'off');
    hold off; grid on; box off;
    xlim([0, maxAcfLag_s]); ylim([-0.4, 1.05]);
    xlabel('Lag (s)'); ylabel('Normalized envelope autocorrelation');
    title('Mechanical period from envelope autocorrelation');
    legend('Channel 1', 'Channel 2', 'Location', 'best');

    sgtitle(sprintf('%s | %s', run.name, run.file), 'Interpreter', 'none');

    if saveOutputs
        if ~isfolder(outputFolder), mkdir(outputFolder); end
        outputName = sprintf('%s_rectangular_plate_xmodal.png', ...
            erase(run.file, '.MAT'));
        exportgraphics(fig, fullfile(outputFolder, outputName), 'Resolution', 180);
    end
end

%% Setup-consistency checks and summary table
fprintf('SETUP CONSISTENCY CHECKS\n');
fprintf('  Logged chain length: %.3f in\n', chainLength_in);
fprintf('  Logged table/pivot to accelerometer: %.3f in\n', ...
    pivotToAccelerometer_in);
fprintf('  Their difference: %.3f in; plate half-height: %.3f in\n', ...
    pivotToAccelerometer_in-chainLength_in, plateHeightZ_in/2);
fprintf(['  X-run period implies a simple-pendulum length of %.3f in, close to\n' ...
         '  the logged 21.5 in distance. This supports the 0.67 Hz mode,\n' ...
         '  but also makes the compound-MOI subtraction poorly conditioned.\n\n'], ...
    equivalentSimpleLength_in(1));

results = table(string({runs.file})', string({runs.name})', ...
    channelPeriod_s(:, 1), channelPeriod_s(:, 2), period_s, frequency_Hz, ...
    equivalentSimpleLength_in, experimentalMOI_kgm2, ...
    experimentalMOI_kgm2*kgm2_to_lbm_in2, analyticalMOI_kgm2, ...
    analyticalMOI_kgm2*kgm2_to_lbm_in2, percentError, quality, ...
    'VariableNames', {'File','Run','Channel1Period_s','Channel2Period_s', ...
    'AdoptedPeriod_s','Frequency_Hz','EquivalentSimpleLength_in', ...
    'ExperimentalMOI_kgm2','ExperimentalMOI_lbm_in2', ...
    'AnalyticalMOI_kgm2','AnalyticalMOI_lbm_in2','SignedError_pct','Assessment'});
disp(results);

if saveOutputs
    writetable(results, fullfile(outputFolder, ...
        'rectangular_plate_xmodal_results.csv'));
end

fprintf(['NOTE: only one X-Modal record exists for each motion. The professor\n' ...
         'requested multiple estimates for statistics. Treat these as Day 1\n' ...
         'estimates and repeat each configuration before final reporting.\n']);

%% Local functions
function acf = localNormalizedAcf(x, maxLag)
    x = x(:) - mean(x);
    n = numel(x);
    nfft = 2^nextpow2(2*n - 1);
    fullAcf = real(ifft(abs(fft(x, nfft)).^2));
    maxLag = min(maxLag, n-1);
    acf = fullAcf(1:maxLag+1);
    overlap = (n:-1:n-maxLag)';
    acf = acf ./ overlap;
    acf = acf / acf(1);
end

function period = localBestAcfPeriod(lags, acf, bounds)
    inRange = lags >= bounds(1) & lags <= bounds(2);
    localMaximum = [false; acf(2:end-1) > acf(1:end-2) & ...
        acf(2:end-1) >= acf(3:end); false];
    candidates = find(inRange & localMaximum);
    if isempty(candidates), candidates = find(inRange); end
    [~, index] = max(acf(candidates));
    period = lags(candidates(index));
end

function scaled = localScale01(x)
    lower = min(x, [], 1);
    span = max(x, [], 1) - lower;
    span(span == 0) = 1;
    scaled = (x-lower) ./ span;
end

function [psd, f] = localOneSidedPsd(x, fs)
    x = x(:) - mean(x);
    n = numel(x);
    window = 0.5 - 0.5*cos(2*pi*(0:n-1)'/(n-1));
    transform = fft(x .* window);
    psd = abs(transform(1:floor(n/2)+1)).^2 / (fs*sum(window.^2));
    if numel(psd) > 2, psd(2:end-1) = 2*psd(2:end-1); end
    f = (0:floor(n/2))' * fs/n;
end
