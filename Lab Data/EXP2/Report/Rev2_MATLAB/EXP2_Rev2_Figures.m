%% EXP2 Heat Transfer - Group E - Rev2 figures and numbers
% Makes every plot used in EXP2_GroupE_Video_Report_Rev2.pptx
% Run from this folder (Report\Rev2_MATLAB). Figures go to .\figures
% Numbers used on the slides are written to .\figures\EXP2_Rev2_results.csv
%
% Equations used (Canvas "Heat Transfer Equations for Thin Rod" + FAQ):
%   steady state:  d2T/dx2 - (h*p/(k*A))*(T - Tfluid) = 0
%   FAQ: ignore tip loss, average h, 3-point central difference for d2T/dx2
%   heater power:  P = V^2/R
%   comparison:    RMS = sqrt( mean( (T_model - T_measured).^2 ) )

clear; clc; close all;
here    = fileparts(mfilename('fullpath'));
if isempty(here), here = pwd; end
runsDir = fullfile(here,'..','..','Runs');   % Lab Data\EXP2\Runs
dataDir = fullfile(here,'data');             % NX nodal temperatures (exported from the .op2 results)
figDir  = fullfile(here,'figures');
if ~exist(figDir,'dir'), mkdir(figDir); end

%% ---------------- inputs ----------------
in2m = 0.0254;
% channel offsets measured at the start of the runs when the rod was still at room temp (C)
offset = [0.02 1.41 -0.57 -0.86];

% rod table: name, run file, format, positions from heated end (in), length (in),
%            OD (in), ID (in), handbook k (W/m-K, NX library), ambient (C), NX h (W/m^2K), NX Q (W)
R(1) = struct('name','Copper',     'file','R1/Copper.txt',         'fmt','D','dt',5.06, ...
    'x',[4.25 6.75 9.25 11.75],'L',11.75,'D',0.195, 'Di',0,     'k',387,'Ta',26.14,'hNX',10.49,'QNX',0.769,'use',[1 1 1 0],'add',[0 0 0 0]);
R(2) = struct('name','Copper tube','file','R5/Tube2.txt',          'fmt','T','dt',NaN, ...
    'x',[3.5 5.5 7.5 9.5],     'L',11.99,'D',0.3142,'Di',0.2358,'k',387,'Ta',26.82,'hNX',18.86,'QNX',2.186,'use',[1 1 1 1],'add',[0 0 0 0]);
R(3) = struct('name','Aluminum',   'file','R7/Aluminum2.txt',      'fmt','T','dt',NaN, ...
    'x',[2.5 3.5 4.5 5.5],     'L',12,   'D',0.1995,'Di',0,     'k',155,'Ta',27.16,'hNX',18.74,'QNX',1.337,'use',[1 1 1 1],'add',[5 0 0 0]);
R(4) = struct('name','Brass',      'file','R6/Bronze2.txt',        'fmt','T','dt',NaN, ...
    'x',[2.5 3.5 4.5 5.5],     'L',12,   'D',0.201, 'Di',0,     'k',116,'Ta',27.27,'hNX',25.00,'QNX',1.372,'use',[1 1 1 1],'add',[0 0 0 0]);
R(5) = struct('name','Stainless',  'file','R4/Steel.txt',          'fmt','T','dt',NaN, ...
    'x',[3 4.5 6 7.5],         'L',11.75,'D',0.201, 'Di',0,     'k',17, 'Ta',24.23,'hNX',25.00,'QNX',1.472,'use',[1 1 1 1],'add',[0 0 0 0]);
nxFile = {'Copper','CuTube','Aluminum','Brass','Stainless'};
% note: Aluminum Ch1 +5 C because T0 read low vs the thermocouple in lab (see lab log)

%% ---------------- heater power (FAQ: P = V^2/R) ----------------
V = 4.98;  Rh = 6.1;
P = V^2/Rh;
fprintf('Heater power P = %.2f W\n',P);

