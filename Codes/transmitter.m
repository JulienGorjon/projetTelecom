% TO DO :
%--------
% Modify the code to use COLUMN vector for signals as asked in the PDF



% total msg = start + data
Mt = [Ms;Md(:,1)];             % temporary work with the msg for the channel N=1

% msg as symbols -1,1 for bits 0,1
Mt(Mt==0)=-1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate a sampled s(t) by using a FIR filter g(t) and then interpolate it with a DAC
% followed by a low-pass filter.
%
% One FIR p(t) for each channel :
% channel 0 : p_0(t) = g(t)
% channel n : p_n(t) = g(t) * cos(Omega_n*t) where Omega_n = 2*pi*2n/Tb
%
% => for k symbols : s_n(t) = A * a_n(k) * p_n(t - k*Tb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% rcosfir(R,N_T,RATE,T)   info here : http://read.pudn.com/downloads67/doc/comm/240139/mfiles/Chapter10/programs/prgs/depfun/rcosfir.m__.htm
%   - T : is the input signal sampling period, in seconds.       => = Tb
%   - RATE  : is the oversampling rate for the filter            => = Beta
%   - R : the rolloff factor, determines the width of the transition 
%         band.  R has no units.  The transition band is (1-R)/(2*T) < |f| < 
%        (1+R)/(2*T).                                            => = alpha ("facteur de descente")
%   - N_T : is a scalar or a vector of length 2.  If N_T is specified as a 
%           scalar, then the filter length is 2 * N_T + 1 input samples.  If N_T is 
%           a vector, it specifies the extent of the filter.  In this case, the filter 
%           length is N_T(2) - N_T(1) + 1 input samples (or 
%           (N_T(2) - N_T(1))* RATE + 1 output samples).            => = L    N.B : window is [-L*Tb:L*Tb]
g0 = rcosfir(Alpha, L , Beta, Tb);
halfPeriod = L*Beta;
time = -halfPeriod:1:halfPeriod;

Omega = 4*pi/Beta;   %Omega_n = 2*pi*2n/Tb
g1 =  g0 .* cos(Omega*1*time);
g3 =  g0 .* cos(Omega*2*time);
g4 =  g0 .* cos(Omega*3*time);

plot(time,g0,time,g1) % plot first two filters pulse responses 
title('Two first FIR filters pulse responses')

s=[];
for k = 1:length(Mt)
    symbolFIR = g0 * Mt(k);
    if length(s) == 0
        s = zeros(1,(2*halfPeriod)+1);
    else 
        symbolFIR = [zeros(1,length(s)-halfPeriod-1), symbolFIR];
        s = [s,zeros(1,2*Beta)];
    end
    s = s + symbolFIR;
end

% interpolate with FFT to get Gamma times more points
s = interpft(s, length(s)*Gamma);

figure
plot(s)
title('Modulated analog signal s(t)')

% TO DO : modulate the amplitude to get the desired power through the cable
% with impedance Zc