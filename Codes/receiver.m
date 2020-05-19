%r is the noised signal
T = Tb/Beta/Gamma;
Fs = 1/T; 
L = length(r); 
Y = fft(r);
double_sided = abs(Y/L);
single_sided = double_sided(1:100+1);
single_sided(2:end-1) = 2*single_sided(2:end-1); % don't know why but from the doc
f = Fs*(0:(100))/L;
figure
plot(f,single_sided)
title("Transform�e de Fourrier sur r, le signal bruit�")
xlabel("[ Hz ]")
window1 = analogFilter(r, 1/Tb, Fs); %1/Tb the cutoff frequency
window2 = analogFilter(r, [2/Tb, 3/Tb], Fs);
window3 = analogFilter(r, [4/Tb, 5/Tb], Fs);
window4 = analogFilter(r, [6/Tb, 7/Tb], Fs);
L = length(window1);
disp1 = fft(window1);
disp1 = abs(disp1/L);
disp1(2:end-1) = 2*disp1(2:end-1);
disp2 = fft(window2);
disp2 = abs(disp2/L);
disp2(2:end-1) = 2*disp2(2:end-1);
disp3 = fft(window3);
disp3 = abs(disp3/L);
disp3(2:end-1) = 2*disp3(2:end-1);
disp4 = fft(window4);
disp4 = abs(disp4/L);
disp4(2:end-1) = 2*disp4(2:end-1);
f = Fs*(0:length(disp1)-1)/L;
length(disp1)
length(f)
figure
plot(f,disp1)
title("Filtrage, fen�tre 1")
xlabel("[ Hz ]")
figure
plot(f,disp2)
title("Filtrage, fen�tre 2")
xlabel("[ Hz ]")
figure
plot(f,disp3)
title("Filtrage, fen�tre 3")
xlabel("[ Hz ]")

%compute values based on the windows
WINDOW = signals(:,1); % declare a proper window to test the receptor
scale = 1; %compute the right scale
Ms
values = simplifiedReceptor(WINDOW, Tn, symbols_time, scale, Ms, Tanal, Gamma, Beta);
%compute error rate
lengthValues = length(values)
Md
errors = xor(Md(:,1), values);
error_rate = nnz(errors)/length(values)

