%% txtest

tx_chan=1;%1=tx1;2=tx2;3=tx1&tx2
%% generate tone signal
a=[ones(1,16),zeros(1,16)]*32767;
% b=zeros(1,32);
% c=a+1i*b;
c=a;

txdata=repmat(c,1,32);
txdata2=txdata;
txdatas = [txdata2,txdata2];
%% add pad
rem=-1;
i=0;
while (rem<0)
    rem=1024*2^i-length(txdatas);
    i=i+1;
end

txdata1=[txdatas zeros(1,rem)];
stem(txdata1);
hold on;
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
