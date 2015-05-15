%% Simulations

%% Set Signal-to-Noise Ration (SNR)

SNRdB_vec = 0:30;   % SNR values in dB

%% Channel A, Scheme 1

channel_index = 1;
scheme_index = 1;
multilayer(channel_index, scheme_index, SNRdB_vec)

%% Channel A, Scheme 2

channel_index = 1;
scheme_index = 2;
multilayer(channel_index, scheme_index, SNRdB_vec)

%% Channel E, Scheme 2

channel_index = 5;
scheme_index = 2;
multilayer(channel_index, scheme_index, SNRdB_vec)