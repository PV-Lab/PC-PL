%Load PL maps of interest and do line scan

clear all;
close all;

load('21-25-5_PCPL.mat');
tau2125 = tau{2}; 
load('21-101-5_PCPL.mat');
tau21101 = tau{2}; 
load('22-25-5_PCPL.mat');
tau2225 = tau{2}; 
load('22-101-5_PCPL.mat');
tau22101 = tau{2}; 
sample_no = {'21-25' '21-101' '22-25' '22-101'};
lines = zeros(length(sample_no),1025);
PLmaps = {tau2125, tau21101, tau2225, tau22101};
count = 1;

while count<=1

figure;


for i = 1:length(sample_no)
    
    figure;
    PL_now = PLmaps{i};
    imagesc(PL_now);
    a = colormap(gray);
    axis('image');
    disp('Click unique point to base line scan from');
    [x,y] = ginput(1);
    y = round(y);
    lines(i,:) = PL_now(y,:);
    hold on;
    plot([0 1024],[y y],'r','LineWidth',2);
    
end

count = count+1;
end
