%{
MIT License

Copyright (c) [2016] [Mallory Ann Jensen, jensenma@alum.mit.edu]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
%}

%Simple processing script for lifetime, PC-PL data comparison
clear all; close all; 

filenameSintonCircle = 'C:\Users\Mallory\Documents\Non-contact crucible\9-15-2015 experiment TR+Amanda\Lifetime stage 1\PC-PL\PCPL_10-2-2015\Sinton_circle_1.txt';

%Get PL data
load('C:\Users\Mallory\Documents\Non-contact crucible\9-15-2015 experiment TR+Amanda\Lifetime stage 1\PC-PL\19-2\19-2_PCPL_CodeFix.mat');
deltanLifetime = deltan; 
tauLifetime = tau; 

%Get QSSPC data 
load('C:\Users\Mallory\Documents\Non-contact crucible\9-15-2015 experiment TR+Amanda\Lifetime stage 1\No box\19-2\LifetimeData.mat');
deltanQSSPC = deltanq; 
tauQSSPC = tau_mean.*1e6; 

compare_QSSPC_lifetime(deltanQSSPC,tauQSSPC,deltanLifetime,tauLifetime,filenameSintonCircle);
