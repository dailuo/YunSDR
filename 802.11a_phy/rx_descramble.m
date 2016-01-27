%scrambling x^7+x^4+1
function out_bits=rx_descramble(data_descramble_bits)
for k=1:7
h1(k)=data_descramble_bits(8-k);
end
for k=8:14
h1(k)=xor(h1(k-7),h1(k-3));
end
h1=h1(8:14);
for i=1:length(data_descramble_bits)
h2(i)=xor(h1(7),h1(4));
h1(2:7)=h1(1:6);
h1(1)=h2(i);
end
h2=h2(1:length(data_descramble_bits));
out_bits=double(xor(data_descramble_bits,h2));

