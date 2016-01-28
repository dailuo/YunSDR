function wave = bitseq2waveform(bitseq, SPB, E)
%turn the bit sequence into a wave,output is list
%E is the voltage pk
wave = [];
for i = 1:length(bitseq)
    for j = 1:SPB
        wave = [wave str2double(bitseq(i))*E];
    end
end
wave = [E,E,E,E,E,0,0,0,0,0,E,E,E,E,E,wave,E,E,E,E,E,0,0,0,0,0,E,E,E,E,E];
end