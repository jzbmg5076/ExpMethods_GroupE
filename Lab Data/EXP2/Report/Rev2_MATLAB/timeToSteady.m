function ts = timeToSteady(t,T,use)
% first time (s) where every trusted channel changes < 0.1 C/min over the previous 3 minutes
% (only counted after Ch1 has warmed up at least 3 C, so the flat start is ignored)
ts = NaN;
for j = 1:numel(t)
    if t(j) < 180 || T(j,1) < T(1,1)+3, continue; end
    w = t >= t(j)-180 & t <= t(j);
    ok = true;
    for c = find(use)
        pp = polyfit(t(w)/60,T(w,c),1);
        if abs(pp(1)) >= 0.1, ok = false; break; end
    end
    if ok, ts = t(j); return; end
end
end
