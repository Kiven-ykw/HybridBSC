function MCSmode = SNRDecision(SNR)
    % SNR：信噪比

    % MCSmode：调制方式

    if (SNR > 4.9)
        MCSmode = 0;
    else
        MCSmode = 15;
    end

end
