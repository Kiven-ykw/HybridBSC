function img_arnoldrec_out = arnoldrec(img_in, num, a, b)
    IMG_current = img_in;
    h = size(img_in, 1);
    IMG_next_iter = zeros(h, h, class(img_in));

    for n = 1:num

        for y = 1:h

            for x = 1:h
                xx = mod((a * b + 1) * (x - 1) + (-b) * (y - 1), h) + 1;
                yy = mod((-a) * (x - 1) + (1) * (y - 1), h) + 1;
                IMG_next_iter(yy, xx) = IMG_current(y, x);
            end

        end

        IMG_current = IMG_next_iter;
    end

    img_arnoldrec_out = IMG_current;
end
