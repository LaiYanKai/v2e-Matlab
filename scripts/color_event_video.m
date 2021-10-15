function Vout = color_event_video(Vin, customColormap)
    mustBeReal(customColormap);
    mustBeGreaterThanOrEqual(customColormap, 0);
    mustBeLessThanOrEqual(customColormap, 1);
    assert(size(customColormap, 2) == 3 && size(customColormap, 2) >= 2, "customColormap must be of size (n times 3), containing at least n=2 rows of RGB triplets [r,g,b] where r,g and b are between 0 and 1");
    mustBeReal(Vin)
    mustBeGreaterThanOrEqual(Vin, 0);
    mustBeLessThanOrEqual(Vin, 1);
    assert(numel(size(Vin)) == 3, "Vin must be a grayscale video of 3 dimensions (numX, numY, numF) with values in [0, 1]");
    
% customColormap must be {x>2}:3 long, with RGB triplet values in [0, 1]
% Vin is size (numX, numY, numF), with float/double values in [0, 1]
% too lazy to validate inputs
    progress_title("Adding color to grayscale video...")
    numX = size(Vin, 1);
    numY = size(Vin, 2);
    numF = size(Vin, 3);
    V = uint16((size(customColormap, 1)-1)*Vin + 1); % map grayscale video from double [0, 1] to uint16 [1, 256]
    Vout = zeros(numX, numY, 3, numF);
    for f = 1:numF
        for x = 1:numX
            for y = 1:numY
                v = V(x,y,f);
                Vout(x, y, 1, f) = customColormap(v, 1);
                Vout(x, y, 2, f) = customColormap(v, 2);
                Vout(x, y, 3, f) = customColormap(v, 3);
            end
        end
        progress(f/numF);
    end
    Vout = uint8(round(255*Vout));
end

