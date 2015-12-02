%Process series of lifetime images

%Where to get the PLI .txt files, including the first part of the sample
%name
sample_no = {'C:\Users\Mallory\Dropbox (MIT)\2015 Oxygen-State Study\NOC samples\NOC 17 21 22 study\PLI\November 25 2015\21-102-5'};

%Where to get the calibration file
calibration = '21-102-5_calibration.mat';

%Exposure time for these sames (s)
exposure = 10;

%LP that you want to process the maps at (and that you have flux parameters
%for
LP = [40 50 60];

%Flux values that correspond to the above LP values
Flux_808 = [5.033421e16 7.455171e16 9.847541e16];

%Grab the calibrated PL maps
[PLmaps,deltan,tau,deltatau]=process_PL(sample_no,calibration,LP,Flux_808,exposure);

%Save the data
save('21-102-5_PCPL.mat','PLmaps','deltan','tau','deltatau','Flux_808','LP','sample_no','exposure')