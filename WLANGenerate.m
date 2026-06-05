function [dataout, BasebandSampleRate] = WLANGenerate(data, MCSnum)
    % data：输入数据

    % dataout：输出数据

    msduLength = 2304;
    bitsPerOctet = 8;
    msdubitsLen = msduLength * bitsPerOctet;
    numMSDUs = ceil((length(data) + 8) / msdubitsLen);
    num_bi = de2bi(numMSDUs, 8)';
    padZeros = msdubitsLen - mod(length(data) + 8, msdubitsLen);
    txData = [num_bi; data; zeros(padZeros, 1)];
    save txData;

    generatorPolynomial = [32 26 23 22 16 12 11 10 8 7 5 4 2 1 0];
    fcsGenerator = comm.CRCGenerator(generatorPolynomial);
    fcsGenerator.InitialConditions = 1;
    fcsGenerator.DirectMethod = true;
    fcsGenerator.FinalXOR = 1;

    MACHeader = ['08'; '02';
                 '00'; '00';
                 'FF'; 'FF'; 'FF'; 'FF'; 'FF'; 'FF';
                 '00'; '12'; '34'; '56'; '78'; '9B';
                 '00'; '12'; '34'; '56'; '78'; '9B';
                 '00'; '00'];
    lengthMACheader = 24;
    lengthFCS = 4;
    lengthMPDU = lengthMACheader + msduLength + lengthFCS;
    sequenceindex = 23;
    txDataBits = zeros(0, 1);

    for ind = 0:numMSDUs - 1
        frameBody = txData(ind * msdubitsLen + 1:msdubitsLen * (ind + 1), :);
        Sequence = dec2hex(ind, 2);
        frameHeader = MACHeader;
        frameHeader(sequenceindex, :) = num2str(Sequence);
        frameHeaderBits = reshape((de2bi(hex2dec(frameHeader)))', [], 1);
        FCS = fcsGenerator([frameHeaderBits; frameBody]);
        frameFCS = FCS(end - lengthFCS * bitsPerOctet + 1:end);
        txDataBits = [txDataBits; [frameHeaderBits; frameBody; frameFCS]];
    end

    nonHTcfg = wlanNonHTConfig;
    nonHTcfg.MCS = MCSnum;
    nonHTcfg.ChannelBandwidth = 'CBW20';
    nonHTcfg.NumTransmitAntennas = 1;
    nonHTcfg.PSDULength = lengthMPDU;
    scramblerInitialization = randi([1 127], numMSDUs, 1);

    txWaveform = wlanWaveformGenerator(txDataBits, nonHTcfg, ...
        'NumPackets', numMSDUs, 'IdleTime', 20e-6, ...
        'ScramblerInitialization', scramblerInitialization);

    fs = SamplerateCheck(nonHTcfg.ChannelBandwidth);
    osf = 1.5;
    BasebandSampleRate = fs .* osf;
    txWaveform = resample(txWaveform, fs * osf, fs);
    dataout = txWaveform;
    fprintf('\n生成WLAN发射数据\n')

end
