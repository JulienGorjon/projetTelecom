%r is the noised signal
T = Tb/Beta/Gamma;
Fs = 1/T; 
L = length(r); 
Y = fft(r);
double_sided = abs(Y/L);
single_sided = double_sided(1:100+1);
single_sided(2:end-1) = 2*single_sided(2:end-1); 
f = Fs*(0:(100))/L;
figure
plot(f,single_sided)
title("Transformée de Fourrier sur r, le signal bruité")
xlabel("[ Hz ]")
% for loop to get all windows in array would be nice 
Bp = 800;%1+alpha/(2*Tb)
window1 = analogFilter(r, Bp, Fs); %1/Tb the cutoff frequency
window2 = analogFilter(r, [2000-Bp, 2000+Bp], Fs);
window3 = analogFilter(r, [4000-Bp, 4000+Bp], Fs);
window4 = analogFilter(r, [6000-Bp, 6000+Bp], Fs);
%%%%%%%%%%%% FFT %%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% DISPLAY %%%%%%%%%%
figure
plot(f,disp1)
title("Filtrage, fenêtre 1")
xlabel("[ Hz ]")
figure
plot(f,disp2)
title("Filtrage, fenêtre 2")
xlabel("[ Hz ]")
figure
plot(f,disp3)
title("Filtrage, fenêtre 3")
xlabel("[ Hz ]")
figure
plot(f,disp4)
title("Filtrage, fenêtre 4")
xlabel("[ Hz ]")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%compute values based on the windows
WINDOW = signals(:,1); % declare a proper window to test the receptor
scale = max(WINDOW); %compute the right scale
original_msg = Md(:,1).'
out_receiver = simplifiedReceptor(WINDOW, Tn, symbols_time, scale, Ms, Tanal, Gamma, Beta, length(Md(:,1)))
%compute error rate
errors = xor(Md(:,1).', out_receiver);
error_rate = nnz(errors)/length(out_receiver)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%  FUNCTIONS DEFINITION  %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[r_n] = analogFilter(signal, frequency, Fs)
   w = [];
   ftype = 'bandpass'; 
   length(frequency);
   if (isa(frequency, 'integer') || isa(frequency, 'float')) && length(frequency) == 1
       if isa(frequency, 'float')
           frequency = round(frequency);
       end
       ftype = 'low';
   elseif length(frequency) == 2
       if isa(frequency, 'float')
           frequency(1) = round(frequency(1));
           frequency(2) = round(frequency(2));
       end
   else
       sprintf("Incorrect frequency format");
   end
   pulse = 2*pi*frequency % :-( for digital filters, wp is normalized with respect to the Nyquist rate (half the sample rate)
   [zero, pole, gain] = butter(5, pulse, ftype, 's');  %lowpass filter if frequency is a scalar, bandpass filter if it is a 2 element vector

   [b, a] = zp2tf(zero, pole, gain);
   [filter_transfer_freq, wb] = freqs(b, a, 4096);
  
   i_filter_transfer_freq = imag(filter_transfer_freq);
   r_i_filter_transfer_freq = [real(filter_transfer_freq) ; i_filter_transfer_freq]; %concatenate both arrays
   mag = abs(filter_transfer_freq);
   plot(wb,mag2db(mag))
   grid on
   hold on
   axis([0 wb(end) -40 5])
   xlabel('Pulse (rad/s)')
   ylabel('Magnitude (dB)')
   %hold off
   filter_transfer = ifft(r_i_filter_transfer_freq); %r_i_filter_transfer_freq
   r_n = conv(signal, r_i_filter_transfer_freq) ; %convolution product conv(signal, transfer)
end


function[out_values] = simplifiedReceptor(window, Tn, symbolsTime, scale, pilotSeq, Tanal, Gamma, Beta, bitsInMessage) %version 1 : scale, sampling, sync, quantization, decision 
%%% DISPLAY %%%
figure
sampleNumber = [1:1:length(window)];
plot(sampleNumber, window)
title('input receptor')
xlabel('sample number')
ylabel('Magnitude')
%%%%%%%%%%%%%%%

%scaling signal, return to range [-1;1]
window = window/scale;
%3 level quantization
partition = [-0.5, 0.5]; % if value < -0.5, qValue = 0, if -0.5 < value < 0.5, qValue = 1, if  value > 0.5, qValue = 2
qValues = quantiz(window, partition); % = quantiz(sampled, partition)

%%% DISPLAY %%%
figure
sampleNumber = [1:1:length(qValues)];
plot(sampleNumber, qValues)
title('qValues')
xlabel('sample number')
ylabel('Magnitude')
%%%%%%%%%%%%%%%

%symbol estimation
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
sampleNumber = [1:1:length(estimValues)];

%%% DISPLAY %%%
plot(sampleNumber, estimValues)
title('estimate of values')
xlabel('sample number')
ylabel('Magnitude')
%%%%%%%%%%%%%%%

%sync by finding time of maximum correlation between pilote sequence and
%the signal
pilotSeq = pilotSeq.';
[correl, lags] = xcorr(estimValues, pilotSeq);

%%% DISPLAY %%%
figure
stem(lags, correl)
%%%%%%%%%%%%%%%

%correlation has double the size of estimValues, so to find the start of
%the payload => substract size of estimValues, than the size of the
%sequence
[maxVal, indexMax] = max(correl);
startTime = indexMax - (length(estimValues)-Gamma*Beta*(length(pilotSeq)));%-length(pilotSeq))

%%%% DISPLAY %%%%
stuff = zeros([1, startTime]);
stuff_after = zeros([1, (length(estimValues) - startTime - length(pilotSeq))]);
sizeStuff = size(stuff);
sizePilotSeq = size(pilotSeq);
pilotSeqDraw = [stuff pilotSeq];
pilotSeqDraw = [pilotSeqDraw stuff_after];
xAxis = [1:1:length(estimValues)];
figure
plot(xAxis,estimValues, xAxis, pilotSeqDraw)
title('start message at position')
grid on
hold on
xlabel('sample number')
ylabel('Magnitude')
%%%%%%%%%%%%%%%%%%%%%%%

estimValuesCrop = estimValues(:, startTime:(startTime + (bitsInMessage-1)*Beta*Gamma));
out_values = downsample(estimValuesCrop, Gamma*Beta);

%%% DISPLAY %%%
figure
sampleNumber = [1:1:length(out_values)];
plot(sampleNumber, out_values)
title('output of receptor')
xlabel('sample number')
ylabel('Magnitude')
%%%%%%%%%%%%%%%
end
