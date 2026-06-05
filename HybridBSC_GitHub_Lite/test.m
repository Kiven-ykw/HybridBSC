num = [[8.892086 2.5548177 2.6374872 1.5766894]
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

num = num * 1e7;

binaryMatrix = arrayfun(@(x) dec2bin(x, max(ceil(log2(num(:))))), num, 'UniformOutput', false);

binarySplitMatrix = cellfun(@(x) reshape(str2num(x')', 1, []), binaryMatrix, 'UniformOutput', false);

binaryResultMatrix = cell2mat(binarySplitMatrix);

temp_data = reshape(binaryResultMatrix, 28, 64);
temp1_ones = ones(18, 64);
temp2_ones = ones(18, 64);

temp_data_reshape = [temp1_ones; temp_data; temp2_ones];

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

test2 - num * 1e-7
