%r is the noised signal
window1 = analogFilter(r, 1/Tb); %1/Tb the cutoff frequency
window2 = analogFilter(r, [2/Tb, 3/Tb]);
window3 = analogFilter(r, [4/Tb, 5/Tb]);
window4 = analogFilter(r, [6/Tb, 7/Tb]);

function[r_n] = analogFilter(signal, frequency)
    %filter butterworth of order 3, in order to minimize attenuation of the
    %nth canal and
   num, den = cheby1(3, 1, frequency); %lowpass filter if frequency is a scalar, bandpass filter if it is a 2 element vector
   %1 is Rp, which is ripple in passband (in dB)
   %TODO : check butter cheby2 ellip and besself filters. "Les familles de ?ltres analogiques physiquement r´ealisables 
   %les plus connues sont les ?ltres de Butterworth, Chebyshev, Bessel et les ?ltres elliptiques. L’ordre kn du ?ltre 
   %(qui d´etermine le nombre de cellules ´el´ementaires `a mettre en cascade), les fr´equences de coupure `a 3 dB f? n
   %et f+ n , le niveau d’oscillation dans la bande passante (’ripple’) et l’a?aiblissement hors-bande sont autant de 
   %param`etres `a prendre ´eventuellement en compte lors du
   %dimensionnement de ces ?ltres."
   w = [];
   if isa(frequency, 'int')
       w = logspace(0, frequency); %lowpass
   elseif length(frequency) == 2
       w = logspace(frequency(0), frequency(1)); %bandpass
   else
       sprintf("Incorrect frequency format");
   end
   filter_transfer_freq = freqs(num, den, w); 
   filter_transfer = ifft(filter_transfer_freq);
   r_n = conv(filter_transfer, signal); %convolution product
end
