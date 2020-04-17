windowedS = analogFilter(s)


function[r_n] = analogFilter(signal, frequency)
   num, den = butter(n, frequency); %lowpass filter if frequency is a number, bandpass filter if it is a 2 element vector
   %TODO : check cheby1 cheby2 ellip and besself filters
   w = [];
   if isa(frequency, 'int')
       w = linspace(0, frequency, n); %lowpass
   elseif length(frequency) == 2
       w = linspace(frequency(0), frequency(1), n); %bandpass
   else
       sprintf("Incorrect frequency format");
   end
   filter_transfer_freq = freqs(num, den, w); 
   filter_transfer = ifft(filter_transfer_freq);
   r_n = conv(filter_transfer, signal); %convolution product
end
