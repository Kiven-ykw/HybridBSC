clc;
clear;
close all;

MCSnum = 4;
fullnum = 500;

msduLength = 2304;
bitsPerOctet = 8;
msdubitsLen = msduLength * bitsPerOctet;
data = round(rand(msdubitsLen * fullnum, 1));
numMSDUs = ceil((length(data)) / msdubitsLen);
padZeros = msdubitsLen - mod(length(data) + 8, msdubitsLen);
txData = [data; zeros(padZeros, 1)];

generatorPolynomial = [32 26 23 22 16 12 11 10 8 7 5 4 2 1 0];
fcsGenerator = comm.CRCGenerator(generatorPolynomial);
fcsGenerator.InitialConditions = 1;
fcsGenerator.DirectMethod = true;
fcsGenerator.FinalXOR = 1;

ACK_MACHeader = ['D4'; '00'];
MACHeader = ['08'; '02';
             '00'; '00';
             'FF'; 'FF'; 'FF'; 'FF'; 'FF'; 'FF';
             '00'; '12'; '34'; '56'; '78'; '9B';
             '00'; '12'; '34'; '56'; '78'; '9B';
             '00'; '00'];
lengthMACheader = 24;
lengthACKMACheader = 2;
lengthFCS = 4;
lengthMPDU = lengthMACheader + msduLength + lengthFCS;
sequenceindex = 23;
txDataBits = zeros(0, 1);

nonHTcfg = wlanNonHTConfig;
nonHTcfg.MCS = MCSnum;
nonHTcfg.ChannelBandwidth = 'CBW20';
nonHTcfg.NumTransmitAntennas = 1;
nonHTcfg.PSDULength = lengthMPDU;

msduLength = 2304;
nonHTcfg = wlanNonHTConfig;
nonHTcfg.MCS = MCSnum;
nonHTcfg.NumTransmitAntennas = 1;
nonHTcfg.ChannelBandwidth = 'CBW20';
chanBW = nonHTcfg.ChannelBandwidth;

nonHTcfg.PSDULength = msduLength + 28;
bitsPerOctet = 8;
lengthMACheader = 24;
lengthACKMACheader = 2;
lengthFCS = 4;
lengthMPDU = lengthMACheader + msduLength + lengthFCS;
lengthACKMPDU = lengthACKMACheader + lengthFCS;

ACKnonHTcfg = wlanNonHTConfig;
ACKnonHTcfg.MCS = MCSnum;
ACKnonHTcfg.NumTransmitAntennas = 1;
ACKnonHTcfg.ChannelBandwidth = 'CBW20';
ACKnonHTcfg.PSDULength = lengthACKMPDU;

sequenceindex = 23;
fs = SamplerateCheck(nonHTcfg.ChannelBandwidth);
osf = 1.5;
ACKFlag = 0;
seqnum = 0;

indLSTF = wlanFieldIndices(nonHTcfg, 'L-STF');
indLLTF = wlanFieldIndices(nonHTcfg, 'L-LTF');
indLSIG = wlanFieldIndices(nonHTcfg, 'L-SIG');
Ns = indLSIG(2) - indLSIG(1) + 1;

number = 0;
errrecord = [];

