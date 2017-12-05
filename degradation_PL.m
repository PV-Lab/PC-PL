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

%Processing PL data - degradation at different points
%Written by Mallory Jensen
%October 17, 2017
%% Get the average injection levels
clear all; close all; clc; 
%the PL maps should already be calibrated and saved as .mat files
%Locations of the different PL maps corresponding to different times
initial_PL = 'C:\Users\Mallory Jensen\Documents\LeTID\PDG\round 2 data\from SERIS\PL\Summary\initial'; 
% deg_PL_1 = 'C:\Users\Mallory Jensen\Documents\LeTID\Dartboard\Repassivated samples\PCPL\8000s PL'; 
times = {'0s'}; 
dirnames = {initial_PL};

%Samples analyzed
samples = {'1-6','2-6','3-6','4-6','5-6','6-6','7-6','8-6'}; 

deltan_avg = cell(size(samples)); 
%Loop over and do the same thing for each sample
for i = 1:length(samples)
    %Loop over and do the same thing for each time measured
    for j = 1:length(times)
        %Make the filename
        filename = [dirnames{j} '\' samples{i} '_calibrated.mat']; 
        load(filename); 
        %The variables we have: 'PLmaps','deltan','tau','LP','exp_sample',
        %'Flux_808','calibration','doping_samp','optical_map'); 
        %Loop over the laser powers
        if j == 1
            deltan_avg_now = zeros(length(times),length(LP));
        end
        for k = 1:length(LP)
            deltan_now = deltan{k}; 
            %Now crop and get an average of the injection level
            if i==1 && j == 1 && k == 1
                [deltan_now,x_crop,y_crop]=crop_PL(deltan_now);
            else
                %crop according to the first attempt
                [m,n] = size(deltan_now);
                %Get rid of highest y values we don't want
                deltan_now(floor(y_crop(2)):m,:) = [];
                %Get rid of highest x values we don't want
                deltan_now(:,floor(x_crop(2)):n) = [];
                %Get rid of lowest y values we don't want
                deltan_now(1:floor(y_crop(1)),:) = [];
                %Get rid of lowest x values we don't want
                deltan_now(:,1:floor(x_crop(1))) = [];
                %Show us the result just for a visual confirmation
                figure;
                imagesc(deltan_now);
                axis('image');
                colormap(gray);
            end
            [linear,M_p] = tau_averages(deltan_now); 
            deltan_avg_now(j,k) = M_p; 
        end
    end
    deltan_avg{i} = deltan_avg_now; 
end

%% Compare degradation points
%Now we need to decide which laser powers to compare throughout degradation based on the averages
clear all; close all; clc; 
%the PL maps should already be calibrated and saved as .mat files
%Locations of the different PL maps corresponding to different times
initial_PL = 'C:\Users\Mallory Jensen\Documents\LeTID\PDG\round 2 data\from SERIS\PL\Summary\initial'; 
% deg_PL_1 = 'C:\Users\Mallory Jensen\Documents\LeTID\Dartboard\Repassivated samples\PCPL\8000s PL'; 
times = {'0s'}; 
dirnames = {initial_PL};
savedirname = 'C:\Users\Mallory Jensen\Documents\LeTID\PDG\round 2 data\from SERIS\PL\Summary\initial';

%Samples analyzed
samples = {'1-6','2-6','3-6','4-6','5-6','6-6','7-6','8-6'}; 

%Laser power indices to match
lps = {[2],[1],[2],[1],[2],[1],[1],[2]}; 

%Loop over and do the same thing for each sample
for i = 1:length(samples)
    deg_plots = figure('units','normalized','outerposition',[0 0 1 1]); 
    tau_maps = cell(size(times)); 
    optical_maps = cell(size(times)); 
    lps_now = lps{i}; 
    %Loop over and do the same thing for each time measured
    for j = 1:length(times)
        %Make the filename
        filename = [dirnames{j} '\' samples{i} '_calibrated.mat']; 
        load(filename); 
        %The variables we have: 'PLmaps','deltan','tau','LP','exp_sample',
        %'Flux_808','calibration','doping_samp','optical_map'); 
        %Loop over the laser powers
        %We need to get the right laser power  for this sample
        tau_now = tau{lps_now(j)}; 
        tau_maps{j} = tau_now; 
        optical_maps{j} = optical_map; 
        h=figure; 
        %Then plot the first image
        imagesc(tau_now);
        axis('image');
        axis off; 
        colormap('gray');
        colorbar; 
        title([times{j} ', LP = ' num2str(LP(lps_now(j)))]); 
        %Save the figure
        set(h,'defaultAxesFontSize', 20)
        hgsave(h,[savedirname '\' samples{i} '_' times{j} '_' num2str(LP(lps_now(j))) 'LP']);
        print(h,'-dpng','-r0',[savedirname '\' samples{i} '_' times{j} '_' num2str(LP(lps_now(j))) 'LP.png']);
        if j == 1
            figure(deg_plots); 
            %Then plot the first image
            subplot(3,length(times),j); 
            imagesc(tau_now);
            axis('image');
            axis off; 
            colormap('gray');
            colorbar; 
            title([times{j} ', LP = ' num2str(LP(lps_now(j)))]); 
        else
            %Then we need to align this map to the original map
            [tau_aligned]=align_maps(tau_maps{1},tau_now);
            %Plot the new aligned map
            figure(deg_plots); 
            subplot(3,length(times),j); 
            imagesc(tau_aligned);
            axis('image');
            axis off; 
            colormap('gray');
            colorbar; 
            title([times{j} ', LP = ' num2str(LP(lps_now(j)))]);
            %Now also make a difference map relative to the initial
            diff_map = tau_aligned./tau_maps{1}; 
            subplot(3,length(times),length(times)+j); 
            imagesc(diff_map);
            axis('image');
            axis off; 
            caxis([0 1]);
            colormap('gray');
            colorbar; 
            title(['ratio ' times{j}]);
            %Plot the effective defect density
            ntstar = (1./tau_aligned)-(1./tau_maps{1}); 
            index = find(isinf(ntstar)==1); 
            ntstar(index) = 0;
            subplot(3,length(times),2*length(times)+j); 
            imagesc(ntstar);
            axis('image');
            axis off; 
            caxis([1e-5 5e-1]);
            colormap('gray');
            colorbar; 
            title(['N_t^* [\mus^{-1}] ' times{j}]);
        end
    end
    %Save the figure
    set(deg_plots,'defaultAxesFontSize', 20)
    hgsave(deg_plots,[savedirname '\' samples{i} '_PCPL_summary']);
    print(deg_plots,'-dpng','-r0',[savedirname '\' samples{i} '_PCPL_summary.png']);
end
    