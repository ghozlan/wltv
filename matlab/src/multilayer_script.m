%% Multi-Layer Transmission in Wideband Linear Time-Varying Channels

%% Choose Channel, Scheme and SNR Values

SNRdB_vec = 0:30;   % signal-to-noise ratio (SNR) values in dB

channel_index = 5;  % choose channel (from 1 to 5)
scheme_index = 1;   % choose scheme (from 1 to 3)

%% Open Log File

sim_start = tic;
% open log file (to keep track of the simulation)
global log_file
log_filename = ['log_channel' num2str(channel_index) '_scheme' num2str(scheme_index) '.txt'];
log_file = fopen(log_filename,'w');

%% Simulation Paramters

PASSBAND = true;            % passband/baseband
T_TRANSMISSION = 32;        % transmission time
F_samp = 64;                % simulation sampling frequency
N0 = 1;                     % one-sided power spectral density of noise

SIM.PASSBAND = PASSBAND;
if(PASSBAND)
    SIM.REAL_DIM_PER_SYM = 1;
else
    SIM.REAL_DIM_PER_SYM = 2;
end

SIM.T_TRANSMISSION = T_TRANSMISSION;
SIM.T_SIMULATION = 3*T_TRANSMISSION;
SIM.df = 1.0/SIM.T_SIMULATION;

SIM.F_samp = F_samp;
SIM.dt = 1.0/F_samp;

t = linspace(0,SIM.T_SIMULATION,SIM.T_SIMULATION/SIM.dt+1);
t(end) = [];
SIM.t = t;

SIM.N0 = N0;

SNR_vec = 10.^(SNRdB_vec/10);
P_vec = SNR_vec * N0; 

%% Transmission Scheme Parameters

% SCHME format: [W (base), a (base), K_prime, fc (base)]
SCHEMES{1} = [1,2,3,1.5]; %fc_base = 1.5*W_base;
SCHEMES{2} = [1,1.587401051968199,4,1.5]; %fc_base = 1.5*W_base;
SCHEMES{3} = [7,1,1,4.5];
SCH = SCHEMES{scheme_index};

W_base = SCH(1); a_base = SCH(2); K_prime = SCH(3); fc_base = SCH(4);
print_log('Scheme parameters:\n')
print_log(sprintf('W = %f, a = %f, K^prime = %d\n', W_base, a_base, K_prime))

%% Generate the Transmitter Matrix

print_log('Generating transmitter matrix\n')
[H_TX f_min f_max] = generate_vecs(W_base,a_base,K_prime,fc_base, SIM);
B_TOTAL = f_max - f_min;
fc = (f_max + f_min)/2;

%% Channel Parameters 

% Deterministic channels
% Wideband linear time-varying channels
CH.N_paths = 2; CH.h_wb = [1 1/2]; CH.tau = [0 2]; CH.alpha = [1 2]; %CHANNEL A
CHANNELS{1} = CH;
CH.N_paths = 2; CH.h_wb = [1 1/2]; CH.tau = [0 2]; CH.alpha = [1 1.587401051968199]; % CHANNEL B
CHANNELS{2} = CH;
CH.N_paths = 2; CH.h_wb = [1 1.5]; CH.tau = [0 2]; CH.alpha = [1 2]; %CHANNEL C
CHANNELS{3} = CH;
CH.N_paths = 2; CH.h_wb = [1 1.5]; CH.tau = [2 3]; CH.alpha = [1 2]; %CHANNEL D
CHANNELS{4} = CH;
CH.N_paths = 3; CH.h_wb = [1 -0.7 1.5]; CH.tau = [2 1 3]; CH.alpha = [1 1.25 2]; %CHANNEL E
CHANNELS{5} = CH;

CHANNEL_LABEL = {'A','B','C','D','E'};

CH = CHANNELS{channel_index};

print_log('Channel parameters:\n')
fields = fieldnames(CH);
for i = 1:length(fields)
    print_log( sprintf('%s = %s\n', fields{i}, mat2str( getfield(CH,fields{i}) )) );
end

%% Generate the Channel Matrix

print_log('Generating channel matrix\n')

K0_t_tau = generate_ch_matrix(CH, SIM);

H_CH = K0_t_tau * SIM.dt;

%% Generate the Receiver Matrix

print_log('Generating receiver matrix\n')
% Make receiver take into account the max delay (seems to be not critical)
SIM_RX = SIM;
SIM_RX.T_TRANSMISSION = SIM.T_TRANSMISSION + max(CH.tau);
% For same band receiver
[H_RX f_min f_max] = generate_vecs(W_base,a_base,K_prime,fc_base, SIM_RX);
% For expanded band receiver
K = K_prime+1;
[H_RX_EB f_min f_max] = generate_vecs(W_base,a_base,K,fc_base, SIM_RX);

%% Optimal Receiver

print_log('Computing rate for optimal receiver\n')

