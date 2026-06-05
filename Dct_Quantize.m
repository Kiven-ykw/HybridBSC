function Matrix_out = Dct_Quantize(Matrix_in, Qua_Factor, Qua_Table)

    % Matrix_in：输入矩阵
    % Qua_Factor: 量化因子
    % Qua_Table：量化表

    % Matrix_out：量化后的矩阵

    Matrix_in = double(Matrix_in) - 128;
    Matrix_in = blkproc(Matrix_in, [8 8], 'dct2(x)');
    Qua_Matrix = Qua_Factor .* Qua_Table;
    Matrix_in = blkproc(Matrix_in, [8 8], 'round(x./P1)', Qua_Matrix);
    Matrix_out = Matrix_in;
end
