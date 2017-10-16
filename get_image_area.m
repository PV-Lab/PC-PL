%Get the area of a sample from an image
clear all; close all; 
filename = 'C:\Users\Mallory Jensen\Documents\LeTID\Dartboard\Sample images\h samples.jpg'; 

raw = imread(filename); 

%Display the figure before any processing
figure;
imshow(raw); 
grid off; axis off; 
title('raw image'); 

grayed = rgb2gray(raw); 

%Now threshold the image
% BW = imbinarize(grayed,'adaptive','Sensitivity',0.7); 
BW = imbinarize(grayed);
figure; 
imshowpair(grayed,BW,'montage'); 
title('binarized image'); 
