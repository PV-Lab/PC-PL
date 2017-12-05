%{
MIT License

Copyright (c) [2016] [Mallory Ann Jensen, jensenma@alum.mit.edu]
Note: File contents modified from Jasmin Hofstetter. 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
%}

clear all; close all; clc; 

%Where are the PL files to calibrate
dir_PL = 'C:\Users\Mallory Jensen\Documents\LeTID\PDG\round 2 data\from SERIS\PL\data\initial'; %round 1

%Where should we save the data
save_dir = 'C:\Users\Mallory Jensen\Documents\LeTID\PDG\round 2 data\from SERIS\PL\Summary\initial'; 

%Get the sample information 
sample_params = 'C:\Users\Mallory Jensen\Documents\LeTID\PDG\round 2 data\from SERIS\PL\Sample measurements.xlsx'; 
[params,names_params] = xlsread(sample_params,'sample summary','A2:U13');

%Get the calibration information 
dir_calib = 'C:\Users\Mallory Jensen\Documents\LeTID\PDG\round 2 data\from SERIS\PL\calibration\PCPL calibrations'; 
samples_calib = {'1-6','2-6','3-6','4-6','5-6','6-6','7-6','8-6'}; 
exposure = [10, 10, 10, 10, 10, 10, 10, 10];

[num_samples,n] = size(names_params); 

%We want to correct the doping
correct_doping = 'N'; 

%Now we loop
for i = 1:num_samples
    %Figure out which calibration we should use
    calibration_name = names_params{i,7}; 
    %Get the exposure time
    exp_index = find(strcmp(samples_calib,calibration_name)==1); 
    %Make the calibration filename
    calibration = [dir_calib '\' calibration_name '_' num2str(exposure(exp_index)) 's_avgcalib.mat']; 
    %Get the laser powers for this sample
    LP = str2num(names_params{i,9}); %round 1
    %Get the exposure for this sample
    exp_sample = params(i,7); %round 1
    Flux_808 = str2num(names_params{i,10}); %round 1
    %What's the doping of this sample
    doping_samp = params(i,3);
    try
        %Now run the script to read and calibrate the data
        [PLmaps,deltan,tau,deltatau]=process_PL({[dir_PL '\' names_params{i}]},...
            calibration,LP,Flux_808,exp_sample,correct_doping,doping_samp);
        %Get the matching optical image
        optical_filename = [dir_PL '\' names_params{i} '_optical_1.txt']; 
        optical_map = importdata(optical_filename,',',0);
        %Save the data
        savename = [save_dir '\' names_params{i} '_calibrated.mat']; 
        save(savename,'PLmaps','deltan','tau','LP','exp_sample',...
            'Flux_808','calibration','doping_samp','optical_map'); 
    catch
        disp(['Error calibrating sample ' names_params{i}]);
    end
end