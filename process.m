% This script performs both interfraction and intrafraction motion
% analysis for both one seed and all seeds at once

addpath('ProjectionSet')

% xmlPath = 'C:\Users\pwalters\Documents\Analysis\patient_11170145\img_1.3.46.423632.335322201751020044500.80\_Frames.xml';
xmlPath = 'C:\Users\pwalters\Documents\patient_11170145\IMAGES\img_1.3.46.423632.3353222017512143254406.31\_Frames.xml'; 
ps = ProjectionSet(xmlPath);

ps.convertFramesToPng()

ps.findSeeds();

%% Location of seeds in 2D
y = [];
angle = [];
time = [];
expectedPosition = [];

for i = 1:length(ps.SeedSeq)    
    seq = ps.SeedSeq(i);
        
    y = cat(1, y, ps.Frames(seq).RedSeed(1));
    angle = cat(1, angle, ps.Frames(seq).kVAngle);
    time = cat(1, time, ps.Frames(seq).DeltaMs);
    expectedPosition = cat(1, expectedPosition, 47.84*sin((ps.Frames(seq).kVAngle*pi/180)-1.334)+394.5);
%     expectedPosition = cat(1, expectedPosition, 266.6898);
end

figure, hold on
plot(angle, y, '.')
plot(angle, expectedPosition)
legend('Red Seed y Position', 'Expected Position')
xlabel('Angle (Degrees)')
ylabel('Displacement (Pixels)')

difference = (y - expectedPosition)/0.5086;
figure
plot(time, difference, '.')
xlabel('Time (ms)')
ylabel('Displacement (mm)')

%% 2D analysis for blue, yellow and green seeds

redX = [];
blueX = [];
yellowX = [];
greenX = [];

redY = [];
blueY = [];
yellowY = [];
greenY = [];

redXExpectedPosition = [];
blueXExpectedPosition = [];
yellowXExpectedPosition = [];
greenXExpectedPosition = [];

redYExpectedPosition = [];
blueYExpectedPosition = [];
yellowYExpectedPosition = [];
greenYExpectedPosition = [];

angle = [];
time = [];

for i = 1:length(ps.SeedSeq)
    seq = ps.SeedSeq(i);
    
    redX = cat(1, redX, ps.Frames(seq).RedSeed(1));
    blueX = cat(1, blueX, ps.Frames(seq).BlueSeed(1));
    yellowX = cat(1, yellowX, ps.Frames(seq).YellowSeed(1));
    greenX = cat(1, greenX, ps.Frames(seq).GreenSeed(1));
    
    redXExpectedPosition = cat(1, redXExpectedPosition, 47.84*sin((ps.Frames(seq).kVAngle*pi/180)-1.334)+394.5);
    blueXExpectedPosition = cat(1, blueXExpectedPosition, 22.84*sin((ps.Frames(seq).kVAngle*pi/180)-0.9302)+395);
    yellowXExpectedPosition = cat(1, yellowXExpectedPosition, 30.22*sin((ps.Frames(seq).kVAngle*pi/180)+0.7849)+393.9);
    greenXExpectedPosition = cat(1, greenXExpectedPosition, 36.77*sin((ps.Frames(seq).kVAngle*pi/180)+1)+394.1);
    
    redY = cat(1, redY, ps.Frames(seq).RedSeed(2));
    blueY = cat(1, blueY, ps.Frames(seq).BlueSeed(2));
    yellowY = cat(1, yellowY, ps.Frames(seq).YellowSeed(2));
    greenY = cat(1, greenY, ps.Frames(seq).GreenSeed(2));
    
    redYExpectedPosition = cat(1, redYExpectedPosition, 266.6898);
    blueYExpectedPosition = cat(1, blueYExpectedPosition, 297.6795);
    yellowYExpectedPosition = cat(1, yellowYExpectedPosition, 243.3461);
    greenYExpectedPosition = cat(1, greenYExpectedPosition, 276.1839);
        
    angle = cat(1, angle, ps.Frames(seq).kVAngle);
    time = cat(1, time, ps.Frames(seq).DeltaMs);
end

