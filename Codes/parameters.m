% Messages' size (Ms, Md)
M = 9;

% Messages' nature (sequence imposee, sequence generee aleatoirement, ...) 
Ms = transpose([1, 0, 1, 1, 0]);
Md = transpose([[0,1,1,0,1,0,1,0,1,1]; [1,1,1,0,1,0,0,0,1,1]; [0,0,1,0,1,0,0,0,1,1]; [1,0,1,0,1,0,0,0,1,1]]);

% Number of modules (K) 
K = 3;

% Number of available physical ressources (N) 
N = 4;

% List of the module numbers that will send a message 
modules = [1,2,3,4];

% Bit rate or bit duration (R = 1/Tb) 
Tb = 0.001;
R = 1 / Tb;

% Oversampling factor of the FIR ? 
Beta = 64;          % ( >= 4N-2)
Tnum = Tb/Beta;

% Oversampling factor for continuous signals 
Gamma = 2; 
Tanal = Tb/Beta/Gamma;

% Parameters of the FIR: alpha, L, nb 
Alpha = 0.4; % ROLL-OFF factor
L = 2;

% attenuation factor over the cable
cableAlpha = 0.8;

% Transmitted power over the wire Pt, impedance of the wire Zc 
Pt = 10;
Zc = 1;
 

% Signal to noise ratio on receiver Eb/N0
wantedEb_over_N0 = 2;   %[dB]

% Analog filter parameters : nature, order, oscillation in bandwidth(ripple), attenuation outside the bandwidth 

% Threshold V for the simplified receiver

% NB : The choice for the threshold must be made wisely with respect to the received signal's dynamic
