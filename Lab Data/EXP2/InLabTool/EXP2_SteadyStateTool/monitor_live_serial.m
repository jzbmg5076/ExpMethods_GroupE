%% monitor_live_serial.m  -- LIVE mode, day-of-lab
%
% This does NOT touch the Arduino sketch in any way. It opens the same
% serial port your laptop already reads (the same stream you'd watch in
% the Arduino IDE's Serial Monitor), parses each incoming line, and runs
% check_steady_state.m on it in real time -- a laptop-side listener
% only. If this script crashes or misbehaves, your data acquisition is
% completely unaffected; worst case you just watch the Serial Monitor
% and type "D" yourself like the fallback plan.
%
% *** PLACEHOLDER WARNING -- READ BEFORE LAB ***
% The exact text format the Arduino prints to serial is NOT confirmed.
% The only view we have is a partial screenshot of setup() from the
% 09-21 lecture (not the print statements in loop()), plus a blurry
% glimpse of a live Serial Monitor on the projector. parseLine() below
% is a best guess at that format. Before trusting this in lab:
%   1) Get the real .ino (professor said he'd post it to Canvas/EXP2 --
%      not there as of 2026-09-22) or copy the actual print/Serial.print
%      lines from loop(), OR
%   2) Just watch the real Serial Monitor for 30 seconds during a dry
%      run, copy 5-10 real lines, and fix parseLine() to match exactly.
% Do not run this unattended in lab until parseLine() has been checked
% against real output -- if it silently fails to parse, isSteady never
% fires and you just fall back to watching the screen yourself, which is
% safe, but confirm that fallback behavior too.

clear; clc;

portName = "COM4";     % check Windows Device Manager / Arduino IDE for the real port
baud     = 115200;     % matches Serial.begin(115200) seen in the lecture code

nChan          = 4;    % or however many channels this rod's test is using
windowSize     = 5;    % see check_steady_state.m
slopeThresh    = 0.05; % PLACEHOLDER -- calibrate with test_steady_state_offline.m first
minConsecutive = 3;

s = serialport(portName, baud);
configureTerminator(s, "LF");

tBuf = [];
TBuf = [];
consecCount = 0;
t0 = tic;

fprintf('Listening on %s... waiting for steady state (Ctrl+C to stop)\n', portName);

while true
    line = readline(s);
    [ok, temps] = parseLine(line, nChan);   % <-- see placeholder warning above
    if ~ok
        continue
    end

    tNow = toc(t0);
    tBuf(end+1,1) = tNow;      %#ok<*SAGROW>
    TBuf(end+1,:) = temps;     %#ok<*SAGROW>

    if size(TBuf,1) < windowSize
        continue
    end

    [isSteady, slopes] = check_steady_state(tBuf, TBuf, windowSize, slopeThresh);
    fprintf('t=%6.1fs  slopes=%s  steady=%d\n', tNow, mat2str(round(slopes,4)), isSteady);

    if isSteady
        consecCount = consecCount + 1;
    else
        consecCount = 0;
    end

    if consecCount >= minConsecutive
        fprintf('\n*** STEADY STATE -- send "D" now (t = %.1f s) ***\n\n', tNow);
        beep;
        break
    end
end

function [ok, temps] = parseLine(line, nChan)
    % PLACEHOLDER PARSER -- confirm against real Arduino output and
    % rewrite before trusting this in lab. Best guess from the lecture
    % screenshot: lines resembling
    %   "hh:mm:ss.mmm -> Temperature: 51.04C   57.05C"
    % This grabs every number on the line and takes the first nChan of
    % them, which will be WRONG if the real format includes the h:m:s
    % timestamp as leading numbers too -- check for that specifically.
    ok = false;
    temps = nan(1, nChan);
    nums = regexp(line, '-?\d+\.?\d*', 'match');
    if numel(nums) >= nChan
        temps = str2double(nums(1:nChan));
        ok = all(~isnan(temps));
    end
end
