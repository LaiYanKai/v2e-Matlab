classdef EventInfo
    properties
        Options {mustBeA(Options, "EventOptions")} = EventOptions
        Frames = zeros(0,0,0) % original video, grayscaled
        Async {mustBeA(Async, "uint32")} = zeros(4,0,'uint32') % 4x(num. events). Row 1 are timestamps in microseconds. Row 2 contain y coordinates. Row 3 contain x. Row 4: 0 for OFF, 1 for ON.
        
    end
    methods
        function E = EventInfo(options, frames, eventsAsync)
            E.Options = options;
            E.Frames = frames;
            E.Async = eventsAsync;
        end
    end
end

