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

%This script loops through different samples and 1) reads a calibration
%PCPL .mat file, 2) reads the calibration file for that sample which
%contains important sample parameters, 3) reads the optical image for that
%sample, 4) Makes a figure containing the optical image, lifetime map,
%injection level map, and line scan across grain boundary of interest for
%each laser power, and 5) saves that line scan data to a new .mat file to
%manipulate later. 

clear all; close all; 
%Where everthing is located
dirname = 'C:\Users\Malloryj\Documents\LeTID\XRF\PCPL'; 

%What are the sample names? These should be consistent across all file
%types. 
samples = {'SAL-a','SAH-a','SA-a','PSL-a','PSH-a','PS-a','PS-1',...
    'SAL-1','SAH-1','SAH-1_repeat','SA-1','PSL-1','PSH-1'};
% samples = {'SAL-a'};

%The axis ranges for different maps
% axis_tau = [0 50]; 
% axis_deltan = [1e12 1e15]; 

linescan_store = cell(length(samples)); 

for i = 1:length(samples)
    %Read the optical image
    load([dirname '\' samples{i} '_optical.mat']); 
    optical_image = PLmap; 
    %Read the calibrated PL data
    load([dirname '\' samples{i} '_calbrated.mat']); 
    %Read the calibration file
    load([dirname '\' samples{i} '_calib.mat']); 
    %Determine the line scan information for this sample
    %We reference to the optical image
    figure;
    imagesc(optical_image); 
    axis('image');
    colormap(gray);
    axis off; 
    title('optical image'); 
    disp('Click two points which encompass the GB we are interested in')
    [x,y] = ginput(2); 
    %Now we determine the line between those points
    len = sqrt(abs(x(1)-x(2))^2 + abs(y(1)-y(2))^2); %pixels 
    angle = atan((y(2)-y(1))/(x(2)-x(1))); %radians
    new_angle = angle + (pi/2); %we want something which is orthogonal
    midpoint = [mean([x(1),x(2)]),mean([y(1),y(2)])];
    new_endpoint_1 = [midpoint(1)-cos(new_angle)*(len/2),midpoint(2)-sin(new_angle)*(len/2)];
    new_endpoint_2 = [midpoint(1)+cos(new_angle)*(len/2),midpoint(2)+sin(new_angle)*(len/2)]; 
    %Loop over the laser powers and do the same thing for each laser power
    linescans_thissample = cell(length(LP)); 
    for j = 1:length(LP)
        figNow = figure('units','normalized','outerposition',[0 0 1 1]);
        %The first image is the optical image
        subplot(3,2,1); 
        imagesc(optical_image); 
        axis('image');
        colormap(gray);
        axis off; 
        title('optical image'); 
        %The next image is the lifetime
        subplot(3,2,3); 
%         imagesc(tau{j},axis_tau); 
        imagesc(tau{j});
        axis('image');
        colorbar;
        colormap(gray);
        axis off; 
        title('lifetime [\mus]'); 
        %The third image is the injection level
        subplot(3,2,5); 
%         imagesc(deltan{j},axis_deltan); 
        imagesc(deltan{j}); 
        axis('image');
        colorbar;
        colormap(gray);
        axis off; 
        title('\Deltan [cm^-^3]'); 
        %The last task is the get the line scans
        subplot(3,2,1); 
        hold on;
        plot([new_endpoint_1(1),new_endpoint_2(1)],[new_endpoint_1(2),new_endpoint_2(2)],'r','LineWidth',1.5);
        subplot(3,2,3); 
        hold on;
        plot([new_endpoint_1(1),new_endpoint_2(1)],[new_endpoint_1(2),new_endpoint_2(2)],'r','LineWidth',1.5);
        subplot(3,2,5); 
        hold on;
        plot([new_endpoint_1(1),new_endpoint_2(1)],[new_endpoint_1(2),new_endpoint_2(2)],'r','LineWidth',1.5);
        linescan_tau = improfile(tau{j},[new_endpoint_1(1),new_endpoint_2(1)],[new_endpoint_1(2),new_endpoint_2(2)]); 
        subplot(3,2,4); 
        plot(linescan_tau,'r','LineWidth',3); 
        ylabel('lifetime [\mus'); 
        linescan_deltan = improfile(deltan{j},[new_endpoint_1(1),new_endpoint_2(1)],[new_endpoint_1(2),new_endpoint_2(2)]); 
        subplot(3,2,6); 
        semilogy(linescan_deltan,'r','LineWidth',3); 
        ylabel('\Deltan [cm^-^3]'); 
        tightfig(figNow); 
        linescans_thissample{j} = [linescan_deltan,linescan_tau]; 
        %Now we save the figure
        hgsave(figNow,[dirname '\' samples{i} '_' num2str(LP(j)) 'LP']);
        print(figNow,'-dpng','-r0',[dirname '\' samples{i} '_' num2str(LP(j)) 'LP.png']); 
    end
    linescan_store{i} = linescans_thissample; 
    %Close figures so we don't get a graphics error
    close all; 
end
save([dirname '\Linescans.mat'],'linescan_store','samples'); 
    