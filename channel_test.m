numSym = 1e4;
snrRange = 0:2:30;
ber = zeros(size(snrRange));

modulator = comm.RectangularQAMModulator('ModulationOrder', 64, 'NormalizationMethod', 'Average power');
demodulator = comm.RectangularQAMDemodulator('ModulationOrder', 64, 'NormalizationMethod', 'Average power');

ricianChan = comm.RicianChannel( ...
    'SampleRate', 20e6, ...
    'KFactor', 7, ...
    'PathDelays', [0 1e-6], ...
    'AveragePathGains', [0 -10], ...
    'MaximumDopplerShift', 5, ...
    'DopplerSpectrum', doppler('Jakes'), ...
    'RandomStream', 'mt19937ar', ...
    'Seed', 1);

berCalc = comm.ErrorRate;

for n = 1:length(snrRange)

    reset(berCalc);
    reset(ricianChan);

    dataIn = randi([0 63], numSym, 1);

    modSig = modulator(dataIn);

    fadedSig = ricianChan(modSig);

    rxSig = awgn(fadedSig, snrRange(n), 'measured');

    dataOut = demodulator(rxSig);

    berResult = berCalc(dataIn, dataOut);
    ber(n) = berResult(1);
end

figure;
plot(snrRange, ber, 'bo-');
xlabel('SNR (dB)');
ylabel('BER');
title('64QAM over Rician Channel BER Performance');
grid on;
