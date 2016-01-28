function text = bitseq2text(bitseq)
    number = floor(length(bitseq)/7);
    text = ' ';
    for i = 0:number-1
        temp = bitseq(1+7*i:(i+1)*7);
        string = char(bin2dec(temp));
        text = strcat(text, string);
    end
end