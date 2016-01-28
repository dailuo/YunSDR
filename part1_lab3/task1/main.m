%% main
bitseqs = bit_seq_gen();
frameseqs = cell(1,length(bitseqs));

for c = 1:length(bitseqs)
    bs = bitseqs{c};
    
    % start
    frame = frame_bs(bs);
    % end
    
    frameseqs{c} = frame;
    
end