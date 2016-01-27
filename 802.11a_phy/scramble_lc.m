%scrambling x^7+x^4+1
function scramble_bits=scramble_lc(data_bits_length,data_bits,sim_options)
h1=[1,0,1,1,1,0,1];
for i=1:data_bits_length
h2(i)=xor(h1(7),h1(4));
h1(2:7)=h1(1:6);
h1(1)=h2(i);
end
scramble_bits=double(xor(data_bits,h2));
% fid = fopen('txt\scramble.txt', 'wt'); 
% for i=1:127
%     fprintf(fid,'7''d%3.0f  :scr=1''b%1.0f;\n',i-1,h2(i));
% end
% fclose(fid);
scramble_bits((16+8*sim_options.PacketLength+1):(16+8*sim_options.PacketLength+6))=0;
