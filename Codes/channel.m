% Attenuation and phase shift
s = [zeros( cablePhaseShift,1); s*cableAlpha];

%figure
%plot(s)
%title('Phase shifted and attenuated signal')