tic
R_OPT = info_rate_optrx(H_TX, H_CH, P_vec, SCHEMES{scheme_index}, SIM);
runtime = toc;
print_log(sprintf('(%.2f sec)\n',runtime))
RUNTIMES.OPT = runtime;

%% Multi-Layer Receiver, Expanded Bandwidth with Joint Decoding

print_log('Computing rate for expanded band receiver\n')

tic
R_EB = info_rate_expand(H_TX, H_CH, H_RX_EB, P_vec, SCHEMES{scheme_index}, SIM);
runtime = toc;
print_log(sprintf('(%.2f sec)\n',runtime))
RUNTIMES.EB = runtime;

%% Multi-Layer Receiver, Same Bandwidth with Joint Layer Decoding

print_log('Computing rate for same band receiver with joint layer decoding\n')

tic
R_SB_JLD = info_rate_expand(H_TX, H_CH, H_RX, P_vec, SCHEMES{scheme_index}, SIM);
runtime = toc;
print_log(sprintf('(%.2f sec)\n',runtime))
RUNTIMES.SB_JLD = runtime;

%% Multi-Layer Receiver, Same Bandwidth with Individual Layer Decoding

print_log('Computing rate for same band receiver with individual layer decoding\n')

tic
R_SB_ILD = info_rate_ild( H_TX, H_CH, H_RX, P_vec, SCHEMES{scheme_index}, SIM );
runtime = toc;
print_log(sprintf('(%.2f sec)\n',runtime))
RUNTIMES.SB_ILD = runtime;

%% Collect and Save Results

print_log('Collecting results\n')

SNR_vec = P_vec/N0;
SNRdB_vec = 10*log10(SNR_vec);

DATA.SIM = SIM;
DATA.SNRdB = SNRdB_vec;
DATA.CHANNEL_PARAMS = CH;
DATA.SCHEME_PARAMS = SCHEMES{scheme_index};
DATA.RX.OPT   .RATE = R_OPT;
DATA.RX.EB    .RATE = R_EB;
DATA.RX.EB    .LABEL = sprintf('EB (K=%d)',K);
DATA.RX.SB_JLD.RATE = R_SB_JLD;
DATA.RX.SB_ILD.RATE = R_SB_ILD;

sim_runtime = toc(sim_start);
DATA.RUNTIME = sim_runtime;

keyword =  '';
timestamp = datestr(now,'HHMMSS');
tail = [timestamp  keyword];
root_filename = ['channel' lower(CHANNEL_LABEL{channel_index}) '_'];
root_filename = [root_filename 'scheme' num2str(scheme_index) '_'];
data_filename = [root_filename tail];
save(data_filename, 'DATA');
fprintf('Output saved to file: %s\n',data_filename)

print_log(sprintf('Simulation runtime: %.2f sec.\n',sim_runtime))
fclose(log_file);

%% Plot Input and Output Spectra (broken down by layer)

plot_spectrum(H_TX, H_CH, SCH, CH, SIM)

fig_filename = ['SPECTRUM_' 'CH' CHANNEL_LABEL{channel_index} '_SCH' num2str(scheme_index) '.eps'];
print('-depsc', fig_filename)

%% Plot Information Rates

LineWidth = 2;
MarkerSize = 10;
FontSize = 17;
FontSizeLegend = 14;

line_style = { 'g*-', 'bs-', 'm+-', 'rx-', 'bo-'};

ch = ['CHANNEL' CHANNEL_LABEL{channel_index}];
sch = ['SCHEME' num2str(scheme_index)];

fig_index = 1000;
set(figure(fig_index),'Name','Rate (nats/sec) vs SNR (dB)')
plot(SNRdB_vec,R_OPT,...
    line_style{1},'LineWidth',LineWidth,'MarkerSize',MarkerSize)
hold on
plot(SNRdB_vec,R_EB,...
    line_style{2},'LineWidth',LineWidth,'MarkerSize',MarkerSize)
plot(SNRdB_vec,R_SB_JLD,...
    line_style{3},'LineWidth',LineWidth,'MarkerSize',MarkerSize)
plot(SNRdB_vec,R_SB_ILD,...
    line_style{4},'LineWidth',LineWidth,'MarkerSize',MarkerSize)
hold off
title(['Channel ' CHANNEL_LABEL{channel_index} ', Scheme ' num2str(scheme_index)])
xlabel('SNR (dB)','FontSize',FontSize)
ylabel('Information Rates (nats/sec)','FontSize',FontSize)        
legend(...
    'Optimal',...
    'EB, K=K^\prime+1',...
    'SB, JLD',...
    'SB, ILD',...
    'Location','SouthEast')
handles = get(fig_index,'Children'); 
set(handles(1),'FontSize',FontSizeLegend);

set(fig_index,'Position',[2*480 50 2*480 2*360]);figure(fig_index)

fig_filename = ['RATE_' ch '_' sch '.eps'];
print('-depsc', fig_filename)