for NoiseSNR = 8:0.2:16
    errnum = 0;

    for ind = 1:numMSDUs

        frameBody = txData((ind - 1) * msdubitsLen + 1:msdubitsLen * ind, :);
        frameHeader = MACHeader;
        frameHeaderBits = reshape((de2bi(hex2dec(frameHeader)))', [], 1);
        FCS = fcsGenerator([frameHeaderBits; frameBody]);
        frameFCS = FCS(end - lengthFCS * bitsPerOctet + 1:end);
        txDataBits = [frameHeaderBits; frameBody; frameFCS];

        txWaveform = wlanWaveformGenerator(txDataBits, nonHTcfg);

        fs = SamplerateCheck(nonHTcfg.ChannelBandwidth);
        osf = 1.5;
        BasebandSampleRate = fs .* osf;
        txWaveform = resample(txWaveform, fs * osf, fs);
        fprintf('\n生成第%d个WLAN发射数据\n', ind);
        txWaveform1 = [txWaveform; zeros(10000, 1)];

        txWaveform = awgn(txWaveform1, NoiseSNR);

        captureLength_RX = length(txWaveform);

        burstCaptures_RX = txWaveform(1:captureLength_RX, 1);

        rxWaveform = resample(burstCaptures_RX, fs, fs * osf);
        rxWaveformLen = size(rxWaveform, 1);
        searchOffset = 0;

        lstfLen = double(indLSTF(2));
        minPktLen = lstfLen * 5;

        sr = SamplerateCheck(nonHTcfg.ChannelBandwidth);
        fineTimingOffset = [];
        packetSeq = [];
        Index = 1;

        while (searchOffset + minPktLen) <= rxWaveformLen
            pktOffset = wlanPacketDetect(rxWaveform, chanBW, searchOffset, 0.9);

            pktOffset = searchOffset + pktOffset;

            if isempty(pktOffset) || (pktOffset + double(indLSIG(2)) > rxWaveformLen)
                errnum = errnum + 1;
                break;
            end

            nonHT = rxWaveform(pktOffset + (indLSTF(1):indLSIG(2)), :);
            coarseFreqOffset = wlanCoarseCFOEstimate(nonHT, chanBW);
            nonHT = helperFrequencyOffset(nonHT, fs, -coarseFreqOffset);
            fineTimingOffset = wlanSymbolTimingEstimate(nonHT, chanBW);
            pktOffset = pktOffset + fineTimingOffset;

            if (pktOffset < 0) || ((pktOffset + minPktLen) > rxWaveformLen)
                searchOffset = pktOffset + 1.5 * lstfLen;
                continue;
            end

            fprintf('\n发射端第%d个包在序列%d被检测到\n', ind, pktOffset + 1);

            nonHT = rxWaveform(pktOffset + (1:7 * Ns), :);
            nonHT = helperFrequencyOffset(nonHT, fs, -coarseFreqOffset);

            lltf = nonHT(indLLTF(1):indLLTF(2), :);
            fineFreqOffset = wlanFineCFOEstimate(lltf, chanBW);
            nonHT = helperFrequencyOffset(nonHT, fs, -fineFreqOffset);
            cfoCorrection = coarseFreqOffset + fineFreqOffset;

            lltf = nonHT(indLLTF(1):indLLTF(2), :);
            demodLLTF = wlanLLTFDemodulate(lltf, chanBW);
            chanEstLLTF = wlanLLTFChannelEstimate(demodLLTF, chanBW);
            noiseVarNonHT = helperNoiseEstimate(demodLLTF);

            format = wlanFormatDetect(nonHT(indLLTF(2) + (1:3 * Ns), :), ...
                chanEstLLTF, noiseVarNonHT, chanBW);
            disp(['  ' format ' format检测成功']);

            if ~strcmp(format, 'Non-HT')
                fprintf('  一个非Non-HT的format被检测到\n');
                searchOffset = pktOffset + 1.5 * lstfLen;
                continue;
            end

            [recLSIGBits, failCheck] = wlanLSIGRecover( ...
                nonHT(indLSIG(1):indLSIG(2), :), chanEstLLTF, noiseVarNonHT, chanBW);

            if failCheck
                fprintf('  L-SIG检测失败 \n');
                searchOffset = pktOffset + 1.5 * lstfLen;
                continue;
            else
                fprintf('  L-SIG检测成功 \n');
            end

            [lsigMCS, lsigLen, rxSamples] = helperInterpretLSIG(recLSIGBits, sr);

            if (rxSamples + pktOffset) > length(rxWaveform)
                disp('** 没有足够的样点去检测包 **');
                break;
            end

            rxWaveform(pktOffset + (1:rxSamples), :) = helperFrequencyOffset( ...
                rxWaveform(pktOffset + (1:rxSamples), :), fs, -cfoCorrection);

            rxNonHTcfg = wlanNonHTConfig;
            rxNonHTcfg.MCS = lsigMCS;
            rxNonHTcfg.PSDULength = lsigLen;
            rxNonHTcfg.ChannelBandwidth = nonHTcfg.ChannelBandwidth;

            indNonHTData = wlanFieldIndices(rxNonHTcfg, 'NonHT-Data');

            [rxPSDU, eqSym] = wlanNonHTDataRecover( ...
                rxWaveform(pktOffset + (indNonHTData(1):indNonHTData(2)), :), ...
                chanEstLLTF, noiseVarNonHT, rxNonHTcfg);

            refSym = wlanClosestReferenceSymbol(eqSym, rxNonHTcfg);

            generatorPolynomial = [32 26 23 22 16 12 11 10 8 7 5 4 2 1 0];
            fcsGenerator = comm.CRCGenerator(generatorPolynomial);
            fcsGenerator.InitialConditions = 1;
            fcsGenerator.DirectMethod = true;
            fcsGenerator.FinalXOR = 1;

            rxPSDU = double(rxPSDU);
            RXMACHeader = rxPSDU(1:lengthMACheader * bitsPerOctet, 1);
            rxBit = rxPSDU(lengthMACheader * bitsPerOctet + 1: ...
            end - lengthFCS * bitsPerOctet, 1);

        RXMACFCS = rxPSDU(end - lengthFCS * bitsPerOctet + 1:end, 1);
        sequence = rxPSDU((sequenceindex - 1) * bitsPerOctet + 1:sequenceindex * bitsPerOctet, 1);
        packetSeq = bi2de(sequence');
        rxBitMatrix(:, ind) = rxBit;

        searchOffset = pktOffset + double(indNonHTData(2));

        FCS = fcsGenerator([RXMACHeader; rxBit]);
        TrueFCS = FCS(end - lengthFCS * bitsPerOctet + 1:end);

        if (RXMACFCS == TrueFCS)
            break;
        else
            errnum = errnum + 1;
            break;
        end

    end

end

% rxData = rxBitMatrix(:);
% rxData = rxData(1:length(data));
% bitErrorRate = comm.ErrorRate;
% number = number + 1;
% err = bitErrorRate(rxData, txData(1:length(rxData)));
% errrecord(number) = err(1);

number = number + 1;
PER(number) = errnum / fullnum;
SNRrecord(number) = NoiseSNR;

if (errnum == 0)
    break;
end

end

plot(SNRrecord, PER)
