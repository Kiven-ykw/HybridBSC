clear all;clc
load('H50.mat');
[output, PSNR, NC] = fitnessfun(originalimage, originalwatermark, X, beta);
PSNR
NC

function [output, PSNR, NC] = fitnessfun(originalimage, originalwatermark, alpha, beta)

    size_alpha = size(alpha);

    for i = 1:size_alpha(1)
        [img_watermark, realwatermark] = AddWatermark(originalimage, originalwatermark, alpha(i, :));
        PSNR = PSNRCalc(originalimage, img_watermark);
        watermark_pick = PickWatermark(img_watermark, alpha(i, :));
        NC = NCCalc(realwatermark, watermark_pick);
        output(i, 1) = PSNR + beta * NC;
    end

end
