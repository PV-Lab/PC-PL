%Simple processing script for lifetime, PC-PL data comparison
clear all; close all; 

filenameSintonCircle = 'C:\Users\Mallory\Documents\Non-contact crucible\9-15-2015 experiment TR+Amanda\Lifetime stage 1\PC-PL\Sinton_circle_1.txt';

%Get PL data
load('C:\Users\Mallory\Documents\Non-contact crucible\9-15-2015 experiment TR+Amanda\Lifetime stage 1\PC-PL\124-6\124-6_PCPL_Excel.mat');
deltanLifetime = deltan; 
tauLifetime = tau; 

%Get QSSPC data 
load('C:\Users\Mallory\Documents\Non-contact crucible\9-15-2015 experiment TR+Amanda\Lifetime stage 1\No box\124-6\LifetimeData.mat');
deltanQSSPC = deltanq; 
tauQSSPC = tau_mean.*1e6; 

compare_QSSPC_lifetime(deltanQSSPC,tauQSSPC,deltanLifetime,tauLifetime,filenameSintonCircle);
