function [out_signal, freq_est] = rx_frequency_sync(rxsignal)
    D = 64; 
    phase = rxsignal(1:64).*conj(rxsignal(65:128));   
    % add all estimates 
    phase = sum(phase, 2);   
    % with rx diversity combine antennas
    freq_est = -angle(phase) / (2*D*pi/20000000);

    radians_per_sample = 2*pi*freq_est/20000000;
    % Now create a signal that has the frequency offset in the other direction
    siglen=length(rxsignal(1,:));
    time_base=0:siglen-1;
    correction_signal=exp(-j*radians_per_sample*time_base);
    % And finally apply correction on the signal
    out_signal = rxsignal.*correction_signal;
%     out_signal = rxsignal;
end