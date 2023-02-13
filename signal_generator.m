% Description: this function creates LoRa symbols, frequency-sweeping
% jamming signals and noise, all in baseband

function [lora,jam3,noise,fs_new,B_lora,a,Tsym,M,Pjam_10MHz] = signal_generator(A_lora,A_jam)

%% Signals parameters

% 1. LoRa signal
f_channel = 868.0e6;                                    % Transmitting frequency
B_lora = 125e3;                                         % Bandwidth, in Hz
SF = 7;                                                 % Spreading factor
M = 2^SF;                                               % Number of bits per symbol
Tsym = M/B_lora;                                        % Symbol time, in seconds 
a = randi([0 M-1],1,M);                                 % Symbol vector

% 2. Noise
snr_db = 20;                                            % SNR, in dB scale
snr = 10^(snr_db/10);                                   % SNR, in linear scale
mu_noise = 0;                                           % Mean value, in V
upsamp_noise = 2;                                       % Upsampling factor 
std_noise = sqrt(upsamp_noise*A_lora^2/(snr));          % Standard deviation, in V 

% 3. Frequency-sweeping jamming signal
f1 = -28e6;                                             % Initial frequency, in Hz
f2 = 112e6;                                             % Final frequency, in Hz
SP = 5e-6;                                              % Sweep time, in seconds
 
%% Creating the sequences in time domain

% 1. LoRa
upsamp_lora = 2;                                            % Upsampling factor 
fs_lora = upsamp_lora*B_lora;                               % Sampling frequency 
dt_lora = 1/fs_lora;                                        % Sampling period                   
t_lora = 0:dt_lora:Tsym-dt_lora;                            % Time vector corresponding to one single LoRa symbol
t_lora_extended = 0:dt_lora:Tsym*length(a)-dt_lora;         % Time vector corresponding to one LoRa sequence 
L = length(t_lora);                                         % Number of time samples

% During each iteration of this loop, we create a LoRa waveform containing
% one symbol. They are then concatenated to form a complete LoRa sequence
% waveform.
for i=1:length(a)

    % LoRa waveform containing the i^th symbol
    lora(1,(i-1)*L+1:i*L) = A_lora*exp(j*2*pi*B_lora.*t_lora.*(a(i)/M-1/2+(B_lora.*t_lora./(2*M)-heaviside(t_lora-(M-a(i))/B_lora)))); 

end

% 2. Noise
noise = std_noise/sqrt(2).*randn(1,length(lora))+1i*std_noise/sqrt(2).*randn(1,length(lora)) + mu_noise;

% 3. Frequency-sweeping jamming signal
upsamp_jam = 2000;                          % Upsampling factor 
fs_jam = upsamp_jam*B_lora;                 % Sampling frequency 
dt_jam = 1/fs_jam;                          % Sampling period
t_jam = 0:dt_jam:SP-dt_jam;                 % Time vector (duration = sweep time)

% First step: a single chirp
jam0 = A_jam.*exp(j*2*pi*(((f2-f1)/SP).*(t_jam.^2)./2+f1.*t_jam));

% Applying a random delay
delay = int64((length(jam0)-1).*rand);
jam0 = circshift(jam0,delay);

% Second step: creating several chirps
t_jam_extended = 0:dt_jam:Tsym*length(a)-dt_jam;                        % Time vector (duration = LoRa symbol)
jam1 = repmat(jam0',[ceil(length(t_jam_extended)/length(t_jam)),1])';   % Periodic frequency-sweeping EMI (duration = LoRa symbol)

% Making sure that 't_jam_extended' and 'jam1' have the same length
if length(t_jam_extended) < length(jam1)
    diff = length(jam1) - length(t_jam_extended);
    jam1(end-diff+1:end) = [];
end

% Shifting the jamming signal spectrum
delta_f = f_channel - floor(f_channel/(1/SP))*(1/SP);
jam2 = jam1.*exp(-j*2*pi*delta_f*t_jam_extended);

% Jamming signal power within a 10-MHz bandwidth window
[jam_10MHz,~] = lowpass(jam2,0.01e3/(fs_jam/2));
Pjam_10MHz = power_calculator(jam_10MHz);

[jam3, fs_new] = rf_frontend(jam2,fs_jam);

%% Plotting some graphs

% figure
% plot(t_jam_extended,real(jam1))
% hold on
% plot(t_jam_extended,real(jam2))
% xlabel('Time (s)')
% ylabel('Amplitude (V)')
% title('Before the frequency shift','After the frequency shift')
% 
% figure
% plot(t_lora_extended,real(lora))
% 
% Lj = length(jam1);
% df_jam = fs_jam/Lj;
% f_jam = df_jam.*(0:Lj-1);
% 
% figure
% hold on
% plot(f_jam.*1e-6,20*log10(abs(fft(jam1))))
% plot(f_jam.*1e-6,20*log10(abs(fft(jam2))))
% hold off
% title('Step 1')
% legend('Before the frequency shift','After the frequency shift')
% xlabel('Frequency (MHz)')
% ylabel('Magnitude (dBV)')

end



