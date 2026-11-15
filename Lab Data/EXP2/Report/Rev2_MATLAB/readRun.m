function [t,T] = readRun(fname,fmt,dt)
% reads an Arduino dump
% 'D' = Canvas sketch dump (T0 T1 T2 T3 T0 T1 ...), 'T' = time,T0,T1,T2,T3 per line
txt = fileread(fname);
txt = strrep(txt,',',' ');
v = sscanf(txt,'%f');
if fmt == 'D'
    T = reshape(v,4,[])'; t = (0:size(T,1)-1)'*dt;
else
    M = reshape(v,5,[])'; t = M(:,1)-M(1,1); T = M(:,2:5);
end
end
