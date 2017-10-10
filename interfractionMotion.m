% This script calculates the mean position of the four seeds in 3D for one
% imaging session. To run the script, change the values for xmlPath,
% filepath and row to the correct values.
% The script works best when it is able to find more than 100 projections
% that have four seeds each. If the length of ps.SeedSeq is less than 100,
% the area cropped may not be surrounding the four seeds. It can be changed
% in ProjectionSet/Frame.m/findSeeds

tic
addpath('ProjectionSet')

% Absolute path to the _Frames.xml file of the current projection set
xmlPath = 'C:\Users\pwalters\Documents\patient_11111529\IMAGES\img_1.3.46.423632.335322201752171147687.46\_Frames.xml';
% Absolute path to the Excel file where interfraction motion data is stored
filepath = 'C:\Users\pwalters\Documents\patient_11111529\patient_11111529_AllSeedLocations.xlsx';
% Row of the Excel file for the current imaging session
row = 'E33';

% Intialize the ProjectionSet instance and find the seeds
ps = ProjectionSet(xmlPath);
ps.convertFramesToPng()
ps.findSeeds();

% Pixel size at detector
detectorWidth = 40; % cm
pixelSizeDetector = detectorWidth / 512; % cm/px

% Determine the location of the seeds in 3D
redProjections = [];
blueProjections = [];
yellowProjections = [];
greenProjections = [];

figure, hold on

for i = 1:length(ps.SeedSeq)
    frame = ps.Frames(ps.SeedSeq(i));
    
    % Position of focal spot in the camera
    alpha = 100*[cos((90-frame.kVAngle)*pi/180) sin((90-frame.kVAngle)*pi/180) 0];
    % Position of the centre of the imaging panel
    gamma = 53.6*[cos((270-frame.kVAngle)*pi/180) sin((270-frame.kVAngle)*pi/180)];
    
    % Red Seed
    r_betaGamma_mag = (frame.RedSeed(1)*pixelSizeDetector)-(20+11.5);
    r_betaGamma = r_betaGamma_mag*[cos(frame.kVAngle*pi/180) -1*sin(frame.kVAngle*pi/180)];
    beta = gamma + r_betaGamma;
    beta = cat(2, beta, (frame.RedSeed(2)*pixelSizeDetector - 20));
    
    % Plot the 3D projection line
    line([alpha(3) beta(3)], [alpha(1) beta(1)], [alpha(2) beta(2)], 'Color', 'r')
    
    % Determine the equation of the back projection line from the seed on 
    % the imaging panel to the focus of the camera
    m = (alpha(2) - beta(2))/(alpha(1) - beta(1));
    b = -1*m*beta(1) + beta(2);
    A = [m b];
    redProjections = cat(1, redProjections, A);
    
    % Blue Seed    
    r_betaGamma_mag_blue = (frame.BlueSeed(1)*pixelSizeDetector)-(20+11.5);
    r_betaGamma_blue = r_betaGamma_mag_blue*[cos(frame.kVAngle*pi/180) -1*sin(frame.kVAngle*pi/180)];
    beta_blue = gamma + r_betaGamma_blue;
    beta_blue = cat(2, beta_blue, (frame.BlueSeed(2)*pixelSizeDetector - 20));
    
    line([alpha(3) beta_blue(3)], [alpha(1) beta_blue(1)], [alpha(2) beta_blue(2)], 'Color', 'b')
    
    m = (alpha(2) - beta_blue(2))/(alpha(1) - beta_blue(1));
    b = -1*m*beta_blue(1) + beta_blue(2);
    A = [m b];
    blueProjections = cat(1, blueProjections, A);
    
    % Yellow Seed    
    r_betaGamma_mag_yellow = (frame.YellowSeed(1)*pixelSizeDetector)-(20+11.5);
    r_betaGamma_yellow = r_betaGamma_mag_yellow*[cos(frame.kVAngle*pi/180) -1*sin(frame.kVAngle*pi/180)];
    beta_yellow = gamma + r_betaGamma_yellow;
    beta_yellow = cat(2, beta_yellow, (frame.YellowSeed(2)*pixelSizeDetector - 20));
    
    line([alpha(3) beta_yellow(3)], [alpha(1) beta_yellow(1)], [alpha(2) beta_blue(2)], 'Color', 'y')
   
    m = (alpha(2) - beta_yellow(2))/(alpha(1) - beta_yellow(1));
    b = -1*m*beta_yellow(1) + beta_yellow(2);
    A = [m b];
    yellowProjections = cat(1, yellowProjections, A);
    
    % Green Seed    
    r_betaGamma_mag_green = (frame.GreenSeed(1)*pixelSizeDetector)-(20+11.5);
    r_betaGamma_green = r_betaGamma_mag_green*[cos(frame.kVAngle*pi/180) -1*sin(frame.kVAngle*pi/180)];
    beta_green = gamma + r_betaGamma_green;
    beta_green = cat(2, beta_green, (frame.GreenSeed(2)*pixelSizeDetector - 20));
    
    line([alpha(3) beta_green(3)], [alpha(1) beta_green(1)], [alpha(2) beta_green(2)], 'Color', 'g')
    
    m = (alpha(2) - beta_green(2))/(alpha(1) - beta_green(1));
    b = -1*m*beta_green(1) + beta_green(2);
    A = [m b];
    greenProjections = cat(1, greenProjections, A);
