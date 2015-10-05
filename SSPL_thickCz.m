% Converts PL images (txt files) into images of minority
% carrier density, lifetime, and iron point defect concentration. 

% adjust experimental parameters and sample information

%1-5-15 - revised to use "Sinton circle_1.txt" instead of
%"Sinton_circle_1.txt."

clear all; %close all;

%Laser flux as measured with silicon reference diode at the desired LP
%LP
Flux_808 = 4.608460e16; %cm^-2/s, 40% LP
% Flux_808 = 6.84514e16; %cm^-2/s, 50% LP
% Flux_808 = 9.077156e16; %cm^-2/s, 60% LP

%sample thickness
sample.d = 0.0180; %cm
sample.R = 0.3; %sample reflectivity
sample.N_A = 2.8e15; %cm^-3, resistivity = 1.7, ntype doping

if true
    [p] = calibration_thick;
    %save('last_calibration.mat','p');
else
    load('last_calibration.mat','p');
end

pnow = p{1};
sample.a = pnow(1);
sample.b = pnow(2);
sample.c = pnow(3);

G = Flux_808*(1-sample.R)/sample.d; %generation rate, assuming uniform generation throughout

save('19-3_5s_calibration.mat','sample','G','Flux_808');