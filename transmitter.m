% total msg = start + data
Mt = [Ms;Md(:,1)];             % temporary work with the msg for the channel N=1

% msg as symbols -1,1 for bits 0,1
Mt(Mt==0)=-1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate a sampled s(t) by using a FIR filter g(t) and then interpolate it with a DAC
% followed by a low-pass filter.
%
% One FIR p(t) for each channel :
% channel 0 : p_0(t) = g(t)
% channel n : p_n(t) = g(t) * cos(Omega_n*t) where Omega_n = 2*pi*2n/Tb
%
% => for k symbols : s_n(t) = A * a_n(k) * p_n(t - k*Tb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% rcosfir(R,N_T,RATE,T)   info here : http://read.pudn.com/downloads67/doc/comm/240139/mfiles/Chapter10/programs/prgs/depfun/rcosfir.m__.htm
%
%   - T : is the input signal sampling period, in seconds.  
%        => = Tb
%
%   - RATE  : is the oversampling rate for the filter (or the number of output samples per input 
%             sample). 
%           => = Beta
%
%   - R : the rolloff factor, determines the width of the transition 
%         band.  R has no units.  The transition band is (1-R)/(2*T) < |f| < 
%        (1+R)/(2*T). 
%        => = alpha ("facteur de descente")
%
%   - N_T : is a scalar or a vector of length 2.  If N_T is specified as a 
%           scalar, then the filter length is 2 * N_T + 1 input samples.  If N_T is 
%           a vector, it specifies the extent of the filter.  In this case, the filter 
%           length is N_T(2) - N_T(1) + 1 input samples (or 
%           (N_T(2) - N_T(1))* RATE + 1 output samples).
%           => = L ? 2 in PDF example
g = rcosfir(Alpha, 2 , Beta, Tb)

