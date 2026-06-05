clear all;clc

channel_model = 1;

input = load('./data_1.txt');
input = reshape(input, 1, 784 * 4);
input = reshape(input, 64, 64);

if channel_model == 1
    rxWaveform = awgn(txWaveform, SNR, 'measured', 'dB');
elseif channel_model == 2
    rayleighChan = comm.RayleighChannel( ...
        'SampleRate', 20e6, ...
        'PathDelays', [0 1e-6], ...
        'AveragePathGains', [0 -20], ...
        'MaximumDopplerShift', 10);
    channel_temp = rayleighChan(txWaveform);
    rxWaveform = awgn(channel_temp, SNR, 'measured', 'dB');
else
    ricianChan = comm.RicianChannel( ...
        'SampleRate', 20e6, ...
        'KFactor', 13, ...
        'PathDelays', [0 1e-6], ...
        'AveragePathGains', [0 -20], ...
        'MaximumDopplerShift', 10);
    channel_temp = ricianChan(txWaveform);
    rxWaveform = awgn(channel_temp, SNR, 'measured', 'dB');
end

output = reshape(output, 1, 784 * 4);
data_temp = ones(784, 4);

for i = 1:4

    for j = i:784
        data_temp(j, i) = output(1, (i - 1) * 784 + j);
    end

end

fid = fopen('./data_test.txt', 'w');
[m, n] = size(data_temp);

for i = 1:m

    for j = 1:n

        if data_temp(i, j) > 0.5
            data_temp = 1;
        else
            data_temp = 0;
        end

        if j == n
            fprintf(fid, '%d\n', data_temp);
        else
            fprintf(fid, '%d ', data_temp);
        end

    end

end

fclose(fid);
