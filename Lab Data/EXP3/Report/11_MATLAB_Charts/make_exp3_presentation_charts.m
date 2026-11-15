%% EXP3 presentation charts - Group E. Every chart here is made by MATLAB (R2022b).
% Run from MATLAB:   make_exp3_presentation_charts
%   or              make_exp3_presentation_charts('C:\...\ExperimentalMethods')
% Reads (never changes):
%   Lab Data\EXP3\Report\09_Data_Tables\*.csv   X-Modal fitted frequencies, NX frequencies, MAC
%   Lab Data\EXP3\LabDay1, LabDay2              raw X-Modal .mat files (FRF + coherence per hit)
% Writes into this folder: C1..C8 PNG charts, chart_numbers.csv, chart_log.txt
% Rev 3 (2026-10-26): C4 (L-plate) and C5 (frame) now use the same layout as C1, minus the
% hand calc: modes 1-4, accelerometer vs NX free-free. They are saved as C4_Lplate_vs_NX.png and
% C5_frame_vs_NX.png; the older C4/C5 PNGs (bar charts) are no longer made.
% Blevins values are the hand calculation from the lab workbook (SS304, E = 193 GPa,
% rho = 8000 kg/m^3, nu = 0.3, a = 12.9 in, b = 5.875 in, h = 0.378 in, a/b interpolated).
function make_exp3_presentation_charts(workspaceRoot)
if nargin < 1 || isempty(workspaceRoot)
    workspaceRoot = fileparts(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))));
end
outDir = fileparts(mfilename('fullpath'));
exp3 = fullfile(workspaceRoot, 'Lab Data', 'EXP3');
tabs = fullfile(exp3, 'Report', '09_Data_Tables');
fid = fopen(fullfile(outDir, 'chart_log.txt'), 'w');
logf(sprintf('EXP3 chart run %s, MATLAB %s', datestr(now), version));

set(groot, 'defaultAxesFontName', 'Arial', 'defaultTextFontName', 'Arial', ...
    'defaultAxesFontSize', 17, 'defaultTextFontSize', 15, 'defaultFigureColor', 'w', ...
    'defaultAxesLineWidth', 1);
col.blev = [0.45 0.45 0.45]; col.nx = [0.00 0.32 0.62]; col.spr = [0.42 0.66 0.90];
col.acc = [0.90 0.40 0.10]; col.mic = [0.15 0.55 0.35]; col.p2 = [0.55 0.30 0.65];
col.p3 = [0.10 0.60 0.65]; col.band = [0.93 0.95 0.99];

opts = {'VariableNamingRule', 'preserve', 'TextType', 'string'};
T1a = readtable(fullfile(tabs, 'P1_Accel_NX_comparison.csv'), opts{:});
T1m = readtable(fullfile(tabs, 'P1_Mic_NX_comparison.csv'), opts{:});
T2  = readtable(fullfile(tabs, 'P2_Accel_NX_comparison.csv'), opts{:});
T3  = readtable(fullfile(tabs, 'P3_Accel_NX_comparison.csv'), opts{:});
fB  = [457.6; 616.2; 1260.1; 1352.7];          % Blevins, rectangle modes (3,1) (2,2) (4,1) (3,2)
numbers = [];                                   % every plotted value, for checking slide text

charts = {@c1_rectangle_methods, @c2_mic_center_vs_moved, @c3_example_frf, ...
          @c4_lplate_four_modes, @c5_frame_four_modes, @c6_all_plates, ...
          @c7_mac, @c8_coherence};
nOK = 0; nBad = 0;
for k = 1:numel(charts)
    try
        charts{k}(); nOK = nOK + 1;
    catch ME
        nBad = nBad + 1;
        logf(sprintf('FAILED %s: %s (line %d)', func2str(charts{k}), ME.message, ME.stack(1).line));
    end
end
if ~isempty(numbers)
    writetable(numbers, fullfile(outDir, 'chart_numbers.csv'));
