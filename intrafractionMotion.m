% This script calculates the intrafraction motion of one seed and plots it

% Instantiate a ProjectionSet class for the current imaging session
addpath('ProjectionSet')

xmlPath = 'C:\Users\pwalters\Documents\patient_11170145\IMAGES\img_1.3.46.423632.3353222017512143254406.31\_Frames.xml'; 
ps = ProjectionSet(xmlPath);

ps.convertFramesToPng()

ps.findSeeds();

x = [];
y = [];
angle = [];
time = [];

% Collect the x and y position, time and angle data into their respective
% vectors
for i = 1:length(ps.SeedSeq)    
    seq = ps.SeedSeq(i);
    
    % Change the seed name to the desired seed
    x = cat(1, x, ps.Frames(seq).RedSeed(1));    
    y = cat(1, y, ps.Frames(seq).RedSeed(2));
    angle = cat(1, angle, ps.Frames(seq).kVAngle);
    time = cat(1, time, ps.Frames(seq).DeltaMs);
end

% Pixel size at iso
isoWidth = 2*(20*100/153.6); % cm
pixelSizeIso = isoWidth / 512; % cm/px

% Fit the x position data to a sinusoid and determine the mean y position
yAvg = mean(y);
f1 = fit(angle, x, 'fourier1');
f1Vals = coeffvalues(f1);
a0 = f1Vals(1);
normalizedX = x - a0;
[f2, gof, output] = fit(angle, normalizedX, 'sin1');

xExpectedPosition = [];
yExpectedPosition = [];

% Determine the expected position for each frame
for j = 1:length(ps.SeedSeq)
   seq = ps.SeedSeq(j);
   xExpectedPosition = cat(1, xExpectedPosition, f2(ps.Frames(seq).kVAngle));
   yExpectedPosition = cat(1, yExpectedPosition, yAvg);
end

% Plot expected and actual normalized x position
figure, hold on
plot(angle, normalizedX, '.')
plot(angle, xExpectedPosition)
legend('Red Seed x Position', 'Expected Position')
xlabel('Angle (Degrees)')
ylabel('Displacement (Pixels)')

% Plot the residuals from the x curve fit
figure, hold on
xResid = output.residuals * pixelSizeIso * 10;
plot(angle, xResid, '.')
title('Intrafraction AP and LR Motion')
xlabel('Angle (Degrees)')
ylabel('Displacement (mm)')

% Plot expected and actual y position
figure, hold on
plot(angle, y, '.')
plot(angle, yExpectedPosition)
legend('Red Seed y Position', 'Expected Position')
xlabel('Angle (Degrees)')
ylabel('Displacement (Pixels)')

% Plot the residuals from the the y average position
figure, hold on
yResid = (y - yExpectedPosition) * pixelSizeIso * 10;
plot(angle, yResid, '.')
title('Intrafraction SI Motion')
xlabel('Angle (Degrees)')
ylabel('Displacement (mm)')