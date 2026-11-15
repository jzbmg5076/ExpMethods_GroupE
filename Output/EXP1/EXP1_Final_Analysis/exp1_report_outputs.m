%% EXP1 Report Outputs: every table, number, and figure used in the report
% EXP1_Final_Analysis, step 3 of 3 (run run_exp1_all.m to do everything).
%
% Steps 1 and 2 must run first:
%   combined_plate_pendulum_analysis.m  -> combined_output/*.csv
%   plate_moi_comparison_analysis.m     -> combined_output/moi_comparison/*.csv
%
% This script adds everything the report uses that steps 1 and 2 do not:
%   - Arduino bifilar frequencies (read straight from the Arduino .txt files)
%   - paired Arduino + commercial frequencies for the bifilar test
%   - uncertainty of every pendulum result and the pivot-distance sensitivity
%   - density check of every plate (weighed mass / measured volume)
%   - principal-axis tilt angles of every plate and the assembly
%   - report Tables 1, 3, 5, 6, 7, 8, a run log, and a sensitivity table
%   - sample calculations with the numbers substituted
%   - report figures: signal processing, bifilar sensor check, comparison
%
% Written with plain arrays and text files so it runs in MATLAB (and GNU
% Octave). All inertias are lbm*in^2, lengths in, mass lbm, g = 386.09 in/s^2.

clear;
clc;
close all;

%% Paths
script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
    script_dir = pwd;
end
em_root = fileparts(fileparts(fileparts(script_dir))); % ExperimentalMethods root (folder is now 3 levels down: Output/EXP1/<this folder>)
data_dir = fullfile(em_root,'Lab Data','EXP1','LabDay2'); % raw data moved here in the Sep 2026 folder reorg
combined_dir = fullfile(script_dir,'combined_output');
comparison_dir = fullfile(combined_dir,'moi_comparison');
out_dir = fullfile(script_dir,'report_outputs');
if ~exist(out_dir,'dir')
    mkdir(out_dir);
end
show_figures = true;

%% Inputs the report relies on (edit here if anything changes)
g_in_s2 = 386.0886;           % standard gravity [in/s^2]
u_length_in = 0.25;           % chain length / pivot distance reading (about half a link)
u_radius_in = 0.125;          % bifilar radius reading
arduino_default_duration_s = 1.833;   % Day 1 measured: 2048 samples in 1833 ms
arduino_channel = 'X';        % Arduino axis that saw the twist
arduino_band_hz = [1.1,2.3];  % same band as the commercial bifilar analysis
arduino_files = {'Bifolar1Arduino.txt','Bifolar2Arduino.txt','Bifolar3Arduino.txt'};

% Report configuration numbers mapped to the MATLAB body numbers
%   Config 1 = Plate 4 (rectangle), Config 2 = Plate 1 (HDPE),
%   Config 3 = Plate 2 (frame),     Config 4 = Assembly 5
config_body = [4,1,2,5];
config_desc = {'Rectangle 12.9 x 5.9 in, 6061-T651 aluminum, 12 holes', ...
    'Notched L plate 15.8 x 7.8 in, HDPE, 16 holes', ...
    'Frame 23.9 x 12.0 in with offset opening, 6061 aluminum, 16 holes', ...
    'Config 2 on Config 1, HDPE rotated 162.7 deg about z'};
config_role = {'Symmetric reference; tested with both sensors', ...
    'Asymmetric shape and a second material', ...
    'Large, heavy part with an internal opening', ...
    'Mixed-material assembly with no common CG or axis'};
handbook_density = [2.70,0.95,2.70];          % g/cm^3 for Configs 1-3
handbook_text = {'2.70 (6061)','0.93-0.97 (HDPE)','2.70 (6061)'};
% NX origin for Config 2 is 6.6 cm above the MATLAB origin (NX page 3)
config_cg_shift_in = [0,0,0; 0,-6.6/2.54,0; 0,0,0; 0,0,0];

% Pendulum tests in the order of experiments(1:3) in step 1, with the lab
% axis names used in the report (named by the test / sensor orientation)
test_config = [3,2,1];
test_lab_axis = {'Ixx','Iyy','Izz'};
test_name = {'Compound, V-harness from one bolt', ...
    'Compound, two chains to top corners', ...
    'Bifilar, two vertical chains'};
test_files = {'YData1-3','IntoTable1-4','Bifolar1-3 (.MAT + Arduino.txt)'};

%% Read the results from steps 1 and 2
mass = read_csv(fullfile(combined_dir,'plate_and_assembly_mass_properties_lbm_in2.csv'));
runs = read_csv(fullfile(combined_dir,'experimental_run_results.csv'));
summ = read_csv(fullfile(combined_dir,'pendulum_summary_results_lbm_in2.csv'));
asm = read_csv(fullfile(combined_dir,'combined_plate_assembly_results_lbm_in2.csv'));
src = read_csv(fullfile(comparison_dir,'plate_moi_source_values_lbm_in2.csv'));
nxmass = read_csv(fullfile(comparison_dir,'plate_mass_basis_comparison.csv'));

kg_to_lbm = 2.2046226218487757;
body_mass_lbm = num(mass,'Mass_kg')*kg_to_lbm;
body_t_in = num(mass,'Thickness_in');
body_area_cm2 = num(mass,'Area_cm2');
body_cg = [num(mass,'CG_X_in'),num(mass,'CG_Y_in'),num(mass,'CG_Z_in')];
body_I = [num(mass,'Ixx_lbm_in2'),num(mass,'Iyy_lbm_in2'),num(mass,'Izz_lbm_in2')];
body_Ixy = num(mass,'Ixy_lbm_in2');
asm_P = [num(asm,'PrincipalI1_lbm_in2'),num(asm,'PrincipalI2_lbm_in2'),num(asm,'PrincipalI3_lbm_in2')];
asm_axes = [num(asm,'PrincipalAxis1_X'),num(asm,'PrincipalAxis1_Y'),num(asm,'PrincipalAxis1_Z'); ...
    num(asm,'PrincipalAxis2_X'),num(asm,'PrincipalAxis2_Y'),num(asm,'PrincipalAxis2_Z'); ...
    num(asm,'PrincipalAxis3_X'),num(asm,'PrincipalAxis3_Y'),num(asm,'PrincipalAxis3_Z')];
asm_nx_cg = [num(asm,'NX_CG_X_in'),num(asm,'NX_CG_Y_in'),num(asm,'NX_CG_Z_in')];
asm_nx_P = [num(asm,'NX_PrincipalI1_lbm_in2'),num(asm,'NX_PrincipalI2_lbm_in2'),num(asm,'NX_PrincipalI3_lbm_in2')];

%% 1) Density check (Table 1)
density = NaN(3,1);
for c = 1:3
    b = config_body(c);
    volume_cm3 = body_area_cm2(b)*body_t_in(b)*2.54;
    density(c) = num(mass,'Mass_kg',b)*1000/volume_cm3;
end
T1 = cell(4,7);
for c = 1:4
    b = config_body(c);
    if c<4
        T1(c,:) = {sprintf('%d',c),config_desc{c},sprintf('%.3f',body_mass_lbm(b)), ...
            sprintf('%.3f',body_t_in(b)),sprintf('%.3f',density(c)),handbook_text{c},config_role{c}};
    else
        T1(c,:) = {'4',config_desc{c},sprintf('%.3f',body_mass_lbm(b)),'-','-','-',config_role{c}};
    end
end
write_csv(fullfile(out_dir,'Table1_configurations.csv'), ...
    {'Config','Part and material','Mass (lbm)','t (in)','Density from mass (g/cm^3)', ...
    'Handbook density (g/cm^3)','Role in test plan'},T1);

%% 2) Commercial-sensor runs from step 1
run_exp = col(runs,'Experiment');
run_f = num(runs,'Frequency_Hz');
run_stem = col(runs,'Dataset');
exp_labels = col(summ,'Experiment');
n_tests = numel(exp_labels);
xmodal_f = cell(n_tests,1);
for k = 1:n_tests
    xmodal_f{k} = run_f(strcmp(run_exp,exp_labels{k}));
end

%% 3) Arduino bifilar frequencies (sine fit, same method as the lab review)
arduino_f = NaN(numel(arduino_files),1);
arduino_signal = cell(numel(arduino_files),1);
arduino_dur = NaN(numel(arduino_files),1);
for k = 1:numel(arduino_files)
    [x,dur] = read_arduino_channel(fullfile(data_dir,arduino_files{k}), ...
        arduino_channel,arduino_default_duration_s);
    arduino_f(k) = sine_fit_frequency(x,dur,arduino_band_hz);
    arduino_signal{k} = x;
    arduino_dur(k) = dur;
end
bif = 3;                                  % bifilar is test 3
xm = xmodal_f{bif};
paired_f = (xm(:)+arduino_f(:))/2;
sensor_trial_diff_pct = 100*(arduino_f(:)-xm(:))./xm(:);
sensor_mean_diff_pct = 100*(mean(arduino_f)-mean(xm))/mean(xm);

%% 4) Table 5: frequencies and periods
T5 = {};
for k = 1:n_tests
    T5(end+1,:) = freq_row(sprintf('%d, %s',test_config(k),test_lab_axis{k}),'Commercial',xmodal_f{k}); %#ok<SAGROW>
end
T5(end+1,:) = freq_row(sprintf('%d, %s',test_config(bif),test_lab_axis{bif}),'Arduino',arduino_f);
T5(end+1,:) = freq_row(sprintf('%d, %s',test_config(bif),test_lab_axis{bif}),'Paired (adopted)',paired_f);
write_csv(fullfile(out_dir,'Table5_frequencies.csv'), ...
    {'Config, axis','Sensor','Trial frequencies (Hz)','Mean f +/- SD (Hz)','Mean T +/- SD (s)','CV'},T5);

%% 5) Experimental inertia, uncertainty, and sensitivity for every test
pend_type = col(summ,'PendulumType');
chain_in = num(summ,'ChainLength_in');
pivot_in = num(summ,'PivotToCG_in');
radius_in = num(summ,'SuspensionRadius_in');
I_model = num(summ,'AnalyticalInertia_lbm_in2');
f_pred = num(summ,'PredictedFrequency_Hz');
adopted_f = cell(n_tests,1);
adopted_f(1:n_tests) = xmodal_f;
adopted_f{bif} = paired_f;
res = struct('I',{},'u',{},'u_len',{},'u_T',{},'share',{},'sens_len',{},'sens_T1',{},'f',{},'T',{});
for k = 1:n_tests
    body = config_body(test_config(k));
    m = body_mass_lbm(body);
    f = adopted_f{k};
    fbar = mean(f);
    T = 1/fbar;
    uT = (std(f)/fbar^2)/sqrt(numel(f));        % standard error of the mean period
    if strcmpi(pend_type{k},'compound')
        d = pivot_in(k);
        Leq = g_in_s2*T^2/(4*pi^2);
        I = m*d*(Leq-d);
        dIdd = m*(Leq-2*d);
        dIdT = 2*m*g_in_s2*d*T/(4*pi^2);
        u_len = abs(dIdd)*u_length_in;
        u_T = abs(dIdT)*uT;
        share = I/(I+m*d^2);
        sens_T1 = abs(dIdT)*0.01*T/I*100;        % % change in I per 1% change in T
    else
        r = radius_in(k);
        L = chain_in(k);
        I = m*g_in_s2*r^2*T^2/(4*pi^2*L);
        u_len = I*sqrt((2*u_radius_in/r)^2+(u_length_in/L)^2);
        u_T = I*2*uT/T;
        share = 1;
        sens_T1 = 2;
    end
    res(k).I = I; res(k).u = hypot(u_len,u_T); res(k).u_len = u_len; res(k).u_T = u_T;
    res(k).share = share; res(k).sens_len = u_len/I*100; res(k).sens_T1 = sens_T1;
    res(k).f = fbar; res(k).T = T;
end
% Sensor-by-sensor bifilar inertia (for the Arduino / commercial comparison)
m1 = body_mass_lbm(config_body(1));
bif_I = @(f) m1*g_in_s2*radius_in(bif)^2/(4*pi^2*chain_in(bif))/mean(f)^2;
I_bif_xmodal = bif_I(xm);
I_bif_arduino = bif_I(arduino_f);
% Bifilar setup mismatch that would explain the whole difference
r_eff = radius_in(bif)*sqrt(I_model(bif)/res(bif).I);
L_eff = chain_in(bif)*res(bif).I/I_model(bif);

%% 6) Table 6: final CG, principal axes, moments of inertia
T6 = cell(4,9);
tilt_deg = NaN(4,1);
for c = 1:4
    b = config_body(c);
    cg = body_cg(b,:)+config_cg_shift_in(c,:);
    if c<4
        J2 = [body_I(b,1),body_Ixy(b); body_Ixy(b),body_I(b,2)];
        [V,D] = eig(J2);
        [lam,order] = sort(diag(D));
        v = V(:,order(1));
        tilt_deg(c) = wrap90(atan2d(v(2),v(1)));
        Ishow = body_I(b,:);
        P = sort([lam(:).',body_I(b,3)]);
        src_text = 'MATLAB';
    else
        v = asm_axes(1,:);
        tilt_deg(c) = wrap90(atan2d(v(2),v(1)));
        Ishow = asm_P;
        P = asm_P;
        src_text = 'MATLAB combination of Configs 1 and 2';
    end
    if abs(tilt_deg(c))<0.05
        axis_text = 'Along the plate edges';
    elseif c<4
        axis_text = sprintf('Tilted %.1f deg from the long edge',abs(tilt_deg(c)));
    else
        axis_text = sprintf('Tilted %.1f deg from the rectangle long edge',abs(tilt_deg(c)));
    end
    T6(c,:) = {sprintf('%d',c),sprintf('(%.3f, %.3f, %.3f)',cg),sig4(Ishow(1)),sig4(Ishow(2)), ...
        sig4(Ishow(3)),sprintf('%s, %s, %s',sig4(P(1)),sig4(P(2)),sig4(P(3))), ...
        sprintf('%.2f',tilt_deg(c)),axis_text,src_text};
end
write_csv(fullfile(out_dir,'Table6_final_mass_properties.csv'), ...
    {'Config','CG (x, y, z) in','Ixx','Iyy','Izz','Principal I1, I2, I3', ...
    'Principal axis angle from x (deg)','Principal axes','Source'},T6);

%% 7) Table 7: comparison of independent estimates
src_plate = col(src,'Plate');
src_axis = col(src,'Axis');
src_nx_native = num(src,'NXNative_lbm_in2');
src_nx_scaled = num(src,'NXScaledToMeasuredMass_lbm_in2');
src_prefix = {'P1','P2','P3','P4'};
model_axis = {'Ixx','Iyy','Izz'};
tested_axis = col(summ,'TestedAxis');
T7 = cell(n_tests,9);
nx_native_t = NaN(n_tests,1); nx_scaled_t = NaN(n_tests,1);
diff_exp = NaN(n_tests,1); diff_nx = NaN(n_tests,1); diff_exp_nx = NaN(n_tests,1); diff_f = NaN(n_tests,1);
for k = 1:n_tests
    body = config_body(test_config(k));
    ax = model_axis{strfind('xyz',lower(tested_axis{k}))};
    row = find(strncmp(src_plate,src_prefix{body},2) & strcmp(src_axis,ax),1);
    nx_native_t(k) = src_nx_native(row);
    nx_scaled_t(k) = src_nx_scaled(row);
    diff_exp(k) = 100*(res(k).I-I_model(k))/I_model(k);
    diff_nx(k) = 100*(nx_scaled_t(k)-I_model(k))/I_model(k);
    diff_exp_nx(k) = 100*(res(k).I-nx_scaled_t(k))/nx_scaled_t(k);
    diff_f(k) = 100*(res(k).f-f_pred(k))/f_pred(k);
    T7(k,:) = {sprintf('%d, %s (%s)',test_config(k),test_lab_axis{k},lower(pend_type{k})), ...
        sig4(I_model(k)),sig4(nx_native_t(k)),sig4(nx_scaled_t(k)), ...
        sprintf('%s +/- %s',sig3(res(k).I),sig3(res(k).u)),pct(diff_exp(k)), ...
        pct(diff_exp_nx(k)),pct(diff_nx(k)), ...
        sprintf('%.4f vs %.4f (%s)',f_pred(k),res(k).f,pct(diff_f(k)))};
end
write_csv(fullfile(out_dir,'Table7_comparison.csv'), ...
    {'Config, axis','MATLAB','NX as modeled','NX scaled to our mass', ...
    'Pendulum test +/- uncertainty','Test vs MATLAB','Test vs NX (scaled)', ...
    'NX (scaled) vs MATLAB','Frequency predicted vs measured (Hz)'},T7);

%% 8) Table 8: assembly, NX versus MATLAB combination
asm_cg = [num(asm,'CG_X_in'),num(asm,'CG_Y_in'),num(asm,'CG_Z_in')];
T8 = {'CG (in)',sprintf('(%.3f, %.3f, %.3f)',asm_nx_cg),sprintf('(%.3f, %.3f, %.3f)',asm_cg), ...
    sprintf('(%+.3f, %+.3f, %+.3f)',asm_nx_cg-asm_cg)};
lab = {'Ixx (lbm*in^2)','Iyy (lbm*in^2)','Izz (lbm*in^2)'};
for k = 1:3
    T8(end+1,:) = {lab{k},sig4(asm_nx_P(k)),sig4(asm_P(k)),pct(100*(asm_nx_P(k)-asm_P(k))/asm_P(k))}; %#ok<SAGROW>
end
T8(end+1,:) = {'Principal axis angle from rectangle x (deg)','see NX figure', ...
    sprintf('%.2f',tilt_deg(4)),'-'};
write_csv(fullfile(out_dir,'Table8_assembly.csv'), ...
    {'Quantity','NX','MATLAB combination','Difference (NX - MATLAB)'},T8);

%% 9) Table 3 (test matrix) and sensitivity / uncertainty table
T3 = cell(n_tests,7);
TS = cell(n_tests,8);
for k = 1:n_tests
    if strcmpi(pend_type{k},'compound')
        geo = sprintf('d = %.2f in',pivot_in(k));
    else
        geo = sprintf('L = %.2f in, r = %.2f in',chain_in(k),radius_in(k));
    end
    ax = model_axis{strfind('xyz',lower(tested_axis{k}))};
    sensors = 'Commercial';
    if k==bif
        sensors = 'Commercial + Arduino';
    end
    T3(k,:) = {sprintf('%d',test_config(k)),test_files{k},test_name{k}, ...
        sprintf('%s = model %s (%s)',test_lab_axis{k},ax,sig4(I_model(k))),geo,sensors, ...
        sprintf('%d',numel(adopted_f{k}))};
    TS(k,:) = {sprintf('%d, %s',test_config(k),test_lab_axis{k}),sig3(res(k).I), ...
        sprintf('%.1f%%',100*res(k).share),sprintf('%.1f (%.1f%%)',res(k).u_len,res(k).sens_len), ...
        sprintf('%.2f',res(k).u_T),sprintf('%.1f%%',res(k).sens_T1), ...
        sprintf('%.1f (%.1f%%)',res(k).u,100*res(k).u/res(k).I),pct(diff_exp(k))};
end
write_csv(fullfile(out_dir,'Table3_test_matrix.csv'), ...
    {'Config','Run files','Pendulum and motion','Tested axis (lab) = model axis', ...
    'Geometry','Sensor(s)','Trials'},T3);
write_csv(fullfile(out_dir,'TableA_uncertainty_sensitivity.csv'), ...
    {'Config, axis','I test (lbm*in^2)','Plate share of pivot inertia', ...
    'From length reading +/-0.25 in (+/-0.125 in radius)','From period scatter', ...
    'Change in I per 1% change in T','Total uncertainty','Test vs MATLAB'},TS);

%% 10) Run log (used runs from the data, excluded runs listed with reasons)
RL = {};
for k = 1:n_tests
    stems = run_stem(strcmp(run_exp,exp_labels{k}));
    ftxt = strjoin(arrayfun(@(v) sprintf('%.4f',v),xmodal_f{k}(:).','UniformOutput',false),', ');
    if k==bif
        ftxt = [ftxt,' | Arduino ',strjoin(arrayfun(@(v) sprintf('%.4f',v),arduino_f(:).','UniformOutput',false),', ')]; %#ok<AGROW>
    end
    RL(end+1,:) = {'2',strjoin(stems(:).',', '),sprintf('%d',test_config(k)),test_name{k},ftxt,'Used'}; %#ok<SAGROW>
end
RL = [RL; ...
    {'2','BackupCombined1-2, BackupCombinedBottomPosition1-3','4','Compound','f = 0.89-0.93 Hz','Excluded: suspension geometry not written down'}; ...
    {'2','PlasticX1-5','2','Flipped, tilted hang','f = 1.06-1.13 Hz','Excluded: coupled wobble, not a principal axis'}; ...
    {'1','ArduinoDataY2, Ytest1','1','Two parallel chains','-','Excluded: plate slid without rotating'}; ...
    {'1','ArduinoDataX, test2settled, Arduinoplot','1','Into table','-','Excluded: twist mode or corrupted record'}; ...
    {'1','Zdata2','1','Twist','f = 1.689 Hz','Supporting only: geometry not written down'}];
write_csv(fullfile(out_dir,'TableA2_run_log.csv'), ...
    {'Day','Files','Config','Motion','Result','Status'},RL);

%% 11) Sample calculations with numbers substituted
fid = fopen(fullfile(out_dir,'sample_calculations.txt'),'w');
k = 1; body = config_body(test_config(k)); m = body_mass_lbm(body); d = pivot_in(k); T = res(k).T;
Leq = g_in_s2*T^2/(4*pi^2);
fprintf(fid,'EXP1 SAMPLE CALCULATIONS (lbm, in, s; g = %.2f in/s^2)\n\n',g_in_s2);
fprintf(fid,'1) Compound pendulum, Config %d (%s):\n',test_config(k),test_lab_axis{k});
fprintf(fid,'   gT^2/(4pi^2) = %.2f(%.4f)^2/39.478 = %.3f in\n',g_in_s2,T,Leq);
fprintf(fid,'   I = m*d*(gT^2/4pi^2 - d) = %.3f(%.2f)(%.3f - %.2f) = %.1f lbm*in^2\n',m,d,Leq,d,res(k).I);
fprintf(fid,'   Uncertainty: length %.1f, period %.1f -> sqrt(%.1f^2 + %.1f^2) = +/-%.1f (%.1f%%)\n\n', ...
    res(k).u_len,res(k).u_T,res(k).u_len,res(k).u_T,res(k).u,100*res(k).u/res(k).I);
k = bif; m = body_mass_lbm(config_body(test_config(k))); T = res(k).T;
fprintf(fid,'2) Bifilar pendulum, Config %d (%s), paired frequency %.4f Hz:\n',test_config(k),test_lab_axis{k},res(k).f);
fprintf(fid,'   I = m*g*r^2*T^2/(4pi^2*L) = %.4f(%.2f)(%.2f)^2(%.4f)^2/(39.478 x %.2f) = %.2f lbm*in^2\n', ...
    m,g_in_s2,radius_in(k),T,chain_in(k),res(k).I);
fprintf(fid,'   Uncertainty +/-%.2f (%.1f%%). Commercial only %.2f, Arduino only %.2f.\n', ...
    res(k).u,100*res(k).u/res(k).I,I_bif_xmodal,I_bif_arduino);
fprintf(fid,'   Setup that would explain the whole difference: r = %.2f in (not %.2f) or L = %.2f in (not %.2f)\n\n', ...
    r_eff,radius_in(k),L_eff,chain_in(k));
b = config_body(1); a_in = 12.9; b_in = 5.9;
fprintf(fid,'3) Hand check, Config 1 without holes: Izz = m(a^2+b^2)/12 = %.4f(%.2f^2+%.2f^2)/12 = %.2f (MATLAB with holes %.2f)\n\n', ...
    body_mass_lbm(b),a_in,b_in,body_mass_lbm(b)*(a_in^2+b_in^2)/12,body_I(b,3));
k = 1;
fprintf(fid,'4) Percent difference, Config %d: (%.1f - %.1f)/%.1f x 100%% = %s\n\n',test_config(k),res(k).I,I_model(k),I_model(k),pct(diff_exp(k)));
fprintf(fid,'5) Predicted frequency, Config %d: f = (1/2pi)sqrt[m g d/(I + m d^2)] = %.4f Hz (measured %.4f Hz)\n\n', ...
    test_config(k),f_pred(k),res(k).f);
fprintf(fid,'6) Units: 1 kg*m^2 = 2.2046 lbm x (39.370 in)^2 = 3417.2 lbm*in^2\n');
fclose(fid);

%% 12) One-page summary of every number quoted in the report
fid = fopen(fullfile(out_dir,'report_numbers_summary.txt'),'w');
fprintf(fid,'EXP1 REPORT NUMBERS (generated %s)\n\n',datestr(now));
fprintf(fid,'Density check: Config 1 %.3f, Config 2 %.3f, Config 3 %.3f g/cm^3 (max %.1f%% from handbook)\n', ...
    density,max(abs(100*(density(:)-handbook_density(:))./handbook_density(:))));
fprintf(fid,'Sensors (bifilar): Arduino vs commercial mean %s, largest single trial %.2f%%\n', ...
    pct(sensor_mean_diff_pct),max(abs(sensor_trial_diff_pct)));
fprintf(fid,'Commercial vs Arduino bifilar inertia: %.2f vs %.2f lbm*in^2\n',I_bif_xmodal,I_bif_arduino);
for k = 1:n_tests
    fprintf(fid,'Config %d %s: test %s +/- %s, MATLAB %s (%s), NX scaled %s (NX vs MATLAB %s), f %s\n', ...
        test_config(k),test_lab_axis{k},sig3(res(k).I),sig3(res(k).u),sig4(I_model(k)),pct(diff_exp(k)), ...
        sig4(nx_scaled_t(k)),pct(diff_nx(k)),pct(diff_f(k)));
    fprintf(fid,'   plate share of pivot inertia %.1f%%, a 0.25 in length error changes I by %.1f%%\n', ...
        100*res(k).share,res(k).sens_len);
end
fprintf(fid,'Principal-axis tilt: Config 1 %.2f, Config 2 %.2f, Config 3 %.2f, Config 4 %.2f deg\n',tilt_deg);
fprintf(fid,'Assembly: CG difference %.3f in, NX vs MATLAB %s / %s / %s\n',norm(asm_nx_cg(1:2)-asm_cg(1:2)), ...
    pct(100*(asm_nx_P(1)-asm_P(1))/asm_P(1)),pct(100*(asm_nx_P(2)-asm_P(2))/asm_P(2)),pct(100*(asm_nx_P(3)-asm_P(3))/asm_P(3)));
fprintf(fid,'Bifilar setup that explains the difference: r_eff = %.2f in or L_eff = %.2f in\n',r_eff,L_eff);
fclose(fid);
type(fullfile(out_dir,'report_numbers_summary.txt'));

%% 13) Figures
blue = [0.165,0.471,0.839];
orange = [0.922,0.408,0.204];
gray = [0.75,0.75,0.75];
vis = 'off';
if show_figures
    vis = 'on';
end

% Figure: how the period was found (aluminum frame, YData1)
[t,x] = load_uff_channel(fullfile(data_dir,'TestsWithDotMAT','YData1.MAT'),1);
x = x-polyval(polyfit(t,x,1),t);
xs = movmean(x,round(0.1/(t(2)-t(1))));
[ff,pp,fpk] = spectrum_peak(t,x,[0.35,1.05]);
fig1 = figure('Color','white','Visible',vis,'Position',[60,60,900,640]);
subplot(2,1,1);
plot(t,1000*x,'Color',gray,'LineWidth',0.5); hold on;
plot(t,1000*xs,'Color',blue,'LineWidth',2);
grid on; xlim([0,t(end)]); xlabel('Time (s)'); ylabel('Acceleration (mg)');
title('(a) Aluminum frame swing, YData1');
legend({'Recorded signal','Smoothed'},'Location','southwest');
subplot(2,1,2);
keep = ff<=3;
plot(ff(keep),pp(keep),'Color',blue,'LineWidth',2); hold on;
plot(fpk,1,'o','Color','k','MarkerFaceColor','k');
text(fpk+0.08,0.92,sprintf('peak = %.3f Hz\nT = 1/f = %.3f s',fpk,1/fpk));
grid on; xlim([0,3]); ylim([0,1.15]);
xlabel('Frequency (Hz)'); ylabel('Strength (scaled)');
title('(b) Frequency content of the same record');
print(fig1,fullfile(out_dir,'Fig_signal_processing_YData1.png'),'-dpng','-r300');

% Figure: bifilar sensor check (Bifolar1, both sensors at the same time)
[tb,xb] = load_uff_channel(fullfile(data_dir,'TestsWithDotMAT','Bifolar1.MAT'),1);
xb = xb-polyval(polyfit(tb,xb,1),tb);
[fb,pb] = spectrum_peak(tb,xb,[0.3,6]);
xa = arduino_signal{1};
ta = (0:numel(xa)-1).'*arduino_dur(1)/numel(xa);
xa = xa-polyval(polyfit(ta,xa,1),ta);
[fa,pa] = spectrum_peak(ta,xa,[0.3,6]);
fig2 = figure('Color','white','Visible',vis,'Position',[80,80,900,640]);
subplot(2,1,1);
plot(tb,xb/max(abs(xb)),'Color',blue,'LineWidth',1); hold on;
plot(ta,xa/max(abs(xa)),'Color',orange,'LineWidth',1.5);
grid on; xlim([0,tb(end)]); xlabel('Time (s)'); ylabel('Signal (scaled)');
title('(a) Twisting test Bifolar1: both sensors recorded at the same time');
legend({'Commercial (pointed up and down)','Arduino (pointed sideways)'},'Location','southeast');
subplot(2,1,2);
kb = fb<=5; ka = fa<=5;
plot(fb(kb),pb(kb),'Color',blue,'LineWidth',2); hold on;
plot(fa(ka),pa(ka),'Color',orange,'LineWidth',2);
grid on; xlim([0,5]); ylim([0,1.15]);
xlabel('Frequency (Hz)'); ylabel('Strength (scaled)');
title(sprintf('(b) Arduino: one peak at %.3f Hz. Commercial: main peak at twice that.',arduino_f(1)));
legend({'Commercial','Arduino'},'Location','northeast');
print(fig2,fullfile(out_dir,'Fig_bifilar_sensor_check.png'),'-dpng','-r300');

% Figure: every estimate compared with the MATLAB value
fig3 = figure('Color','white','Visible',vis,'Position',[100,100,900,480]);
hold on;
ypos = n_tests:-1:1;
labels = cell(n_tests,1);
for k = 1:n_tests
    u_pct = 100*res(k).u/I_model(k);
    line([diff_exp(k)-u_pct,diff_exp(k)+u_pct],[ypos(k),ypos(k)],'Color',orange,'LineWidth',2);
    line([diff_exp(k)-u_pct,diff_exp(k)-u_pct],ypos(k)+[-0.08,0.08],'Color',orange,'LineWidth',2);
    line([diff_exp(k)+u_pct,diff_exp(k)+u_pct],ypos(k)+[-0.08,0.08],'Color',orange,'LineWidth',2);
    h1 = plot(diff_exp(k),ypos(k),'o','MarkerSize',10,'MarkerFaceColor',orange,'MarkerEdgeColor',orange);
    h2 = plot(diff_nx(k),ypos(k)-0.2,'s','MarkerSize',9,'MarkerFaceColor',blue,'MarkerEdgeColor',blue);
    text(diff_exp(k),ypos(k)+0.22,pct(diff_exp(k)),'HorizontalAlignment','center');
    if strcmpi(pend_type{k},'compound')
        kind = 'swinging';
    else
        kind = 'twisting';
    end
    labels{k} = sprintf('Config %d %s, %s',test_config(k),test_lab_axis{k},kind);
end
line([0,0],[0.4,n_tests+0.6],'Color','k','LineWidth',1);
set(gca,'YTick',fliplr(ypos),'YTickLabel',flipud(labels(:)));
ylim([0.4,n_tests+0.6]); grid on;
xlabel('Difference from MATLAB value (%)');
legend([h1,h2],{'Pendulum test +/- uncertainty','NX (scaled to our mass)'},'Location','southoutside','Orientation','horizontal');
print(fig3,fullfile(out_dir,'Fig_moi_comparison.png'),'-dpng','-r300');

fprintf('\nReport outputs complete: %s\n',out_dir);

%% Local functions
function T = read_csv(filename)
if exist(filename,'file')~=2
    error('Missing %s. Run steps 1 and 2 first (run_exp1_all.m).',filename);
end
lines = regexp(fileread(filename),'\r?\n','split');
lines = lines(~cellfun(@isempty,strtrim(lines)));
T.names = strrep(strtrim(strsplit(lines{1},',')),'"','');
T.data = cell(numel(lines)-1,numel(T.names));
for r = 2:numel(lines)
    parts = strrep(strsplit(lines{r},','),'"','');
    T.data(r-1,1:numel(parts)) = parts;
end
end

function c = col(T,name)
idx = find(strcmp(T.names,name),1);
if isempty(idx)
    error('Column %s not found.',name);
end
c = T.data(:,idx);
end

function v = num(T,name,row)
v = str2double(col(T,name));
if nargin>2
    v = v(row);
end
end

function write_csv(filename,header,rows)
fid = fopen(filename,'w');
fprintf(fid,'%s\n',strjoin(cellfun(@csvq,header,'UniformOutput',false),','));
for r = 1:size(rows,1)
    fprintf(fid,'%s\n',strjoin(cellfun(@csvq,rows(r,:),'UniformOutput',false),','));
end
fclose(fid);
end

function s = csvq(s)
s = ['"',strrep(char(s),'"','""'),'"'];
end

function row = freq_row(config_axis,sensor,f)
f = f(:);
T = 1./f;
row = {config_axis,sensor,strjoin(arrayfun(@(v) sprintf('%.4f',v),f.','UniformOutput',false),', '), ...
    sprintf('%.4f +/- %.4f',mean(f),std(f)),sprintf('%.4f +/- %.4f',1/mean(f),std(f)/mean(f)^2), ...
    sprintf('%.2f%%',100*std(f)/mean(f))};
end

function s = sig4(v)
if abs(v)>=100
    s = sprintf('%.1f',v);
else
    s = sprintf('%.4g',v);
end
end

function s = sig3(v)
if abs(v)>=100
    s = sprintf('%.0f',v);
elseif abs(v)>=10
    s = sprintf('%.1f',v);
else
    s = sprintf('%.2f',v);
end
end

function s = pct(v)
s = sprintf('%+.1f%%',v);
if abs(v)<1
    s = sprintf('%+.2f%%',v);
end
end

function a = wrap90(a)
a = mod(a+90,180)-90;
end

function [x,duration_s] = read_arduino_channel(filename,channel,default_duration_s)
text = fileread(filename);
tok = regexp(text,[channel,'\s*=\s*\[([^\]]*)\]'],'tokens','once');
if isempty(tok)
    error('Channel %s not found in %s.',channel,filename);
end
x = sscanf(strrep(tok{1},',',' '),'%f');
cap = regexp(text,'Capture:\s*(\d+)\s*mS','tokens','once','ignorecase');
duration_s = default_duration_s;
if ~isempty(cap)
    duration_s = str2double(cap{1})/1000;
end
end

function f_best = sine_fit_frequency(x,duration_s,band_hz)
% Rough FFT peak, then the sine frequency that best fits the whole record.
x = x(:);
n = numel(x);
t = (0:n-1).'*duration_s/n;
A = [ones(n,1),t];
y = x-A*(A\x);
w = 0.5-0.5*cos(2*pi*(0:n-1).'/(n-1));
F = abs(fft(y.*w));
f = (0:n-1).'/duration_s;
half = f<=band_hz(2) & f>=band_hz(1);
fb = f(half); Fb = F(half);
[~,i] = max(Fb);
f0 = fb(i);
grid_f = linspace(max(0.1,f0-0.7),f0+0.7,2801);
best = Inf;
f_best = f0;
for k = 1:numel(grid_f)
    M = [sin(2*pi*grid_f(k)*t),cos(2*pi*grid_f(k)*t)];
    r = y-M*(M\y);
    sse = r.'*r;
    if sse<best
        best = sse;
        f_best = grid_f(k);
    end
end
end

function [t,x] = load_uff_channel(filename,channel)
loaded = load(filename);
count = 0;
for k = 1:numel(loaded.UFCELLS)
    item = loaded.UFCELLS{k};
    if isstruct(item) && isfield(item,'DataValues') && ~isempty(item.DataValues)
        count = count+1;
        if count==channel
            x = double(item.DataValues(:));
            t = (0:numel(x)-1).'*double(item.AbscissaIncrement);
            return
        end
    end
end
error('Channel %d not found in %s.',channel,filename);
end

function [f,p,f_peak] = spectrum_peak(t,x,band_hz)
% Same idea as step 1: fade the ends, finer frequency steps, find the peak.
x = x(:);
n = numel(x);
w = 0.5-0.5*cos(2*pi*(0:n-1).'/(n-1));
nfft = 2^nextpow2(16*n);
X = fft(x.*w,nfft);
p = abs(X(1:floor(nfft/2)+1)).^2;
f = (0:floor(nfft/2)).'/((t(2)-t(1))*nfft);
in = f>=band_hz(1) & f<=band_hz(2);
p = p/max(p(in));
[~,i] = max(p.*in);
f_peak = f(i);
end
