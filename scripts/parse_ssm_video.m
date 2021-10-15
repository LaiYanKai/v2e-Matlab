function V = parse_ssm_video(in_path, out_path, crop_rect, resize, adapt_contrast)
% converts the S21+ Super Slow Mo video into an appropraiate format
% in_path: input src video path
% out_path: output video path
% crop_rect: [x0, y0, x1, y1]; (x0, y0) < (x1, y1), are points to crop, inclusive.
% resize: [x, y], dimensions to resize to

    progress_title('Reading Vid...');
    v_src = VideoReader(in_path);
    v = read(v_src, [31, 510]); % frames 31 to 510 inclusive contain the 960fps vid
    progress(1)

    progress_title('Parsing Vid...');
    V = zeros(resize(1), resize(2), 480, 'uint8');
    for f = 1:480
        frame = v(:,:,:,f);
        frame = rgb2gray(frame); % grayscale
        frame = frame(crop_rect(1):crop_rect(3), crop_rect(2):crop_rect(4)); %frame((281:1000)-80, 1:720); % imcrop is very weird
        frame = imresize(frame, resize);
        if adapt_contrast
            frame = adapthisteq(frame);
        end
        V(:,:,f) = frame;
    end
    progress(1);
end

