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
directory = 'C:\Users\Mallory Jensen\Documents\LeTID\PDG\as-received lifetimes\PLI';
sample_name = {'SD-2-2','SD-2-4','SD-3-1','SD-3-2','SD-3-4','SD-4-1','SD-4-2',...
    'SD-4-4','SD-5-1','SD-5-2','SD-5-4','SD-6-1','SD-6-2','SD-6-4','SD-7-1',...
    'SD-7-4','SD-8-1','SD-8-4','SD-FZ-1'}; 
exposure = 30.*ones(size(sample_name)); 
LP = [60]; 

for i = 1:length(sample_name)
    for k = 1:length(LP)
        filename = [directory '\' sample_name{i} '_' num2str(exposure(i)) 'sec_' num2str(LP(k)) 'LP_1.txt'];
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