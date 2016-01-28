%%
%main
SPB = 2;
E = 30000;
text = 'hi';
bitseq = text2bitseq(text);
waveform = bitseq2waveform(bitseq, SPB, E);
rxbitseq = waveform2bitseq(waveform, SPB, E);
rxtext = bitseq2text(rxbitseq);
rxtext
