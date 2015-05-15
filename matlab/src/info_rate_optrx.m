function R_vec = info_rate_optrx( H_TX, H_CH, P_vec, SCHEME, SIM )

N0 = SIM.N0;
dt = SIM.dt;
REAL_DIM_PER_SYM = SIM.REAL_DIM_PER_SYM;
T_TRANSMISSION = SIM.T_TRANSMISSION;

%%

Sigma_X_NORMALIZED = power_alloc(H_TX, SCHEME, SIM);
POWER_FACTOR = trace((H_TX' * H_TX) * Sigma_X_NORMALIZED)*dt/T_TRANSMISSION;
Sigma_X_NORMALIZED = Sigma_X_NORMALIZED/POWER_FACTOR;

%%
H_CHTX = H_CH * H_TX;
NN = size(H_CHTX,1);

Sigma_N = N0/2 * REAL_DIM_PER_SYM * (1/dt);  % DEPENDS ON WHETHER NOISE IS REAL (PASSBAND) OR COMPLEX (BASEBAND)
%trace(Sigma_N)*dt

% Sigma_Z = Sigma_N * eye(NN)
HYX = NN * log(Sigma_N);

Sigma_S_NORMALIZED = H_CHTX * Sigma_X_NORMALIZED * H_CHTX'; 
EIG_Sigma_S_NORMALIZED = eig(Sigma_S_NORMALIZED);
EIG_Sigma_Z = Sigma_N * ones(NN,1);

I_vec = zeros(1,length(P_vec));
loop_index = 1;
for P = P_vec

Sigma_X = P * Sigma_X_NORMALIZED;

EIG_Sigma_Y = P * EIG_Sigma_S_NORMALIZED + EIG_Sigma_Z; 

HY = sum(log( EIG_Sigma_Y ));
I = ( HY - HYX );
%I_vec = [I_vec I];
I_vec(loop_index) = I;
loop_index = loop_index + 1;
end

R_vec = I_vec / 2 * REAL_DIM_PER_SYM / T_TRANSMISSION;

end

