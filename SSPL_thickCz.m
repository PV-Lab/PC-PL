% Converts PL images (txt files) into images of minority
% carrier density, lifetime, and iron point defect concentration. 

% adjust experimental parameters and sample information

%1-5-15 - revised to use "Sinton circle_1.txt" instead of
%"Sinton_circle_1.txt."

clear all; close all;

%Laser flux as measured with silicon reference diode on Dec 18-2014 and Dec
%19-2014 (average) @ 60%
%LP
Flux_808 = 1.002033e17; %cm^-2/s

%sample thickness
sample.d = 0.0180; %cm, thin
sample.R = 0.3; %sample reflectivity
sample.N_A = 3.1e15; %cm^-3, resistivity = 4.5, ptype doping, thin

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

save('thick_calibration_60LP_121814.mat','sample','G','Flux_808');