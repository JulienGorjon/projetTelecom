function [] = plotFFT(signal, T, cropFactor)   % cropFactor between 0 and 1 to limit the max frequency
    Fs = 1/T; 
    L = length(signal); 
    Y = fft(signal);
    double_sided = abs(Y/L);
    crop = round(cropFactor*length(signal));   % L/2 instead of 100 in doc but result too much zoomed out
    single_sided = double_sided(1:crop+1);   
    single_sided(2:end-1) = 2*single_sided(2:end-1); % don't know why but from the doc
    f = Fs*(0:(crop))/L;
    plot(f,single_sided)
    xlabel("[ Hz ]")
end 