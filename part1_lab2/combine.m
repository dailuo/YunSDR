%% combine
clc;
clear all;
close all;
warning off;
%****************ht7600*******************//
%ref_hex 1=external ref;0=internal ref
%vco_cal_hex 1=AUXDAC1;0=ADF4001
%fdd_tdd_hex 1=FDD 0=TDD
%trx_sw_hex 1=TX 0=RX
%****************ht7600*******************//
rcount=dec2hex(10,4);%reference clock divide
ncount=dec2hex(26,4);%internal vctcxo divide
ref_hex=dec2hex(0,8);%1=external ref 0=internal ref
vco_cal_hex=dec2hex(1,8);%1=auxdac 0=reference clock
aux_dac1_hex=dec2hex(0,8);
fdd_tdd_hex=dec2hex(1,8);
trx_sw_hex=dec2hex(1,8);
samp_hex=dec2hex(40e6,8);
bw_hex=dec2hex(18e6,8);
freq_hex=dec2hex(1500e6,10); %%for ad9361
tx_att1=dec2hex(30000,8);
tx_att2=dec2hex(30000,8);
tx_chan=1;%1=tx1;2=tx2;3=tx1&tx2
%% generate tone signal
a=[ones(1,16),zeros(1,16)]*32767;
% b=zeros(1,32);
% c=a+1i*b;
c=a;

txdata=repmat(c,1,32);
%% copy to 2chanel
if tx_chan==1 || tx_chan==2
    txdata2=txdata;
elseif tx_chan==3
    txdata2=zeros(1,length(txdata)*2);
    txdata2(1:2:end)=txdata;
    txdata2(2:2:end)=txdata;
end
%% iq mux
% txdatas=zeros(1,length(txdata2)*2);
% txdatas(1:2:end)=real(txdata2);
% txdatas(2:2:end)=imag(txdata2);
txdatas = [txdata2,txdata2];
%% add pad
rem=-1;
i=0;
while (rem<0)
    rem=1024*2^i-length(txdatas);
    i=i+1;
end

txdata1=[txdatas zeros(1,rem)];
figure
stem(txdata1);

