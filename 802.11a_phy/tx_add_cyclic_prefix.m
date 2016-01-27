function time_signal = tx_add_cyclic_prefix(time_syms,up)

num_symbols = size(time_syms, 2)/(64*up);
n_antennas = size(time_syms, 1);
time_signal = zeros(n_antennas, num_symbols*80*up);
% Add cyclic prefix for each antenna's signal
for antenna = 1:n_antennas
   symbols = reshape(time_syms(antenna,:), 64*up, num_symbols);
   tmp_syms = [symbols(end-16*up+1:end,:) ; symbols]; 
   time_signal(antenna,:) = tmp_syms(:).';
end