% figure, hold on
% plot(angle, greenY, '.')
% plot(angle, greenYExpectedPosition)
% legend('Green Seed Y Position', 'Expected Position')
% xlabel('Angle (Degrees)')
% xlabel('Time (ms)')
% ylabel('Displacement (Pixels)')

% difference = (greenY - greenYExpectedPosition)*1.966;
% figure
% plot(angle, difference, '.')
% xlabel('Time (ms)')
% xlabel('Angle (Degrees)')
% ylabel('Displacement (mm)')

%% Determine equation of projection in transverse plane
% Ray passes through kV source, seed at iso and seed on detector

% Pixel size at iso
isoWidth = 2*(20*100/153.6); % cm
pixelSizeIso = isoWidth / 512; % cm/px

% Pixel size at detector
detectorWidth = 40; % cm
pixelSizeDetector = detectorWidth / 512; % cm/px

projections = [];
angles = [];

figure, hold on

for i = 1:length(ps.SeedSeq)
    frame = ps.Frames(ps.SeedSeq(i));
    angles = cat(1, angles, frame.kVAngle);
    
    % Location of focal spot
    alpha = 100*[cos((90-frame.kVAngle)*pi/180) sin((90-frame.kVAngle)*pi/180) 0];
    
    gamma = 53.6*[cos((270-frame.kVAngle)*pi/180) sin((270-frame.kVAngle)*pi/180)];
    
    r_betaGamma_mag = (frame.RedSeed(1)*pixelSizeDetector)-(20+11.5);
    r_betaGamma = r_betaGamma_mag*[cos(frame.kVAngle*pi/180) -1*sin(frame.kVAngle*pi/180)];
    
    % Location of seed on detector
    beta = gamma + r_betaGamma;
    beta = cat(2, beta, (frame.RedSeed(2)*pixelSizeDetector - 20));
    
    m = (alpha(2) - beta(2))/(alpha(1) - beta(1));
    b = -1*m*beta(1) + beta(2);
    A = [m b];
    projections = cat(1, projections, A);
    
    line([alpha(3) beta(3)], [alpha(1) beta(1)], [alpha(2) beta(2)], 'Color', 'r')
    
%     v = alpha - beta;
%     A = cat(3, v, alpha, beta);
%     projections = cat(1, projections, A);
end

xlabel('Superior-Inferior')
ylabel('Right-Left')
zlabel('Posterior-Anterior')
view(3)

%% Determine equation of projection for all seeds in transverse plane
% Pixel size at iso
isoWidth = 2*(20*100/153.6); % cm
pixelSizeIso = isoWidth / 512; % cm/px

% Pixel size at detector
detectorWidth = 40; % cm
pixelSizeDetector = detectorWidth / 512; % cm/px

redProjections = [];
blueProjections = [];
yellowProjections = [];
greenProjections = [];
angles = [];

figure, hold on

for i = 1:length(ps.SeedSeq)
    frame = ps.Frames(ps.SeedSeq(i));
    angles = cat(1, angles, frame.kVAngle);
    
    % Location of focal spot
    alpha = 100*[cos((90-frame.kVAngle)*pi/180) sin((90-frame.kVAngle)*pi/180) 0];
    gamma = 53.6*[cos((270-frame.kVAngle)*pi/180) sin((270-frame.kVAngle)*pi/180)];
    
    % Red Seed
    r_betaGamma_mag = (frame.RedSeed(1)*pixelSizeDetector)-(20+11.5);
    r_betaGamma = r_betaGamma_mag*[cos(frame.kVAngle*pi/180) -1*sin(frame.kVAngle*pi/180)];
    beta = gamma + r_betaGamma;
    beta = cat(2, beta, (frame.RedSeed(2)*pixelSizeDetector - 20));
    
    line([alpha(3) beta(3)], [alpha(1) beta(1)], [alpha(2) beta(2)], 'Color', 'r')
    
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

%% Find intersection in transverse plane
allX = [];
allY = [];
allZ = [];
all = [];
figure, hold on

tic

