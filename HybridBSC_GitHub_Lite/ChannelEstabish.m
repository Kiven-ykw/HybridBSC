function signalout = ChannelEstabish(signalin, SNR)
    % signalin：输入信号
    % SNR：信噪比
    % signalin：输出信号

    fs = 20e6;
    pathDelays = [0 1 5 50 100] * 1e-9;
    avgPathGains = [0 -5.9 -10 -12.3 -15.6];
    fD = 2;
    rayleighchan = comm.RayleighChannel('SampleRate', fs, ...
        'PathDelays', pathDelays, ...
        'AveragePathGains', avgPathGains, ...
        'MaximumDopplerShift', fD);
    % tgnChan = wlanTGnChannel('SampleRate', fs, ...
    %     'LargeScaleFadingEffect', 'shadowing');
    % signalout = tgnChan(signalin);
    signalout = awgn(rayleighchan(signalin), SNR);

end