%% ---------------- load runs ----------------
for i = 1:numel(R)
    [t,T] = readRun(fullfile(runsDir,R(i).file),R(i).fmt,R(i).dt);
    R(i).t = t; R(i).T = T;
    last = t >= t(end)-180;                               % last 3 minutes
    R(i).Tss = mean(T(last,:),1) - offset + R(i).add;     % steady value
    for c = 1:4
        pp = polyfit(t(last)/60, T(last,c), 1); R(i).slope(c) = pp(1);   % C/min
    end
    R(i).tSteady = timeToSteady(t,T,R(i).use);
end

%% ---------------- FIGURE 1: test set-up sketch ----------------
f = figure('Color','w','Position',[100 100 900 380]); hold on; axis off;
rectangle('Position',[-1.5 -0.6 1.5 1.2],'FaceColor',[0.95 0.45 0.2],'EdgeColor','k');   % heater + clamp
text(-0.75,-0.85,{'Heater + clamp','(covers 1.5 in)'},'HorizontalAlignment','center','FontWeight','bold');
rectangle('Position',[0 -0.12 12 0.24],'FaceColor',[0.80 0.50 0.20],'EdgeColor','k');     % rod
text(6,0,'rod (Cu, Al, brass, stainless, Cu tube)','HorizontalAlignment','center','Color','w','FontSize',9);
xs = [2.5 5 7.5 10];
for c = 1:4
    plot([xs(c) xs(c)],[0.2 0.5],'k-','LineWidth',1);
    plot(xs(c),0.18,'kv','MarkerFaceColor','k','MarkerSize',8);
    text(xs(c),0.65,sprintf('Ch%d',c),'HorizontalAlignment','center');
end
for xa = 1.5:2:11.5                                   % convection arrows
    plot([xa xa],[-0.2 -0.75],'-','Color',[0 0.45 0.74]);
    plot(xa,-0.75,'v','Color',[0 0.45 0.74],'MarkerFaceColor',[0 0.45 0.74]);
end
text(6.5,-1.05,'convection to room air, h   (T_{fluid} = 24-27 ^oC)','HorizontalAlignment','center','Color',[0 0.45 0.74]);
plot([0 12],[1.0 1.0],'k-'); plot(0,1.0,'k<','MarkerFaceColor','k'); plot(12,1.0,'k>','MarkerFaceColor','k');
text(6,1.2,'x = distance from heated end (0 to 12 in)','HorizontalAlignment','center');
plot(xs(1)+0.35,0.3,'g^','MarkerFaceColor','g','MarkerSize',8);
text(xs(1)+0.5,0.42,'TC (thermocouple at T0)','Color',[0 0.5 0],'FontSize',9);
rectangle('Position',[13 -0.5 2.2 1.0],'FaceColor',[0.85 0.9 1],'EdgeColor','k');
text(14.1,0,{'Arduino','4-ch board','to MATLAB'},'HorizontalAlignment','center');
plot([10.2 13],[0.5 0.3],'k:');
title('EXP2 test set-up (not to scale)');
xlim([-2 15.5]); ylim([-1.4 1.4]);
saveFig(f,fullfile(figDir,'fig01_test_setup.png'));

%% ---------------- FIGURE 2: transient response, every rod ----------------
f = figure('Color','w','Position',[100 100 1100 600]);
for i = 1:numel(R)
    subplot(2,3,i);
    Tc = R(i).T - repmat(offset,size(R(i).T,1),1);
    plot(R(i).t/60, Tc, 'LineWidth',1); grid on; hold on;
    if ~isnan(R(i).tSteady)
        yl = ylim; plot([1 1]*R(i).tSteady/60, yl,'k--');
    end
    title(sprintf('%s (%s)',R(i).name,strtok(R(i).file,'/')));
    xlabel('Time (min)'); ylabel('T (^oC)');
    if i==1, legend('Ch1','Ch2','Ch3','Ch4','Location','southeast'); end
