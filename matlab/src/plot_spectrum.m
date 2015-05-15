function plot_spectrum(H_TX, H_CH, SCH, CH, SIM)

[Sigma_X_NORMALIZED, layer] = power_alloc(H_TX, SCH, SIM);
K_prime = length(layer);
SELECTED_VECS = zeros(1,K_prime);
for k=1:K_prime
    SELECTED_VECS(k) = layer{k}(2);
end


N_FFT = SIM.T_SIMULATION/SIM.dt;
f = linspace(-SIM.F_samp/2,SIM.F_samp/2,N_FFT);

H_TX_SELECTED = H_TX(:,SELECTED_VECS);
FT_IN = fftshift( fft(H_TX_SELECTED)*SIM.dt ,1);

% transpose(H_TX) * H_TX * SIM.dt; % diagonal

line_color = {'b',[0 0.5 0],'r','m'};

W_base = SCH(1); a_base = SCH(2); K_prime = SCH(3); fc_base = SCH(4);
f_max = (fc_base+W_base/2)*a_base^(K_prime-1);
F = f_max * max(CH.alpha);

H_CHTX = H_CH * H_TX_SELECTED;
FT_OUT = fftshift( fft(H_CHTX)*SIM.dt , 1);

figure(20)
clf(20)
subplot(K_prime+1,1,1)
for k=1:K_prime
    plot(f,abs(FT_IN(:,k)),'Color',line_color{k},'LineWidth',2)
    hold on
    axis([-F F 0 1])
end
hold off
xlabel('f')
ylabel('|FT|')
title('Input Spectrum')

for k=1:K_prime
    subplot(K_prime+1,1,k+1)
    plot(f,abs(FT_OUT(:,k)),'Color',line_color{k},'LineWidth',2)
    axis([-F F 0 1])
    xlabel('f')
    ylabel('|FT|')
    title(sprintf('Output Spectrum (k''=%d)',k))
end

set(20,'Position',[2*480 50 2*480 2*470]);figure(20)