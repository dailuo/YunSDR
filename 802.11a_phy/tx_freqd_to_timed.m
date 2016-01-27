

function [time_syms,syms_into_ifft_up] = rx_freqd_to_timed(mod_ofdm_syms,up) 

global sim_consts;
num_symbols = size(mod_ofdm_syms, 2)/sim_consts.NumSubc;
n_antennas = size(mod_ofdm_syms, 1);

resample_patt=[33:64 1:32];
time_syms = zeros(n_antennas, num_symbols*64*up);

% Convert each antenna's signal to time domain
for antenna = 1:n_antennas
   syms_into_ifft = zeros(64, num_symbols);
   syms_into_ifft(sim_consts.UsedSubcIdx,:) = reshape(mod_ofdm_syms(antenna,:), ...
      sim_consts.NumSubc, num_symbols);
   
   syms_into_ifft(resample_patt,:) = syms_into_ifft;
   syms_into_ifft_up=zeros(64*up,num_symbols);
   syms_into_ifft_up(1:32,:)=syms_into_ifft(1:32,:);
   syms_into_ifft_up(end-31:end,:)=syms_into_ifft(33:64,:);
   % Convert to time domain
%    fid = fopen('txt\signal_noifft.txt', 'wt'); 
%    for i=1:length(syms_into_ifft_up)
%        fprintf(fid,'%6.3f,%6.3f\n',real(syms_into_ifft_up(i)),imag(syms_into_ifft_up(i)));
%    end
%    fclose('all');
   ifft_out = ifft(syms_into_ifft_up);
   time_syms(antenna,:) = ifft_out(:).';
end
