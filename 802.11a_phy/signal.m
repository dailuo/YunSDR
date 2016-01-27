function mysignal=signal(sim_options)
if(sim_options.rate==6)
    signal1=[1,1,0,1];
elseif(sim_options.rate==9)
    signal1=[1,1,1,1];
elseif(sim_options.rate==12)
    signal1=[0,1,0,1];
elseif(sim_options.rate==18)
    signal1=[0,1,1,1];
elseif(sim_options.rate==24)
    signal1=[1,0,0,1];
elseif(sim_options.rate==36)
    signal1=[1,0,1,1];
elseif(sim_options.rate==48)
    signal1=[0,0,0,1];
else
    signal1=[0,0,1,1];
end
signal1(5)=0;

A=sim_options.PacketLength;
A1=floor(A/2);
a1=rem(A,2);
A2=floor(A1/2);
a2=rem(A1,2);
A3=floor(A2/2);
a3=rem(A2,2);
A4=floor(A3/2);
a4=rem(A3,2);
A5=floor(A4/2);
a5=rem(A4,2);
A6=floor(A5/2);
a6=rem(A5,2);
A7=floor(A6/2);
a7=rem(A6,2);
A8=floor(A7/2);
a8=rem(A7,2);
A9=floor(A8/2);
a9=rem(A8,2);
A10=floor(A9/2);
a10=rem(A9,2);
A11=floor(A10/2);
a11=rem(A10,2);
A12=floor(A11/2);
a12=rem(A11,2);
a=[a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12];

signal2=[signal1 a];

b1=xor(signal2(1),signal2(2));
b2=xor(b1,signal2(3));
b3=xor(b2,signal2(4));
b4=xor(b3,signal2(5));
b5=xor(b4,signal2(6));
b6=xor(b5,signal2(7));
b7=xor(b6,signal2(8));
b8=xor(b7,signal2(9));
b9=xor(b8,signal2(10));
b10=xor(b9,signal2(11));
b11=xor(b10,signal2(12));
b12=xor(b11,signal2(13));
b13=xor(b12,signal2(14));
b14=xor(b13,signal2(15));
b15=xor(b14,signal2(16));
b16=xor(b15,signal2(17));

mysignal=[signal2 b16 0 0 0 0 0 0];
end

    
   
    
