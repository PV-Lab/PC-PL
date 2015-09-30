function [PLmaps,deltan,tau,deltatau]=process_PL(sample_no,calibration,LP,Flux_808_input,exposure)
% Read the data

%Populate the filename array 
samples = cell(length(LP),length(sample_no));
delimiterIn = ',';
headerlinesIn = 0;

for i = 1:length(sample_no)
    for j = 1:length(LP)
        textFilename = [sample_no{i} '_' num2str(exposure) 's_' num2str(LP(j)) 'LP_1.txt'];
        samples{j,i}=textFilename;
    end
end

PLmaps = cell(length(LP),length(sample_no)); 
for i = 1:length(sample_no);
    for j = 1:length(LP)
        filename = samples{j,i};
        PLmap = importdata(filename,delimiterIn,headerlinesIn);
        PLmap = PLmap(:,1:end)./exposure; %counts/second

        figure;
        tca=imagesc(PLmap);
        axis('image');
        colorbar;
        a = colormap(gray);

        %Edit this title based on your sample details
        title(['Sample ' sample_no{i} ' ' LP(j)],'FontSize',20);
        set(gca,'Xtick',[]);
        set(gca,'Ytick',[]);
        PLmaps{j,i} = PLmap;
    end
end

%Process the data into lifetime
load(calibration);

G = Flux_808_input.*(1-sample.R)./sample.d; %generation rate, assuming uniform generation throughout

PL_percent = 4.4;

for i = 1:length(sample_no)
    for j = 1:length(LP)
        
        %Get the PL map for this particular experiment
        PLnow = PLmaps{j,i};
        
        indices = find(PLnow<0);
        PLnow(indices) = 0; %if the PL counts are negative, set them equal to zero
        
        %Calculate the excess carrier density using the calibration and store it  
        deltan{j,i} = (-sample.b+abs(sqrt(sample.b^2-4*sample.a.*(sample.c-PLnow))))./(2*sample.a);

        %Calculate the lifetime using the generation rate and store it
        tau{j,i} = (deltan{j,i}./G(j)) .* 1e6; %microseconds
        
        %Calculate the lifetime error by error propagation
        PL_error = PLnow.*(PL_percent/100);
        deltatau{j,i} = (1/G(i)).*(1e6).*(abs((sample.b^2-4*sample.a.*(sample.c-PLnow)).^(-1/2))).*PL_error;

        %Plot the resulting lifetime
        figure; 
        imagesc(tau{j,i});
        axis('image');
        colorbar;
        colormap(gray);
        title(['Lifetime of sample ' sample_no{i} ' at LP ' num2str(LP(j))]);

        figure;
        imagesc(deltan{j,i});
        axis('image');
        colorbar;
        colormap(gray);
        title(['Injection level of sample ' sample_no{i} ' at LP ' num2str(LP(j))]);
        
    end
end