% txd1=(txdata1<0)*65536+txdata1;
txd1 = txdata1;
txd2=dec2hex(txd1,4);
txd3=txd2(:,1:2);
txd4=txd2(:,3:4);
txd5=hex2dec(txd3);
txd6=hex2dec(txd4);
txd7=zeros(length(txd6)*2,1);
txd7(1:2:end)=txd6;
txd7(2:2:end)=txd5;
%% open control port
ctrl_link = udp('192.168.1.10', 5006);
fopen(ctrl_link);
%% open data port
data_link = tcpip('192.168.1.10', 5005);
set(data_link,'InputBufferSize',16*1024);
set(data_link,'OutputBufferSize',64*1024);
fopen(data_link);
%% tx samp rate
samp=[0 5 hex2dec('22') hex2dec('f0') hex2dec(samp_hex(7:8)) hex2dec(samp_hex(5:6)) hex2dec(samp_hex(3:4)) hex2dec(samp_hex(1:2))];
fwrite(ctrl_link,samp,'uint8');
%% tx bandwidth rate
bw=[0 7 hex2dec('22') hex2dec('f0') hex2dec(bw_hex(7:8)) hex2dec(bw_hex(5:6)) hex2dec(bw_hex(3:4)) hex2dec(bw_hex(1:2))];
fwrite(ctrl_link,bw,'uint8');
%% send tx freq set cmd
tx_freq=[hex2dec(freq_hex(1:2)) 3 hex2dec('22') hex2dec('f0') hex2dec(freq_hex(9:10)) hex2dec(freq_hex(7:8)) hex2dec(freq_hex(5:6)) hex2dec(freq_hex(3:4))];
fwrite(ctrl_link,tx_freq,'uint8');
%% send tx vga set cmd
tx_vga=[0 9 hex2dec('22') hex2dec('f0') hex2dec(tx_att1(7:8)) hex2dec(tx_att1(5:6)) hex2dec(tx_att1(3:4)) hex2dec(tx_att1(1:2))]; %TX1
fwrite(ctrl_link,tx_vga,'uint8');
tx_vga=[0 11 hex2dec('22') hex2dec('f0') hex2dec(tx_att2(7:8)) hex2dec(tx_att2(5:6)) hex2dec(tx_att2(3:4)) hex2dec(tx_att2(1:2))]; %TX2
fwrite(ctrl_link,tx_vga,'uint8');
%% send tx channel set cmd
channel=[tx_chan 0 hex2dec('20') hex2dec('f0') 0 0 0 0];
fwrite(ctrl_link,channel,'uint8');
%% custom rf control command
% adf4001 config
adf4001=[0 40 hex2dec('18') hex2dec('f0') hex2dec(ncount(3:4)) hex2dec(ncount(1:2)) hex2dec(rcount(3:4)) hex2dec(rcount(1:2))];
fwrite(ctrl_link,adf4001,'uint8');
% ref_select
ref_select=[0 40 hex2dec('22') hex2dec('f0') hex2dec(ref_hex(7:8)) hex2dec(ref_hex(5:6)) hex2dec(ref_hex(3:4)) hex2dec(ref_hex(1:2))];
fwrite(ctrl_link,ref_select,'uint8');
% vco_cal_select
vco_cal_select=[0 41 hex2dec('22') hex2dec('f0') hex2dec(vco_cal_hex(7:8)) hex2dec(vco_cal_hex(5:6)) hex2dec(vco_cal_hex(3:4)) hex2dec(vco_cal_hex(1:2))];
fwrite(ctrl_link,vco_cal_select,'uint8');
% fdd_tdd_select
fdd_tdd_select=[0 42 hex2dec('22') hex2dec('f0') hex2dec(fdd_tdd_hex(7:8)) hex2dec(fdd_tdd_hex(5:6)) hex2dec(fdd_tdd_hex(3:4)) hex2dec(fdd_tdd_hex(1:2))];
fwrite(ctrl_link,fdd_tdd_select,'uint8');
% trx_sw
trx_sw=[0 43 hex2dec('22') hex2dec('f0') hex2dec(trx_sw_hex(7:8)) hex2dec(trx_sw_hex(5:6)) hex2dec(trx_sw_hex(3:4)) hex2dec(trx_sw_hex(1:2))];
fwrite(ctrl_link,trx_sw,'uint8');
% aux_dac1
aux_dac1=[0 44 hex2dec('22') hex2dec('f0') hex2dec(aux_dac1_hex(7:8)) hex2dec(aux_dac1_hex(5:6)) hex2dec(aux_dac1_hex(3:4)) hex2dec(aux_dac1_hex(1:2))];
fwrite(ctrl_link,aux_dac1,'uint8');
%% send handshake cmd
handshake=[2 0 hex2dec('16') hex2dec('f0') 0 0 0 0];
fwrite(ctrl_link ,handshake, 'uint8');
%% send handshake2 cmd
data_length = dec2hex((2^(i-1)*2)*1024,8);
handshake=[2 0 hex2dec('17') hex2dec('f0') hex2dec(data_length(7:8)) hex2dec(data_length(5:6)) hex2dec(data_length(3:4)) hex2dec(data_length(1:2))];
fwrite(ctrl_link ,handshake, 'uint8');
%% Write data to the zing and read from the host.
fwrite(data_link,txd7,'uint8');
%% send handshake2 cmd to stop adc output
%handshake=[hex2dec('ff') 0 hex2dec('17') hex2dec('f0') 0 0 0 0];
%fwrite(ctrl_link,handshake,'uint8');
%% close all link
fclose(data_link);
delete(data_link);
clear data_link;
fclose(ctrl_link);
delete(ctrl_link);
clear ctrl_link;
disp('data tansfer done');

