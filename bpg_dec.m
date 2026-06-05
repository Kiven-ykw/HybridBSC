function bpg_dec(input_image, output_image)
    % input_image: 输入的图像文件名
    % bpp: 压缩比
    % output_image: 输出的图像文件名

    decompress_cmd = sprintf('.\\bpg\\bpgdec -o %s %s', output_image, input_image);
    [status, cmdout] = system(decompress_cmd);

    if status ~= 0
        error('解压缩图像失败：%s', cmdout);
    end

end
