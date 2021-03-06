% total msg = start + data
Mt = [Ms;Md(:,1)];             % temporary work with the msg for the channel N=1

% msg as symbols -1,1 for bits 0,1
Mt(Mt==0)=-1;


% rcosfir(R,N_T,RATE,T)   info here : http://read.pudn.com/downloads67/doc/comm/240139/mfiles/Chapter10/programs/prgs/depfun/rcosfir.m__.htm
%   - T : is the input signal sampling period, in seconds.       => = Tb
%   - RATE  : is the oversampling rate for the filter            => = Beta
%   - R : the rolloff factor, determines the width of the transition 
%         band.  R has no units.  The transition band is (1-R)/(2*T) < |f| < 
%        (1+R)/(2*T).                                            => = alpha ("facteur de descente")
%   - N_T : is a scalar or a vector of length 2.  If N_T is specified as a 
%           scalar, then the filter length is 2 * N_T + 1 input samples.  If N_T is 
%           a vector, it specifies the extent of the filter.  In this case, the filter 
%           length is N_T(2) - N_T(1) + 1 input samples (or 
%           (N_T(2) - N_T(1))* RATE + 1 output samples).            => = L    N.B : window is [-L*Tb:L*Tb]
g0 = transpose(rcosfir(Alpha, L , Beta, Tb));
FIR_time = transpose(-L*Tb:Tnum:L*Tb);


modulationFactors = cos(FIR_time * ((1:1:N-1) .* (4*pi/Tb)));   %cos(Omega_n*time) where Omega_n = 2*pi*2n/Tb
p = [g0,g0 .* modulationFactors];

FIR_time = FIR_time / Tb;  % time axis as T graduation
figure
plot(FIR_time,p(:,1),FIR_time,p(:,2),FIR_time,p(:,3)) % plot first two filters pulse responses 
title('Trois premiers FIR')
xlabel("[ T ]")

% modulate the symbols with the filter of the choosed module n 
s=[]; % total signal but should be calculated in channel
signals=[];
for n = modules
    q=[];
    % for every symbol
    for k = 1:length(Mt)
        symbolFIR = p(:,n) .* Mt(k);  % get the FIR of the current module
        
        % shift the the FIR symbol to right, and add zeros to the current
        % signal q so that they have the same length and will be superposed
        % correctly when we will sum the new FIR symbol to the signal
        if isempty(q)
            q = zeros((2*L*Beta)+1,1);
        else 
            symbolFIR = [zeros(length(q)-((2*L)-1)*Beta-1, 1); symbolFIR];
            q = [q;zeros(Beta,1)];
        end
        q = q + symbolFIR;
    end
    
    
    q = interpft(q, length(q)*Gamma);  % interpolate and oversample the signal
    signals=[signals,q];               % add it to the list
    
    
    % this will sum all the signals for the following FFT
    if isempty(s)
        s = q;
    else
        s = s + q;
    end
end


% Level adjustment on each signal for wanter power Pt
for i = 1:length(modules)
    signal= signals(:,i);
    signalPower = sum(signal.^2)/(length(signal)*Zc);
    scaleFactor = sqrt(Pt/signalPower); % compare to wanted power
    leveledSignal = signal*scaleFactor; % if u^2 / z *4 = Pt then (u*sqrt(4))^2 / z = Pt 
    signals(:,i) = leveledSignal;       % replace
end




%%% --- ALL THIS CODE IS ONLY FOR DEVELOPMENT --- %%%%
% it uses a sum of all the signals to plot its FFT

    % interpolate with FFT to get Gamma times more points
    %s = interpft(s, length(s)*Gamma);

    % Time vector to plot the output signal
    periodNumber = 4 + length(Mt)-1;
    s_time = 0 : Tanal : (length(s)*Tanal)-Tanal;

    % Time and value vectors for the symbols
    bitsTimeIndexes = L:1:length(Mt)-1+L;
    bitsTimeIndexes = bitsTimeIndexes * Beta * Gamma;
    symbols_time = s_time(bitsTimeIndexes);
    symbols_value = s(bitsTimeIndexes);

    figure
    plot(s_time,s)
    hold on
    scatter(symbols_time, symbols_value)
    title('Superposition des signaux')
    xlabel("[ s ]")
    hold off


    % FFT on the output signal
    figure
    plotFFT(s, Tanal, 0.065)
    %title("Transformée de Fourrier")
    %xlabel("[ Hz ]")