end

xlabel('Superior-Inferior')
ylabel('Right-Left')
zlabel('Posterior-Anterior')
view(3)

redAllLR = [];
redAllAP = [];
redAllSI = [];

blueAllLR = [];
blueAllAP = [];
blueAllSI = [];

yellowAllLR = [];
yellowAllAP = [];
yellowAllSI = [];

greenAllLR = [];
greenAllAP = [];
greenAllSI = [];

figure, hold on

for i = 1:length(redProjections(:,1))
    seq = ps.SeedSeq(i);
    % Iterate through each pair of back projections to find where they
    % intersect in the transverse plane. This results in a pair of AP and
    % LR coordinates
    for j = (i + 1):length(redProjections(:,1))
        redLR = (redProjections(j,2) - redProjections(i,2)) / (redProjections(i,1) - redProjections(j,1));
        redAP = redProjections(i,1) * redLR + redProjections(i,2);
        
        blueLR = (blueProjections(j,2) - blueProjections(i,2)) / (blueProjections(i,1) - blueProjections(j,1));
        blueAP = blueProjections(i,1) * blueLR + blueProjections(i,2);
        
        yellowLR = (yellowProjections(j,2) - yellowProjections(i,2)) / (yellowProjections(i,1) - yellowProjections(j,1));
        yellowAP = yellowProjections(i,1) * yellowLR + yellowProjections(i,2);
        
        greenLR = (greenProjections(j,2) - greenProjections(i,2)) / (greenProjections(i,1) - greenProjections(j,1));
        greenAP= greenProjections(i,1) * greenLR + greenProjections(i,2);
        
        % Remove points outside the body
        if (redLR <= 50) && (redLR >= -50) && (redAP <= 30) && (redAP >= -30)
            plot(redLR,redAP,'r.')
            redAllLR = cat(1, redAllLR, redLR);
            redAllAP = cat(1, redAllAP, redAP);
            redAllSI = cat(1, redAllSI, (256 - ps.Frames(seq).RedSeed(2))*1.966);
        end
        
        if (blueLR <= 50) && (blueLR >= -50) && (blueAP <= 30) && (blueAP >= -30)
            plot(blueLR,blueAP,'b.')
            blueAllLR = cat(1, blueAllLR, blueLR);
            blueAllAP = cat(1, blueAllAP, blueAP);
            blueAllSI = cat(1, blueAllSI, (256 - ps.Frames(seq).BlueSeed(2))*1.966);
        end
        
        if (yellowLR <= 50) && (yellowLR >= -50) && (yellowAP <= 30) && (yellowAP >= -30)
            plot(yellowLR,yellowAP,'y.')
            yellowAllLR = cat(1, yellowAllLR, yellowLR);
            yellowAllAP = cat(1, yellowAllAP, yellowAP);
            yellowAllSI = cat(1, yellowAllSI, (256 - ps.Frames(seq).YellowSeed(2))*1.966);
        end
        
        if (greenLR <= 50) && (greenLR >= -50) && (greenAP <= 30) && (greenAP >= -30)
            plot(greenLR,greenAP,'g.')
            greenAllLR = cat(1, greenAllLR, greenLR);
            greenAllAP = cat(1, greenAllAP, greenAP);
            greenAllSI = cat(1, greenAllSI, (256 - ps.Frames(seq).GreenSeed(2))*1.966);
        end
    end
end

xlabel('Right-Left')
ylabel('Posterior-Anterior')

% Red
% Fit the position data to a normal distribution. Write the mean and
% standard deviation of all points to the Excel fil
mleLR = mle(redAllLR);
mleAP = mle(redAllAP);
mleSI = mle(redAllSI);

A = [mleLR(1) mleLR(2) mleAP(1) mleAP(2) mleSI(1) mleSI(2)];
xlswrite(filepath, A, 'Red Seed', row)

% Blue
mleLR = mle(blueAllLR);
mleAP = mle(blueAllAP);
mleSI = mle(blueAllSI);

A = [mleLR(1) mleLR(2) mleAP(1) mleAP(2) mleSI(1) mleSI(2)];
xlswrite(filepath, A, 'Blue Seed', row)

% Yellow
mleLR = mle(yellowAllLR);
mleAP = mle(yellowAllAP);
mleSI = mle(yellowAllSI);

A = [mleLR(1) mleLR(2) mleAP(1) mleAP(2) mleSI(1) mleSI(2)];
xlswrite(filepath, A, 'Yellow Seed', row)

% Green
mleLR = mle(greenAllLR);
mleAP = mle(greenAllAP);
mleSI = mle(greenAllSI);

A = [mleLR(1) mleLR(2) mleAP(1) mleAP(2) mleSI(1) mleSI(2)];
xlswrite(filepath, A, 'Green Seed', row)

toc