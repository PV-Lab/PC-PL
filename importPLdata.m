function [PL_averages,PLmaps] = importPLdata(sample_no,exposure,LP,filename_after,sensor)
%Created by J. Hofstetter. Revised by M. Jensen on March 7, 2014.

% imports PL maps (.txt files) taken at different laser powers (LP) and
% calculates the average PL counts in the sensor region of the Sinton tool;
% returns a vector containing average PL signals in sensor region as a
% function of laser power. a cell array containing all of the PL maps at
% different laser powers can also be returned for processing outside of
% this function. 

%% Inputs (change these when you have a new file set)

%Define delimiter and header in order to read txt files
delimiterIn = ',';
headerlinesIn = 0;

%% Evaluate PL files for each laser power
 
% CREATE A CELL ARRAY THAT WILL CONTAIN .TXT FILE NAMES OF PL MAPS (assume
% one exposure time for all images)
samples = cell(length(LP),1); 
 
% fill up the cell array with .txt file names
for i = 1:1
    for cc=1:length(LP)  
        textFilename = [sample_no '_' num2str(exposure) 's_' num2str(LP(cc)) filename_after];
        samples{cc,i}=textFilename;
    end
end

% %Read in the first PL map
% filename_initial = samples{1}; 
% PLmap_initial = importdata(filename_initial,delimiterIn,headerlinesIn);
% %Exclude the first column of the PL text files b/c it is just a counter
% PLmap_initial = PLmap_initial(:,2:end); %counts
% %Normalize by the exposure time to get counts/second
% PLmap_initial = PLmap_initial./exposure; %counts/second
% 
% %Make a plot of the first PL map
% %clim = [0 1400]; %define counts range
% figure;
% imagesc(PLmap_initial);
% axis('image'); %use real aspect ratio
% colorbar;

%Initialize a cell array that will contain all of our PL maps
PLmaps = cell(size(samples));
%Place the first map in the array
%PLmaps{1}=PLmap_initial; %counts/second

%Now go through and place all of the maps into the cell array

for i = 1:1
    for cc = 1:length(LP)
        filename = samples{cc,i};
        PLmap = importdata(filename,delimiterIn,headerlinesIn);
        PLmap = PLmap(:,2:end)./exposure; %counts/second
    
%         figure;
%         imagesc(PLmap);
%         axis('image');
%         colorbar;
%         colormap(gray);
    
        PLmaps{cc,i}=PLmap;
    end
end

%% Evaluate Sensor file and pare down other PL maps

PLsensor = importdata(sensor,delimiterIn,headerlinesIn);
figure;
imagesc(PLsensor);
axis('image');

circletest = 0;

while circletest == 0
    
    PLsensor_circletest = PLsensor;
    
    disp('Click the center of the circle ...');
    [x,y] = ginput(1);
    disp('Click the edge of the circle ...');
    [xr,yr] = ginput(1);
    radius = sqrt((x-xr)^2 + (y-yr)^2);
    
    %PL maps have 1024 x 1024 pixels
    %set all pixels outside of the sensor region to NaN
    for i = 1:1024
        for j = 1:1024
            if abs(sqrt(abs(i-y)^2+abs(j-x)^2))>radius
                PLsensor_circletest(i,j) = NaN;
            end
        end
    end
    
    %Plot the new map with the sensor region only
    figure;
    imagesc(PLsensor_circletest);
    axis('image');
    
    promptcorrect = 'Is the mask acceptable?';
    str = input(promptcorrect,'s');
    if isempty(str)
        str = 'Y';
    end
    
    if str == 'Y'
        circletest = 1;
    end
    
end
    
%Now mask all of the other PLmaps and average the counts
PL_averages = zeros(size(PLmaps));
[m,n] = size(PLmaps);
for i = 1:n;
    for j = 1:m
    PLmap_now = PLmaps{j,i};

    %PL maps have 1024 x 1024 pixels
        %set all pixels outside of the sensor region to NaN
        for k = 1:1024
            for l = 1:1024
                if abs(sqrt(abs(k-y)^2+abs(l-x)^2))>radius
                    PLmap_now(k,l) = NaN;
                end
            end
        end
        
% %     PLmaps{j,i} = PLmap_now;
% %     figure;
% %     imagesc(PLmaps{j,i});
% %     axis('image');
% %     colorbar;
% %     colormap(gray);
    
    PL_averages(j,i) = nanmean(nanmean(PLmap_now));
    end
end

end
