function R_vec = info_rate_expand( H_TX, H_CH, H_RX, P_vec, SCHEME, SIM, IMPLEMENT )

if nargin == 6
    IMPLEMENT = 1; 
end

[U, S, V] = svd(H_RX);
svalue = diag(S);
SELECTED_COLS_IDX = find(svalue > max(svalue) * 1e-4);

if IMPLEMENT==1
    H_RX_REDUCED = U(:,SELECTED_COLS_IDX);
else
    H_RX_REDUCED = H_RX * V;
    H_RX_REDUCED = H_RX_REDUCED(:,SELECTED_COLS_IDX);
end

%%

N0 = SIM.N0;
dt = SIM.dt;
REAL_DIM_PER_SYM = SIM.REAL_DIM_PER_SYM;
T_TRANSMISSION = SIM.T_TRANSMISSION;

Sigma_X_NORMALIZED = power_alloc(H_TX, SCHEME, SIM);

H_RXCHTX = H_RX_REDUCED' * H_CH * H_TX;

sigma2_N = N0/2 * REAL_DIM_PER_SYM * (1/dt);  % DEPENDS ON WHETHER NOISE IS REAL (PASSBAND) OR COMPLEX (BASEBAND)
N_sim = size(H_TX,1);
Sigma_N = sigma2_N * eye(N_sim);
N_POWER = trace(Sigma_N)*dt/SIM.T_SIMULATION;

Sigma_Z = H_RX_REDUCED' * Sigma_N * H_RX_REDUCED;
Z_POWER = trace(Sigma_Z)*dt/T_TRANSMISSION;

I_vec = zeros(1,length(P_vec));
loop_index = 1;
for P = P_vec
Sigma_X = P * Sigma_X_NORMALIZED; %XXXXXXXXXXXXXXXXXXXXXXXXXXXX
%[trace((H_TX' * H_TX) * Sigma_X)*dt/T_TRANSMISSION P]   % CHECK POWER CONSTRAINT
Sigma_S = H_RXCHTX * Sigma_X * H_RXCHTX'; 

I = ( sum(log(eig(Sigma_S + Sigma_Z))) - sum(log(eig(Sigma_Z))) );
I_vec(loop_index) = I;
loop_index = loop_index + 1;
end

R_vec = I_vec / 2 * REAL_DIM_PER_SYM / T_TRANSMISSION;

end

