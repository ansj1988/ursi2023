% URSI GAAS 2023
% DESCRIPTION: a script that evaluates the impacts of frequency-sweeping
% intentional electromagnetic interference on a LoRa demodulation process
% AUTHOR: Artur Nogueira de São José

%%%% IF YOU USE THIS CODE IN YOUR RESEARCH, PLEASE CITE THE FOLLOWING PAPER %%%%

% @inproceedings{ursi2023,
%   title={A simulation tool to interpret error rates in LoRa systems under frequency-sweeping IEMI},
%   author={Artur N. de Sao Jose, Virginie Deniau, Alexandre Boé, Eric Pierre Simon},
%   booktitle={2023 XXXVth General Assembly and Scientific Symposium of the International Union of Radio Science (URSI GASS)},
%   pages={1--4},
%   year={2023},
%   organization={IEEE}
% }

close all
clear
clc

% How many times will we run the simulation?
runs = 1; % For our paper, we used runs = 1000

% Intensity of the attack
A_lora = 1e-3;  % Sinal amplitude, in volts
A_jam = 100e-3; % Jamming signal amplitude, in volts
    
for k = 1:runs

    % Here, we obtain three time-domain waveforms: LoRa, noise and
    % jamming signal, all in base-band and sampled at the rate of 250 kSa/s
    
    [lora_bb,jam_bb,noise_bb,fs_lora_upsamp,B_lora,a,Tsym,M,Pjam_10MHz] = signal_generator(A_lora,A_jam);
    resulting_sig = lora_bb + jam_bb + noise_bb;
   
    % These waveforms are processed by a lora receiver containing a
    % LoRa filter and a down-sampling stage, resulting in a 125 kSa/s
    % sampled signal
    
    lora_downsp = baseband_processor(lora_bb,fs_lora_upsamp,B_lora);
    jam_downsp = baseband_processor(jam_bb,fs_lora_upsamp,B_lora);
    noise_downsp = baseband_processor(noise_bb,fs_lora_upsamp,B_lora);
    resulting_sig_downsp = baseband_processor(resulting_sig,fs_lora_upsamp,B_lora);
          
    % Calculating the signal-to-interference and signal-to-noise ratios
    
    % Power levels, in dBm
    P_signal_dbm = power_calculator(lora_downsp);
    P_noise_dbm = power_calculator(noise_downsp);
    P_interference_dbm = power_calculator(jam_downsp);   

    % Power ratios, in dB
    snr_125khz(k) = P_signal_dbm - P_noise_dbm;
    sir_125khz(k) = P_signal_dbm - P_interference_dbm;
    sir_10MHz(k) = P_signal_dbm - Pjam_10MHz;
       
    % Demodulation            
    ser_percentage(k) = demodulator(B_lora,M,a,lora_downsp,resulting_sig_downsp); 

end
    
% Average signal-to-noise and signal-to-interference ratios
snr_125khz_avg = mean(snr_125khz);
sir_125khz_avg = mean(sir_125khz); 
sir_10MHz_avg = mean(sir_10MHz);

% Average symbol error rate
ser_avg = mean(ser_percentage); 

% Displaying the results
msgbox(sprintf('The SER is %2.3g %% for a SIR of %2.3g dB',ser_avg,sir_10MHz_avg))