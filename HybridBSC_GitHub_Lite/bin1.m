function temp_data_reshape = bin1(test)

    test = test * 1e7;

    binaryMatrix = arrayfun(@(x) dec2bin(x, max(ceil(log2(test(:))))), test, 'UniformOutput', false);

    binarySplitMatrix = cellfun(@(x) reshape(str2num(x')', 1, []), binaryMatrix, 'UniformOutput', false);

    binaryResultMatrix = cell2mat(binarySplitMatrix);

    temp_data = reshape(binaryResultMatrix, 28, 64);
    temp1_ones = randi([0, 1], 18, 64);
    temp2_ones = randi([0, 1], 18, 64);

    temp_data_reshape = [temp1_ones; temp_data; temp2_ones];
