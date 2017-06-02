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

%Make a PL image from files
clear all; close all; 
directory = 'C:\Users\Mallory Jensen\Documents\LeTID\XRF\PL new ROI\Mallory GB samples\all ASCII';
sample_name = {'PSH-1_1_optical' 'PSH-1_2_optical' 'PSH-1_3_optical' 'PSH-1_1_PLl' 'PSH-1_2_PLl' 'PSH-1_3_PLI'}; 
exposure = [10,10,10,10,10,10]; 
LP = [80]; 

for i = 1:length(sample_name)
    for k = 1:length(LP)
        filename = [directory '\' sample_name{i} '_' num2str(exposure(i)) 's_' num2str(LP(k)) 'LP_1.txt'];
        delimiterIn = ',';
        headerlinesIn = 0;
        PLmap = importdata(filename,delimiterIn,headerlinesIn);
%         PLmap = PLmap(:,2:end)./exposure(i); %counts/second
        PLmaps_store{i,k} = PLmap; 
        minvalue = min(min(PLmap));
        maxvalue = max(max(PLmap));
        scaled = (PLmap-minvalue)./(maxvalue-minvalue);
        h=figure;
        imagesc(scaled);
        axis('image');
        colormap('gray');
        caxis([0 1]);
        colorbar; 
        axis off; 
        title([sample_name{i} ', LP = ' num2str(LP(k))],'FontSize',20); 
        hgsave(h,[directory '\' sample_name{i} '_' num2str(LP(k))]);
        print(h,'-dpng','-r0',[directory '\' sample_name{i} '_' num2str(LP(k)) '.png']); 
    end
end