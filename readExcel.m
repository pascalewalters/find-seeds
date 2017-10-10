% This script reads in the values from the Excel file to track mean seed
% position over time

% Absolute path to the Excel file
% excelPath = 'C:\Users\pwalters\Documents\patient_11111529\patient_11111529_AllSeedLocations.xlsx';
excelPath = 'C:\Users\pwalters\Documents\patient_11170145\patient_11170145_AllSeedLocations.xlsx';

redSeedLR = [];
redSeedAP = [];
redSeedSI = [];

blueSeedLR = [];
blueSeedAP = [];
blueSeedSI = [];

yellowSeedLR = [];
yellowSeedAP = [];
yellowSeedSI = [];

greenSeedLR = [];
greenSeedAP = [];
greenSeedSI = [];

dates = [];

[num, txt, raw] = xlsread(excelPath, 'Red Seed');
blue = xlsread(excelPath, 'Blue Seed');
yellow = xlsread(excelPath, 'Yellow Seed');
green = xlsread(excelPath, 'Green Seed');
 
 for i = 1:length(num(:,1))
     if ~isnan(num(i,4))
         date = raw((i + 1),1);

         % Date information is contained in the first column
         if length(strfind(date{1}, '/')) == 2
            d = datetime(date, 'InputFormat', 'dd/MM/yyyy');
         end

         d.Format = 'eeee, MMMM d, yyyy HH:mm:ss';

         % Time information is in the first column of the num array
         % It is stored as a decimal number that needs to be converted to
         % hours and minutes
         t = num(i,1)*24;
         hour = floor(t);
         d.Minute = int32((t - hour)*60);
         d.Hour = hour;

         dates = cat(1, dates, d);

         redSeedLR = cat(1, redSeedLR, num(i,4));
         redSeedAP = cat(1, redSeedAP, num(i,6));
         redSeedSI = cat(1, redSeedSI, num(i,8));

         blueSeedLR = cat(1, blueSeedLR, blue(i,4));
         blueSeedAP = cat(1, blueSeedAP, blue(i,6));
         blueSeedSI = cat(1, blueSeedSI, blue(i,8));

         yellowSeedLR = cat(1, yellowSeedLR, yellow(i,4));
         yellowSeedAP = cat(1, yellowSeedAP, yellow(i,6));
         yellowSeedSI = cat(1, yellowSeedSI, yellow(i,8));

         greenSeedLR = cat(1, greenSeedLR, green(i,4));
         greenSeedAP = cat(1, greenSeedAP, green(i,6));
         greenSeedSI = cat(1, greenSeedSI, green(i,8));
     end
 end
 
 figure, hold on
 plot(dates, redSeedAP, 'r-o')
 plot(dates, blueSeedAP, 'b-o')
 plot(dates, yellowSeedAP, 'y-o')
 plot(dates, greenSeedAP, 'g-o')
 
 ylabel('AP Displacement (mm)')
 
 figure, hold on
 plot(dates, redSeedLR, 'r-o')
 plot(dates, blueSeedLR, 'b-o')
 plot(dates, yellowSeedLR, 'y-o')
 plot(dates, greenSeedLR, 'g-o')
 
 ylabel('LR Displacement (mm)')
 
 figure, hold on
 plot(dates, redSeedSI, 'r-o')
 plot(dates, blueSeedSI, 'b-o')
 plot(dates, yellowSeedSI, 'y-o')
 plot(dates, greenSeedSI, 'g-o')
 
 ylabel('SI Displacement (mm)')