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

function [p] = calibration_thick

%PL filenames (Ex. 187_10s_20LP_1.txt)
sample_no_PL = 'C:\Users\Mallory\Documents\Non-contact crucible\9-15-2015 experiment TR+Amanda\Lifetime stage 1\PC-PL\15-9-21-N\15-9-21-N'; %this is the first part of the filenames
sample_no_xls = 'C:\Users\Mallory\Documents\Non-contact crucible\9-15-2015 experiment TR+Amanda\Lifetime stage 1\PC-PL\15-9-21-N\15-9-21-N';
exposure = 5; %seconds, this is the second part of the filename
LP = [22 25 30 35 40 45 50 55 60 65 70 75 80]; %This is the last part of the filename
filename_after_PL='LP_1.txt';
sensor = 'C:\Users\Mallory\Documents\Non-contact crucible\9-15-2015 experiment TR+Amanda\Lifetime stage 1\PC-PL\PCPL_10-2-2015\Sinton_circle_1.txt'; %This is the PL file with the Sinton circle image
filename_after_PC='LP.xlsm';

%Get matrices with averages of PL/PC signals. These matrices should have
%dimensions laser powers x samples. For 5 laser powers and 2 samples, the
%matrix will be 5x2.
[PL_averages,PLmaps] = importPLdata(sample_no_PL,exposure,LP,filename_after_PL,sensor); 
[deltaN] = importXLSdata(sample_no_xls,exposure,LP,filename_after_PC);

%Store all of the fits
[m,n]=size(PL_averages);
[s,r]=size(deltaN);

if m ~= s
    display 'error'
elseif n~= r
    display 'error'
end

p = cell(1,n); 

for i = 1:n
    pnow = polyfitZero(deltaN(:,i),PL_averages(:,i),2);
    %pnow = polyfit(deltaN(:,i),PL_averages(:,i),2);
    a = pnow(1);
    b = pnow(2);
    c = pnow(3);
    figure;
    plot(deltaN(:,i),PL_averages(:,i),'.');
    y = a.*(deltaN(:,i).^2) + b.*deltaN(:,i) + c;

    hold on;
    plot(deltaN(:,i),y);
    title(['Sample ' sample_no_xls(i)]);
    xlabel('Excess carrier density (cm^-^3)');
    ylabel('PL signal (counts/second)');
    p{i} = [a,b,c];
    %sheet = ['Sheet' num2str(i)];
    write = [deltaN, PL_averages];
    xlswrite('Calibration_curves.xlsx',write,i);
    
end