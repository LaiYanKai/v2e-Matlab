function eventInfo = generate_events(options)
    mustBeA(options, "EventOptions");
    progress_title("Getting video...")
    in = VideoReader(options.InputPath);
    in = read(in);
    numX = size(in, 1);
    numY = size(in, 2);
    numF = size(in, 4);
    progress(1);

    % grayscale video
    progress_title("Grayscaling...")
    Vin = zeros(numX, numY, numF, 'uint8');
    for f = 1:numF
       Vin(:,:,f) = rgb2gray(in(:,:,:,f)); % grayscale
    end
    clear v
    progress(1);
    
    % get lin-log mapping (lookup table) of px luma to log luma (input voltage across lpf)
    LinLogMap = log(0:255);
    cache_ = LinLogMap(options.LinLogCutoff+1) / options.LinLogCutoff;
    for i = 0:options.LinLogCutoff
        LinLogMap(i+1) = cache_*i;
    end
%     % plot log mapping vs lin-log
%     latexfig("LinLog", [300, 300, 480, 240])
%     plot(0:255, log(0:255), 'o')
%     hold on
%     plot(0:255, LinLogMap, 'x')
%     hold off
%     legend(["log", "lin-log"], 'location', 'southeast')
%     xlim([0 options.LinLogCutoff+20])
%     grid on
%     title(['Log vs. Lin-log cutoff at ' num2str(options.LinLogCutoff) 'DP']);
%     latexexp("linlog");

    % event simulator parameter initialisations
    progress_title("Simulating Events...")
    tDiff = 1/options.FPS;
    LogMem = zeros(numX, numY);        
    % prepare first frame to prevent whiteout
    for x = 1:numX
       for y = 1:numY
           in = Vin(x,y,1);
           LogMem(x,y) = LinLogMap(in+1);
       end
    end
    LogCur = LogMem;

    memCap = 1000000;
    EventsAsync = zeros(4, memCap);
    e = 0;
    numE = memCap;
    tCurFrame = 0;
    
    % start event simulation
    if options.Noisy
        
        Th = normrnd(options.ThetaMean, options.ThetaStd, [numX, numY]); % generate different thresholds (small threshes are hot pixels)
        Th = max(Th, options.ThetaMin); % cutoff at theta_min
        LPFMinCutoff = options.LPFMinCutoffFraction * options.LPFMaxCutoff; % intercept to calc cutoff freq
        LPFCache_ = (options.LPFMaxCutoff - LPFMinCutoff) / 255; % gradient to calc cutoff freq
        shotCache_ = options.ShotNoiseRate * options.ShotNoiseReduction / 255 * tDiff;
        
        % LogCur copied from LogMem
        for f = 2:numF
            tPrevFrame = tCurFrame;
            tCurFrame = (f-1)*tDiff;
            for x = 1:numX
                for y = 1:numY
                    in = Vin(x,y,f); % pixel luma
                    logIn = LinLogMap(in+1); % get lin-log mapping to luma
                    theta = Th(x, y);

                    LPFCutoff = LPFCache_*double(in) + LPFMinCutoff; % get passive (inf imp.) lpf BW based on px luma
                    LPFForget = 2*pi*LPFCutoff / (2*pi*LPFCutoff + options.FPS); % calc resulting forgetting factor for lpf
                    prevLog = LogCur(x,y);
                    curLog = LPFForget*logIn + (1-LPFForget)*prevLog; % get resulting low pass filtered log luma
                    curLog = curLog + options.LeakNoiseRate / theta * tDiff;
                    LogCur(x,y) = curLog;

                    tPrev = tPrevFrame;
                    % regardless of shot noise
                    logDiffMem = curLog - LogMem(x, y);
                    if abs(logDiffMem) > theta 
                        % exceeded threshold ==> events identified
                        numEvents = logDiffMem / theta; % floor before adding to memory
                        if abs(round(numEvents) - numEvents) < 1e-6 % prevent rounding errors
                            numEvents = round(numEvents);
                        end
                        absEvents = abs(numEvents);
                        sgnEvents = sign(numEvents);
                        eventType = numEvents > 0;
                        logGrad = (curLog - prevLog) / (tCurFrame - tPrev);
                        for ee = sgnEvents*(1:absEvents) % interpolate
                            resetLog = LogMem(x, y) + ee*theta;
                            diff = (resetLog - prevLog) / logGrad;
                            t = tPrev + diff;
                            if (diff < 0)
                                disp("hi")
                            end
                            e = e + 1;
                            if (e > numE); EventsAsync = [EventsAsync, zeros(4,memCap)]; numE = numE + memCap; end
                            EventsAsync(1,e) = t;
                            EventsAsync(2,e) = y;
                            EventsAsync(3,e) = x;
                            EventsAsync(4,e) = eventType;
                        end
                        LogMem(x, y) = LogMem(x, y) + fix(numEvents) * theta; % memorise cur log out;
                    else % get shot noise if no threshold increase
                        shotNoiseProb = shotCache_ * double(255 - in); % p in Sec. 4G
                        shotNoiseRand = rand;
                        
                        if shotNoiseRand < shotNoiseProb
                            tPrev = rand()*tDiff + tPrevFrame;
                            % shot noise off event generated
                            e = e + 1;
                            if (e > numE); EventsAsync = [EventsAsync, zeros(4,memCap)]; numE = numE + memCap; end
                            EventsAsync(1,e) = tPrev;
                            EventsAsync(2,e) = y;
                            EventsAsync(3,e) = x;
                            EventsAsync(4,e) = 0;
                            LogMem(x,y) = LogMem(x, y) - theta;
                            LogCur(x,y) = LogMem(x,y); % to prevent 0 gradient situations
                        elseif shotNoiseRand > (1-shotNoiseProb)
                            tPrev = rand()*tDiff + tPrevFrame;
                            % shot noise on event generated
                             % place it randomly at some time betw prev and cur asynchronously
                            e = e + 1;
                            if (e > numE); EventsAsync = [EventsAsync, zeros(4,memCap)]; numE = numE + memCap; end
                            EventsAsync(1,e) = tPrev;
                            EventsAsync(2,e) = y;
                            EventsAsync(3,e) = x;
                            EventsAsync(4,e) = 1;
                            LogMem(x,y) = LogMem(x,y) - theta;
                            LogCur(x,y) = LogMem(x,y); % to prevent 0 gradient situations
                        end
                    end
                end
            end
            progress(f/numF);
        end
    else % is clean
        theta = options.ThetaMean;
        for f = 2:numF
            tPrevFrame = tCurFrame;
            tCurFrame = (f-1)*tDiff;
            for x = 1:numX
                for y = 1:numY
                    in = Vin(x,y,f); % pixel luma
                    curLog = LinLogMap(in+1); % get lin-log mapping to luma
                    prevLog = LogCur(x,y);
                    LogCur(x,y) = curLog;
                    logDiffMem = curLog - LogMem(x, y);
                    
                    if abs(logDiffMem) > theta 
                        % exceeded threshold ==> events identified
                        numEvents = logDiffMem / theta; % floor before adding to memory
                        if abs(round(numEvents) - numEvents) < 1e-6 % prevent rounding errors
                            numEvents = round(numEvents);
                        end
                        absEvents = abs(numEvents);
                        eventType = numEvents > 0;
                        sgnEvents = sign(numEvents);
                        logGrad = (curLog - prevLog) / tDiff;
                        for ee = sgnEvents*(1:absEvents) % interpolate
                            resetLog = LogMem(x, y) + ee*theta;
                            diff = (resetLog - prevLog) / logGrad;
                            t = tPrevFrame + diff;
