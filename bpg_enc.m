function bpg_enc(input_image, bpp, output_image)
    % input_image: 输入的图像文件名
    % bpp: 压缩比
    % output_image: 输出的图像文件名

    param = sprintf('-q %d', bpp);

    compress_cmd = sprintf('.\\bpg\\bpgenc %s %s -o %s', param, input_image, output_image);
    [status, cmdout] = system(compress_cmd);

    if status ~= 0
        error('压缩图像失败：%s', cmdout);
    end

end