end
subplot(2,3,6); axis off;
text(0,0.8,'Dashed line = steady state reached','FontSize',10);
text(0,0.6,'(all channels < 0.1 ^oC/min over 3 min)','FontSize',10);
yy = 0.35;
for i = 1:numel(R)
    if isnan(R(i).tSteady)
        text(0,yy,sprintf('%s: not reached (still rising)',R(i).name),'FontSize',10); yy = yy-0.15;
    end
end
saveFig(f,fullfile(figDir,'fig02_transient_all_rods.png'));

%% ---------------- load NX results ----------------
for i = 1:numel(R)
    nd  = csvread(fullfile(dataDir,['NX_' nxFile{i} '_nodes.csv']),1,0);   % x, y, dist from heated end, T
    tri = csvread(fullfile(dataDir,['NX_' nxFile{i} '_tri.csv']));
    R(i).nxNodes = nd; R(i).nxTri = tri;
    % average NX temperature along the rod (bins of 0.1 in)
    edges = 0:0.1:max(nd(:,3))+0.1; xc = []; Tc = [];
    for b = 1:numel(edges)-1
        s = nd(:,3)>=edges(b) & nd(:,3)<edges(b+1);
        if any(s), xc(end+1) = mean(nd(s,3)); Tc(end+1) = mean(nd(s,4)); end %#ok<AGROW>
    end
    R(i).nxX = xc; R(i).nxT = Tc;
    R(i).nxAtSensor = interp1(xc,Tc,R(i).x,'linear','extrap');
end

%% ---------------- FIGURE 3: NX thermal results (all rods) ----------------
f = figure('Color','w','Position',[100 100 1000 900]);
for i = 1:numel(R)
    subplot(5,1,i);
    nd = R(i).nxNodes;
    patch('Faces',R(i).nxTri,'Vertices',[nd(:,3) nd(:,1) nd(:,2)],'FaceVertexCData',nd(:,4), ...
          'FaceColor','interp','EdgeColor','none');
    colormap(jet); cb = colorbar; ylabel(cb,'T (^oC)');
    view(0,90); axis tight; set(gca,'YTick',[]);
    title(sprintf('%s  -  NX steady-state temperature, max %.0f ^oC, min %.0f ^oC',R(i).name,max(nd(:,4)),min(nd(:,4))));
    if i==5, xlabel('Distance from heated end (in)'); end
end
saveFig(f,fullfile(figDir,'fig03_NX_thermal_all_rods.png'));

% one 3-D view per rod (radial scale exaggerated so the rod is visible)
for i = 1:numel(R)
    f = figure('Color','w','Position',[100 100 900 420]);
    nd = R(i).nxNodes;
    ax = axes('Position',[0.05 0.32 0.9 0.58]);
    patch('Faces',R(i).nxTri,'Vertices',[nd(:,3) nd(:,1) nd(:,2)],'FaceVertexCData',nd(:,4), ...
          'FaceColor','interp','EdgeColor','none');
    colormap(jet); daspect([1 0.25 0.25]); view(-15,20); axis tight; axis off;
    text(0,0,-0.17,'heated end','HorizontalAlignment','center');
    text(R(i).L,0,0.17,'far end','HorizontalAlignment','center');
    title(sprintf('%s - NX temperature (radial scale x4)',R(i).name));
    cb = colorbar('southoutside'); set(cb,'Position',[0.15 0.12 0.7 0.05]); xlabel(cb,'T (^oC)');
    saveFig(f,fullfile(figDir,sprintf('fig03_NX_%s.png',strrep(R(i).name,' ','_'))));
end

