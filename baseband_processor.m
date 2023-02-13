% Description: a LoRa baseband processor based on the SX1303

function downsp_sig_out = baseband_processor(signal,fs,bw)

% LoRa filter
[filtered_sig,d] = lowpass(signal,(bw/2)/(fs/2));

% 125 kHz sampler
fs_out = 125e3;
dt_out = 1/fs_out;
samp_out = ceil(fs/fs_out);
downsp_sig_out = filtered_sig(1:samp_out:end); 

% Some graphs
% L = length(filtered_sig);
% df = fs/L;
% f = df*(0:L-1);
% figure
% hold on
% plot(f*1e-6,20*log10(abs(fft(signal))))
% plot(f*1e-6,20*log10(abs(fft(filtered_sig))))
% hold off
% title('Step 3')
% ylabel('Magnitude (dBV)')
% xlabel('Frequency (MHz)')
% legend('Before the LoRa digital filter', 'After the LoRa digital filter')

end