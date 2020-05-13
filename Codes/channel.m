% Attenuation and phase shift
s = [zeros( cablePhaseShift,1); s*cableAlpha];
r = s;
%figure
%plot(s)
%title('Phase shifted and attenuated signal')