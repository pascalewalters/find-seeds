classdef Frame < handle
    % Represents one CBCT projection
    % Note: .png files must already exist with adjusted contrast
    % (ProjectionSet.convertFramesToPng must be run)
    
    properties
        Seq % Index of the projection
        DeltaMs % Time elapsed since first projection
        HasPixelFactor % Boolean
        PixelFactor
        GantryAngle
        kVAngle
        Exposed % Boolean
        MVOn % Boolean
        UCentre
        VCentre
        Inactive % Boolean
        Path % Not used
        ContrastPath % Absolute path to the .png file of the projection with adjusted contrast
        RedSeed % Vector representing the position of the coordinates of the red seed in pixels
        BlueSeed % Vector representing the position of the coordinates of the blue seed in pixels
        YellowSeed % Vector representing the position of the coordinates of the yellow seed in pixels
        GreenSeed % Vector representing the position of the coordinates of the green seed in pixels
    end
    
    methods
        function obj = Frame(st, ProjectionSet)
            % Constructor
            obj.Seq = st.Children(2).Children.Data;
            obj.DeltaMs = str2double(st.Children(4).Children.Data);
            obj.HasPixelFactor = st.Children(6).Children.Data;
            obj.PixelFactor = str2double(st.Children(8).Children.Data);
            obj.GantryAngle = str2double(st.Children(10).Children.Data);
            obj.kVAngle = obj.GantryAngle + 90;
            obj.Exposed = st.Children(12).Children.Data;
            obj.MVOn = st.Children(14).Children.Data;
            obj.UCentre = str2double(st.Children(16).Children.Data);
            obj.VCentre = str2double(st.Children(18).Children.Data);
            obj.Inactive = st.Children(20).Children.Data;
            
            obj.Path = setPath(obj.Seq, ProjectionSet);
            obj.ContrastPath = setContrastPath(obj.Seq, ProjectionSet);
        end
        
        function showFrame(obj)
            % Display the image of the projection
            if exist(obj.ContrastPath, 'file')
                imshow(obj.ContrastPath)
            elseif exist(obj.Path, 'file')
                imshow(obj.Path)
            else
                fprintf('Frame does not exist');
            end
        end
        
        function [redSeed, blueSeed, yellowSeed, greenSeed] = findSeeds(obj, ps)
            % Find the seeds on the projection
            
            % TODO: find out if these are required
            absLat = str2double(ps.Image.AbsoluteTableLatPosIEC1217_MM);
            absLong = str2double(ps.Image.AbsoluteTableLongPosIEC1217_MM);
            
            % The rectangle that contains the four seeds
            % This may need to be changed if the script doesn't find four
            % seeds
            % rect = [342.5100  234.5100  120.9800   90.9800];
            rect = [335 220 120.98 90.98];
           
            % Read in the image with contrast adjusted
            im_adjust = imread(obj.ContrastPath);
            
            % Draw the rectangle on the projections
            % figure, hold on
            % imshow(im_adjust)
            % rectangle('Position', rect, 'EdgeColor', 'r');
            % hold off
            
            im_crop = imcrop(im_adjust, rect);
            im_seeds = findSeeds3(im_crop);
            [redSeed, blueSeed, yellowSeed, greenSeed] = processImage2(im_seeds, obj, rect, absLat, absLong);
        end
        
        function setSeedLocations(obj, redSeed, blueSeed, yellowSeed, greenSeed)
            % Set the positions of the four seeds
            
            obj.RedSeed = redSeed;
            obj.BlueSeed = blueSeed;
            obj.YellowSeed = yellowSeed;
            obj.GreenSeed = greenSeed;
        end
    end
end

function path = setPath(seq, ps)
% Not used
path = ps.Folder;
for i = 1:5 - length(seq)
    path = strcat(path, '0');
end
path = strcat(path, seq, '.', ps.Image.DicomUID, '.png');
end

function contrastPath = setContrastPath(seq, ps)
% Set the ContrastPath property
contrastPath = strcat(ps.Folder, 'Contrast\');

for i = 1:5 - length(seq)
    contrastPath = strcat(contrastPath, '0');
end
contrastPath = strcat(contrastPath, seq, '.', ps.Image.DicomUID, '.png');
end