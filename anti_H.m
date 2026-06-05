clc;
clear;
close all;

temp_test_1 = [[8.892086 2.5548177 2.6374872 1.5766894]
                [11.846643 7.109644 1.5175437 7.1242013]
                [10.710667 3.2525904 9.297316 4.42019]
                [5.325512 4.7994957 1.8940842 6.6524844]
                [5.09738 9.874977 13.429089 2.25565]
                [4.573896 3.8574762 1.6581953 4.460027]
                [8.59332 6.002548 8.963325 6.4220924]
                [9.972875 5.1412272 8.122083 7.9075556]
                [8.03007 9.211128 5.030007 6.824195]
                [7.588398 7.2953386 9.762885 2.0278094]
                [4.1039505 6.2196712 4.452737 5.9302087]
                [5.0736356 11.236098 6.5961647 3.5077233]
                [3.0948272 8.75057 3.7505405 5.84871]
                [7.2343664 5.710694 3.7123504 2.1045477]
                [11.376616 5.841233 7.662611 5.5186615]
                [0. 8.401035 5.7363653 7.9992776]];
test = bin1(temp_test_1);
test_gray = mat2gray(test, [0 255])
originalwatermark = gray2rgb(test_gray);
originalimage = imread("./TrainPic/Test/lena.tiff");
alpha = 52.9988 + 7.9224 * 1; % 7.7433(44)7.9342(46)8.0478(48)
% originalimage = imread("peppers.tiff");
% alpha = 60.0245; % 8.0255(44)8.0085(46)8.0245(48)
% originalimage = imread("baboon.tiff");
% alpha = 61.8893; % 7.4966(44)7.6078(46)7.8893(48)
% originalimage = imread("airplane.tiff");
% alpha = 60.9863; % 7.9969(44)7.9873(46)7.9863(48)

[img_watermark, realwatermark] = AddWatermark(originalimage, originalwatermark, alpha);
PSNR = PSNRCalc(originalimage, img_watermark)

watermark_pick1 = PickWatermark(img_watermark, alpha);
% NC = NCCalc(realwatermark, watermark_pick);

img_watermark2 = imadd(img_watermark, +4);
watermark_pick2 = PickWatermark(img_watermark2, alpha);

img_watermark3 = imadd(img_watermark, -4);
watermark_pick3 = PickWatermark(img_watermark3, alpha);

img_watermark4 = imnoise(img_watermark, 'gaussian', 0, 0.01);
img_watermark5 = imnoise(img_watermark, 'gaussian', 0, 0.02);
img_watermark6 = imnoise(img_watermark, 'salt & pepper', 0.01);
img_watermark7 = imnoise(img_watermark, 'salt & pepper', 0.03);

watermark_pick4 = PickWatermark(img_watermark4, alpha);
watermark_pick5 = PickWatermark(img_watermark5, alpha);
watermark_pick6 = PickWatermark(img_watermark6, alpha);
watermark_pick7 = PickWatermark(img_watermark7, alpha);

R = img_watermark(:, :, 1);
G = img_watermark(:, :, 2);
B = img_watermark(:, :, 3);

R1 = medfilt2(R, [3, 3]);
G1 = medfilt2(G, [3, 3]);
B1 = medfilt2(B, [3, 3]);

R2 = medfilt2(R, [5, 5]);
G2 = medfilt2(G, [5, 5]);
B2 = medfilt2(B, [5, 5]);

R3 = filter2(fspecial('average', 3), R);
G3 = filter2(fspecial('average', 3), G);
B3 = filter2(fspecial('average', 3), B);

R4 = filter2(fspecial('average', 5), R);
G4 = filter2(fspecial('average', 5), G);
B4 = filter2(fspecial('average', 5), B);

R5 = filter2(fspecial('gaussian', 3, 0.01), R);
G5 = filter2(fspecial('gaussian', 3, 0.01), G);
B5 = filter2(fspecial('gaussian', 3, 0.01), B);

R6 = filter2(fspecial('gaussian', 5, 0.01), R);
G6 = filter2(fspecial('gaussian', 5, 0.01), G);
B6 = filter2(fspecial('gaussian', 5, 0.01), B);

img_watermark8 = cat(3, R1, G1, B1);
img_watermark9 = cat(3, R2, G2, B2);
img_watermark10 = cat(3, R3, G3, B3);
img_watermark11 = cat(3, R4, G4, B4);
img_watermark12 = cat(3, R5, G5, B5);
img_watermark13 = cat(3, R5, G5, B5);

watermark_pick8 = PickWatermark(img_watermark8, alpha);
watermark_pick9 = PickWatermark(img_watermark9, alpha);
watermark_pick10 = PickWatermark(img_watermark10, alpha);
watermark_pick11 = PickWatermark(img_watermark11, alpha);
watermark_pick12 = PickWatermark(img_watermark12, alpha);
watermark_pick13 = PickWatermark(img_watermark13, alpha);

