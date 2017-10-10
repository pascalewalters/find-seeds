function [redSeed, blueSeed, yellowSeed, greenSeed] = processImage2(im_seeds, frame, rect, absLat, absLong)
% Find the seeds from the projection image

% Params:
%   im_seeds: binary image after processing by the findSeeds3 function
%   frame: Frame instance
%   rect: rectangle that surrounds the four seeds
%   absLat: absolute lateral position of the couch (TODO: determine
%       how this is used)
%   absLong: absolute longitudinal position of the couch (TODO: determine
%       how this is used)
% Returns:
%   vector containing the locations of the four seeds

% Find the centroids and areas of the four seeds
s = regionprops(im_seeds, 'Centroid', 'Area');

plotCentroids = [];

if ~isempty(s)
    % Ignore shapes that have an area smaller than 2 pixels
    for j = 1:length(s)
        if s(j).Area > 2
            % Add the rectange back on to have the seed position from the
            % whole projection image
            temp = cat(2, s(j).Centroid(1) + rect(1), s(j).Centroid(2) + rect(2));
            plotCentroids = cat(1, plotCentroids, temp);
        end
    end
   
    % Only use frames that have four seeds
    if length(plotCentroids) == 4
        % Sort seed coordinates by their x value
        sortedByX = sortrows(plotCentroids);

        % seedColumn1 contains the coordinates of the 2 seeds
        % furthest to the left
        % seedColumn2 contains the coordinates of the 2 seeds
        % furthest to the right
        seedColumn1 = cat(1, sortedByX(1,:), sortedByX(2,:));
        seedColumn2 = cat(1, sortedByX(3,:), sortedByX(4,:));

        % Sort each seedColumn by their y values
        [~,a] = sort(seedColumn1(:,2));
        [~,b] = sort(seedColumn2(:,2));

        sortedSeedCoords = cat(1, seedColumn1(a,:), seedColumn2(b,:));

        % Flip the seed orientation when the kV imager is below horizontal
        if frame.kVAngle > -78 && frame.kVAngle < 80            
            redSeed = sortedSeedCoords(1,:);
            blueSeed = sortedSeedCoords(2,:);
            yellowSeed = sortedSeedCoords(3,:);
            greenSeed = sortedSeedCoords(4,:);
        else
            redSeed = sortedSeedCoords(3,:);
            blueSeed = sortedSeedCoords(4,:);
            yellowSeed = sortedSeedCoords(1,:);
            greenSeed = sortedSeedCoords(2,:);
        end
        
    else
        redSeed = [];
        blueSeed = [];
        yellowSeed = [];
        greenSeed = [];
    end
    
else
    redSeed = [];
    blueSeed = [];
    yellowSeed = [];
    greenSeed = [];
end

end

