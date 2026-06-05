function datacode = Q_JPEGEncode(QuanityFactor, img)
    % img：待压缩图片

    % datacodebits：压缩后图片数据

    Y_Table = [16, 11, 10, 16, 24, 40, 51, 61;
               12, 12, 14, 19, 26, 58, 60, 55;
               14, 13, 16, 24, 40, 57, 69, 56;
               14, 17, 22, 29, 51, 87, 80, 62;
               18, 22, 37, 56, 68, 109, 103, 77;
               24, 35, 55, 64, 81, 104, 113, 92;
               49, 64, 78, 87, 103, 121, 120, 101;
               72, 92, 95, 98, 112, 100, 103, 99];

    CbCr_Table = [17, 18, 24, 47, 99, 99, 99, 99;
                  18, 21, 26, 66, 99, 99, 99, 99;
                  24, 26, 56, 99, 99, 99, 99, 99;
                  47, 66, 99, 99, 99, 99, 99, 99;
                  99, 99, 99, 99, 99, 99, 99, 99;
                  99, 99, 99, 99, 99, 99, 99, 99;
                  99, 99, 99, 99, 99, 99, 99, 99;
                  99, 99, 99, 99, 99, 99, 99, 99];

    img_ycbcr = rgb2ycbcr(img);
    [row, col, ~] = size(img_ycbcr);

    row_expand = ceil(row / 16) * 16;

    if mod(row, 16) ~= 0

        for i = row:row_expand
            img_ycbcr(i, :, :) = img_ycbcr(row, :, :);
        end

    end

    col_expand = ceil(col / 16) * 16;

    if mod(col, 16) ~= 0

        for j = col:col_expand
            img_ycbcr(:, j, :) = img_ycbcr(:, col, :);
        end

    end

    Y = img_ycbcr(:, :, 1);
    Cb = zeros(row_expand / 2, col_expand / 2);
    Cr = zeros(row_expand / 2, col_expand / 2);

    for i = 1:row_expand / 2

        for j = 1:2:col_expand / 2 - 1
            Cb(i, j) = double(img_ycbcr(i * 2 - 1, j * 2 - 1, 2));
            Cr(i, j) = double(img_ycbcr(i * 2 - 1, j * 2 + 1, 3));
        end

    end

    for i = 1:row_expand / 2

        for j = 2:2:col_expand / 2
            Cb(i, j) = double(img_ycbcr(i * 2 - 1, j * 2 - 2, 2));
            Cr(i, j) = double(img_ycbcr(i * 2 - 1, j * 2, 3));
        end

    end

    % QuanityFactor = 0.5;
    Y_dct_q = Dct_Quantize(Y, QuanityFactor, Y_Table);
    Cb_dct_q = Dct_Quantize(Cb, QuanityFactor, CbCr_Table);
    Cr_dct_q = Dct_Quantize(Cr, QuanityFactor, CbCr_Table);

    data = [Y_dct_q(:); Cb_dct_q(:); Cr_dct_q(:)];
    data = data + 128;

    datacode = RLCEncode(data);
    % datacode = data;

end
