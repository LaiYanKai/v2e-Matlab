%%% FOR THE DOT VIDEO %%%
%% Generate Video from v2e Events (Noisy)
init

%%%%%%%%%%%%%%%%%%%%%%%%%%%% USER PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputH5Path = "data/dot_v2e.h5";
outputPath = "data/dot_v2e.mp4"; % output must be avi to support custom colormaps
outputFrameDuration = 0; % put 0 to use all events (avoids aliasing from rounding errors in this value)
outputContrast = 1; % increase contrast to see more clearly. (1) is default.
outputColormap = eventVideoColormap; % color the event video. See next next section for info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate events
eventInfo = get_v2e_events(inputH5Path);
disp(strcat("Number of events = ", num2str(size(eventInfo.Async, 2))));
% generate grayscale event video
VGray = generate_event_video(eventInfo, outputFrameDuration, outputContrast);

% color video
VColor = color_event_video(VGray, outputColormap);
% export video if required
if strlength(outputPath) > 0
    export_video(outputPath, VColor)
end

% show videos
hGray = implay(VGray, 30);
hGray.Parent.Name = "Grayscale";
hColor = implay(VColor, 30);
hColor.Parent.Name = "Colorised";
%% Generate events from scratch (Noisy)
init

%%%%%%%%%%%%%%%%%%%%%%%%%%%% USER PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputPath = "data/dot.mp4";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = EventOptions; % parameter descriptions + default values in file
options.InputPath = inputPath;
options.FPS = 960;
disp("<strong>CA: Noisy Parameters used</strong>")
options.LinLogCutoff = 20;
options.ThetaMean = 0.3;
options.ThetaStd = 0.03;
options.ThetaMin = 0.01;
options.ShotNoiseRate = 1;
options.ShotNoiseReduction = 0.25;
options.LeakNoiseRate = 0.1;
options.LPFMaxCutoff = 200;
options.LPFMinCutoffFraction = 0.1;
options.Noisy = true;

% generate asynchronous events in E.Async
eventInfo = generate_events(options);
disp(strcat("Number of events = ", num2str(size(eventInfo.Async, 2))));
%% Visualise and Export the Event Videos from scratch (Noisy)
% make sure previous section was run
%%%%%%%%%%%%%%%%%%%%%%%%%%%% USER PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputPath = "data/dot_ca.mp4"; % leave blank to stop export of colored video
outputFrameDuration = 0; 
%     5
%     0 % put 0 to use all events (avoids aliasing from rounding errors in this value)
outputContrast = 3; % adjust the grayscale video to make events easier to see
outputColormap = eventVideoColormap; % add color to outputvideo
%     gray;
%     eventVideoColormap;
%     bone;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate grayscale event video
VGray = generate_event_video(eventInfo, outputFrameDuration, outputContrast);
% color video
VColor = color_event_video(VGray, outputColormap);
% export video if required
if strlength(outputPath) > 0
    export_video(outputPath, VColor)
end

% show videos
hGray = implay(VGray, 30);
hGray.Parent.Name = "Grayscale";
hColor = implay(VColor, 30);
hColor.Parent.Name = "Colorised";
%% Generate Video from v2e Events (Clean)
init

%%%%%%%%%%%%%%%%%%%%%%%%%%%% USER PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputH5Path = "data/dot_v2e_clean_thresh1.h5";
outputPath = "data/dot_v2e_clean_thresh1.mp4"; % output must be avi to support custom colormaps
outputFrameDuration = 0; % put 0 to use all events (avoids aliasing from rounding errors in this value)
outputContrast = 1; % increase contrast to see more clearly. (1) is default.
outputColormap = eventVideoColormap; % color the event video. See next next section for info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate events
eventInfo = get_v2e_events(inputH5Path);
disp(strcat("Number of events = ", num2str(size(eventInfo.Async, 2))));
% generate grayscale event video
VGray = generate_event_video(eventInfo, outputFrameDuration, outputContrast);
% color video
VColor = color_event_video(VGray, outputColormap);
% export video if required
if strlength(outputPath) > 0
    export_video(outputPath, VColor)
end

% show videos
hGray = implay(VGray, 30);
hGray.Parent.Name = "Grayscale";
hColor = implay(VColor, 30);
hColor.Parent.Name = "Colorised";
%% Generate events from scratch (Clean)
init

%%%%%%%%%%%%%%%%%%%%%%%%%%%% USER PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputPath = "data/dot.mp4";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = EventOptions; % parameter descriptions + default values in file
options.InputPath = inputPath;
options.FPS = 960;
disp("<strong>CA: Clean Parameters used</strong>")
options.LinLogCutoff = 20;
options.ThetaMean = 0.3;
options.Noisy = false;

