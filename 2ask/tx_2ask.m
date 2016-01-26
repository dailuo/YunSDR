clc;
clear all;
close all;
%% open control port
ctrl_link = udp('192.168.1.10', 5006);
fopen(ctrl_link);
%% open data port
data_link = tcpip('192.168.1.10', 5005);
set(data_link,'InputBufferSize',16*1024);
set(data_link,'OutputBufferSize',64*1024);
fopen(data_link);

%% ************************************
ref_hex=dec2hex(0,8);
vco_cal_hex=dec2hex(1,8);
aux_dac1_hex=dec2hex(0,8);
fdd_tdd_hex=dec2hex(1,8);
trx_sw_hex=dec2hex(1,8);
%% ************************************
bw_hex=dec2hex(20e6,8);
samp_hex=dec2hex(40e6,8);
freq_hex=dec2hex(2140e6,10); %%for ad9361
tx_att1=dec2hex(30000,8);
tx_att2=dec2hex(30000,8);
tx_chan=3;%1=tx1;2=tx2;3=tx1&tx2




%% generate tone signal
% a=round(cos(2*pi/32*[0:31]).*32767);
% b=round(sin(2*pi/32*[0:31]).*32767);
% figure(1); clf; stem(a);
% c=a+1i*b;
% txdata=repmat(c,1,32);

%%new tone signal(a step function for test)

% bitseq = '11111111110000000000';
% % bitseq = '0000000000';
% SPB = 2;
% E = 32767*100;
% wave = bitseq2waveform(bitseq, SPB, E);
% 
% a=wave;
% b=wave;
% 
% figure(1); clf; stem(a);
% c=a+1i*b;
% txdata = repmat(c,1,32);




%% copy to 2chanel
if tx_chan==1 || tx_chan==2
    txdata2=txdata;
elseif tx_chan==3
    txdata2=zeros(1,length(txdata)*2);
    txdata2(1:2:end)=txdata;
    txdata2(2:2:end)=txdata;
end
%% iq mux
txdatas=zeros(1,length(txdata2)*2);
txdatas(1:2:end)=real(txdata2);
txdatas(2:2:end)=imag(txdata2);
%% add pad
rem=-1;
i=0;
while (rem<0)
    rem=1024*2^i-length(txdatas);
    i=i+1;
end
txdata1=[txdatas zeros(1,rem)];
txd1=(txdata1<0)*65536+txdata1;
txd2=dec2hex(txd1,4);
txd3=txd2(:,1:2);
txd4=txd2(:,3:4);
txd5=hex2dec(txd3);
txd6=hex2dec(txd4);
txd7=zeros(length(txd6)*2,1);
txd7(1:2:end)=txd6;
txd7(2:2:end)=txd5;

%% tx bandwidth rate
bw=[0 7 hex2dec('22') hex2dec('f0') hex2dec(bw_hex(7:8)) hex2dec(bw_hex(5:6)) hex2dec(bw_hex(3:4)) hex2dec(bw_hex(1:2))];
fwrite(ctrl_link,bw,'uint8');
%% tx samp rate
samp=[0 5 hex2dec('22') hex2dec('f0') hex2dec(samp_hex(7:8)) hex2dec(samp_hex(5:6)) hex2dec(samp_hex(3:4)) hex2dec(samp_hex(1:2))];
fwrite(ctrl_link,samp,'uint8');
%% send tx freq set cmd
tx_freq=[hex2dec(freq_hex(1:2)) 3 hex2dec('22') hex2dec('f0') hex2dec(freq_hex(9:10)) hex2dec(freq_hex(7:8)) hex2dec(freq_hex(5:6)) hex2dec(freq_hex(3:4))];
fwrite(ctrl_link,tx_freq,'uint8');
%% send tx vga set cmd
tx_vga=[0 9 hex2dec('22') hex2dec('f0') hex2dec(tx_att1(7:8)) hex2dec(tx_att1(5:6)) hex2dec(tx_att1(3:4)) hex2dec(tx_att1(1:2))];  %TX1
fwrite(ctrl_link,tx_vga,'uint8');
tx_vga=[0 11 hex2dec('22') hex2dec('f0') hex2dec(tx_att2(7:8)) hex2dec(tx_att2(5:6)) hex2dec(tx_att2(3:4)) hex2dec(tx_att2(1:2))]; %TX2
fwrite(ctrl_link,tx_vga,'uint8');
%% send tx channel set cmd

