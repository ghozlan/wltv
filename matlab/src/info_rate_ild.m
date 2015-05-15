function R_vec = info_rate_ild( H_TX, H_CH, H_RX, P_vec, SCHEME, SIM )
% Layer by layer (applying the equations exactly)

N0 = SIM.N0;
dt = SIM.dt;
REAL_DIM_PER_SYM = SIM.REAL_DIM_PER_SYM;
T_TRANSMISSION = SIM.T_TRANSMISSION;

%% Power allocation

[Sigma_X_NORMALIZED, layer] = power_alloc(H_TX, SCHEME, SIM);
K_prime = length(layer);

%% Compute mutual informal layer by layer

R_vec_per_layer = zeros(K_prime,length(P_vec));
for k = 1:K_prime
    sigma2_N = N0/2 * REAL_DIM_PER_SYM * (1/dt);  % DEPENDS ON WHETHER NOISE IS REAL (PASSBAND) OR COMPLEX (BASEBAND)
    %Sigma_N = sigma2_N * eye(length(layer{k}));
    
    H_RX_k = H_RX(:,layer{k});
    H_RXCHTX = H_RX_k' * H_CH * H_TX;
    
    I_vec = zeros(1,length(P_vec));
    loop_index = 1;
    for P = P_vec
        Sigma_X = P * Sigma_X_NORMALIZED;     %XXXXXXXXXXXXXXXXXXXXXXXXXXXX
        
        Sigma_S = H_RXCHTX * Sigma_X * H_RXCHTX';
        
        Sigma_Z = H_RX_k' * sigma2_N * H_RX_k;
        
        Sigma_X_bar = Sigma_X;
        Sigma_X_bar(:,layer{k}) = 0;
        Sigma_X_bar(layer{k},:) = 0;
        
        Sigma_S_bar = H_RXCHTX * Sigma_X_bar * H_RXCHTX';
        
        %EIG_S = eig(Sigma_S);
        %EIG_S_bar = eig(Sigma_S_bar);       
        %I = sum(log( P * EIG_S + sigma2_N )) - sum(log( P * EIG_S_bar + sigma2_N ));
        
        I = sum(log(eig(Sigma_S + Sigma_Z))) - sum(log(eig(Sigma_S_bar + Sigma_Z)));
        I_vec(loop_index) = I;
        loop_index = loop_index + 1;
    end
    R_vec_per_layer(k,:) = I_vec / 2 * REAL_DIM_PER_SYM / T_TRANSMISSION;
end

R_vec = sum(R_vec_per_layer,1);

end

