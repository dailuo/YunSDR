

function fine_time_est = rx_fine_time_sync(input_signal);

   %timing search window size
   start_search=1;
   end_search=300;
   
   % get time domain long training symbols
   %long_tr_symbols = tx_freqd_to_timed(sim_consts.LongTrainingSymbols);
   LongTrainingSymbols=[0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1];
   long_tr_symbols=ifft(LongTrainingSymbols,64);

   long_trs = [long_tr_symbols(33:64) long_tr_symbols long_tr_symbols];

   time_corr_long = zeros(1,end_search-start_search+1);

   % calculate cross correlation      
   for idx=start_search:end_search
       time_corr_long(idx-start_search+1) = sum((input_signal(idx:idx+159).*conj(long_trs)));
   end
   
   % combine, if we had two antennas
   time_corr_long = abs(time_corr_long);
   [max_peak_long,long_search_idx] = max(abs(time_corr_long));

  fine_time_est = start_search-1 + long_search_idx;
end
   