%                             if (isnan(t))
%                                 disp('h');
%                             end
                            e = e + 1;
                            if (e > numE); EventsAsync = [EventsAsync, zeros(4,memCap)]; numE = numE + memCap; end
                            EventsAsync(1,e) = t;
                            EventsAsync(2,e) = y;
                            EventsAsync(3,e) = x;
                            EventsAsync(4,e) = eventType;
                        end
                        LogMem(x, y) = LogMem(x, y) + fix(numEvents) * theta; % memorise cur log out;
                    end
                end
            end
            progress(f/numF);
        end
    end
    % sort by time
    progress_title("Sorting Events...")
    EventsAsync = EventsAsync(:, 1:e);
    [~, I] = sort(EventsAsync(1, :));
    EventsAsync = EventsAsync(:, I);
    
    % convert to appropriate type
    EventsAsync(1, :) = EventsAsync(1, :)*1e6; % convert to microsec
    EventsAsync = uint32(round(EventsAsync));
    progress(1);
    
    eventInfo = EventInfo(options, Vin, EventsAsync);
%     % adjust video (contrast)
%     eventsMin = min(EventsPerFrame, [], 'all'); % always non +ve
%     eventsMax = max(EventsPerFrame, [], 'all'); % always non -ve
%     eventsRadius = max(abs(eventsMin), abs(eventsMax));
%     V = (EventsPerFrame * options.OutputContrast) / eventsRadius / 2 + 0.5; % normalise to [-0.5, 0.5] and add to centralise 0 counts at gray (0.5)
%     V = max(V, 0); % cutoff -ve values at 0
%     V = min(V, 1); % cap +ve values at 1
%     
%     % expose for ff frames (gather all events in ff frames)
%     if options.OutputExposedFrames > 1
%         progress_title(['Create every ' num2str(options.OutputExposedFrames) ' frames in exposed event video...'])
%         numFF = floor(numF / options.OutputExposedFrames);
%         EventsExposed = zeros(numX, numY, numFF);
%         for ff = 1:numFF
%             for g = ((ff-1)*options.OutputExposedFrames+1):(ff*options.OutputExposedFrames)
%                EventsExposed(:,:,ff) = EventsExposed(:,:,ff) + EventsPerFrame(:,:,g); % gather counts
%             end
%             progress(ff/numFF)
%         end
%         % adjust video (contrast)
%         eventsMin = min(EventsExposed, [], 'all'); % always non +ve
%         eventsMax = max(EventsExposed, [], 'all'); % always non -ve
%         eventsRadius = max(abs(eventsMin), abs(eventsMax));
%         VExp = (EventsExposed * options.OutputContrast) / eventsRadius / 2 + 0.5;
%         VExp = max(VExp, 0);
%         VExp = min(VExp, 1);
%     else
%         VExp = zeros(0, 0, 0);
%     end
    
end