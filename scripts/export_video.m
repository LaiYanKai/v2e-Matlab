function export_video(outputPath, V)
    % V is a video of size (numX, numY, 3, numF)([0, 255]) or (numX, numY, numF)([0, 1])
    progress_title(strcat('Exporting "', outputPath, '"...'))
    out = VideoWriter(outputPath, 'MPEG-4');
    out.FrameRate = 30;
    out.Quality = 100;
    open(out)
    if numel(size(V)) == 3
        numF = size(V, 3);
        for f = 1:numF
            writeVideo(out, V(:,:,f))
            progress(f / numF);
        end
    else
        numF = size(V, 4);
        for f = 1:numF
            writeVideo(out, V(:,:,:,f))
            progress(f / numF);
        end
    end
    close(out)
end