channel=[tx_chan 0 hex2dec('20') hex2dec('f0') 0 0 0 0];
fwrite(ctrl_link,channel,'uint8');

% %% **********************************************************
% % 如果是单板收发测试，那么在rx.m中没必要再配置以下参数，如果只收不发，则在rx.m中要添加以下配置
% %% custom rf control command
% rcount =dec2hex(10,4);
% ncount = dec2hex(26,4);
% % spi_data = dec2hex((rcount<<16)|ncount,8);
% % % spi
% spi=[0 40 hex2dec('18') hex2dec('f0') hex2dec(ncount(3:4)) hex2dec(rcount(1:2)) hex2dec(rcount(3:4)) hex2dec(rcount(1:2))];
% if hex2dec(vco_cal_hex) == 0
   % fwrite(ctrl_link,spi,'uint8');
% end

% % ref_select
% ref_select=[0 40 hex2dec('22') hex2dec('f0') hex2dec(ref_hex(7:8)) hex2dec(ref_hex(5:6)) hex2dec(ref_hex(3:4)) hex2dec(ref_hex(1:2))];
% fwrite(ctrl_link,ref_select,'uint8');
% % vco_cal_select
% vco_cal_select=[0 41 hex2dec('22') hex2dec('f0') hex2dec(vco_cal_hex(7:8)) hex2dec(vco_cal_hex(5:6)) hex2dec(vco_cal_hex(3:4)) hex2dec(vco_cal_hex(1:2))];
% fwrite(ctrl_link,vco_cal_select,'uint8');
% % fdd_tdd_select
% fdd_tdd_select=[0 42 hex2dec('22') hex2dec('f0') hex2dec(fdd_tdd_hex(7:8)) hex2dec(fdd_tdd_hex(5:6)) hex2dec(fdd_tdd_hex(3:4)) hex2dec(fdd_tdd_hex(1:2))];
% fwrite(ctrl_link,fdd_tdd_select,'uint8');
% % trx_sw
% trx_sw=[0 43 hex2dec('22') hex2dec('f0') hex2dec(trx_sw_hex(7:8)) hex2dec(trx_sw_hex(5:6)) hex2dec(trx_sw_hex(3:4)) hex2dec(trx_sw_hex(1:2))];
% fwrite(ctrl_link,trx_sw,'uint8');

% % aux_dac1
% aux_dac1=[0 44 hex2dec('22') hex2dec('f0') hex2dec(aux_dac1_hex(7:8)) hex2dec(aux_dac1_hex(5:6)) hex2dec(aux_dac1_hex(3:4)) hex2dec(aux_dac1_hex(1:2))];

% if hex2dec(vco_cal_hex) == 1
    % fwrite(ctrl_link,aux_dac1,'uint8');
% end
%% ***************************************************************
%% send handshake cmd
handshake=[2 0 hex2dec('16') hex2dec('f0') 0 0 0 0];
fwrite(ctrl_link ,handshake, 'uint8');
pause(0.5);
%% send handshake2 cmd  (通知PS要发送的数据量)
data_length = dec2hex((2^(i-1)*2)*1024,8);
handshake=[2 0 hex2dec('17') hex2dec('f0') hex2dec(data_length(7:8)) hex2dec(data_length(5:6)) hex2dec(data_length(3:4)) hex2dec(data_length(1:2))];
fwrite(ctrl_link ,handshake, 'uint8');

%% Write data to the zing and read from the host.
fwrite(data_link,txd7,'uint8');
% pause(10);
% %% send handshake2 cmd to stop adc thread (用以结束TX loop线程)
% handshake=[hex2dec('ff') 0 hex2dec('17') hex2dec('f0') 0 0 0 0];
% fwrite(ctrl_link,handshake,'uint8');
%% close all link
fclose(data_link);
delete(data_link);
clear data_link;
fclose(ctrl_link);
delete(ctrl_link);
clear ctrl_link;

disp('data tansfer done');