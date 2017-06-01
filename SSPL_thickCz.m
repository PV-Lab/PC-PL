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

% Converts PL images (txt files) into images of minority
% carrier density, lifetime, and iron point defect concentration. 

% adjust experimental parameters and sample information

%1-5-15 - revised to use "Sinton circle_1.txt" instead of
%"Sinton_circle_1.txt."

clear all; close all;

%sample thickness
sample.d = 0.0167; %cm
sample.R = 0.1; %sample reflectivity
sample.N_A = 1.1e16; %cm^-3

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

save('C:\Users\Mallory Jensen\Documents\LeTID\XRF\PCPL April 19 2017\PS-a_10s_calib.mat','sample');