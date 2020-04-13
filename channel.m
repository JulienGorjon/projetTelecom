% Attenuation and phase shift
s = [zeros(1, cablePhaseShift), s*cableAlpha];

figure
plot(s)
title('Cable output signal')