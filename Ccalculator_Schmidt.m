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

%This function has been edited on 10/16/14 so that it contains defect
%values from Schmidt, JPV, 2013. It has also been edited so that it is
%using the same method for parameter calculation as chromium script. 

function [C] =  Ccalculator_Schmidt(N_A, n_dark, n_illum)

%inputs
deltaN_d = n_dark;
deltaN_i = n_illum;

%constants
T = 300;    %K
k = 8.6173324e-5; %eV/K, Boltzmann
Nc = 2.84e19; %cm^-3, at room temperature, PVCDROM
Nv = 2.68e19; %cm^-3, at room temperature, PVCDROM
Eg = 1.1242; %eV, bandgap of silicon at room temperature

nu_th_e=1e7; 
nu_th_p=1e7; 


%FeB properties
EcEt_FeB = 0.26; %eV
EtEv_FeB = Eg-EcEt_FeB; %eV

n1_Fe_B = Nc*exp(-EcEt_FeB/(k*T));
p1_Fe_B = Nv*exp(-EtEv_FeB/(k*T));

sigma_e_Fe_B=5e-15;
sigma_p_Fe_B=3e-15; 
k_FeB = sigma_e_Fe_B/sigma_p_Fe_B;

%Fe_i properties
EtEv_Fei = 0.38;
EcEt_Fei = Eg-EtEv_Fei; %eV

n1_Fe_i = Nc*exp(-EcEt_Fei/(k*T));
p1_Fe_i = Nv*exp(-EtEv_Fei/(k*T));

sigma_e_Fe_i=1.3e-14; 
sigma_p_Fe_i=7e-17;   
k_Fei = sigma_e_Fe_i/sigma_p_Fe_i;

%Calculate the relevant quantities for Fei and FeB after association (dark). If
%deltaN_d is a matrix, chi will also be a matrix.
X_Fei_assoc = (nu_th_e.*sigma_e_Fe_i.*(N_A+deltaN_d))./(N_A+p1_Fe_i+deltaN_d+(k_Fei.*(n1_Fe_i+deltaN_d))); 
X_FeB_assoc = (nu_th_e.*sigma_e_Fe_B.*(N_A+deltaN_d))./(N_A+p1_Fe_B+deltaN_d+(k_FeB.*(n1_Fe_B+deltaN_d)));

%Calculate the relevant quantities for Fei and FeB after dissociation (light). If
%deltaN_i is a matrix, chi will also be a matrix. 
X_Fei_dissoc = (nu_th_e.*sigma_e_Fe_i.*(N_A+deltaN_i))./(N_A+p1_Fe_i+deltaN_i+(k_Fei.*(n1_Fe_i+deltaN_i))); 
X_FeB_dissoc = (nu_th_e.*sigma_e_Fe_B.*(N_A+deltaN_i))./(N_A+p1_Fe_B+deltaN_i+(k_FeB.*(n1_Fe_B+deltaN_i)));

%Fei in dissociated state
f_dissoc_Fei = .99;
%FeB in dissociated state
f_dissoc_FeB = 1-f_dissoc_Fei;
%Fei in associated state
f_assoc_Fei = 0.01;
%FeB in associated state
f_assoc_FeB = 1-f_assoc_Fei;

%Calculate factor C for partially dissociated/associated pairs This will be
%a matrix if the chi's are matrices. 
C = ((f_assoc_FeB.*X_FeB_assoc)+(f_assoc_Fei.*X_Fei_assoc)-(f_dissoc_Fei.*X_Fei_dissoc)-(f_dissoc_FeB.*X_FeB_dissoc)).^-1; 