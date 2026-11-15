% Example filter script

%sample_arduino_data
load sample_commercial_data


% Filter response
A = 1;

% Fs = 500, FL = 50, BL = 100
B = [0.172608949702014097
     0.213356395356531503
     0.228069309882908744
     0.213356395356531503
     0.172608949702014097];

Y = filter(B,A,X);

Z = Y;
for ii=1:5
    Z = filter(B,A,Z);
end

t = dt*(0:length(X)-1);

plot(t,X,t,Y,t,Z)