function[r_n] = analogFilter(signal, frequency, Fs)
   w = [];
   ftype = 'bandpass'; 
   length(frequency);
   if (isa(frequency, 'integer') || isa(frequency, 'float')) && length(frequency) == 1
       if isa(frequency, 'float')
           frequency = round(frequency);
       end
       w = 2*pi*logspace(0, log10(frequency), 100);
       w2 = 2*pi*logspace(0, log10(frequency*2), 100);
       ftype = 'low';
   elseif length(frequency) == 2
       w = 2*pi*logspace(log10(frequency(1)), log10(frequency(2)), 100); 
       w2 = 2*pi*logspace(log10(frequency(1)), log10(frequency(2)*2), 100); 
   else
       sprintf("Incorrect frequency format");
   end
   %filter chebyshev of order 3, in order to have greater selectivity
   pulse = 2*pi*frequency; % :-( for digital filters, wp is normalized with respect to the Nyquist rate (half the sample rate)
   [num, den] = butter(1, pulse, ftype, 's');  %lowpass filter if frequency is a scalar, bandpass filter if it is a 2 element vector
   %0.1 is Rp, which is ripple in passband (in dB)
   %TODO : check butter cheby2 ellip and besself filters. "Les familles de ?ltres analogiques physiquement r�ealisables 
   %les plus connues sont les ?ltres de Butterworth, Chebyshev, Bessel et les ?ltres elliptiques. L�ordre kn du ?ltre 
   %(qui d�etermine le nombre de cellules �el�ementaires `a mettre en cascade), les fr�equences de coupure `a 3 dB f? n
   %et f+ n , le niveau d�oscillation dans la bande passante (�ripple�) et l�a?aiblissement hors-bande sont autant de 
   %param`etres `a prendre �eventuellement en compte lors du
   %dimensionnement de ces ?ltres."
   filter_transfer_freq = freqs(num, den, w);
  
   i_filter_transfer_freq = imag(filter_transfer_freq);
   r_i_filter_transfer_freq = [filter_transfer_freq i_filter_transfer_freq] %concatenate both arrays
   w2 = [w (w+w(end))]
   mag = abs(r_i_filter_transfer_freq);
   plot(w2,mag)
   grid on
   hold on
   xlabel('Frequency (rad/s)')
   ylabel('Magnitude')
   %hold off
   filter_transfer = ifft(r_i_filter_transfer_freq);
   r_n = conv(filter_transfer, signal); %convolution product
end

%nb is the quantization step
%1/Tn is the sampling rate
%endTime = max (symbols_time)
function[values] = simplifiedReceptor(window, Tn, symbolsTime, scale, pilotSeq, Tanal, Gamma, Beta) %version 1 : scale, sampling, sync, quantization, decision 
figure
sampleNumber = [1:1:length(window)]
plot(sampleNumber, window)
title('input receptor')
xlabel('sample number')
ylabel('Magnitude')
%scaling signal, return to range [-1;1]
window = window/scale;
%3 level quantization
partition = [-1, 1]; % if value < -1, qValue = 0, if -1 < value < 1, qValue = 1, if  value > 1, qValue = 2
qValues = quantiz(window, partition); % = quantiz(sampled, partition);
%symbol estimation
figure
sampleNumber = [1:1:length(qValues)]
plot(sampleNumber, qValues)
title('qValues')
xlabel('sample number')
ylabel('Magnitude')
estimValues = ones([1, length(qValues)]).*(-1);
for k = 1:length(qValues)
   if qValues(k) == 0
       estimValues(k) = 0;
   elseif qValues(k) == 2
       estimValues(k) = 1;
   else %undetermined, error risk
       if k > 1
            estimValues(k) = estimValues(k-1);
       else
           estimValues(k) = 0;
       end
   end           
end
figure
sampleNumber = [1:1:length(estimValues)]
plot(sampleNumber, estimValues)
title('estimate of values')
xlabel('sample number')
ylabel('Magnitude')
%sync by finding time of maximum correlation between pilote sequence and
%the signal
pilotSeq = pilotSeq.';
[correl, lags] = xcorr(estimValues, pilotSeq);
figure
stem(lags, correl)
[maxVal, indexMax] = max(correl);
size(correl)
startTime = indexMax * Tanal; %start sampling at the end of pilot sequence
%Sampling to original rate
%endTime = symbolsTime(end); %last value is the maximum value and the last sample time
%tSamp = startTime:Tn:endTime;
%values = interp1(symbolsTime, estimValues, tSamp, 'spline');
indexMax = indexMax - (length(estimValues)-length(pilotSeq))
%%%% DISPLAY %%%%
stuff = zeros([1, indexMax]);
stuff_after = zeros([1, (length(estimValues) - indexMax - length(pilotSeq))]);
sizeStuff = size(stuff)
sizePilotSeq = size(pilotSeq)
pilotSeqDraw = [stuff pilotSeq];
pilotSeqDraw = [pilotSeqDraw stuff_after];
xAxis = [1:1:length(estimValues)]
figure
plot(xAxis,estimValues, xAxis, pilotSeqDraw)
title('pilote sequence position')
grid on
hold on
xlabel('Frequency (rad/s)')
ylabel('Magnitude')
%%%%%%%%%%%%%%%%%%%%%%%
estimValuesCrop = estimValues(:, indexMax:end);
values = downsample(estimValuesCrop, Gamma*Beta);
%%% DISPLAY %%%
figure
sampleNumber = [1:1:length(values)]
plot(sampleNumber, values)
title('output of receptor')
xlabel('sample number')
ylabel('Magnitude')
%%%%%%%%%%%%%%%
end