end
logf(sprintf('done: %d charts written, %d failed', nOK, nBad));
fprintf('EXP3 charts: %d written, %d failed. See chart_log.txt\n', nOK, nBad);
fclose(fid);

    % ------------------------------------------------------------------
    function c1_rectangle_methods()
        fA = T1a.xmodal_f_Hz(1:4); fM = T1m.xmodal_f_Hz(1:4); fN = T1a.NX_freefree_Hz(1:4);
        d = 100 * ([fB fA fM] ./ fN - 1);
        f = newfig(1300, 720); ax = axes(f); hold(ax, 'on');
        patch(ax, [0.5 4.5 4.5 0.5], [-1 -1 1 1], col.band, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        text(ax, 4.45, -1.3, 'within \pm1%', 'HorizontalAlignment', 'right', 'Color', [0.35 0.45 0.65], 'FontSize', 13);
        hN = yline(ax, 0, '-', 'Color', col.nx, 'LineWidth', 2.5);
        off = [-0.24 0 0.24]; mk = {'s', 'o', '^'}; cc = {col.blev, col.acc, col.mic};
        h = gobjects(1, 3);
        for j = 1:3
            h(j) = plot(ax, (1:4) + off(j), d(:, j), mk{j}, 'MarkerSize', 14, 'LineStyle', 'none', ...
                'MarkerFaceColor', cc{j}, 'MarkerEdgeColor', 'k');
            for i = 1:4
                lbl = sprintf('%+.1f%%', d(i, j)); if abs(d(i, j)) < 0.05, lbl = '0.0%'; end
                text(ax, i + off(j), d(i, j) + 0.45, lbl, ...
                    'HorizontalAlignment', 'center', 'FontSize', 13, 'Color', cc{j} * 0.8);
            end
        end
        xlim(ax, [0.5 4.5]); ylim(ax, [-2 6]); grid(ax, 'on'); ax.XGrid = 'off';
        xticks(ax, 1:4);
        xticklabels(ax, {'Mode 1\newline1st bending', 'Mode 2\newline1st twist', ...
            'Mode 3\newline2nd bending', 'Mode 4\newlinebend + twist'});
        ylabel(ax, 'Difference from NX model (%)');
        legend(ax, [hN h], {'NX model (free-free) = 0', 'Blevins hand calc', 'Accelerometer (Day 1)', 'Microphone (Day 2)'}, ...
            'Location', 'southoutside', 'NumColumns', 4, 'Box', 'off');
        save_png(f, 'C1_rectangle_four_methods.png');
        addnum('C1 rectangle vs NX free-free', ["Blevins" "Accel" "Mic"], d, [fB fA fM], fN);
    end

    function c2_mic_center_vs_moved()
        d1 = fullfile(exp3, 'LabDay1', 'Steel_Rectagle', 'MIC');
        d2 = fullfile(exp3, 'LabDay2', 'RectRedo');
        n1 = arrayfun(@(p) sprintf('MicRect%dx%d.mat', ceil(p/5), mod(p-1, 5) + 1), 1:15, 'UniformOutput', false);
        n2 = arrayfun(@(p) sprintf('Mic%d.mat', p), 1:15, 'UniformOutput', false);
        [fr, Hc] = read_set(d1, n1); [~, Hm] = read_set(d2, n2);
        rc = sqrt(mean(abs(Hc).^2, 2)); rm = sqrt(mean(abs(Hm).^2, 2));
        b = fr > 430 & fr < 480; rc = rc / max(rc(b)); rm = rm / max(rm(b));
        f = newfig(1400, 760); ax = axes(f); hold(ax, 'on');
        fa = T1a.xmodal_f_Hz(1:6);
        for i = 1:6
            xline(ax, fa(i), ':', 'Color', [0.55 0.55 0.55], 'LineWidth', 1.2, 'HandleVisibility', 'off');
        end
        h1 = plot(ax, fr, 20*log10(rc), 'Color', [0.55 0.55 0.55], 'LineWidth', 2);
        h2 = plot(ax, fr, 20*log10(rm), 'Color', col.mic, 'LineWidth', 2.4);
        xlim(ax, [300 2400]); ylim(ax, [-45 32]); grid(ax, 'on');
        tx = {fa(1), '1 bend'; fa(2), '2 twist'; mean(fa(3:4)), '3, 4'; mean(fa(5:6)), '5, 6'};
        for i = 1:4
            text(ax, tx{i, 1}, 29, tx{i, 2}, 'HorizontalAlignment', 'center', 'FontSize', 13, 'Color', [0.3 0.3 0.3]);
        end
        for i = [2 4]
            [~, k] = min(abs(fr - fa(i)));
            yy = 20*log10(max(rc(k-2:k+2)));
            text(ax, fa(i), yy - 6, {'missing', 'at center'}, 'HorizontalAlignment', 'center', ...
                'FontSize', 13, 'Color', [0.35 0.35 0.35], 'FontWeight', 'bold');
        end
        xlabel(ax, 'Frequency (Hz)'); ylabel(ax, {'Mic response, all 15 hits', '(dB, mode 1 = 0)'});
        legend(ax, [h1 h2], {'Day 1: mic over the plate center', 'Day 2: mic moved near the far edge'}, ...
            'Location', 'southoutside', 'NumColumns', 2, 'Box', 'off');
        save_png(f, 'C2_mic_center_vs_moved.png');
        k6 = arrayfun(@(x) find(abs(fr - x) == min(abs(fr - x)), 1), fa);
        addnum('C2 mic dB at accel mode freqs', ["Center" "Moved"], ...
            [20*log10(rc(k6)) 20*log10(rm(k6))], [rc(k6) rm(k6)], fa);
    end

    function c3_example_frf()
        [fr, H, Co] = read_xmodal(fullfile(exp3, 'LabDay1', 'Steel_Rectagle', 'Rect3x5.mat'));
        f = newfig(1400, 780);
        tl = tiledlayout(f, 3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
        ax1 = nexttile(tl, [2 1]); hold(ax1, 'on');
        db = 20*log10(abs(H));
        plot(ax1, fr, db, 'Color', col.acc, 'LineWidth', 1.8);
        fa = T1a.xmodal_f_Hz(1:6);
        for i = 1:6
            w = abs(fr - fa(i)) < 9; dw = db(w); fw = fr(w); [pk, k] = max(dw);
            if i == 5, dx = -45; elseif i == 6, dx = 45; else, dx = 0; end
            text(ax1, fw(k) + dx, pk + 5, sprintf('%d', i), 'HorizontalAlignment', 'center', ...
                'FontWeight', 'bold', 'FontSize', 16, 'Color', [0.2 0.2 0.2]);
        end
        xlim(ax1, [0 2500]); grid(ax1, 'on'); ylabel(ax1, 'Response / hammer force (dB)');
        yl = ylim(ax1); ylim(ax1, [yl(1) yl(2) + 10]); ax1.XTickLabel = [];
        ax2 = nexttile(tl); hold(ax2, 'on');
        plot(ax2, fr, Co, 'Color', col.nx, 'LineWidth', 1.6);
        yline(ax2, 0.9, '--', 'Color', [0.4 0.4 0.4]);
        xlim(ax2, [0 2500]); ylim(ax2, [0 1.05]); grid(ax2, 'on');
        ylabel(ax2, 'Coherence'); xlabel(ax2, 'Frequency (Hz)');
        save_png(f, 'C3_example_hit_FRF_and_coherence.png');
        addnum('C3 example hit (rectangle pt 15) median coherence 200-2500 Hz', "Coherence", ...
            median(Co(fr > 200 & fr < 2500)), NaN, NaN);
    end

    function c4_lplate_four_modes()
        % Same look as C1 (rectangle) without the hand calc: first four modes, accelerometer vs NX free-free.
        d = 100 * (T2.xmodal_f_Hz(1:4) ./ T2.NX_freefree_Hz(1:4) - 1);
        one_sensor_chart(d, [-7 2], -1.3, {'Mode 1\newline1st bending', 'Mode 2\newline1st twist', ...
            'Mode 3\newline2nd bending', 'Mode 4\newlinebend + twist'}, 'C4_Lplate_vs_NX.png');
        addnum('C4 L-plate vs NX free-free (modes 1-4)', "Accel", d, T2.xmodal_f_Hz(1:4), T2.NX_freefree_Hz(1:4));
    end

    function c5_frame_four_modes()
        % Same look as C1 (rectangle) without the hand calc: first four modes, accelerometer vs NX free-free.
        d = 100 * (T3.xmodal_f_Hz(1:4) ./ T3.NX_freefree_Hz(1:4) - 1);
        one_sensor_chart(d, [-3 8], 1.3, {'Mode 1\newline1st bending', 'Mode 2\newline1st twist', ...
            'Mode 3\newlinebend + twist', 'Mode 4\newline2nd bending'}, 'C5_frame_vs_NX.png');
        addnum('C5 frame vs NX free-free (modes 1-4)', "Accel", d, T3.xmodal_f_Hz(1:4), T3.NX_freefree_Hz(1:4));
    end

    function one_sensor_chart(d, yl, bandLabelY, labels, fname)
        % Copy of the C1 layout: NX free-free line at 0, +/-1% band, one marker per mode.
        f = newfig(1300, 720); ax = axes(f); hold(ax, 'on');
        patch(ax, [0.5 4.5 4.5 0.5], [-1 -1 1 1], col.band, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        text(ax, 4.45, bandLabelY, 'within \pm1%', 'HorizontalAlignment', 'right', 'Color', [0.35 0.45 0.65], 'FontSize', 13);
        hN = yline(ax, 0, '-', 'Color', col.nx, 'LineWidth', 2.5);
        h = plot(ax, 1:4, d, 'o', 'MarkerSize', 14, 'LineStyle', 'none', ...
            'MarkerFaceColor', col.acc, 'MarkerEdgeColor', 'k');
        for i = 1:4
            lbl = sprintf('%+.1f%%', d(i)); if abs(d(i)) < 0.05, lbl = '0.0%'; end
            text(ax, i, d(i) + 0.45, lbl, 'HorizontalAlignment', 'center', 'FontSize', 13, 'Color', col.acc * 0.8);
        end
        xlim(ax, [0.5 4.5]); ylim(ax, yl); grid(ax, 'on'); ax.XGrid = 'off';
        xticks(ax, 1:4); xticklabels(ax, labels);
        ylabel(ax, 'Difference from NX model (%)');
        legend(ax, [hN h], {'NX model (free-free) = 0', 'Accelerometer (Day 2)'}, ...
            'Location', 'southoutside', 'NumColumns', 2, 'Box', 'off');
        save_png(f, fname);
    end

    function c6_all_plates()
        S = {T1a, T1m, T2, T3};
        names = {'Rectangle, accelerometer', 'Rectangle, microphone', 'L-plate, accelerometer', 'Frame, accelerometer'};
        cc = {col.acc, col.mic, col.p2, col.p3}; mk = {'o', '^', 'd', 's'}; off = [-0.24 -0.08 0.08 0.24];
        f = newfig(1300, 760); ax = axes(f); hold(ax, 'on');
        patch(ax, [0.5 6.5 6.5 0.5], [-2 -2 2 2], col.band, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        hN = yline(ax, 0, '-', 'Color', col.nx, 'LineWidth', 2.5);
        h = gobjects(1, 4); allD = NaN(6, 4);
        for j = 1:4
            T = S{j}; d = 100 * (T.xmodal_f_Hz(1:6) ./ T.NX_freefree_Hz(1:6) - 1); allD(:, j) = d;
            h(j) = plot(ax, (1:6) + off(j), d, mk{j}, 'MarkerSize', 13, 'LineStyle', 'none', ...
                'MarkerFaceColor', cc{j}, 'MarkerEdgeColor', 'k');
        end
        text(ax, 6.45, 2.5, 'within \pm2%', 'HorizontalAlignment', 'right', 'Color', [0.35 0.45 0.65], 'FontSize', 13);
        xlim(ax, [0.5 6.5]); ylim(ax, [-7 7.5]); grid(ax, 'on'); ax.XGrid = 'off';
        xticks(ax, 1:6); xticklabels(ax, compose('Mode %d', 1:6));
        ylabel(ax, 'Test vs NX model (%)');
        legend(ax, [h hN], [names {'NX model = 0'}], 'Location', 'southoutside', 'NumColumns', 3, 'Box', 'off');
        save_png(f, 'C6_all_plates_vs_NX.png');
        addnum('C6 all plates vs NX free-free', ["RectAccel" "RectMic" "LPlate" "Frame"], allD, NaN(6, 4), NaN(6, 1));
    end

    function c7_mac()
        files = {'P1_Accel', 'P1_Mic', 'P2_Accel', 'P3_Accel'};
        ttl = {'Rectangle, accelerometer', 'Rectangle, microphone', 'L-plate', 'Frame'};
        cm = [linspace(1, 0, 256)' linspace(1, 0.32, 256)' linspace(1, 0.62, 256)'];
        f = newfig(1400, 1200);
        tl = tiledlayout(f, 2, 2, 'TileSpacing', 'compact', 'Padding', 'loose');
        for k = 1:4
            M = readmatrix(fullfile(tabs, [files{k} '_MAC_test_vs_NX.csv']), 'NumHeaderLines', 1);
            M = M(1:min(6, size(M, 1)), :);                % first six test modes vs NX modes 1-6
            ax = nexttile(tl); imagesc(ax, M); axis(ax, 'image'); colormap(ax, cm); caxis(ax, [0 1]);
            for i = 1:size(M, 1)
                for j = 1:size(M, 2)
                    text(ax, j, i, sprintf('%.2f', M(i, j)), 'HorizontalAlignment', 'center', ...
                        'FontSize', 12, 'Color', (M(i, j) > 0.55) * [1 1 1]);
                end
            end
            xticks(ax, 1:size(M, 2)); yticks(ax, 1:size(M, 1));
            xlabel(ax, 'NX mode'); ylabel(ax, 'Test mode'); title(ax, ttl{k}, 'FontWeight', 'normal');
        end
        cb = colorbar(ax); cb.Layout.Tile = 'east'; cb.Label.String = 'Shape match (MAC)';
        save_png(f, 'C7_shape_match_MAC.png');
    end

    function c8_coherence()
        sets = {
            'P1_Accel', fullfile(exp3, 'LabDay1', 'Steel_Rectagle'), 'Rectangle, accelerometer', [200 2500];
            'P1_Mic',   fullfile(exp3, 'LabDay2', 'RectRedo'),      'Rectangle, microphone',    [200 2500];
            'P2_Accel', fullfile(exp3, 'LabDay2', 'LPlate'),        'L-plate',                  [200 2500];
            'P3_Accel', fullfile(exp3, 'LabDay2', 'Rectcutout'),    'Frame',                    [100 1300]};
        f = newfig(1400, 900);
        tl = tiledlayout(f, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
        for k = 1:4
            G = readtable(fullfile(tabs, [sets{k, 1} '_grid_points.csv']), opts{:});
            [fr, ~, Co] = read_set(sets{k, 2}, cellstr(G.raw_file));
            band = fr > sets{k, 4}(1) & fr < sets{k, 4}(2);
            med = median(Co(band, :), 1)';
            ax = nexttile(tl); hold(ax, 'on');
            bar(ax, G.node, med, 0.7, 'FaceColor', col.nx, 'EdgeColor', 'none');
            yline(ax, 0.9, '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
            ylim(ax, [0.6 1.0]); xlim(ax, [0.3 max(G.node) + 0.7]); grid(ax, 'on'); ax.XGrid = 'off';
            xticks(ax, G.node);
            title(ax, sprintf('%s (%d-%d Hz)', sets{k, 3}, sets{k, 4}), 'FontWeight', 'normal');
            xlabel(ax, 'Hit point'); ylabel(ax, 'Median coherence');
            addnum(['C8 coherence ' sets{k, 1}], "MedianCoherence", med, NaN(size(med)), NaN(size(med)));
        end
        save_png(f, 'C8_coherence_by_hit_point.png');
    end

    % ---------------------------- helpers -----------------------------
    function f = newfig(w, h)
        f = figure('Visible', 'off', 'Units', 'pixels', 'Position', [40 40 w h], 'Color', 'w');
    end
    function save_png(f, name)
        exportgraphics(f, fullfile(outDir, name), 'Resolution', 200, 'BackgroundColor', 'white');
        close(f); logf(['wrote ' name]);
    end
    function addnum(chart, cols, d, vals, ref)
        n = size(d, 1);
        for j = 1:size(d, 2)
            r = table(repmat(string(chart), n, 1), repmat(string(cols(min(j, numel(cols)))), n, 1), (1:n)', ...
                d(:, j), vals(:, min(j, size(vals, 2))), ref(:, 1), ...
                'VariableNames', {'chart', 'series', 'mode', 'value_plotted', 'frequency_Hz', 'reference_Hz'});
            if isempty(numbers), numbers = r; else, numbers = [numbers; r]; end %#ok<AGROW>
        end
    end
    function logf(msg)
        fprintf(fid, '%s\n', msg);
    end
end

% -------------------- raw X-Modal file readers (local) --------------------
function [fr, H, Co] = read_xmodal(file)
S = load(file); U = S.UFCELLS; fr = []; H = []; Co = [];
for k = 1:numel(U)
    u = U{k};
    if isfield(u, 'DSN') && u.DSN == 58 && isfield(u, 'Type')
        if u.Type == 4
            H = u.DataValues(:);
            fr = u.AbscissaMinimum + u.AbscissaIncrement * (0:numel(H) - 1)';
        elseif u.Type == 6
            Co = real(u.DataValues(:));
        end
    end
end
if isempty(H), error('No FRF (dataset 58, type 4) in %s', file); end
end

function [fr, H, Co] = read_set(folder, names)
fr = []; H = []; Co = [];
for k = 1:numel(names)
    [fk, Hk, Ck] = read_xmodal(fullfile(folder, names{k}));
    if isempty(fr), fr = fk; H = zeros(numel(fk), numel(names)); Co = H; end
    H(:, k) = Hk; Co(:, k) = Ck;
end
end