for i = 1:length(projections(:,1))
    for j = (i + 1):length(projections(:,1))
        x = (projections(j,2) - projections(i,2)) / (projections(i,1) - projections(j,1));
        y = projections(i,1) * x + projections(i,2);
        
        % Remove points outside the body
        if (x <= 50) && (x >= -50) && (y <= 30) && (y >= -30)
            plot(x,y,'.')
            allX = cat(1, allX, x);
            allY = cat(1, allY, y);
        end
    end
    allZ = cat(1, allZ, (ps.Frames(ps.SeedSeq(i)).RedSeed(2)*pixelSizeIso)-20);
end

xlabel('Right-Left')
ylabel('Posterior-Anterior')

toc

%% Find intersection of all seeds in transverse plane
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

tic

for i = 1:length(redProjections(:,1))
    seq = ps.SeedSeq(i);
    
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

toc

%% Write to Excel file
filepath = 'C:\Users\pwalters\Documents\patient_11170145\AllSeedLocations.xlsx';

% Red
mleLR = mle(redAllLR);
mleAP = mle(redAllAP);
mleSI = mle(redAllSI);

A = [mleLR(1) mleLR(2) mleAP(1) mleAP(2) mleSI(1) mleSI(2)];
xlswrite(filepath, A, 'Red Seed', 'E22')

% Blue
mleLR = mle(blueAllLR);
mleAP = mle(blueAllAP);
mleSI = mle(blueAllSI);

A = [mleLR(1) mleLR(2) mleAP(1) mleAP(2) mleSI(1) mleSI(2)];
xlswrite(filepath, A, 'Blue Seed', 'E22')

% Yellow
mleLR = mle(yellowAllLR);
mleAP = mle(yellowAllAP);
mleSI = mle(yellowAllSI);

A = [mleLR(1) mleLR(2) mleAP(1) mleAP(2) mleSI(1) mleSI(2)];
xlswrite(filepath, A, 'Yellow Seed', 'E22')

% Green
mleLR = mle(greenAllLR);
mleAP = mle(greenAllAP);
mleSI = mle(greenAllSI);

A = [mleLR(1) mleLR(2) mleAP(1) mleAP(2) mleSI(1) mleSI(2)];
xlswrite(filepath, A, 'Green Seed', 'E22')

%% Find intersection in 3D (FIXME: does not work)
allX = [];
allY = [];
allZ = [];

tic

for i = 1:length(projections(:,1,1))
    for j = (i + 1):length(projections(:,1,1))
        a = projections(j,1,1)/projections(i,1,1);
        x = a*(projections(i,1,2)-projections(j,1,2))/(a - 1);
        
        b = projections(j,2,1)/projections(i,2,1);
        y = b*(projections(i,2,2)-projections(j,2,2))/(b - 1);
        
        c = projections(j,3,1)/projections(i,3,1);
        z = c*(projections(i,3,2)-projections(j,3,2))/(c - 1);
        
        t1 = (x-projections(i,1,2))/projections(i,1,1);
        t2 = (y-projections(i,2,2))/projections(i,2,1);
        t3 = (z-projections(i,3,2))/projections(i,3,1);
        
        if (t1 == t2) && (t2 == t3) && (t1 == t3)
%         if (x <= 50) && (x >= -50) && (y <= 30) && (y >= -30) 
            allX = cat(1, allX, x);
            allY = cat(1, allY, y);
            allZ = cat(1, allZ, z);
        end
        
        c = cross(projections(i,:,1), projections(j,:,1));
        % Minimum distance between the two projections
        d = abs(dot((projections(i,:,2)-projections(j,:,2)), c)/norm(c));
        
        max = 5;
        
        for t = 0:0.01:1
            for s = 0:0.01:1
                xdistance = (projections(i,1,2)+projections(i,1,1)*t)-(projections(j,1,2)+projections(j,1,1)*s);
                ydistance = (projections(i,2,2)+projections(i,2,1)*t)-(projections(j,2,2)+projections(j,2,1)*s);
                zdistance = (projections(i,3,2)+projections(i,3,1)*t)-(projections(j,3,2)+projections(j,3,1)*s);
                
                if norm([xdistance ydistance zdistance]) < max
                   max = norm([xdistance ydistance zdistance]);
                end
            end
        end
    end
end

toc