%% ---------------- analytical model ----------------
% (a) our Excel sheet: 3-point central difference at the 2nd sensor (FAQ)
%     m^2 = (T0 + T2 - 2*T1) / (dx^2 * (T1 - Tfluid)),  h/k = m^2 * A/p
% (b) closed-form solution of the same steady equation with the tip loss ignored (FAQ):
%     T(x) = Tfluid + (T0 - Tfluid)*cosh(m*(L-x))/cosh(m*(L-x0)), m fitted to all sensors
for i = 1:numel(R)
    D = R(i).D*in2m; Di = R(i).Di*in2m;
    A = pi/4*(D^2-Di^2); p = pi*D;
    R(i).A = A; R(i).p = p;
    x = R(i).x*in2m; Ts = R(i).Tss; dx = mean(diff(x)); L = R(i).L*in2m;
    % (a) Excel method
    m2 = (Ts(1)+Ts(3)-2*Ts(2)) / (dx^2*(Ts(2)-R(i).Ta));
    R(i).hk_excel = m2*A/p;
    R(i).h_excel  = R(i).hk_excel*R(i).k;
    % Excel predictions of T1, T2 from T0 and T3 (same formula as the sheet)
    a = 2 + m2*dx^2; c = m2*dx^2*R(i).Ta;
    R(i).T1_excel = (Ts(4) + a*Ts(1) + c*(1+a)) / (a^2-1);
    R(i).T2_excel = (Ts(1) + a*Ts(4) + c*(1+a)) / (a^2-1);
    % (b) closed-form fit, uses all sensors that are trusted
    u = logical(R(i).use);
    cost = @(q) sum(( R(i).Ta + q(1)*cosh(abs(q(2))*(L-x(u)))/cosh(abs(q(2))*(L-x(1))) - Ts(u) ).^2);
    q = fminsearch(cost,[Ts(1)-R(i).Ta 20],optimset('TolX',1e-8,'TolFun',1e-10,'MaxFunEvals',5000));
    R(i).th0 = q(1); R(i).m = abs(q(2));
    R(i).hk_fit = R(i).m^2*A/p;
    R(i).h_fit  = R(i).hk_fit*R(i).k;          % h if k = handbook value
    R(i).k_fit  = R(i).hNX/R(i).hk_fit;        % k if h = NX value
    xx = linspace(R(i).x(1),R(i).L,200)*in2m;   % analytical curve starts at the first sensor (that is where T0 is)
    R(i).anX = xx/in2m;
    R(i).anT = R(i).Ta + R(i).th0*cosh(R(i).m*(L-xx))/cosh(R(i).m*(L-x(1)));
    R(i).anAtSensor = interp1(R(i).anX,R(i).anT,R(i).x);
    % comparisons (RMS, trusted sensors only)
    R(i).rms_NX_exp = sqrt(mean((R(i).nxAtSensor(u)-Ts(u)).^2));
    R(i).max_NX_exp = max(abs(R(i).nxAtSensor(u)-Ts(u)));
    R(i).rms_AN_exp = sqrt(mean((R(i).anAtSensor(u)-Ts(u)).^2));
    xu = R(i).x(u);
    xr = linspace(xu(1),xu(end),50);            % NX vs analytical over the sensor span
    R(i).rms_NX_AN  = sqrt(mean((interp1(R(i).nxX,R(i).nxT,xr,'linear','extrap')-interp1(R(i).anX,R(i).anT,xr)).^2));
    R(i).Qfrac = R(i).QNX/P;
end

%% ---------------- FIGURE 4: steady profiles, NX vs analytical vs measured ----------------
for i = 1:numel(R)
    f = figure('Color','w','Position',[100 100 640 420]);
    plot(R(i).nxX,R(i).nxT,'b-','LineWidth',1.5); hold on; grid on;
    plot(R(i).anX,R(i).anT,'r--','LineWidth',1.5);
    u = logical(R(i).use);
    plot(R(i).x(u),R(i).Tss(u),'ko','MarkerFaceColor','k','MarkerSize',7);
    lg = {'NX model','Analytical (fit)','Measured'};
    if any(~u), plot(R(i).x(~u),R(i).Tss(~u),'kx','MarkerSize',10,'LineWidth',2); lg{end+1} = 'Measured (not used)'; end
    plot([0 12],[1 1]*R(i).Ta,'k:');
    xlabel('Distance from heated end (in)'); ylabel('Steady-state T (^oC)');
    title(sprintf('%s - NX h = %.1f W/m^2K, analytical h = %.1f W/m^2K',R(i).name,R(i).hNX,R(i).h_fit));
    legend(lg,'Location','northeast'); xlim([0 12]);
    yl = ylim; ylim([floor(R(i).Ta)-2 min(yl(2),80)]);
    saveFig(f,fullfile(figDir,sprintf('fig04_profile_%s.png',strrep(R(i).name,' ','_'))));
