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


