% Description: a script that extracts the mean power from a waveform

function P_dbm = power_calculator(waveform)

waveform = abs(waveform);

N = length(waveform);
P_watts = sum((waveform.^2))/N;
P_dbm = 10*log10(P_watts/1e-3);

end