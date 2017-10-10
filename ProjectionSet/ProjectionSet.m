classdef ProjectionSet < handle
   properties
      Station
      Patient
      Treatment
      Field
      Image
      Frames % Array of Frame objects
      Date % Date of the images
      Folder % Name of the directory of the scan
      Seeds % Array of seed positions
      SeedSeq % Vector of frame indices that contain four seeds
   end
   
   methods
       function obj = ProjectionSet(xmlPath)
           % Constructor
           st = parseXML(xmlPath);
           
           obj.Folder = xmlPath(1:length(xmlPath) - 11);
           obj.Station = Station(st.Children(4)); % Station struct
           obj.Patient = Patient(st.Children(6)); % Patient struct
           obj.Treatment = Treatment(st.Children(8)); % Treatment struct
           obj.Field = Field(st.Children(10)); % Field struct
           obj.Image = Image(st.Children(12)); % Image struct
           obj.Frames = setFrames(st.Children(14), obj); % Frames
           obj.Date = setDate(obj);
       end
       
       function time = scanTime(obj)
          % Return the time taken for the entire scan
          time = obj.Frames(length(obj.Frames)).DeltaMs; 
       end
       
       function plotGantry(obj)
           % Plot the gantry angle as a function of frame index
           seq = [];
           gantry = [];
           
           for i = 1:length(obj.Frames)
              seq = cat(2, seq, str2double(obj.Frames(i).Seq));
              gantry = cat(2, gantry, obj.Frames(i).GantryAngle);
           end
           
           figure
           plot(seq, gantry);
           hold on
           ylabel('Gantry Angle (degrees)');
           title('Gantry Angle');
       end
       
       function convertFramesToPng(obj)
           % Convert .his files to .png with the contrast adjusted
           addpath('readHISfile')
           hisFiles = dir(strcat(obj.Folder, '*.his'));
           if ~exist(fullfile(obj.Folder, 'Contrast'), 'dir')
               mkdir(obj.Folder, 'Contrast')
           end
           
           for hisFile = hisFiles'               
               fileName = strcat(obj.Folder, '\', hisFile.name);
               im = readHISfile(fileName);
               image_seq = str2double(hisFile.name(1:5));
               contrastIm = adjustContrast(obj, im, image_seq);
               
               contrastPath = fullfile(obj.Folder, 'Contrast', strcat(hisFile.name(1:length(hisFile.name) - 4), '.png'));
               imwrite(contrastIm, contrastPath);
           end
       end

       function findSeeds(obj)
           % Find the four seeds on each frame
           redSeeds = [];
           blueSeeds = [];
           yellowSeeds = [];
           greenSeeds = [];
           seq = [];
           
           for i = 1:length(obj.Frames)  
               % Ignore projections that are +/- 15 degrees from horizontal
               % (too many imaging artefacts)
               if (obj.Frames(i).kVAngle < 75 && obj.Frames(i).kVAngle > -75) || ...
                       obj.Frames(i).kVAngle < -105 || obj.Frames(i).kVAngle > 105
                   
                   [redSeed, blueSeed, yellowSeed, greenSeed] = obj.Frames(i).findSeeds(obj);
                   
                   if ~isempty(redSeed)
                       redSeeds = cat(1, redSeeds, cat(2, obj.Frames(i).kVAngle, redSeed));
                       blueSeeds = cat(1, blueSeeds, cat(2, obj.Frames(i).kVAngle, blueSeed));
                       yellowSeeds = cat(1, yellowSeeds, cat(2, obj.Frames(i).kVAngle, yellowSeed));
                       greenSeeds = cat(1, greenSeeds, cat(2, obj.Frames(i).kVAngle, greenSeed));
                       seq = cat(1, seq, str2double(obj.Frames(i).Seq));
                       obj.Frames(i).setSeedLocations(redSeed, blueSeed, yellowSeed, greenSeed);
                       
                       % View the four seeds on all frames
                       % figure
                       % imshow(obj.Frames(i).ContrastPath)
                       % hold on
                       % plot(obj.Frames(i).RedSeed(1),obj.Frames(i).RedSeed(2), 'r*')
                       % plot(obj.Frames(i).BlueSeed(1),obj.Frames(i).BlueSeed(2), 'b*')
                       % plot(obj.Frames(i).YellowSeed(1),obj.Frames(i).YellowSeed(2), 'y*')
                       % plot(obj.Frames(i).GreenSeed(1),obj.Frames(i).GreenSeed(2), 'g*')
                       % hold off

                   end
               end
           end
           
           obj.Seeds = cat(3, redSeeds, blueSeeds, yellowSeeds, greenSeeds);
           obj.SeedSeq = seq;
       end
   end
end

function frames = setFrames(st, ProjectionSet)
% Set the Frames property as a vector of Frame instances
frames = [];
for k = 2:2:length(st.Children)   
    frame = Frame(st.Children(k), ProjectionSet);
    frames = cat(2, frames, frame);
end
end

function date = setDate(ProjectionSet)
% Set the date of the imaging session
file = fullfile(ProjectionSet.Folder, strcat('00001.', ProjectionSet.Image.DicomUID, '.his'));
d = dir(file);
date = datetime(d.date, 'InputFormat', 'dd-MMMM-yyyy HH:mm:ss');
end

function contrastIm = adjustContrast(ProjectionSet, im, image_seq)
% Adjust the contrast of each frame so that the seeds are visible
load('C:\Users\pwalters\Documents\MATLAB\lowContrastFit.mat');
load('C:\Users\pwalters\Documents\MATLAB\highContrastFit.mat');

contrastIm = imadjust(im, ...
    [f1(ProjectionSet.Frames(image_seq).kVAngle) f2(ProjectionSet.Frames(image_seq).kVAngle)], [0 1]);
end