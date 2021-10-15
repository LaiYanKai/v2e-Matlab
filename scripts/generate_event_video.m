function V = generate_event_video(eventInfo, outputFrameDuration, outputContrast)
    % outputFrameDuration is in milliseconds. Specifies the duration to gather asynchronous events in each frame in the output grayscale video V
    % outputContrast multiplies and caps video grayscale values to get better contrast
    % outputs a grayscale video of size (numX, numY, numF)
    
    % argument validation
    mustBeA(eventInfo, "EventInfo");
    mustBeReal(outputFrameDuration);    
    mustBeReal(outputContrast);
    
    progress_title("Gathering Events...")
    if outputFrameDuration == 0 % use all frames
        outputFrameDuration = 1e6/eventInfo.Options.FPS; % avoid rounding errors
    else
        outputFrameDuration = outputFrameDuration * 1e3; % convert to microsec
    end
    numE = size(eventInfo.Async, 2);
    t = outputFrameDuration + 1;
    EventTimes = double(eventInfo.Async(1, :));
    EventTypes = double(eventInfo.Async(4, :))*2 - 1; % map {0,1} to {-1,1}
    f = 2; % fill from frame 2 onwards, bcos frame 1 is used for init when generating events
    numX = size(eventInfo.Frames, 1);
    numY = size(eventInfo.Frames, 2);
    numF = ceil(EventTimes(end) / outputFrameDuration)+1;
    Events = zeros(numX, numY, numF);
    for e = 1:numE
        if EventTimes(e) >= t
            progress(f / numF);
            t = f * outputFrameDuration + 1;
            f = f + 1;
        end
        x = eventInfo.Async(3, e);
        y = eventInfo.Async(2, e);
        Events(x,y,f) = Events(x,y,f) + EventTypes(e);
    end
    progress(1);
    % adjust video (contrast)
    progress_title("Adjusting Grayscale Video Contrast...")
    eventsMin = min(Events, [], 'all'); % always non +ve
    eventsMax = max(Events, [], 'all'); % always non -ve
    eventsRadius = max(abs(eventsMin), abs(eventsMax));
    V = (Events * outputContrast) / eventsRadius / 2 + 0.5; % normalise to [-0.5, 0.5] and add to centralise 0 counts at gray (0.5)
    V = max(V, 0); % cutoff -ve values at 0
    V = min(V, 1); % cap +ve values at 1
    progress(1);
end