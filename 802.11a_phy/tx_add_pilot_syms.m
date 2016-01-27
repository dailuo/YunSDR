function mod_ofdm_syms = tx_add_pilot_syms(mod_syms, sim_options)

global sim_consts;

n_mod_syms = size(mod_syms,2);
n_ofdm_syms = n_mod_syms/sim_consts.NumDataSubc;

%pilot scrambling pattern
scramble_patt = repmat(sim_consts.PilotScramble,1,ceil(n_ofdm_syms/length(sim_consts.PilotScramble)));
scramble_patt = scramble_patt(1:n_ofdm_syms).*2^10;

mod_ofdm_syms = zeros(sim_consts.NumSubc, n_ofdm_syms);
mod_ofdm_syms(sim_consts.DataSubcPatt,:) = reshape(mod_syms, sim_consts.NumDataSubc, n_ofdm_syms);

mod_ofdm_syms(sim_consts.PilotSubcPatt,:) = repmat(scramble_patt, sim_consts.NumPilotSubc,1).* ...
   repmat(sim_consts.PilotSubcSymbols, 1, n_ofdm_syms);

mod_ofdm_syms = mod_ofdm_syms(:).';

% pilot([2:127 1])=sim_consts.PilotScramble;
% fid = fopen('txt\pilot.txt', 'wt'); 
% for i=1:length(pilot)
%     fprintf(fid,'7''d%3.0f:pilot=1''b%1.0f;\n',i-1,(pilot(i)>0));
% end
% fclose(fid);

