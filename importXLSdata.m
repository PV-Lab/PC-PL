%{
MIT License

Copyright (c) [2016] [Mallory Ann Jensen, jensenma@alum.mit.edu]

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

function [deltaN] = importXLSdata(sample_no,exposure,LP,filename_after)
%% Created by J. Hofstetter. Revised by M. Jensen on March 7, 2014.
% imports SSPC data from excel files taken at different laser powers (LP) and
% calculates the average injection carrier density. returns a vector with
% average minority carrier denities as a function of laser power LP. 

%% Inputs (change these when you have a new file set)

% % laser powers at which PL maps were measured (for calibration curve)
% LP=[50 55 60 65 70 75 80]; 
% 
% %Filename before/after laser power number (Ex. 'SampleA_10s_60LP_001_1.txt')
% %filename before = 'SampleA_10s_'
% %filename after = '_001_1.txt'
% filename_before = '188-5_retake_';
% filename_after = 'LP_001.xlsm';

%Define which rows you want to consider from the Sinton spreadsheet (i.e.
%separate out the rising signal)
sheet = 'Calc'; %may need to change this depending on which version spreadsheet you are using
deltaN_range = 'I50:I130';

%% Evaluate Sinton files for each laser power

% create a cell array that will contain excel file names
XLSsamples = cell(length(LP),1);

for i = 1:1
    for cc=1:length(LP)
        textFilename = [sample_no '_' num2str(exposure) 's_' num2str(LP(cc)) filename_after];
        XLSsamples{cc,i}=textFilename;
    end
end

% create a vector that will contain average minority carrier densities at
% different laser powers for each sample
deltaN=zeros(size(XLSsamples));
for i=1:1
    for j = 1:length(LP)
    
        filename = XLSsamples{j,i};
        % read in data from excel spreadsheet 
        subsetA = xlsread(filename, sheet, deltaN_range);
        % calculate average minority carrier density
        deltaN(j,i) = mean(subsetA); 
    end
end

