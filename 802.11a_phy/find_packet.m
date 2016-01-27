clc;
clear;
close all;
warning off
sim_consts = set_sim_consts;
%% load dump
fid1=fopen('E:\matlab_work\dump\33RX\3.dmp','r');
% fid1=fopen('E:\code\ieee802_11a\rx_test_data\one_ref\rad_at2.dmp','r');
% fid1=fopen('E:\code\ieee802_11a\rx_test_data\frame6_at_r2.dmp','r');
data=fread(fid1,'int16');
fclose('all');
datadmp=reshape(data,64,length(data)/64);
datao=datadmp(9:64,:);
dataos=datao(:);
a1=dataos(1:2:end/16);
a2=dataos(2:2:end/16); 
mean(a1)
mean(a2)
rx_singal_40m=(a1+1i*a2);
rx_signal =rx_singal_40m(1:2:end).';
%% load prn 
% % [a1,a2,a4,a3]=textread('E:\code\usrp\sora_adda_doc_rx_tx\data\5','%f%f%f%f','headerlines',1);
% [a1,a2,a4,a3]=textread('E:\code\ieee802_11a\rx_data\20','%f%f%f%f','headerlines',1);
% % [a1,a2,a3,a4]=textread('E:\code\v6_mimo_v2\ada_test\1','%f%f%f%f','headerlines',1);
% mean(a3)
% mean(a4)
% % a3=a3-mean(a3);
% % a4=a4-mean(a4);
% rx_signal_40m =a3+1i*a4;
% rx_signal=rx_signal_40m(1:2:end).';
%% add path
% r=3;%多径数 
% a=[0.3 0.3 0.3];%多径的幅度 
% d=[10 20 30];%各径的延迟 
% rx1=rx_singal_40m;
% channel1=zeros(length(rx1),1); 
% channel1(1+d(1):end)=a(1)*rx1(1:end-d(1));
% channel2=zeros(size(rx1),1); 
% channel2(1+d(2):end)=a(2)*rx1(1:end-d(2)); 
% channel3=zeros(size(rx1),1); 
% channel3(1+d(3):end)=a(3)*rx1(1:end-d(3)); 
% rx2=rx1+channel1+channel2+channel3;
% rx_signal =rx2(1:2:end).';
%% plot pwelch
figure(1);
subplot(411);
plot(real(rx_signal),'r');
hold on;
plot(imag(rx_signal),'b');
title('原始信号时域波形');
%% load local short training
realp2=[1/4,-1,-1/16,1,1/2,1,-1/16,-1,1/4,0,-1/2,-1/16,0,-1/16,-1/2,0];
imagp2=[1/4,0,-1/2,-1/16,0,-1/16,-1/2,0,1/4,-1,-1/16,1,1/2,1,-1/16,-1];
realme=ones(1,16);
imagme=ones(1,16);
%% setup window = short training length
win = 16;
%% packet search
i=1;   
j=1;
time=1;
while (i<length(rx_signal)-win)
    rx_var_r(i)=floor(abs(sum(real(rx_signal(i:i+win-1).*realp2))));
    rx_var_i(i)=floor(abs(sum(imag(rx_signal(i:i+win-1).*imagp2))));
    pwr_r(i)=floor(abs(sum(real(rx_signal(i:i+win-1).*realme))));
    pwr_i(i)=floor(abs(sum(imag(rx_signal(i:i+win-1).*imagme))));
    if rx_var_r(i)>rx_var_i(i)
        rx_var(i)=rx_var_r(i)+floor(rx_var_i(i)./2);
    else
        rx_var(i)=rx_var_i(i)+floor(rx_var_r(i)./2);
    end
    if pwr_r(i)>pwr_i(i)
        pwr(i)=pwr_r(i)+floor(pwr_i(i)./2);
    else
        pwr(i)=pwr_i(i)+floor(pwr_r(i)./2);
    end
    if i~=1
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
        if  rx_var_ratio(i)>32 && rx_pwr_ratio(i)>1%r 
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
i=i-16
subplot(412);
plot(rx_var,'b');
hold on;
plot(rx_varm,'g');
hold on;
plot(pwr,'m');
title('互相关自相关');
subplot(413);
plot(rx_pwr_ratio,'b');
grid on
title('互相关/自相关');
subplot(414);
plot(rx_var_ratio,'m');
title('互相关/最小值');
grid on