img_watermark14 = img_watermark;
img_watermark15 = img_watermark;
img_watermark14(1:128, 1:128, :) = 0;
img_watermark15(1:256, 1:128, :) = 0;
watermark_pick14 = PickWatermark(img_watermark14, alpha);
watermark_pick15 = PickWatermark(img_watermark15, alpha);

txData = DataForm(img_watermark);
tximage = img_watermark;
img_rec = DataDisForm(txData, tximage);
img_watermark16 = img_rec;
watermark_pick16 = PickWatermark(img_watermark16, alpha);

% subplot(441)
% imshow(watermark_pick1)
% title('无攻击');
% subplot(442)
% imshow(watermark_pick2)
% title('亮度调节(+4)');
% subplot(443)
% imshow(watermark_pick3)
% title('亮度调节(-4)');
% subplot(444)
% imshow(watermark_pick4)
% title('高斯噪声(σ=0.01)');
% subplot(445)
% imshow(watermark_pick5)
% title('高斯噪声(σ=0.02)');
% subplot(446)
% imshow(watermark_pick6)
% title('均值噪声(σ=0.01)');
% subplot(447)
% imshow(watermark_pick7)
% title('均值噪声(σ=0.03)');
% subplot(448)
% imshow(watermark_pick8)
% title('中值滤波(3×3)');
% subplot(449)
% imshow(watermark_pick9)
% title('中值滤波(5×5)');
% subplot(4, 4, 10)
% imshow(watermark_pick10)
% title('均值滤波(3×3)');
% subplot(4, 4, 11)
% imshow(watermark_pick11)
% title('均值滤波(5×5)');
% subplot(4, 4, 12)
% imshow(watermark_pick12)
% title('高斯滤波(3×3)');
% subplot(4, 4, 13)
% imshow(watermark_pick13)
% title('高斯滤波(5×5)');
% subplot(4, 4, 14)
% imshow(watermark_pick14)
% title('裁剪攻击(1/16)');
% subplot(4, 4, 15)
% imshow(watermark_pick15)
% title('裁剪攻击(1/8)');
% subplot(4, 4, 16)
% imshow(watermark_pick16)
% title('JPEG压缩');

% subplot(441)
% imshow(watermark_pick1)
% title('无攻击');
subplot(531)
imshow(watermark_pick2)
title('亮度调节(+4)');
subplot(532)
imshow(watermark_pick3)
title('亮度调节(-4)');
subplot(533)
imshow(watermark_pick4)
title('高斯噪声(σ=0.01)');
subplot(534)
imshow(watermark_pick5)
title('高斯噪声(σ=0.02)');
subplot(535)
imshow(watermark_pick6)
title('均值噪声(σ=0.01)');
subplot(536)
imshow(watermark_pick7)
title('均值噪声(σ=0.03)');
subplot(537)
imshow(watermark_pick8)
title('中值滤波(3×3)');
subplot(538)
imshow(watermark_pick9)
title('中值滤波(5×5)');
subplot(539)
imshow(watermark_pick10)
title('均值滤波(3×3)');
subplot(5, 3, 10)
imshow(watermark_pick11)
title('均值滤波(5×5)');
subplot(5, 3, 11)
imshow(watermark_pick12)
title('高斯滤波(3×3)');
subplot(5, 3, 12)
imshow(watermark_pick13)
title('高斯滤波(5×5)');
subplot(5, 3, 13)
imshow(watermark_pick14)
title('裁剪攻击(1/16)');
subplot(5, 3, 14)
imshow(watermark_pick15)
title('裁剪攻击(1/8)');
subplot(5, 3, 15)
imshow(watermark_pick16)
title('JPEG压缩');

NC = NCCalc(realwatermark, watermark_pick1)
NC = NCCalc(realwatermark, watermark_pick2)
NC = NCCalc(realwatermark, watermark_pick3)
NC = NCCalc(realwatermark, watermark_pick4)
NC = NCCalc(realwatermark, watermark_pick5)
NC = NCCalc(realwatermark, watermark_pick6)
NC = NCCalc(realwatermark, watermark_pick7)
NC = NCCalc(realwatermark, watermark_pick8)
NC = NCCalc(realwatermark, watermark_pick9)
NC = NCCalc(realwatermark, watermark_pick10)
NC = NCCalc(realwatermark, watermark_pick11)
NC = NCCalc(realwatermark, watermark_pick12)
NC = NCCalc(realwatermark, watermark_pick13)
NC = NCCalc(realwatermark, watermark_pick14)
NC = NCCalc(realwatermark, watermark_pick15)
NC = NCCalc(realwatermark, watermark_pick16)
