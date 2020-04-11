% Messages' size (Ms, Md)
M = 9;

% Messages' nature (sequence imposee, sequence generee aleatoirement, ...) 

% Number of modules (K) 
K = 3;

% Number of available physical ressources (N) 
N = 4;

% Bit rate or bit duration (R = 1/Tb) 
Tb = 0.001;
R = 1 / Tb;

% Oversampling factor of the FIR ? 
Beta = 64;          % ( >= 4N-2)

% Parameters of the FIR: ?, L, nb 
Alpha = 0.4;

% Transmitted power over the wire Pt, impedance of the wire Zc 

% Oversampling factor for continuous signals (?) 
Gamma = 100;

% Signal to noise ratio on receiver Eb/N0

% Analog filter parameters : nature, order, oscillation in bandwidth(ripple), attenuation outside the bandwidth 

% Threshold V for the simplified receiver
% NB : The choice for the threshold must be made wisely with respect to the received signal's dynamic
