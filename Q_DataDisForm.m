function image = Q_DataDisForm(Q, datacode, originalimage)
    % data：输入数据流

    % image：输出图片

    size_img = size(originalimage);
    row = size_img(1);
    col = size_img(2);

    data = Q_JPEGEncode(Q, originalimage);
    len = length(data);
    uniquedata = unique(data);

    for i = 1:length(uniquedata)
        num(i, 1) = length(find(data == uniquedata(i, 1)));
        p(1, i) = num(i, 1) / len;
    end

    dict = huffmandict(uniquedata, p);

    data = huffmandeco(datacode, dict);

    % dataout = RLCDecode(data);
    image = Q_JPEGDecode(Q, data, row, col);

end