% generate asynchronous events in E.Async
eventInfo = generate_events(options);
disp(strcat("Number of events = ", num2str(size(eventInfo.Async, 2))));
%% Visualise and Export the Event Videos from scratch (Clean)
% make sure previous section was run
%%%%%%%%%%%%%%%%%%%%%%%%%%%% USER PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputPath = "data/dot_ca_clean.mp4"; % leave blank to stop export of colored video
outputFrameDuration = 0; 
%     5
%     0 % put 0 to use all events (avoids aliasing from rounding errors in this value)
outputContrast = 1; % adjust the grayscale video to make events easier to see
outputColormap = eventVideoColormap; % add color to outputvideo
%     gray;
%     eventVideoColormap;
%     bone;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate grayscale event video
VGray = generate_event_video(eventInfo, outputFrameDuration, outputContrast);
% color video
VColor = color_event_video(VGray, outputColormap);
% export video if required
if strlength(outputPath) > 0
    export_video(outputPath, VColor)
end

% show videos
hGray = implay(VGray, 30);
hGray.Parent.Name = "Grayscale";
hColor = implay(VColor, 30);
hColor.Parent.Name = "Colorised";
%% Combine videos (src, noisy V2E, noisy CA)
init

%%%%%%%%%%%%%%%%%%%%%%%%%%%% USER PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputPath = "data/dot_comb.mp4";
inputSrcPath = "data/dot.mp4";
inputV2EPath = "data/dot_v2e.mp4";
inputCAPath = "data/dot_ca.mp4";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp("<strong>Combine source, noisy V2E and noisy CA videos</strong>")
inSrc = VideoReader(inputSrcPath);
inSrc = read(inSrc);
inV2E = VideoReader(inputV2EPath);
inV2E = read(inV2E);
inCA = VideoReader(inputCAPath);
inCA = read(inCA);

numF = min([size(inSrc, 4), size(inV2E, 4), size(inCA, 4)]); % vids amy not have same frames due to rounding errors
numX = size(inSrc, 1); % vids must have same height and width
numY = size(inSrc, 2); % vids must have same height and width
V = zeros(numX, 3*numY, 3, numF, 'uint8');
progress_title('Combining (Src, V2E, CA) videos...');
for f = 1:numF
    for c = 1:3
        fSrc = inSrc(:,:,c,f);
        fV2E = inV2E(:,:,c,f);
        fCA = inCA(:,:,c,f);
        if c == 2 % draw separator
            fSrc(:, end) = 1;
            fV2E(:, end) = 1;
        end
        V(:,:,c,f) = [fSrc, fV2E, fCA];
    end
    progress(f/numF);
end

% write Video
export_video(outputPath, V);
h = implay(V, 30);
h.Parent.Name = "Combined (Src, V2E, CA)";
%% Combine videos (Src, clean v2e, and clean CA)
init

%%%%%%%%%%%%%%%%%%%%%%%%%%%% USER PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputPath = "data/dot_comb_clean.mp4";
inputSrcPath = "data/dot.mp4";
inputV2EPath = "data/dot_v2e_clean.mp4";
inputCAPath = "data/dot_ca_clean.mp4";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp("<strong>Combine Src, clean V2E and clean CA videos</strong>")
inSrc = VideoReader(inputSrcPath);
inSrc = read(inSrc);
inV2E = VideoReader(inputV2EPath);
inV2E = read(inV2E);
inCA = VideoReader(inputCAPath);
inCA = read(inCA);

numF = min([size(inSrc, 4), size(inV2E, 4), size(inCA, 4)]); % vids amy not have same frames due to rounding errors
numX = size(inSrc, 1); % vids must have same height and width
numY = size(inSrc, 2); % vids must have same height and width
V = zeros(numX, 3*numY, 3, numF, 'uint8');
progress_title('Combining (Src, Clean V2E, Clean CA) videos...');
for f = 1:numF
    for c = 1:3
        fSrc = inSrc(:,:,c,f);
        fV2E = inV2E(:,:,c,f);
        fClean = inCA(:,:,c,f);
        if c == 2 % draw separator
            fSrc(:, end) = 1;
            fV2E(:, end) = 1;
        end
        V(:,:,c,f) = [fSrc, fV2E, fClean];
    end
    progress(f/numF);
end

% write Video
export_video(outputPath, V);
h = implay(V, 30);
h.Parent.Name = "Combined (Src, clean V2E, clean CA)";