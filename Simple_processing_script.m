%Simple processing script for lifetime, PC-PL data comparison
clear all; close all; 

filenameSintonCircle = 'C:\Users\Mallory\Dropbox (MIT)\2015 Oxygen-State Study\NOC samples\NOC 17 21 22 study\PLI\November 25 2015\Sinton_circle_1.txt';

%Get PL data
load('21-102-5_PCPL.mat');
deltanLifetime = deltan; 
tauLifetime = tau; 

%Get QSSPC data 
load('C:\Users\Mallory\Dropbox (MIT)\2015 Oxygen-State Study\NOC samples\NOC 17 21 22 study\November 2015\One Day after Anneal\21-102-5\average_data.mat');
deltanQSSPC = deltanq; 
tauQSSPC = tau_mean.*1e6; 

compare_QSSPC_lifetime(deltanQSSPC,tauQSSPC,deltanLifetime,tauLifetime,filenameSintonCircle);
