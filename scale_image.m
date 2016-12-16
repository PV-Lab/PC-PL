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

%Scale an image to [0 1]
filename = 'C:\Users\Mallory\Documents\Non-contact crucible\SiliconPV\20-1_afterTR_asPassivated.tiff';

[A,map] = imread(filename); 

figure;
image(A); 

matrix = rgb2gray(A);
matrix = double(matrix);

minvalue = min(min(matrix));
maxvalue = max(max(matrix));

scaled = (matrix-minvalue)./(maxvalue-minvalue); 

figure;
imagesc(scaled);
axis('image');
colormap('gray');
caxis([0 1]);
colorbar; 

%% For a PC image taken at MIT that is already a matrix
clear all;close all;
filename = 'C:\Users\Mallory\Documents\Non-contact crucible\9-15-2015 experiment TR+Amanda\Lifetime stage 1\PC-PL\124-3 refocus\124-3_PCPL_codeFix.mat';
i = 1; %laser power interested in = 40%

load(filename); 

PL = PLmaps{i,1};

minvalue = min(min(PL));
maxvalue = max(max(PL));

scaled = (PL-minvalue)./(maxvalue-minvalue);

figure;
imagesc(scaled);
axis('image');
colormap('gray');
caxis([0 1]);
colorbar; 