end

%% ---------------- FIGURE 5: h from each method ----------------
f = figure('Color','w','Position',[100 100 800 420]);
H = [[R.hNX]' [R.h_fit]' [R.h_excel]'];
Hp = H; Hp(Hp<0) = 0; Hp(Hp>60) = 60;
hb = bar(Hp); grid on; hold on;
set(gca,'XTickLabel',{R.name}); ylim([0 65]);
ylabel('h (W/m^2K)');
plot([0.5 5.5],[25 25],'k--');
legend(hb,{'NX (tuned to data)','Analytical fit (all sensors)','Excel 3-point'},'Location','northwest');
title('Convection coefficient h from each model (k = handbook value)');
for i = 1:numel(R)
    if H(i,3) < 0,  text(i+0.22,3,'neg.','HorizontalAlignment','center','FontSize',8); end
    if H(i,3) > 60, text(i+0.22,62,sprintf('%.0f',H(i,3)),'HorizontalAlignment','center','FontSize',8); end
end
text(5.45,27,'top of lecture range (25)','HorizontalAlignment','right','FontSize',8);
saveFig(f,fullfile(figDir,'fig05_h_by_method.png'));

%% ---------------- FIGURE 6: how well do they match ----------------
f = figure('Color','w','Position',[100 100 800 420]);
bar([[R.rms_NX_exp]' [R.rms_NX_AN]']); grid on;
set(gca,'XTickLabel',{R.name}); ylabel('RMS difference (^oC)');
legend('NX vs experiment','NX vs analytical','Location','northwest');
title('RMS = sqrt(mean((T_{model} - T_{meas})^2))');
saveFig(f,fullfile(figDir,'fig06_rms_match.png'));

%% ---------------- results table ----------------
fid = fopen(fullfile(figDir,'EXP2_Rev2_results.csv'),'w');
fprintf(fid,'Rod,k_handbook,h_NX,Q_NX_W,Q_over_P,hk_excel,h_excel,T1_meas,T1_excel,T2_meas,T2_excel,hk_fit,h_fit,k_fit_with_hNX,rms_NX_exp,max_NX_exp,rms_AN_exp,rms_NX_AN,Tss1,Tss2,Tss3,Tss4,tSteady_min,maxSlope\n');
for i = 1:numel(R)
    fprintf(fid,'%s,%g,%.2f,%.3f,%.3f,%.4f,%.1f,%.2f,%.2f,%.2f,%.2f,%.4f,%.1f,%.0f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.1f,%.2f\n', ...
        R(i).name,R(i).k,R(i).hNX,R(i).QNX,R(i).Qfrac,R(i).hk_excel,R(i).h_excel,R(i).Tss(2),R(i).T1_excel,R(i).Tss(3),R(i).T2_excel, ...
        R(i).hk_fit,R(i).h_fit,R(i).k_fit,R(i).rms_NX_exp,R(i).max_NX_exp,R(i).rms_AN_exp,R(i).rms_NX_AN,R(i).Tss,R(i).tSteady/60,max(abs(R(i).slope)));
end
fclose(fid);
type(fullfile(figDir,'EXP2_Rev2_results.csv'));
% helper functions are in readRun.m, timeToSteady.m and saveFig.m (same folder)
