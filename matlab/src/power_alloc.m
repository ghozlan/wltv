function [Sigma_X_NORMALIZED, layer]= power_alloc( H_TX, SCHEME, SIM )

dt = SIM.dt;
T_TRANSMISSION = SIM.T_TRANSMISSION;

W_A_Kprime = SCHEME;
W_base = W_A_Kprime(1); a_base = W_A_Kprime(2); K_prime = W_A_Kprime(3);

%%
W_vec = W_base * a_base.^(0:K_prime-1);
N_symb_per_layer = floor(T_TRANSMISSION .* W_vec)*2;
N_sym_total = sum(N_symb_per_layer);

first_index_of_layer = cumsum([0 N_symb_per_layer(1:end-1)]) + 1;
last_index_of_layer = cumsum(N_symb_per_layer(1:end));

Sigma_X_DIAG = ones(N_sym_total,1); 
LAYER_MASK = zeros(N_sym_total);
for layer_index = 1:K_prime
    layer{layer_index} = first_index_of_layer(layer_index):last_index_of_layer(layer_index);
    %Sigma_X_DIAG(layer{layer_index}) = 1/W_vec(layer_index);
    Sigma_X_DIAG(layer{layer_index}) = 1;
    LAYER_MASK(layer{layer_index},layer{layer_index}) = 1;
end
Sigma_X_NORMALIZED = 1/K_prime * diag(Sigma_X_DIAG);
POWER_FACTOR = trace((H_TX' * H_TX) * Sigma_X_NORMALIZED)*dt/T_TRANSMISSION; % SHOULD BE = 1
Sigma_X_NORMALIZED = Sigma_X_NORMALIZED / POWER_FACTOR;

end

