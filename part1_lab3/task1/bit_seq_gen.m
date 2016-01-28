function bitseqs = bit_seq_gen()
    bitseqs{1} = randint(1,128 - randint(1,1,[1 127]),[0 1]);
    bitseqs{2} = randint(1,128 + randint(1,1,[1 127]),[0 1]);
    bitseqs{3} = randint(1,128,[0 1]);
end