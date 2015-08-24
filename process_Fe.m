%Process Sergio's samples

clear all; close all;


%% Read the data
%Enter the laser powers (%) at which images were taken
LP = [22];

%Enter the exposure time
exposure = 10; %seconds

%Enter the same number as a string
sample_no = {'C64'};

%Experiments that were run
experiments = {'After' 'Before'};

%Populate the filename array 
samples = cell(length(experiments),length(sample_no));
delimiterIn = ',';
headerlinesIn = 0;

for i = 1:length(sample_no)
    for cc=1:length(experiments)  
        textFilename = [sample_no{i} '_' num2str(exposure) 's_' num2str(LP) 'LPSMOOTH_' experiments{cc} '_1.txt'];
        samples{cc,i}=textFilename;
    end
end

PLmaps = cell(length(experiments),length(sample_no)); 
for i = 1:length(sample_no);
    for cc = 1:length(experiments)
        filename = samples{cc,i};
        PLmap = importdata(filename,delimiterIn,headerlinesIn);
        PLmap = PLmap(:,1:end)./exposure; %counts/second

        figure;
        tca=imagesc(PLmap);
        axis('image');
        colorbar;
        a = colormap(gray);

        %Edit this title based on your sample details
        title(['Sample ' sample_no{i} ' ' experiments{cc}],'FontSize',20);
        set(gca,'Xtick',[]);
        set(gca,'Ytick',[]);
        PLmaps{cc,i} = PLmap;
    end
end

%% Now Process the Data

%calibration data from Sergio, assuming something for N_A,R and d
sample.b = 1.3628191460E-13;
sample.a = 2.3549133092E-29;
sample.c = 0;
sample.R = 0.3;
sample.d = 0.0175; %cm
Flux_808 = 8.872230E+15;
G = Flux_808*(1-sample.R)/sample.d; %generation rate, assuming uniform generation throughout
N_A = 1.5e16; 
sample.N_A = 3.1e15; 

sample.b = sample.b*N_A/sample.N_A; 

%Define the structures that we will fill up in the for loop
tau = cell(length(experiments),1);
deltan = cell(length(experiments),1);
deltatau = cell(length(experiments),1); %this will contain the error in lifetime for each map
iron = cell(1,1);
iron_zero = cell(1,1);
error_save = cell(1,1); %this will contain the propagated iron error
clim_tau = [0 50];
clim_Fe = [0 1e12];

PL_percent = 4.4;


    
for j = 1:length(experiments)    

    %Get the PL map for this particular experiment
    PLnow = PLmaps{j,1};

    indices = find(PLnow<0);
    PLnow(indices) = 0; %if the PL counts are negative, set them equal to zero

    %Calculate the excess carrier density using the calibration and store it  
    deltan{j,1} = (-sample.b+abs(sqrt(sample.b^2-4*sample.a.*(sample.c-PLnow))))./(2*sample.a);

    %Calculate the lifetime using the generation rate and store it
    tau{j,1} = (deltan{j,1}./G) .* 1e6; %microseconds

    %Calculate the lifetime error by error propagation
    PL_error = PLnow.*(PL_percent/100);
    deltatau{j,1} = (1/G).*(1e6).*(abs((sample.b^2-4*sample.a.*(sample.c-PLnow)).^(-1/2))).*PL_error;

    %Plot the resulting lifetime
    figure; 
    imagesc(tau{j,1},clim_tau);
    axis('image');
    colorbar;
    colormap(gray);
    title(['Lifetime in state ' experiments{j}]);

    figure;
    imagesc(deltan{j,1},[0 1e13]);
    axis('image');
    colorbar;
    colormap(gray);
    title(['Injection level in state ' experiments{j}]);

end

%Get the C values (should be a matrix)
n_dark = deltan{2,1}; %FeB
n_illum = deltan{1,1}; %Fe-i
[C] =  Ccalculator_Schmidt(N_A, n_dark, n_illum);

%Convert the lifetimes to seconds
tau_dark = tau{2,1}.*1e-6; %seconds
tau_illum = tau{1,1}.*1e-6; %seconds

%Calculate the concentration using our previously defined C matrix
Fe = C.*((1./tau_dark)-(1./tau_illum));

%Calculated total error due to variation in PL measurement
dtau_dark = deltatau{2,1};
dtau_illum = deltatau{1,1};
quantity1 = C./(tau_dark.^2);
quantity1 = quantity1.*(dtau_dark.*1e-6);
quantity2 = C./(tau_illum.^2);
quantity2 = quantity2.*(dtau_illum.*1e-6);
error = ((quantity1.^2)+(quantity2.^2)).^(1/2);
error_save{1} = error;

%Make NaN any negative Fe entries because these don't make sense
index = find(Fe<=0);
Fe(index) = NaN; 

iron = Fe;

figure;
imagesc(Fe,clim_Fe);
axis('image');
colorbar;
colormap(gray);
title(['Iron concentration']);
figure;
imagesc(error,clim_Fe);
axis('image');
colorbar;
colormap(gray);
title(['Error in Iron concentration']);

indices = find(Fe<error); 
Fe_error = Fe; 
Fe_error(indices) = 0; 
figure;
imagesc(Fe_error,clim_Fe);
axis('image');
colorbar;
colormap(gray);
title('Iron concentration with Fe<error = 0');

