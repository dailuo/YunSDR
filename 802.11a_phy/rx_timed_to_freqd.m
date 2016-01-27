

function [freq_tr_syms, freq_data] = rx_timed_to_freqd(time_signal)

   % Long Training symbols   
   long_tr_syms = time_signal(1:2*64);
   long_tr_syms = reshape(long_tr_syms, 64, 2);
   % to frequency domain
   freq_long_tr = fft(long_tr_syms);
   reorder = [33:64 1:32];
   freq_long_tr(reorder,:) = freq_long_tr;   
   % Select training carriers
   freq_tr_syms = freq_long_tr;%(sim_consts.UsedSubcIdx,:);
         
   % Take data symbols
   data_syms = time_signal(129:length(time_signal));
   data_sig_len = length(data_syms);
   n_data_syms = floor(data_sig_len/80);
   
   % Cut to multiple of symbol period
   data_syms = data_syms(1:n_data_syms*80);
   data_syms = reshape(data_syms, 80, n_data_syms);
   
   % remove guard intervals
   data_syms(1:16,:) = [];
   
   % perform fft
   freq_data = fft(data_syms);
   
   %Reorder pattern is [33:64 1:32]
   freq_data(reorder,:) = freq_data;
   freq_data=freq_data;

