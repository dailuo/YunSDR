function bitseq = text2bitseq(text)
%convert a string to acsii bit sequence, output is a string
textascii = abs(text);
textbit = dec2bin(textascii);
str = num2str(textbit);
sizestr = size(str);
for i = 1:sizestr(1)
    if i == 1
        bitseq = str(i,:);
        continue;
    end
    bitseq = strcat(bitseq, str(i,:));
end
% bitseq = strcat('0000000',bitseq);
% bitseq = strcat(bitseq,'1111111');
end