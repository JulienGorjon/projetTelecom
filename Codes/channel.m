
% SUM OF SHIFTED ATTENUATED AND SHIFTED SIGNALS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% delays of max T (Beta*Gamma samples) for each channel
cablePhaseShifts= round(rand(1,length(modules)) * Beta * Gamma);

% initialize the total signal with the max number of samples
maxShift = max(cablePhaseShifts);
s = zeros(length(signals(:,1)) + maxShift, 1);

% shift every signal and add it to the total signal s
for i = 1:length(modules)
   % shift and add zeros at th end to get the dimension of s
   shiftedSignal = [ zeros(cablePhaseShifts(i),1) ; signals(:,i) ; zeros(maxShift-cablePhaseShifts(i),1) ]; 
   s = s + shiftedSignal;
end

 

% ADD NOISE WITH RESULTING Eb/N0 % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noise = randn(length(s),1);
figure
plot(noise)

% LOW PASS filter the noise
cutoffFreq = 2*N/Tb;
sampleFreq = 1/(Tn/Gamma);
[a,b] = butter(1,cutoffFreq/(sampleFreq/2) ,'low');
noise = filter(a, b, noise);
figure
plot(noise)

% MEASUREMENT OF RESULTING Eb/N0 (energy per bit to noise power spectral density
% ratio)
% Eb/N0 = C/N * B/fb  
% where C/N = signal to noise ration (P_signal/P_noise)
%       B = channel bandwidth
%       fb = bitrate
signalPower = sum(s.^2)/length(s);
noisePower = sum(noise.^2)/length(noise);
SNR = signalPower / noisePower;
B = cutoffFreq;
fb = 1/Tb;
Eb_over_N0 = SNR * B / fb;

% SCALE TO GET WANTED Eb/N0
wantedEb_over_N0 = 100;                     % TODO : init in parameters and in dB
factor = wantedEb_over_N0 / Eb_over_N0;     % noise power is -factor- times to high
noise = noise / sqrt(factor);               % voltage/sqrt(-factor-) gives power -factor- smaller

figure
plot(noise)

figure
plot(s+noise)
title('Phase shifted and attenuated signal')