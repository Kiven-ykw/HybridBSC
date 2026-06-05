function img_w = func_watermark1(img)
    temp_test_1 = load('.\data_1.txt');
    temp1 = reshape(temp_test_1, 1, 784 * 4);
    temp1_ones = randi([0, 1], 1, 480);
    temp2_ones = randi([0, 1], 1, 480);
    test = [temp1_ones temp1 temp2_ones];
    test = reshape(test, 64, 64);

    test_gray = mat2gray(test, [0 255]);
    watermark = gray2rgb(test_gray);

    alpha = 14;
    [img_w, realwatermark] = AddWatermark(img, watermark, alpha);
end
