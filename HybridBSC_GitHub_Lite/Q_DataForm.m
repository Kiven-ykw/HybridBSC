function databits = Q_DataForm(Q, image)
    % image：输入图片

    % databit：输出数据比特流
    % coderate：压缩比

    data = Q_JPEGEncode(Q, image);
    % data = RLCEncode(datain);

    len = length(data);
    uniquedata = unique(data);

    for i = 1:length(uniquedata)
        num(i, 1) = length(find(data == uniquedata(i, 1)));
        p(1, i) = num(i, 1) / len;
    end

    dict = huffmandict(uniquedata, p);
    datacode = huffmanenco(data, dict);

    len = reshape(de2bi(length(datacode), 32), [], 1);
    databits = datacode;

end
