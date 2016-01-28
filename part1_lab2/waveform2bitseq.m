function bitseq = waveform2bitseq(wave,SPB,E)
bit = ' ';
for i = 1:length(wave)
    if wave(i) > E/2
        bit = strcat(bit,'1');
    else
        bit = strcat(bit,'0');
    end
end
bitseq = bit(1:SPB:end);
end