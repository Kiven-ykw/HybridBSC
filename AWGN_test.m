function y = AWGN_test(x, snr)
    snr = 10 ^ (snr / 10.0);
    xpower = sum(x .^ 2) / length(x);
    npower = xpower / snr;

    if isreal(x(1))
        noise = randn(size(x)) * sqrt(npower);
    else
        noise = (randn(size(x)) + 1i * randn(size(x))) * sqrt(0.5 * npower);
    end

    y = x + noise;
end
