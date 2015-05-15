function [H_TX, f_min, f_max] = generate_vecs(W_base,a_base,N_layers,fc_base, SIM)
PASSBAND = SIM.PASSBAND;
F_samp = SIM.F_samp;
df = SIM.df;
dt = SIM.dt;
T_TRANSMISSION = SIM.T_TRANSMISSION;
T_SIMULATION = SIM.T_SIMULATION;

a_vec = a_base.^(0:N_layers-1);

T_sym = 1/W_base;
N_sym = floor(T_TRANSMISSION/T_sym);         % number of signals %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
L = floor(T_sym/dt);                         % oversampling factor

idx = 1;
for a = a_vec
    W = W_base * a;         % bandwidth
    
    if(PASSBAND)
        fc = fc_base * a;       % carrier frequency
    else
        fc = 0;
    end
    
    
    N_FFT = T_SIMULATION/dt;
    f = linspace(-F_samp/2,F_samp/2,N_FFT);
    Xf = zeros(1,length(f));
    Xf(abs(f-fc)<W/2) = 1/sqrt(W);
    %Xf(abs(f-fc)<W) = 1/sqrt(2*W);
    Xf = fftshift(Xf);
    %xt = fftshift(ifft(Xf));
    xt = fftshift(N_FFT*ifft(Xf*df));
    xt_pb_iphase =  sqrt(2)*real(xt); %pass band: sum(abs(xt_pb_iphase).^2)*dt = 1
    xt_pb_qphase = -sqrt(2)*imag(xt); %pass band: sum(abs(xt_pb_qphase).^2)*dt = 1
    
    % set(figure(101),'Name','Band-Limited pulse (sinc)')
    % subplot(2,1,1)
    % plot(f,fftshift(Xf))
    % xlabel('f')
    % ylabel('|X(f-fc)|')
    % legend(['|f-f_c|>W/2=0, W=' num2str(W)])
    % subplot(2,1,2)
    % plot(t,xt)
    % hold on
    % plot(t,circshift(xt_re,[1 L]),'r')
    % plot(t,circshift(xt_re,[1 2*L]),'g')
    % hold off
    % xlabel('t')
    % legend('x(t)','x(t-T{sym})','x(t-2 T{sym})')
    
    % energy_fdomain = sum(abs(Xf).^2)*df
    % energy_tdomain = sum(abs(xt).^2)*dt
    
    
    N = floor(N_sym * a);
    %H_TX = zeros(length(xt),N); % tall matrix
    
    if(PASSBAND)
        H_TX_IPHASE = zeros(length(xt),N); % tall matrix
        H_TX_QPHASE = zeros(length(xt),N); % tall matrix
        for k = 1:N
            H_TX_IPHASE(:,k) = circshift(xt_pb_iphase(:),[(k-1)* ceil(L/a) 0]); % passband inphase
            H_TX_QPHASE(:,k) = circshift(xt_pb_qphase(:),[(k-1)* ceil(L/a) 0]); % passband quadrature phase
        end
        
        H_TX = 1/sqrt(2) * [H_TX_IPHASE H_TX_QPHASE]; % inphase energy = 1/2, quadrature phase energy = 1/2
        fprintf('Layer %d: 2x%d (real) symbols\n',idx,N)
    else
        H_TX_BASEBAND = zeros(length(xt),N); % tall matrix
        for k = 1:N
            H_TX_BASEBAND(:,k) = circshift(xt(:),[(k-1)* ceil(L/a) 0]);
        end
        
        H_TX = H_TX_BASEBAND;
        fprintf('Layer %d: %d (complex) symbols\n',idx,N)
    end
    
    H{idx} = H_TX; % H{i} is a matrix in which the columns are the tx vector of layer i
    idx = idx + 1;
    %pause(2)
end

f_min = min( a_vec*(fc_base-W_base/2) );
f_max = max( a_vec*(fc_base+W_base/2) );
B = f_max-f_min;
fprintf('f_min = %.5f, f_max = %.5f, B = %.5f\n',f_min,f_max,B)

%%
%K_prime = N_layers;
%B = W_base * (a_base.^K_prime-1)/(a_base-1) % THIS EXPRESSION IS RIGHT
%ONLY WHEN LAYERS ARE ORTHOGONAL IN FREQUENCY

%% Concatenate all tx (column) vectors in one matrix
H_TX = [];
for idx = 1:length(a_vec)
    H_TX = [H_TX H{idx}];
end

% %% Plot the transmit vectors (columns of H_TX) in time domain and frequecny domain
%
% set(figure(11),'Name','H_TX')
% imagesc(abs(H_TX))
% %surf(1:size(H_TX,2),t,abs(H_TX),'EdgeColor','None'); view(0,-90); axis tight;
% colormap(gray)
% xlabel('index of TX vecotr')
% ylabel('time')
% title('tx vectors in time domain')
% colorbar
%
% set(figure(12),'Name','FT{H_TX}');
% imagesc(abs(fft(H_TX)));
% colormap(gray)
% xlabel('index of tx vecotr')
% ylabel('frequency')
% title('Spectrum (|FT|) of TX vectors')
% colorbar
%
% set(figure(13),'Name','H_TX (Inner Product)')
% subplot(1,2,1)
% %imagesc(abs(H_TX'*H_TX))
% imagesc(abs(conj(transpose(H_TX))*H_TX))
% colormap(gray)
% xlabel('index of TX vecotr')
% ylabel('index of TX vecotr')
% title('H_{TX}^H H_{TX} (orthogonality check)')
% axis square
% subplot(1,2,2)
% %imagesc(abs(H_TX.'*H_TX))
% imagesc(abs(transpose(H_TX)*H_TX))
% colormap(gray)
% xlabel('index of TX vecotr')
% ylabel('index of TX vecotr')
% title('H_{TX}^T H_{TX}')
% axis square
%
