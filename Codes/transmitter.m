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
g0 = transpose(rcosfir(Alpha, L , Beta, Tb));
FIR_time = transpose(-L*Tb:Tb/Beta:L*Tb);


modulationFactors = cos(FIR_time * ((1:1:N-1) .* (4*pi/Tb)));   %cos(Omega_n*time) where Omega_n = 2*pi*2n/Tb
p = [g0,g0 .* modulationFactors];

FIR_time = FIR_time / Tb;  % time axis as T graduation
figure
plot(FIR_time,p(:,1),FIR_time,p(:,2),FIR_time,p(:,3)) % plot first two filters pulse responses 
title('Trois premiers FIR')
xlabel("[ T ]")

% modulate the symbols with the filter of the choosed module n 
s=[];
for n = modules
    q=[];
    for k = 1:length(Mt)
        symbolFIR = p(:,n) .* Mt(k);
        if length(q) == 0
            q = zeros((2*L*Beta)+1,1);
        else 
            symbolFIR = [zeros(length(q)-((2*L)-1)*Beta-1, 1); symbolFIR];
            q = [q;zeros(Beta,1)];
        end
        q = q + symbolFIR;
    end
    if length(s) == 0
        s = q;
    else
        s = s + q;
    end
end

% interpolate with FFT to get Gamma times more points
s = interpft(s, length(s)*Gamma);

% Time vector to plot the output signal
periodNumber = 4 + length(Mt)-1;
s_time = 0 : Tb/Beta/Gamma : (length(s)*Tb/Beta/Gamma)-Tb/Beta/Gamma;

% Time and value vectors for the symbols
bitsTimeIndexes = L:1:length(Mt)-1+L;
bitsTimeIndexes = bitsTimeIndexes * Beta * Gamma;
symbols_time = s_time(bitsTimeIndexes);
symbols_value = s(bitsTimeIndexes);

figure
plot(s_time,s)
hold on
scatter(symbols_time, symbols_value)
title('Superposition des signaux')
xlabel("[ s ]")
hold off


% FFT on the output signal
T = Tb/Beta/Gamma;
Fs = 1/T; 
L = length(s); 
Y = fft(s);
double_sided = abs(Y/L);
crop = 100;   % L/2 instead of 100 in doc but result too much zoomed out
single_sided = double_sided(1:crop+1);   
single_sided(2:end-1) = 2*single_sided(2:end-1); % don't know why but from the doc
f = Fs*(0:(crop))/L;
figure
plot(f,single_sided)
title("Transformée de Fourrier")
xlabel("[ Hz ]")

% TO DO : modulate the amplitude to get the desired power through the cable
% with impedance Zc
