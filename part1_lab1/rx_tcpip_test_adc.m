clc;
clear;
close all;
warning off;
buff_size=128;
samp_hex=dec2hex(40e6,8);
bw_hex=dec2hex(18e6,8);
freq_hex=dec2hex(1500e6,10);%%for ad9361
rxgain1=5;
rxgain2=5;
rx_chan=3;%1=rx1;2=rx2;3=rx1&rx2
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
figure(1);clf;
datah=data(2:2:end);
datal=data(1:2:end);
datah_hex=dec2hex(datah,2);
datal_hex=dec2hex(datal,2);
data_hex(:,1:2)=datah_hex;
data_hex(:,3:4)=datal_hex;
dataun=hex2dec(data_hex);
datain=dataun-(dataun>32767)*65536;
if rx_chan==1
    a1=datain(1:2:end);
    a2=datain(2:2:end);
    a3=zeros(1,length(a1));
    a4=zeros(1,length(a1));
elseif rx_chan==2
    a3=datain(1:2:end);
    a4=datain(2:2:end);
    a1=zeros(1,length(a3));
    a2=zeros(1,length(a3));
elseif rx_chan==3
    a1=datain(1:4:1024);
    a2=datain(2:4:512);
    a3=datain(3:4:512);
    a4=datain(4:4:512);
end
% a1 = a1 + (max(a1)-min(a1));
% a1 = a1 -min(a1);
a1 = abs(a1);

subplot(211),stem(a1(1:end));
m=max(a1);
b=a1;
for i = 1:length(b)
    b(i)=(b(i)>m/2);
end
subplot(212),stem(b(1:end));
b=b';
result = detect('111110000011111','111110000011111',b)
bitseqout = waveform2bitseq(result,4,1);
text = bitseq2text(bitseqout);
text
% [uV sV] = memory;
% mem=round(uV.MemUsedMATLAB/2^20);
% subplot(221);
% plot(a1(1:end),'b');
% hold on
% plot(a2(1:end),'r');
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