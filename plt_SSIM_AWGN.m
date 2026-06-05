clear all;clc

SNR_t = 0:3:24;

AWGN_B_QPSK = [0
               0.334632311
               0.880770486
               0.883027243
               0.882527994
               0.882527994
               0.882527994
               0.882527994
               0.882527994
               ];

AWGN_B_16QAM = [0
                0
                0
                0.46778455
                0.978917106
                0.978724001
                0.978724001
                0.978724001
                0.978724001
                ];

AWGN_B_64QAM = [0
                0
                0
                0
                0
                0.451828051
                0.98629472
                0.986441301
                0.986441301
                ];

AWGN_S_QPSK = [0
               -0.020994707
               0.968203112
               0.982350698
               0.982350698
               0.982350698
               0.982350698
               0.982350698
               0.982350698
               ];

AWGN_S_16QAM = [0
                0
                0
                -0.009179692
                0.996977388
                0.996977388
                0.996977388
                0.996977388
                0.996977388
                ];

AWGN_S_64QAM = [0
                0
                0
                0
                0
                -0.00547038
                0.996977388
                0.996977388
                0.996977388
                ];

figure;

plot(SNR_t(2:9), AWGN_B_QPSK(2:9), '-+');
hold on;
plot(SNR_t(4:9), AWGN_B_16QAM(4:9), '-*');
hold on;
plot(SNR_t(6:9), AWGN_B_64QAM(6:9), '-x');
hold on;
plot(SNR_t(2:9), AWGN_S_QPSK(2:9), '--d');
hold on;
plot(SNR_t(4:9), AWGN_S_16QAM(4:9), '--^');
hold on;
plot(SNR_t(6:9), AWGN_S_64QAM(6:9), '--v');
hold on;

% plot(SNR_t, AWGN_B_QPSK, '-+');
% hold on;
% plot(SNR_t, AWGN_B_16QAM, '-*');
% hold on;
% plot(SNR_t, AWGN_B_64QAM, '-x');
% hold on;
% plot(SNR_t, AWGN_S_QPSK, '--d');
% hold on;
% plot(SNR_t, AWGN_S_16QAM, '--^');
% hold on;
% plot(SNR_t, AWGN_S_64QAM, '--v');
% hold on;

xlabel('SNR');
ylabel('SSIM');
title('AWGN');
legend('bit-QPSK', 'bit-16QAM', 'bit-64QAM', 'semantic-QPSK', 'semantic-16QAM', 'semantic-64QAM');
