%Simple processing script for lifetime, PC-PL data comparison
clear all; close all; 

filenameSintonCircle = 'C:\Users\Mallory\Documents\Non-contact crucible\9-15-2015 experiment TR+Amanda\Lifetime stage 1\PC-PL\PCPL_10-2-2015\Sinton_circle_1.txt';

%Get PL data
load('C:\Users\Mallory\Documents\Non-contact crucible\9-15-2015 experiment TR+Amanda\Lifetime stage 1\PC-PL\15-9-21-N\15-9-21-N_PCPL_CodeFix.mat');
deltanLifetime = deltan; 
tauLifetime = tau; 

%Get QSSPC data 
load('C:\Users\Mallory\Documents\Non-contact crucible\9-15-2015 experiment TR+Amanda\Lifetime stage 1\No box\15-9-21-N\LifetimeData.mat');
deltanQSSPC = deltanq; 
tauQSSPC = tau_mean.*1e6; 

compare_QSSPC_lifetime(deltanQSSPC,tauQSSPC,deltanLifetime,tauLifetime,filenameSintonCircle);
