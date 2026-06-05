clc;
clear;
close all;

img = imread("img.tiff");
imwrite(img, 'img.jpg', 'jpg', 'Quality', 100);
img = imread("img.jpg");

temp_test_1 = load('.\data_1.txt');
temp1 = reshape(temp_test_1, 1, 784 * 4);
temp1_ones = randi([0, 1], 1, 480);
temp2_ones = randi([0, 1], 1, 480);
test = [temp1_ones temp1 temp2_ones];
test = reshape(test, 64, 64);

test_gray = mat2gray(test, [0 255])
watermark = gray2rgb(test_gray);

% alpha = AlphaGet_PN(img, watermark);
% alpha = 0.9;
% [img_w, realwatermark] = AddWatermark_PN(img, watermark, alpha);

% alpha = AlphaGet(img, watermark);
alpha = 14;
[img_w, realwatermark] = AddWatermark(img, watermark, alpha);

save("pluto_tx_image.mat", "img_w")

% imwrite(img, 'com_tx.jpg', 'jpg');
imwrite(img_w, 'com_tx.jpg', 'jpg');

figure(1)
subplot(221)
imshow(img)
title("原始图像")

img_rec = img_w;
load("pluto_rx_image.mat");
img_rec = receivedImage;

subplot(222)
imshow(img_rec)
title("添加水印后图像")

% watermark_pick = PickWatermark_PN(img_rec, alpha);

watermark_pick = PickWatermark(img_rec, alpha);

subplot(223)
imshow(realwatermark)
title("基于语义的数字水印")

subplot(224)
imshow(watermark_pick)
title("基于语义的数字水印（提取）")

temp2 = reshape(watermark_pick, 1, 4096);
temp2 = temp2(481:3616);
temp_test_2 = ones(784, 4);

for i = 1:4

    for j = i:784
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

figure;
imshow(img);
imwrite(img, '.\img_test_Tx.png', 'png');

figure;
imshow(img_rec);
imwrite(img_rec, '.\img_test_Rx.png', 'png');
