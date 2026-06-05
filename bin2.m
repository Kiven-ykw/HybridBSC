function test2 = bin2(temp_data_reshape)

    de_reshape = temp_data_reshape(19:46, :);
    de_bin = reshape(de_reshape, 16, 112);

    restoredBinaryResultMatrix = de_bin;

    test2 = ones(16, 4);

    for i = 1:16

        for j = 1:28:112
            temp_test = 0;

            for k = 1:28
                temp_test = temp_test + 2 ^ ((28 - k) * restoredBinaryResultMatrix(i, j - 1 + k));
            end

            test2(i, (j - 1) / 28 + 1) = temp_test * 1e-7;
        end

    end
