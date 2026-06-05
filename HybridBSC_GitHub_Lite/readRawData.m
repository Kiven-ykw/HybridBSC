function rawData = readRawData(filename)
    fileId = fopen(filename, 'rb');

    if fileId == -1
        error('File cannot be opened: %s', filename);
    end

    rawData = fread(fileId, inf, '*uint8');
    fclose(fileId);
end
