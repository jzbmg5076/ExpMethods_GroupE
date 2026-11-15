function [isSteady, slopes] = check_steady_state(t, T, windowSize, slopeThresh)
%CHECK_STEADY_STATE  Per-channel rolling-window slope check for EXP2 rod data.
%
%   [isSteady, slopes] = check_steady_state(t, T, windowSize, slopeThresh)
%
%   t            : Nx1 vector of sample timestamps, seconds, oldest first
%   T            : NxC matrix of temperatures (deg C), one column per
%                  thermistor channel, rows aligned with t
%   windowSize   : number of most-recent samples to fit a line through
%                  (use REAL elapsed time, not an assumed 5s spacing --
%                  the Arduino loop runs closer to ~7s per the EXP2 FAQ)
%   slopeThresh  : max allowed |dT/dt| per channel, deg C / s, before
%                  that channel counts as "flat" -- THIS NUMBER IS A
%                  PLACEHOLDER. It has not been calibrated against your
%                  actual thermistor noise floor. Run
%                  test_steady_state_offline.m against a real transient
%                  data set and look at what the slope looks like once a
%                  channel has visibly flattened out, then set this from
%                  that -- don't trust 0.05 as a real answer.
%
%   isSteady     : true only if EVERY channel's fitted slope magnitude is
%                  below slopeThresh (this is the "AND" across channels
%                  -- same idea as ANDing continuity/momentum/energy
%                  residuals in a CFD convergence check)
%   slopes       : 1xC vector of the fitted slope per channel, deg C/s
%                  (log/plot this even when isSteady is false -- it's
%                  useful for picking a real threshold after the fact)
%
%   Uses a linear regression over the last windowSize samples rather than
%   a single-step delta (T(end)-T(end-1)), so one noisy reading can't
%   fake convergence and one noisy reading can't fake non-convergence
%   either.

    n = size(T,1);
    nChan = size(T,2);
    slopes = nan(1,nChan);

    if n < windowSize
        isSteady = false;   % not enough history yet to judge
        return
    end

    idx = (n-windowSize+1):n;
    tw = t(idx);

    for c = 1:nChan
        Tw = T(idx,c);
        p = polyfit(tw, Tw, 1);   % p(1) = slope, deg C per second
        slopes(c) = p(1);
    end

    isSteady = all(abs(slopes) < slopeThresh);
end