clc;
clear;
close all;
warning off;
buff_size=2;
samp_hex=dec2hex(40e6,8);
bw_hex=dec2hex(18e6,8);
freq_hex=dec2hex(1500e6,10);%%for ad9361
rxgain1=5;
rxgain2=5;
rx_chan=1;%1=rx1;2=rx2;3=rx1&rx2
cyc=1;
%% open control port
ctrl_link = udp('192.168.1.10', 5006);
fopen(ctrl_link);
%% open data port
data_link = tcpip('192.168.1.10', 5004);
set(data_link,'InputBufferSize',256*1024);
set(data_link,'OutputBufferSize',16*1024);
fopen(data_link);
%% rx samp rate
samp=[0 17 hex2dec('22') hex2dec('f0') hex2dec(samp_hex(7:8)) hex2dec(samp_hex(5:6)) hex2dec(samp_hex(3:4)) hex2dec(samp_hex(1:2))];
fwrite(ctrl_link,samp,'uint8');
%% rx bandwidth rate
bw=[0 19 hex2dec('22') hex2dec('f0') hex2dec(bw_hex(7:8)) hex2dec(bw_hex(5:6)) hex2dec(bw_hex(3:4)) hex2dec(bw_hex(1:2))];
fwrite(ctrl_link,bw,'uint8');
%% send rx freq
rx_freq=[hex2dec(freq_hex(1:2)) 15 hex2dec('22') hex2dec('f0') hex2dec(freq_hex(9:10)) hex2dec(freq_hex(7:8)) hex2dec(freq_hex(5:6)) hex2dec(freq_hex(3:4))];
fwrite(ctrl_link,rx_freq,'uint8');
%% agc mode
agc_mode=[0 21 hex2dec('22') hex2dec('f0') 0 0 0 0]; %定义RX1的增益控制模�?0-MGC 1-FGC 2-SGC
fwrite(ctrl_link,agc_mode,'uint8');
agc_mode=[0 23 hex2dec('22') hex2dec('f0') 0 0 0 0];
fwrite(ctrl_link,agc_mode,'uint8');
%% send rx vga
rx_vga=[0 25 hex2dec('22') hex2dec('f0') rxgain1 0 0 0];
fwrite(ctrl_link,rx_vga,'uint8');
rx_vga=[0 27 hex2dec('22') hex2dec('f0') rxgain2 0 0 0];
fwrite(ctrl_link,rx_vga,'uint8');
%% send rx channel set cmd
channel=[rx_chan 0 hex2dec('21') hex2dec('f0') 0 0 0 0];
fwrite(ctrl_link,channel,'uint8');
%% send handshake cmd
handshake=[2 1 hex2dec('16') hex2dec('f0') 0 0 0 0];
fwrite(ctrl_link,handshake,'uint8');
% while (1)
%% send handshake2 cmd to start adc thread
size_hex=dec2hex(buff_size*1024,8);
handshake=[2 1 hex2dec('17') hex2dec('f0') hex2dec(size_hex(7:8)) hex2dec(size_hex(5:6)) hex2dec(size_hex(3:4)) hex2dec(size_hex(1:2))];
fwrite(ctrl_link,handshake,'uint8');
%% read 256*1024 bytes data from zing
data = fread(data_link,buff_size*1024,'uint8');
%% receive
% figure(1);clf;
datah=data(2:2:end);
datal=data(1:2:end);
datah_hex=dec2hex(datah,2);
datal_hex=dec2hex(datal,2);
data_hex(:,1:2)=datah_hex;
data_hex(:,3:4)=datal_hex;
dataun=hex2dec(data_hex);
% datain=dataun-(dataun>32767)*65536;
datain = dataun;
subplot(2,1,2),stem(datain);
if rx_chan==1
    a1=datain(1:2:end);
%     a1=datain;
    a2=datain(2:2:end);
    a3=zeros(1,length(a1));
    a4=zeros(1,length(a1));
elseif rx_chan==2
    a3=datain(1:2:end);
    a4=datain(2:2:end);
    a1=zeros(1,length(a3));
    a2=zeros(1,length(a3));
elseif rx_chan==3
    a1=datain(1:4:512);
    a2=datain(2:4:512);
    a3=datain(3:4:512);
    a4=datain(4:4:512);
end
[uV sV] = memory;
% mem=round(uV.MemUsedMATLAB/2^20);
% subplot(221);
% hold on
% stem(a2(1:end),'r');
% dc1=abs(mean(a1)+1i*mean(a2));
% title(['dc=',num2str(dc1,4)]);
% subplot(222);
% plot(a1,a2);
% axis equal;
% subplot(223);
% plot(a3(1:end),'b');
% hold on
% plot(a4(1:end),'r');
% dc2=abs(mean(a3)+1i*mean(a4));
% title(['dc=',num2str(dc2,4)]);
% subplot(224);
% plot(a3,a4);
% axis equal;
% title(['cyc=',num2str(cyc),';mem=',num2str(mem),'MB']);
% cyc=cyc+1;
% pause(0.5);
% end
%% send handshake2 cmd to stop adc thread
handshake=[hex2dec('ff') 1 hex2dec('17') hex2dec('f0') 0 0 0 0];
fwrite(ctrl_link,handshake,'uint8');
%% close all link
fclose(data_link);
delete(data_link);
clear data_link;
fclose(ctrl_link);
delete(ctrl_link);
clear ctrl_link;