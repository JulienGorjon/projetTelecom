%r is the noised signal
window1 = analogFilter(r, ); %cutoff frequency
window2 = analogFilter(r, );
window3 = analogFilter(r, );
window4 = analogFilter(r, );


function[r_n] = analogFilter(signal, frequency)
    %filter butterworth of order 3, in order to minimize attenuation of the
    %nth canal and
   num, den = butter(3, frequency); %lowpass filter if frequency is a number, bandpass filter if it is a 2 element vector
   %TODO : check cheby1 cheby2 ellip and besself filters. "Les familles de ?ltres analogiques physiquement r´ealisables 
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
