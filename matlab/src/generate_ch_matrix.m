function K0_t_tau = generate_ch_matrix( CH, SIM )
%% Widebandband Linear Time-Varying (LTV) Channel

t = SIM.t;
dt = SIM.dt;
F_samp = SIM.F_samp;

[tau_,t_] = meshgrid(t);
h_t_tminustau = zeros(length(t));
for m = 1:CH.N_paths
    h_t_tminustau = h_t_tminustau + CH.h_wb(m) * sqrt(CH.alpha(m)) * ...
     (1/dt) * sinc(F_samp*( (t_-tau_) - (CH.alpha(m)*CH.tau(m)-(CH.alpha(m)-1)*t_) ));
end

% handle = figure(601);
% set(handle,'Name','WB LTV: h(t,tau)')
% subplot(3,1,1)
% stem(abs(h_t_tminustau(1,:)),'.')
% subplot(3,1,2)
% %stem(h_t_tminustau(1:10:100,:)','.')
% stem(abs(h_t_tminustau(1:10:100,:))','.')
% subplot(3,1,3)
% plot(real(xt(:)),'r--','LineWidth',2) %############################# xt
% hold on
% plot(real(h_t_tminustau*xt(:)))
% hold off
% legend('x(t) [input]','y(t) [output] WB LTV')

K0_t_tau = h_t_tminustau; % Kernel


end

