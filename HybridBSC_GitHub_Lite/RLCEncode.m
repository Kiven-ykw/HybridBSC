function datacode = RLCEncode(data)
    % data：输入数据(列向量)

    % code：输出编码

    [len, ~] = size(data);
    code(1, 1) = data(1, 1);
    code(1, 2) = 1;
    num = 1;

    for i = 2:len

        if (data(i, 1) == data(i - 1, 1))

            if (code(num, 2) >= 255)
                num = num + 1;
                code(num, 1) = data(i, 1);
                code(num, 2) = 1;
            else
                code(num, 2) = code(num, 2) + 1;
            end

        else
            num = num + 1;
            code(num, 1) = data(i, 1);
            code(num, 2) = 1;
        end

    end

    code = code';
    datacode = code(:);

end
