function dataout = SequenceDepend(datain)
    % datain：输入数据

    % dataout：输出数据

    Sequence = datain(1, :);

    dataout = [];
    maxsequence = max(Sequence);

    for i = 0:maxsequence

        for j = 1:maxsequence + 1

            if (datain(1, j) == i)

                if (datain(1, j) == 0)
                    dataout = [dataout; datain(10:end, j)];
                else
                    dataout = [dataout; datain(2:end, j)];
                end

            end

        end

    end

end
