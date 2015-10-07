% Converts PL images (txt files) into images of minority
% carrier density, lifetime, and iron point defect concentration. 

% adjust experimental parameters and sample information

%1-5-15 - revised to use "Sinton circle_1.txt" instead of
%"Sinton_circle_1.txt."

clear all; close all;

%sample thickness
sample.d = 0.0280; %cm
sample.R = 0.3; %sample reflectivity
sample.N_A = 1.9e15; %cm^-3, resistivity = 1.7, ntype doping

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

save('test.mat','sample');