% Description: a RF front-end based on the SX1257

function [signal_out, fs_new] = rf_frontend(signal,fs)

% Simulation of an analog filter with a bandwidth of 500 kHz
Ws = 500e3/(fs/2);                           % End of the stopband (normalized freq.)
Rs = 40;                                     % Attenuation in the stopband
n = 4;                                       % Order
[num,den] = cheby2(n,Rs,Ws);                 % Numerator and denominator of H(z)
filtered_sig = filter(num,den,signal);       % Filtered signal

% 250 kHz sampler
fs_new = 250e3;
samp_new = ceil(fs/fs_new);
signal_out = filtered_sig(1:samp_new:end); 

% Some graphs
% L = length(signal);
% dt = 1/fs;
% df = 1/(L*dt);
% f=(0:L-1).*df;
% figure
% hold on
% plot(f,20*log10(abs(fft(signal))))
% plot(f,20*log10(abs(fft(filtered_sig))))
% hold off
% title('Step 2')
% legend('Before the analog filter','After the analog filter')

end