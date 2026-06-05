function saveRawData(rawData, newFilename)
    fileId = fopen(newFilename, 'wb');

    if fileId == -1
        error('File cannot be opened for writing: %s', newFilename);
    end

    fwrite(fileId, rawData, 'uint8');
    fclose(fileId);
end
