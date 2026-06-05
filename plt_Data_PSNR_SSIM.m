function plt_Data_PSNR_SSIM(judge, Data_QPSK_bit, Data_16QAM_bit, Data_64QAM_bit, Data_QPSK_semantic, Data_16QAM_semantic, Data_64QAM_semantic)

    SNR_t = 0:3:24;

    figure;
    plot(SNR_t(2:9), Data_QPSK_bit(2:9), '-+');
    hold on;
    plot(SNR_t(4:9), Data_16QAM_bit(4:9), '-*');
    hold on;
    plot(SNR_t(6:9), Data_64QAM_bit(6:9), '-x');
    hold on;
    plot(SNR_t(2:9), Data_QPSK_semantic(2:9), '--d');
    hold on;
    plot(SNR_t(4:9), Data_16QAM_semantic(4:9), '--^');
    hold on;
    plot(SNR_t(6:9), Data_64QAM_semantic(6:9), '--v');
    hold on;

    xlabel('SNR(dB)');

    if judge == 1
        ylabel('PSNR(dB)');
        axis([0, 25, 0, 45]);
    else
        ylabel('SSIM');
        axis([0, 25, 0.1, 1]);
    end

    legend('BitComm-QPSK', 'BitComm-16QAM', 'BitComm-64QAM', 'SemanticComm-QPSK', 'SemanticComm-16QAM', 'SemanticComm-64QAM');

end
