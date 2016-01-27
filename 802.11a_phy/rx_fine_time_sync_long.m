function fine_time_est_long=rx_fine_time_sync_long(input_signal)
global sim_consts;
start_search=1;
end_search=400;   
% get time domain long training symbols
long_tr = sim_consts.LongTrainingSymbols;
long_tr_symbols = rx_freqd_to_timed(long_tr);
long_trs = [long_tr_symbols(33:64) long_tr_symbols(1:32)];
%time_corr_long = zeros(1,end_search); 
i=1;
j=1;
time=1;
while i<end_search
	time_corr_long(i) = abs(sum((input_signal(i:i+63).*conj(long_trs))));
 	time_pwr_long(i) = abs(abs(sum(input_signal(i:i+63)))-abs(sum(input_signal(1:64))));
%     time_pwr_long(i) = abs(sum(input_signal(i:i+63)));
    if i>63
        time_corr_mean(i)=mean(time_corr_long(i-63:i));
        if i==64
            time_corr_min=time_corr_mean(i);
        else
            if time_corr_mean(i)<time_corr_min
                time_corr_min=time_corr_mean(i);
            end
        end
        time_corr_ratio(i)=time_corr_long(i)/time_pwr_long(i);
        time_min_ratio(i)=time_corr_long(i)/time_corr_min;
%         i=i+1;
        if   time_min_ratio(i)>4 && time_corr_ratio(i)>1%
            ratio(j)=i;
            if j==2
                if ratio(2)-ratio(1)==64
                    break
                else
                    j=1;
                end
            else
                i=i+64;
                j=j+1;
            end
        else
            i=i+1;
            j=1;
        end
    else
        i=i+1;
	end
end
fine_time_est_long = i-64;
% figure(2)
% subplot(212);
% plot(time_corr_long,'r');
% hold on
% plot(time_pwr_long,'g');
% hold on
% plot(time_corr_mean,'b');
   

