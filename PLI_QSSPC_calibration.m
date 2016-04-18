%%Calibrating PLI from a Sinton QSSPC curve
%April 5, 2016
%Written by Mallory Jensen
%This script attempts to determine the calibration curve for PLI given a
%single QSSPC curve and a series of PLI images at different laser powers. 

%% Load the PL images directly from the .txt files

clear all; close all; 

%Check these parameters before you run the code - they describe the
%filename
sample_no_PL = '\\becquerel\pvlab\DataExchange\DBN\201600405 ASU PLI\A-113-CC-4'; %this is the first part of the filenames
exposure = 30; %seconds, this is the second part of the filename
LP = [22 25 30 35 40 45 50 55 60 65 70 75 80]; %This is part of the file name, laser powers that PL images are taken at. If you change this also change it in section 3
filename_after_PL='s bkgd_1.txt';

%Now loop throuugh the different laser powers and load the PL images. Store
%in PLmaps - this is a cell array composed of matrices. The indices
%correspond to the indices in the list of laser powers.
delimiterIn = ',';
headerlinesIn = 0;
sample_no = cell(size(LP)); 
PLmaps = cell(size(LP)); 
for i = 1:length(LP)
    sample_no{i} = [sample_no_PL ' ' num2str(LP(i)) 'p ' num2str(exposure) filename_after_PL];
    PLmap = importdata(sample_no{i},delimiterIn,headerlinesIn);
    PLmap = PLmap(:,2:end)./exposure; %counts/second
    PLmaps{i} = PLmap; 
end

%% Collect the data which is used to obtain the calibration curve

%Loop through the PL maps for the different laser powers, crop as directed,
%and then obtain the arithmetic mean
PL_averages = zeros(size(LP));
crop_locations_flag = 0; 
for i = 1:length(LP)
    if crop_locations_flag == 0 
        [PLimage_now,x_crop,y_crop]=crop_PL(PLmaps{i});
        crop_locations_flag = 1; 
    else
        PLimage_now = PLmaps{i}; 
        [m,n] = size(PLimage_now); 
        %Get rid of highest y values we don't want
        PLimage_now(floor(y_crop(2)):m,:) = [];
        %Get rid of highest x values we don't want
        PLimage_now(:,floor(x_crop(2)):n) = [];
        %Get rid of lowest y values we don't want
        PLimage_now(1:floor(y_crop(1)),:) = [];
        %Get rid of lowest x values we don't want
        PLimage_now(:,1:floor(x_crop(1))) = [];
        figure;
        imagesc(PLimage_now);
        axis('image');
        colormap(gray);
    end
    [linear,M_p] = tau_averages(PLimage_now);
    PL_averages(i) = linear; 
end

%You should have measured the generation rate for each PL image
filename = '\\becquerel\pvlab\DataExchange\DBN\201600405 ASU PLI\PLI laser intensities.xlsx';
data = xlsread(filename,'Sheet2'); 
suns = data(:,6); 

%Load the QSSPC data
filename = '\\becquerel\pvlab\DataExchange\DBN\201600405 ASU PLI\MIT113cells_CC_aSi.xlsm'; 
data = xlsread(filename,'RawData','E8:I124');
lifetime = data(:,1); %seconds
deltan = data(:,3); %cm^-3
implied_suns = data(:,5); %suns

%Now for each "suns" value we want to interpolate using the QSSPC curve
%First figure out which excess carrier densities we are at. 
deltan_guess = interp1(implied_suns,deltan,suns);

figure;
plot(deltan_guess,PL_averages); 
title('Points for fitting calibration curve'); 
xlabel('Excess carrier density'); 
ylabel('PL intensity'); 
% Extract curve and fit it in Excel, then use fitted parameters to make
% calibration PL images

figure;
loglog(deltan,lifetime,'.'); 
title('Measured lifetime from QSSPC'); 

%Write the data to an Excel spreadsheet for fitting
write = [deltan_guess, PL_averages'];
xlswrite('\\becquerel\pvlab\DataExchange\DBN\201600405 ASU PLI\Calibration_curves.xlsx',write);

%% Open and calibrate PL files

%Take the calibration from the Excel spreadsheet
filename = '\\becquerel\pvlab\DataExchange\DBN\201600405 ASU PLI\Calibration_curves.xlsx'; 
data = xlsread(filename); 
sample.a = data(19,2);
sample.b = data(20,2); 
sample.c = data(21,2); 
sample.thickness = .0180; %cm

%List of laser powers evaluated at - this is probably already in the
%workspace
LP = [22 25 30 35 40 45 50 55 60 65 70 75 80]; 

%Calculate the generation rate in the sample during the measurement
flux = ((suns.*0.1)./((1240/808)*1.602e-19)).*(60.5/78.4); %photons/cm2/s
G = flux./sample.thickness; %photons/cm3/s

deltan_maps = cell(size(LP)); 
tau_maps = cell(size(LP)); 

%Loop through the different laser powers and calculate injection level and
%lifetime point by point. Store the results in cell arrays that are the
%same size as laser power list
for i = 1:length(LP)
    %Get the PL map for this particular experiment
    PLnow = PLmaps{i};

    indices = find(PLnow<0);
    PLnow(indices) = 0; %if the PL counts are negative, set them equal to zero

    %Calculate the excess carrier density using the calibration and store it  
    deltan_maps{i} = (-sample.b+abs(sqrt(sample.b^2-4*sample.a.*(sample.c-PLnow))))./(2*sample.a);

    %Calculate the lifetime using the generation rate and store it
    tau_maps{i} = (deltan_maps{i}./G(i)) .* 1e6; %microseconds
    
    figure; 
    imagesc(PLnow);
    axis('image');
    colorbar;
    colormap(gray);
    title(['PL counts of sample ' sample_no{i} ' at LP ' num2str(LP(i))]);
    
    %Plot the resulting lifetime
    figure; 
    imagesc(tau_maps{i});
    axis('image');
    colorbar;
    colormap(gray);
    title(['Lifetime of sample ' sample_no{i} ' at LP ' num2str(LP(i))]);

    figure;
    imagesc(deltan_maps{i});
    axis('image');
    colorbar;
    colormap(gray);
    title(['Injection level of sample ' sample_no{i} ' at LP ' num2str(LP(i))]);
end
    

