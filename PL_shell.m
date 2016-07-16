%Make a PL image from files
clear all; close all; 
directory = 'C:\Users\Mallory\Documents\Australia\Passivation run';
sample_name = {'A99-2'}; 
exposure = [10,10]; 
LP = [30]; 

for i = 1:length(sample_name)
    for k = 1:length(LP)
        filename = [directory '\' sample_name{i} '_' num2str(exposure(i)) 's_' num2str(LP(k)) 'LP_1.txt'];
        delimiterIn = ',';
        headerlinesIn = 0;
        PLmap = importdata(filename,delimiterIn,headerlinesIn);
        PLmap = PLmap(:,2:end)./exposure(i); %counts/second
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