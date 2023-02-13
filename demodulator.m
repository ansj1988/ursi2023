% Description: demodulation of LoRa signals and symbol error rate (SER)
% calculation

function ser_percentage = demodulator(B,M,a,lora,resulting_signal)

% Frequency and time vectors
k = 0:M-1;              % Frequency samples
t = (1/B)*k;            % Time vector (fs = B)

% Raw chirp sequence
chirp_rx = exp(-j*2*pi*B.*t.*(-1/2+(B.*t)./(2*M)-heaviside((t-M)/B)));

% Counter used to identify symbol errors
wrong_syms_total = 0;

% Number of transmitted symbols
N_sym = length(a);

% Initializing the vector that will stock the symbols extracted from the
% interfered signal
obtained_sym = zeros(size(a));

% Here, we analyze each received symbol 
for i=1:N_sym

    dem_lora = lora((i-1)*M+1:i*M).*chirp_rx;              % LoRa without jamming + noise
    dem_meas = resulting_signal((i-1)*M+1:i*M).*chirp_rx;  % LoRa with jamming + noise

    YA = abs(fft(dem_lora));  % LoRa without jamming + noise
    YB = abs(fft(dem_meas));  % LoRa with jamming + noise

    % True symbol
    true_sym(i) = a(i);

    % Symbol found from the interfered LoRa signal
    [~,I] = max(YB);
    obtained_sym(i) = k(I);

    % Identifying corrupted symbols
    if obtained_sym(i) ~= true_sym(i)
        wrong_syms_total = wrong_syms_total + 1;     % Number of corrupted symbols
    end

    % Signals spectra
%     figure(1)
%     hold on
%     plot(k,20*log10(YA))
%     plot(k,20*log10(YB))
%     hold off
%     title('Last step: symbol extraction')
%     xlabel('Frequency (samples)')
%     ylabel('Magnitude (dBV)')
%     legend('True symbol','Corrupted symbol')
%     xlim([0 M-1])
%     ylim([-100 0])
%     box on

 end

% Symbol error rate calculation
ser = wrong_syms_total/length(a);
ser_percentage = ser*100;

end
