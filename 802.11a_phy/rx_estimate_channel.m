%

function channel_estimate = rx_estimate_channel(freq_tr_syms)

   % Estimate from training symbols
   LongTrainingSymbols=[0 0 0 0 0 0 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 0 ...
      1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1 0 0 0 0 0];

   mean_symbols = mean(freq_tr_syms.');
   channel_estimate = mean_symbols.*conj(LongTrainingSymbols);
   channel_estimate=channel_estimate.';

end
