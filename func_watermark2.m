function func_watermark2(img_rec)
    alpha = 14;
    watermark_pick = PickWatermark(img_rec, alpha);
    temp2 = reshape(watermark_pick, 1, 4096);
    temp2 = temp2(481:3616);
    temp_test_2 = ones(784, 4);

    for i = 1:4

        for j = 1:784
            temp_test_2(j, i) = temp2(1, (i - 1) * 784 + j);
        end

    end

    fid = fopen('.\data_2.txt', 'w');
    [m, n] = size(temp_test_2);

    for i = 1:m

        for j = 1:n

            if temp_test_2(i, j) > 0.5
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
end
