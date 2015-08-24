function [Cr,error,Cr_correct,Cr_zero,Cr_error,store_ltz,store_lte,store_nanerror] = calculate_Cr_Schmidt(N_A,T_assoc,T_dissoc,time,tau_Cri,dtau_Cri, deltan_Cri,tau_CrB,dtau_CrB, deltan_CrB)
%This function was edited on 10/16/14 to include defect values from Schmidt
%JPV 2013. 

%This function was created by Mallory Jensen on April 24, 2014 to calculate
%chromium concentrations in p-type material, given an appropriately
%designed experiment. The function takes as input the experimental
%parameters N_A (doping concentration in cm^-3), T_assoc (temperature
%samples were held at for CrB pair association, in Celcius), T_dissoc
%(temperature samples were held at for CrB dissociation, in Celcius), and
%time (time samples were held to dissociate pairs, in seconds). The results
%for lifetime (microseconds) at specified deltan (cm^-3) for each state are
%also inputs. These can be matrices that correspond to images.

%This value determined from measuring PL of a float zone sample for many
%frames and determining standard deviation. Then, standard deviation is
%converted to an error in lifetime using the same calibration used for the
%real samples.
%deltatau = 0.0038;

%% Calculate experimental parameters

%Experimental inputs
Tkelvin_assoc = T_assoc+273.15; %degrees Kelvin
Tkelvin_dissoc = T_dissoc+273.15; %degrees Kelvin

%Constants needed for calculation
Em = 0.79; %eV, migration enthalpy, Habenicht 2010
kB = 8.6173324e-5; %eV/K, Boltzmann
D0 = 6.8e-4; %cm^2/s, Habenicht 2010
D_Cri = D0*exp(-Em/(kB*Tkelvin_assoc)); %cm^2/s, Habenicht 2010
tau_assoc = (577*Tkelvin_assoc)/(N_A*D_Cri); %seconds, Habenicht 2010
A = 5e22; %cm^-3, Habenicht 2010
E_A = 0.56; %eV, Habenicht 2010

%ratio of CrB pairs to total Cr after association (this is written
%incorrectly in the paper)
f_assoc = 1-exp(-time/tau_assoc); %Habenicht 2010

%fraction of pairs dissociated at temperature T_dissoc
ratio_dissoc = ((N_A/A)*exp(E_A/(kB*Tkelvin_dissoc))); %Habenicht 2010, CrB to Cri
f_dissoc_CrB = ratio_dissoc/(1+ratio_dissoc); 
f_dissoc_Cri = 1-f_dissoc_CrB;

%% Calculate the relevant quantities for the metastable defect

%Material parameters
vth = 1e7; %cm/s
N_D = 0; %no donor doping in this material because it is p=type
NC = 2.84e19; %cm^-3, at room temperature, PVCDROM
NV = 2.68e19; %cm^-3, at room temperature, PVCDROM
Eg = 1.1242; %eV, bandgap of silicon at room temperature

%Defect parameters for CrB
sigman_CrB = 2e-14; %electron capture cross section of CrB, Schmidt 2013
sigmap_CrB = 1e-14; %hole capture cross section of CrB, Schmidt 2013
k_CrB = sigman_CrB/sigmap_CrB; 
EtEv_CrB = 0.27; %eV, Schmidt 2013
EcEt_CrB = Eg-EtEv_CrB; %eV

%Defect parameters for Cri
sigman_Cri = 2e-14; %electron capture cross section of Cri, Schmidt 2013
sigmap_Cri = 4e-15; %hole capture cross section of Cri, Schmidt 2013
k_Cri = sigman_Cri/sigmap_Cri;
EcEt_Cri = 0.24; %eV, Schmidt 2013
EtEv_Cri = Eg-EcEt_Cri; %eV

%Cri SRH densities
n1_Cri = NC*exp(-EcEt_Cri/(kB*300)); 
p1_Cri = NV*exp(-EtEv_Cri/(kB*300));

%CrB SRH densities
n1_CrB = NC*exp(-EcEt_CrB/(kB*300)); 
p1_CrB = NV*exp(-EtEv_CrB/(kB*300));

%Calculate the relevant quantities for Cri and CrB after association. If
%deltan_CrB is a matrix, chi will also be a matrix.
chi_Cri_assoc = (vth.*sigman_Cri.*(N_A+N_D+deltan_CrB))./(N_A+p1_Cri+deltan_CrB+(k_Cri.*(N_D+n1_Cri+deltan_CrB))); 
chi_CrB_assoc = (vth.*sigman_CrB.*(N_A+N_D+deltan_CrB))./(N_A+p1_CrB+deltan_CrB+(k_CrB.*(N_D+n1_CrB+deltan_CrB)));

%Calculate the relevant quantities for Cri and CrB after dissociation. If
%deltan_Cri is a matrix, chi will also be a matrix. 
chi_Cri_dissoc = (vth.*sigman_Cri.*(N_A+N_D+deltan_Cri))./(N_A+p1_Cri+deltan_Cri+(k_Cri.*(N_D+n1_Cri+deltan_Cri))); 
chi_CrB_dissoc = (vth.*sigman_CrB.*(N_A+N_D+deltan_Cri))./(N_A+p1_CrB+deltan_Cri+(k_CrB.*(N_D+n1_CrB+deltan_Cri)));

%Calculate factor C for partially dissociated/associated pairs This will be
%a matrix if the chi's are matrices. 
C = ((f_assoc.*chi_CrB_assoc)+((1-f_assoc).*chi_Cri_assoc)-(f_dissoc_Cri.*chi_Cri_dissoc)-(f_dissoc_CrB.*chi_CrB_dissoc)).^-1; 

%% Evaluate the lifetimes in each state to determine Cr concentration. 

%Convert the lifetimes to seconds
tau_Cri = tau_Cri.*1e-6; %seconds
tau_CrB = tau_CrB.*1e-6; %seconds

%Calculate the concentration using our previously defined C matrix
Cr = C.*((1./tau_CrB)-(1./tau_Cri)); %switched order of CrB, Cri with new defect parameters
Cr_zero = Cr;
Cr_error = Cr;


%Calculate total error
% quantity1 = C./(tau_CrB.^2); 
% quantity1 = quantity1.*(deltatau.*tau_CrB);
% quantity2 = -C./(tau_Cri.^2);
% quantity2 = quantity2.*(deltatau.*tau_Cri);
% error = ((quantity1.^2)+(quantity2.^2)).^(1/2);

%Revised calculate total error (9/11/2014)
quantity1 = C./(tau_CrB.^2);
quantity1 = quantity1.*(dtau_CrB.*1e-6);
quantity2 = C./(tau_Cri.^2);
quantity2 = quantity2.*(dtau_Cri.*1e-6);
error = ((quantity1.^2)+(quantity2.^2)).^(1/2);

index = find(Cr<0);
store_ltz = length(index);
Cr(index) = NaN; 
Cr_zero(index) = 0;
Cr_error(index) = error(index);

%Zero any Cr entries where the error is larger than the concentration
Cr_correct = Cr;
index_error = find(error>Cr_correct);
index_2 = find(isnan(error)==1);
Cr_correct(index_error) = NaN;
Cr_correct(index_2) = NaN;
store_lte = length(index_error);
store_nanerror = length(index_2);

end


    
    



