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
dirname = 'C:\Users\Mallory Jensen\Documents\LeTID\XRF\PCPL April 19 2017'; 

%What are the sample names? These should be consistent across all file
%types. 
% samples = {'SAL-a','SAH-a','SA-a','PSL-a','PSH-a','PS-a','PS-1',...
%     'SAL-1','SAH-1','SAH-1_repeat','SA-1','PSL-1','PSH-1'};
% samples = {'SAL-a'};
samples = {'PS-1_10s','PS-1_5s','PSH-1_5s','PSH-1_10s','PSL-1_5s','PSL-1_10s','SAL-1_30s','SAH-1_30s','SA-1_30s'};

%The axis ranges for different maps
% axis_tau = [0 50]; 
% axis_deltan = [1e12 1e15]; 

linescan_store = cell(length(samples)); 
linescan_length = cell(length(samples));

for i = 1:length(samples)
    %Read the optical image
    load([dirname '\' samples{i} '_optical.mat']); 
    optical_image = PLmap; 
    %Read the calibrated PL data
    load([dirname '\' samples{i} '_calibrated.mat']); 
    %Read the calibration file
%     load([dirname '\' samples{i} '_calib.mat']); 
    load([dirname '\total_calibration_' samples{i} '.mat']); 
    %Determine the line scan information for this sample
    %We reference to the optical image
    im=figure;
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
    %Calculate the length of this line in pixels
    len_x = abs(new_endpoint_1(1)-new_endpoint_2(1));
    len_y = abs(new_endpoint_1(2)-new_endpoint_2(2)); 
    ls_len = sqrt((len_x^2)+(len_y^2)); %pixels
    %Now we also need the conversion
    figure(im); 
    disp('Click bottom corners to determine conversion from pixels');
    [x,y] = ginput(2); 
    len = sqrt(abs(x(1)-x(2))^2 + abs(y(1)-y(2))^2); %pixels
    %Now we hard code that this is 1 cm
    conv = (1e4)/len; %microns/pixel
    ls_len = ls_len*conv; %now this length should be in microns
    %Loop over the laser powers and do the same thing for each laser power
    linescans_thissample = cell(length(LP)); 
    linescan_length_thissample = cell(length(samples));
    for j = 1:length(LP)
        figNow = figure('units','normalized','outerposition',[0 0 1 1]);
        %The first image is the optical image
        subplot(3,2,1); 
        range_im = max(max(optical_image))-min(min(optical_image)); 
        imagesc(optical_image,[0.05*range_im+min(min(optical_image)) 0.8*range_im+min(min(optical_image))]); 
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
        %Let's save a vector of the "length"
        %Let's make an appropriate vector
        linescan_length_thissample{j} = linspace(0,ls_len,length(linescan_tau)); 
        %Now we save the figure
        hgsave(figNow,[dirname '\' samples{i} '_' num2str(LP(j)) 'LP']);
        print(figNow,'-dpng','-r0',[dirname '\' samples{i} '_' num2str(LP(j)) 'LP.png']); 
    end
    linescan_store{i} = linescans_thissample; 
    linescan_length{i} = linescan_length_thissample;
    %Close figures so we don't get a graphics error
    close all; 
end
save([dirname '\Linescans_only1cm.mat'],'linescan_store','samples','linescan_length'); 

%% Plot line scans from approximately the same injection level
%From the previous section we should have been able to identify which maps
%result in similar injection levels, and now we can directly compare line
%scans at those similar injection levels (as opposed to a similar
%generation rate). 
clear all; close all; 
%where is everything located
dirname = 'C:\Users\Mallory Jensen\Documents\LeTID\XRF\PCPL April 19 2017'; 

%Which samples do I want to compare?
samples_to_analyze = {'PS-1_10s','PSH-1_10s','PSL-1_10s','SAL-1_30s','SAH-1_30s','SA-1_30s'}; 
%Which laser powers correspond to which sample?
LP_to_analyze = [30,25,25,30,80,80]; 
%Unfortunately I didn't save the laser powers originally so let's just tell
%it which index to go to if we have the right sample
LP_index = [2,1,1,5,7,7];

tau_raw = figure('units','normalized','outerposition',[0 0 1 1]);
deltan_raw = figure('units','normalized','outerposition',[0 0 1 1]);
tau_norm = figure('units','normalized','outerposition',[0 0 1 1]);
deltan_norm = figure('units','normalized','outerposition',[0 0 1 1]);
save_data = cell(size(LP_index)); 

%Load the linescan data
load([dirname '\Linescans_only1cm.mat']);
for i = 1:length(samples_to_analyze)
    %find the index in our old storage method
    index = find(strcmp(samples_to_analyze{i},samples)==1); 
    linescan_now = linescan_store{index}; 
    linescan_now = linescan_now{LP_index(i)}; 
    ls_length_now = linescan_length{index}; 
    ls_length_now = ls_length_now{LP_index(i)}'; 
    %Center the scan based on the presumed location of the GB
    figure;
    plot(ls_length_now,linescan_now(:,2)); 
    disp('Click what you think is the center of the linescan')
    [x,y] = ginput(1); 
%     x_center = ls_length_now(find(abs(ls_length_now-x)==min(abs(ls_length_now-x)))); 
    x_new = ls_length_now-x; 
%     x_center = round(x); 
%     x_before = linspace(1,length(linescan_now(:,1)),length(linescan_now(:,1))); 
%     x_new = x_before-x_center; 
    %The first column is the injection level
    figure(deltan_raw); 
    hold all; 
    plot(x_new,linescan_now(:,1),'LineWidth',3); 
    deltan_norm_linescan = (linescan_now(:,1)-min(linescan_now(:,1)))./(max(linescan_now(:,1))-min(linescan_now(:,1))); 
    figure(deltan_norm); 
    hold all;
    plot(x_new,deltan_norm_linescan,'LineWidth',3); 
    %The second column is the lifetime
    figure(tau_raw); 
    hold all;
    plot(x_new,linescan_now(:,2),'LineWidth',3); 
    tau_norm_linescan = (linescan_now(:,2)-min(linescan_now(:,2)))./(max(linescan_now(:,2))-min(linescan_now(:,2))); 
    figure(tau_norm); 
    hold all;
    plot(x_new,tau_norm_linescan,'LineWidth',3);
    %Read the calibrated PL data
    calib_tau = figure('units','normalized','outerposition',[0 0 1 1]);
    load([dirname '\' samples_to_analyze{i} '_calibrated.mat']);
    imagesc(flipud(tau{LP_index(i)}));%[2 7]);
    axis('image');
    colorbar;
    colormap(gray);
    axis off; 
    hgsave(calib_tau,[dirname '\' samples_to_analyze{i} '_' num2str(LP_to_analyze(i)) 'LP_calibratedtau']);
    print(calib_tau,'-dpng','-r0',[dirname '\' samples_to_analyze{i} '_' num2str(LP_to_analyze(i)) 'LP_calibratedtau.png']);
    save_data{i} = [x_new,linescan_now(:,2)]; 
end
figure(tau_raw); 
xlabel('pixel'); 
ylabel('lifetime [\mus]'); 
legend(samples_to_analyze');
figure(tau_norm); 
xlabel('pixel'); 
ylabel('norm. lifetime [-]'); 
legend(samples_to_analyze');
figure(deltan_raw); 
xlabel('pixel'); 
ylabel('\Deltan [cm^-^3]'); 
legend(samples_to_analyze');
figure(deltan_norm); 
xlabel('pixel'); 
ylabel('norm. \Deltan [-]'); 
legend(samples_to_analyze');
tightfig(tau_raw); 
tightfig(tau_norm); 
tightfig(deltan_raw);
tightfig(deltan_norm); 
%Save the figures
hgsave(tau_raw,[dirname '\Lifetime linescans_wLen']);
print(tau_raw,'-dpng','-r0',[dirname '\Lifetime linescans_wLen.png']); 
hgsave(tau_norm,[dirname '\Norm lifetime linescans_wLen']);
print(tau_norm,'-dpng','-r0',[dirname '\Norm lifetime linescans_wLen.png']);
hgsave(deltan_raw,[dirname '\Deltan linescans_wLen']);
print(deltan_raw,'-dpng','-r0',[dirname '\Deltan linescans_wLen.png']); 
hgsave(deltan_norm,[dirname '\Norm deltan linescans_wLen']);
print(deltan_norm,'-dpng','-r0',[dirname '\Norm deltan linescans_wLen.png']); 

%% Make image with the same injection level
clear all; close all; 
%where is everything located
dirname = 'C:\Users\Mallory Jensen\Documents\LeTID\XRF\PCPL April 19 2017'; 

%Which samples do I want to compare?
samples = {'PS-1_10s','PSH-1_10s','PSL-1_10s','SAL-1_30s','SAH-1_30s','SA-1_30s'}; 

%Target injection level
injection = 1e14; %cm^-3

linescan_store = cell(length(samples)); 
linescan_length = cell(length(samples));

for i = 1:length(samples)
    %Read the optical image
    load([dirname '\' samples{i} '_optical.mat']); 
    optical_image = PLmap; 
    %Read the calibrated PL data
    load([dirname '\' samples{i} '_calibrated.mat']); 
    %Read the calibration file
%     load([dirname '\' samples{i} '_calib.mat']); 
    load([dirname '\total_calibration_' samples{i} '.mat']); 
    %We need to get the uniform injection level image
    [PL_uni_inj,LP_map] = uniform_injection(tau,deltan,LP,Flux,...
        injection,sample.d,sample.R); 
    %We reference to the optical image
    im=figure;
    imagesc(optical_image); 
    axis('image');
    colormap(gray);
    axis off; 
    title('optical image'); 
    disp('Click two points which encompass the GB we are interested in')
    [x,y] = ginput(2); 
    %Now we determine the line between those points
    len = sqrt(abs(x(1)-x(2))^2 + abs(y(1)-y(2))^2); %pixels 
    %Let's extend the length just to have more to work with
    len = len*2; 
    angle = atan((y(2)-y(1))/(x(2)-x(1))); %radians
    new_angle = angle + (pi/2); %we want something which is orthogonal
    midpoint = [mean([x(1),x(2)]),mean([y(1),y(2)])];
    new_endpoint_1 = [midpoint(1)-cos(new_angle)*(len/2),midpoint(2)-sin(new_angle)*(len/2)];
    new_endpoint_2 = [midpoint(1)+cos(new_angle)*(len/2),midpoint(2)+sin(new_angle)*(len/2)]; 
    %Calculate the length of this line in pixels
    len_x = abs(new_endpoint_1(1)-new_endpoint_2(1));
    len_y = abs(new_endpoint_1(2)-new_endpoint_2(2)); 
    ls_len = sqrt((len_x^2)+(len_y^2)); %pixels
    %Now we also need the conversion
    figure(im); 
    disp('Click bottom corners to determine conversion from pixels');
    [x,y] = ginput(2); 
    len = sqrt(abs(x(1)-x(2))^2 + abs(y(1)-y(2))^2); %pixels
    %Now we hard code that this is 1 cm
    conv = (1e4)/len; %microns/pixel
    ls_len = ls_len*conv; %now this length should be in microns
    linescan_tau = improfile(PL_uni_inj,[new_endpoint_1(1),new_endpoint_2(1)],[new_endpoint_1(2),new_endpoint_2(2)]); 
    linescan_LP = improfile(LP_map,[new_endpoint_1(1),new_endpoint_2(1)],[new_endpoint_1(2),new_endpoint_2(2)]); 
    linescan_store{i} = [linescan_LP,linescan_tau]; 
    %Let's save a vector of the "length"
    %Let's make an appropriate vector
    linescan_length{i} = linspace(0,ls_len,length(linescan_tau)); 
    
    figNow = figure('units','normalized','outerposition',[0 0 1 1]);
    %The first image is the optical image
    subplot(3,2,1); 
    range_im = max(max(optical_image))-min(min(optical_image)); 
    imagesc(optical_image,[0.05*range_im+min(min(optical_image)) 0.8*range_im+min(min(optical_image))]); 
    axis('image');
    colormap(gray);
    axis off; 
    title('optical image'); 
    %The next image is the lifetime
    subplot(3,2,3); 
    imagesc(PL_uni_inj);
    axis('image');
    colorbar;
    colormap(gray);
    axis off; 
    title('lifetime [\mus]'); 
    %The third image is the laser power map
    subplot(3,2,5); 
    imagesc(LP_map); 
    axis('image');
    colorbar;
    colormap(gray);
    axis off; 
    title(['LP at injection = ' num2str(injection,'%1.1E')]); 
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
    subplot(3,2,4); 
    plot(linescan_tau,'r','LineWidth',3); 
    ylabel('lifetime [\mus'); 
    subplot(3,2,6); 
    semilogy(linescan_LP,'r','LineWidth',3); 
    ylabel('LP'); 
    tightfig(figNow); 
    hgsave(figNow,[dirname '\' samples{i} '_linescans_uni_inj']);
    print(figNow,'-dpng','-r0',[dirname '\' samples{i} '_linescans_uni_inj.png']); 
    close all; 
end

%% Plot line scans from maps that have unified injection level
clear all; close all; 
%where is everything located
dirname = 'C:\Users\Mallory Jensen\Documents\LeTID\XRF\PCPL April 19 2017'; 

%Which samples do I want to compare?
samples_to_analyze = {'PS-1_10s','PSH-1_10s','PSL-1_10s','SAL-1_30s','SAH-1_30s','SA-1_30s'}; 

tau_raw = figure('units','normalized','outerposition',[0 0 1 1]);
LP_raw = figure('units','normalized','outerposition',[0 0 1 1]);
tau_norm = figure('units','normalized','outerposition',[0 0 1 1]);
LP_norm = figure('units','normalized','outerposition',[0 0 1 1]);
save_data = cell(size(samples_to_analyze)); 

%Load the linescan data
load([dirname '\Linescans_uni_inj.mat']);
for i = 1:length(samples_to_analyze)
    %find the index in our old storage method
    index = find(strcmp(samples_to_analyze{i},samples)==1); 
    linescan_now = linescan_store{index}; 
    ls_length_now = linescan_length{index}'; 
    %Center the scan based on the presumed location of the GB
    figure;
    plot(ls_length_now,linescan_now(:,2)); 
    disp('Click what you think is the center of the linescan')
    [x,y] = ginput(1); 
%     x_center = ls_length_now(find(abs(ls_length_now-x)==min(abs(ls_length_now-x)))); 
    x_new = ls_length_now-x; 
%     x_center = round(x); 
%     x_before = linspace(1,length(linescan_now(:,1)),length(linescan_now(:,1))); 
%     x_new = x_before-x_center; 
    %The first column is the injection level
    figure(LP_raw); 
    hold all; 
    plot(x_new,linescan_now(:,1),'LineWidth',3); 
    LP_norm_linescan = (linescan_now(:,1)-min(linescan_now(:,1)))./(max(linescan_now(:,1))-min(linescan_now(:,1))); 
    figure(LP_norm); 
    hold all;
    plot(x_new,LP_norm_linescan,'LineWidth',3); 
    %The second column is the lifetime
    figure(tau_raw); 
    hold all;
    plot(x_new,linescan_now(:,2),'LineWidth',3); 
    tau_norm_linescan = (linescan_now(:,2)-min(linescan_now(:,2)))./(max(linescan_now(:,2))-min(linescan_now(:,2))); 
    figure(tau_norm); 
    hold all;
    plot(x_new,tau_norm_linescan,'LineWidth',3);
    save_data{i} = [x_new,linescan_now(:,2)]; 
end
figure(tau_raw); 
xlabel('pixel'); 
ylabel('lifetime [\mus]'); 
legend(samples_to_analyze');
figure(tau_norm); 
xlabel('pixel'); 
ylabel('norm. lifetime [-]'); 
legend(samples_to_analyze');
figure(LP_raw); 
xlabel('pixel'); 
ylabel('LP'); 
legend(samples_to_analyze');
figure(LP_norm); 
xlabel('pixel'); 
ylabel('norm. LP [-]'); 
legend(samples_to_analyze');
tightfig(tau_raw); 
tightfig(tau_norm); 
tightfig(LP_raw);
tightfig(LP_norm); 
%Save the figures
hgsave(tau_raw,[dirname '\Lifetime linescans_wLen_uni_inj']);
print(tau_raw,'-dpng','-r0',[dirname '\Lifetime linescans_wLen_uni_inj.png']); 
hgsave(tau_norm,[dirname '\Norm lifetime linescans_wLen_uni_inj']);
print(tau_norm,'-dpng','-r0',[dirname '\Norm lifetime linescans_wLen_uni_inj.png']);
hgsave(LP_raw,[dirname '\LP linescans_wLen_uni_inj']);
print(LP_raw,'-dpng','-r0',[dirname '\LP linescans_wLen_uni_inj.png']); 
hgsave(LP_norm,[dirname '\Norm LP linescans_wLen_uni_inj']);
print(LP_norm,'-dpng','-r0',[dirname '\Norm LP linescans_wLen_uni_inj.png']); 

    


    