function alpha = AlphaGet(originalimage, originalwatermark)
    % originalimage：原始图像
    % originalwatermark：水印图像
    % alpha：最佳水印修正因子

    NCmax = 0;
    alpha = 60;

    for x = 60:-1:0
        [img_w, realwatermark] = AddWatermark(originalimage, originalwatermark, x);
        watermark_pick = PickWatermark(img_w, x);
        NC = NCCalc(realwatermark, watermark_pick);

        if (NC >= NCmax)
            NCmax = NC;
            alphatemp = x;

            if (alphatemp < alpha)
                alpha = alphatemp;
            end

        else
            break;
        end

    end

end
