function thres_idx = rx_find_packet_edge_lc4(rx_signal)
global sim_consts;
%% load local short training
short_tr = sim_consts.ShortTrainingSymbols;
short_tr_symbols = rx_freqd_to_timed(short_tr);
Strs = short_tr_symbols(1:16);
realp=round(real(Strs)*128);
imagp=round(imag(Strs)*128);
% realp2=[1/4,-1,-1/16,1,1/2,1,-1/16,-1,1/4,0,-1/2,-1/16,0,-1/16,-1/2,0];
% imagp2=[1/4,0,-1/2,-1/16,0,-1/16,-1/2,0,1/4,-1,-1/16,1,1/2,1,-1/16,-1];
for k=1:length(realp)
    if realp(k) ==0
        realp2(k)=0;
    elseif realp(k)==1
        realp2(k)=1; 
    elseif realp(k)==2
        realp2(k)=2; 
    elseif realp(k)>=3 && realp(k)<6
        realp2(k)=4;        
    elseif realp(k)>=6 && realp(k)<12
        realp2(k)=8;           
    elseif realp(k)>=12
        realp2(k)=16;
    elseif realp(k)==-1
        realp2(k)=-1; 
    elseif realp(k)==-2
        realp2(k)=-2; 
    elseif realp(k)>-6 && realp(k)<=-3
        realp2(k)=-4;        
    elseif realp(k)>-12 && realp(k)<=-6
        realp2(k)=-8;           
    elseif realp(k)<=-12
        realp2(k)=-16;
    end
    if imagp(k) ==0
        imagp2(k)=0;
    elseif imagp(k)==1
        imagp2(k)=1; 
    elseif imagp(k)==2
        imagp2(k)=2; 
    elseif imagp(k)>=3 && imagp(k)<6
        imagp2(k)=4;        
    elseif imagp(k)>=6 && imagp(k)<12
        imagp2(k)=8;           
    elseif imagp(k)>=12
        imagp2(k)=16;
    elseif imagp(k)==-1
        imagp2(k)=-1; 
    elseif imagp(k)==-2
        imagp2(k)=-2; 
    elseif imagp(k)>-6 && imagp(k)<=-3
        imagp2(k)=-4;        
    elseif imagp(k)>-12 && imagp(k)<=-6
        imagp2(k)=-8;           
    elseif imagp(k)<=-12
        imagp2(k)=-16;
    end
end
realp3=realp2./16;
imagp3=imagp2./16;
%% packet search
i=1;   
j=1;
time=1;
while (i<length(rx_signal)-16)
%     rx_var(i) = abs(sum((rx_signal(i:i+15).*conj(Strs))));
% %     pwr(i) = abs(abs(sum(rx_signal(i:i+15))));
%  	pwr(i) = abs(abs(sum(rx_signal(i:i+15)))-abs(sum(rx_signal(1:16))));
    rx_var_real(i)=abs(sum( floor(real(rx_signal(i:i+15)).*realp3)+floor(imag(rx_signal(i:i+15)).*imagp3)));
    rx_var_imag(i)=abs(sum(-floor(real(rx_signal(i:i+15)).*imagp3)+floor(imag(rx_signal(i:i+15)).*realp3)));
    if rx_var_real(i)>rx_var_imag(i)
        rx_var(i)=rx_var_real(i)+rx_var_imag(i)/2;
    else
        rx_var(i)=rx_var_imag(i)+rx_var_real(i)/2;
    end
    pwr_real(i)=abs(sum(real(rx_signal(i:i+15)).*ones(1,16)));
    pwr_imag(i)=abs(sum(imag(rx_signal(i:i+15)).*ones(1,16)));
    if pwr_real(i)>pwr_imag(i)
        pwr(i)=pwr_real(i)+pwr_imag(i)/2;
    else
        pwr(i)=pwr_imag(i)+pwr_real(i)/2;
    end
    if i>1
        pwr(i)=abs(pwr(i)-pwr(1));
    end 
    if i>31
        rx_varm(i)=mean(rx_var(i-31:i));
        if i==32
            rx_vram_min=rx_varm(i);
        end
        if rx_varm(i)<rx_vram_min
            rx_vram_min=rx_varm(i);
        end
        rx_var_ratio(i)=rx_var(i)./rx_vram_min;
        rx_pwr_ratio(i)=rx_var(i)./pwr(i);
%         i=i+1;
        if  rx_var_ratio(i)>8 && rx_pwr_ratio(i)>1
            ratio(j)=i;
            if j==2
                if ratio(2)-ratio(1)==16
                    break
                else
                    j=1;
                end
            else
                i=i+16;
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
thres_idx=i-16;
% figure(2);clf;
% subplot(211);
% plot(rx_var,'r');
% hold on
% plot(pwr,'g');
% hold on
% plot(rx_varm,'b');
