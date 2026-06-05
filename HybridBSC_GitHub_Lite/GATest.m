clc;
clear;
close all;

originalimage = imread("./TrainPic/Test/lena.tiff");
% peppers.tiff
% lena.tiff
% baboon.tiff
% airplane.tiff
% originalwatermark = imread("uestc.bmp");
% temp_test_1 = [[8.892086 2.5548177 2.6374872 1.5766894]
%                 [11.846643 7.109644 1.5175437 7.1242013]
%                 [10.710667 3.2525904 9.297316 4.42019]
%                 [5.325512 4.7994957 1.8940842 6.6524844]
%                 [5.09738 9.874977 13.429089 2.25565]
%                 [4.573896 3.8574762 1.6581953 4.460027]
%                 [8.59332 6.002548 8.963325 6.4220924]
%                 [9.972875 5.1412272 8.122083 7.9075556]
%                 [8.03007 9.211128 5.030007 6.824195]
%                 [7.588398 7.2953386 9.762885 2.0278094]
%                 [4.1039505 6.2196712 4.452737 5.9302087]
%                 [5.0736356 11.236098 6.5961647 3.5077233]
%                 [3.0948272 8.75057 3.7505405 5.84871]
%                 [7.2343664 5.710694 3.7123504 2.1045477]
%                 [11.376616 5.841233 7.662611 5.5186615]
%                 [0. 8.401035 5.7363653 7.9992776]];
% test = bin1(temp_test_1);
temp_test_1 = load('./data_1.txt');
temp1 = reshape(temp_test_1, 1, 784 * 4);
temp1_ones = randi([0, 1], 1, 480);
temp2_ones = randi([0, 1], 1, 480);
test = [temp1_ones temp1 temp2_ones];
test = reshape(test, 64, 64);
test_gray = mat2gray(test, [0 255]);
originalwatermark = gray2rgb(test_gray);
beta = 50;

NIND = 25;
MAXGEN = 100;
PRECI = 16;
GGAP = 0.95;
px = 0.7;
pm = 0.01;
N = 1;
trace = zeros(N + 1, MAXGEN);

FieldD = [repmat(PRECI, 1, N); repmat([5; 10], 1, N); repmat([1; 0; 1; 1], 1, N)];
Chrom = crtbp(NIND, PRECI * N);

gen = 0;
X = bs2rv(Chrom, FieldD);
ObjV = fitnessfun(originalimage, originalwatermark, X, beta);

while gen < MAXGEN
    fprintf('%d\n', gen)
    FitnV = ranking(-ObjV);
    SelCh = select('sus', Chrom, FitnV, GGAP);
    SelCh = recombin('xovsp', SelCh, px);
    SelCh = mut(SelCh, pm);
    X = bs2rv(SelCh, FieldD);
    ObjVSel = fitnessfun(originalimage, originalwatermark, X, beta);
    [Chrom, ObjV] = reins(Chrom, SelCh, 1, 1, ObjV, ObjVSel);
    X = bs2rv(Chrom, FieldD);
    gen = gen + 1;

    [Y, I] = max(ObjV);
    trace(1:N, gen) = X(I, :);
    trace(end, gen) = Y;
end

plot(1:MAXGEN, trace(end, :));
grid on
xlabel('遗传代数')
ylabel('性能变化')
title('进化过程')
bestY = trace(end, end);
bestX = trace(1:end - 1, end);
fprintf(['最优嵌入因子:\nX=', num2str(bestX'), '\n最优性能err=', num2str(bestY), '\n'])

function output = fitnessfun(originalimage, originalwatermark, alpha, beta)

    size_alpha = size(alpha);

    for i = 1:size_alpha(1)
        [img_watermark, realwatermark] = AddWatermark(originalimage, originalwatermark, alpha(i, :));
        PSNR = PSNRCalc(originalimage, img_watermark);
        watermark_pick = PickWatermark(img_watermark, alpha(i, :));
        NC = NCCalc(realwatermark, watermark_pick);
        output(i, 1) = PSNR + beta * NC;
    end

end
