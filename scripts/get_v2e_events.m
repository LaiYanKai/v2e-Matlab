function eventInfo = get_v2e_events(inputH5Path)
    progress_title(strcat("Reading H5 file from ", inputH5Path, "..."));
    inE = h5read(inputH5Path, '/events'); % 1st row:time; 3:x; 2:y; 4:on/off
    inI = h5read(inputH5Path, '/frame_idx'); % cumulative num. events at end of frame
    inT = h5read(inputH5Path, '/frame_ts'); % frame time, used by /events to index events
    inF = h5read(inputH5Path, '/frame'); % the original video
    progress(1);
    
    % parameter initialisations
    numX = size(inF, 2);
    numY = size(inF, 1);
    numF = size(inF, 3);

    % for each frame, associate the events
    progress_title('Gathering Events...')
    EventsAsync = inE;
    EventsAsync(2:3, :) = EventsAsync(2:3, :) + 1;
    EventTypes = double(EventsAsync(4,:))*2 - 1; % map uint32 [0, 1] to double [-1, 1]
    EventsPerFrame = zeros(numX, numY, numF);
    prev_e = 1;
    for f = 1:numF
        cur_e = inI(f);
        for e = prev_e:cur_e
            y = EventsAsync(2, e);
            x = EventsAsync(3, e);
            EventsPerFrame(x,y,f) = EventsPerFrame(x,y,f) + EventTypes(e);
        end
        prev_e = cur_e + 1;
    end
    
    options = EventOptions;
    options.FPS = round(1e6/double(inT(end))*(numel(inT)-1));
    options.InputPath = inputH5Path; 
    options.LinLogCutoff = NaN;
    options.ThetaMean = NaN;
    options.ThetaStd = NaN;
    options.ThetaMin = NaN;
    options.ShotNoiseRate = NaN;
    options.ShotNoiseReduction = NaN;
    options.LeakNoiseRate = NaN;
    options.LPFMaxCutoff = NaN;
    options.LPFMinCutoffFraction = NaN;
    options.Noisy = NaN;
    eventInfo = EventInfo(options, EventsPerFrame, EventsAsync);
end