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

%This function takes as input a set of PL maps in terms of injection level 
%and lifetime (calibrated), taken at specified laser
%powers (LP) and generation rates (flux). The output is a PL map at a
%uniform injection level as specified by the user. 
function [PL_uni_inj,LP_map] = uniform_injection(tau,deltan,LP,Flux,...
    injection,thickness,R)

[LP,I] = sort(LP); %ascending order, for later
tau = tau(I); 
deltan = deltan(I); 
Flux = Flux(I); 

%What's the size of a PL map. They should all be the same.
[m,n] = size(tau{1}); 

%Get the relationship between LP and flux
%We assume a linear relationship
y = Flux; 
[mflux,nflux] = size(Flux); 
if mflux<nflux
    y = y'; 
end
[mLP,nLP] = size(LP); 
if mLP<nLP
    LP = LP'; 
end
x = [ones(length(LP),1),LP]; 
flux_fit = x\y; %intercept, then slope
%Make a plot just to check
figure; 
plot(LP,y,'o'); 
hold all;
plot(LP,x*flux_fit,'-'); 
xlabel('laser power'); 
ylabel('flux'); 
legend('measured','fit'); 

%We are going to build a new tau map and a corresponding laser power map
LP_map = zeros(m,n); 
PL_uni_inj = zeros(m,n); 

%This operation must occur pixel-by-pixel
for i = 1:m
    for j = 1:n
        %Let's figure out two relationships
        %First, the relationship between deltan and LP
        %Second, the relationship between LP and generation rate (we
        %figured this out outside of the loop to save time)
        deltan_LP = zeros(size(LP)); 
        for k = 1:length(LP)
            deltan_now = deltan{k}; 
            deltan_LP(k) = deltan_now(i,j); 
        end
        %Now we want to know which injection level is closest to our target
        diff = deltan_LP-injection; 
        min_index = find(diff<0); 
        if isempty(min_index)==0
            min_index = min_index(end);
        end
        max_index = find(diff>0);
        if isempty(max_index)==0
            max_index = max_index(1); 
        end
        if isempty(min_index)==1
            %Then we'll use a linear fit between the first two points
            y = deltan_LP(1:2,1); 
            x = [ones(length(y),1) LP(1:2,1)];        
        elseif isempty(max_index)==1
            %Then we'll use a linear fit between the last two points
            y = deltan_LP(length(diff)-1:length(diff),1); 
            x = [ones(length(y),1) LP(length(diff)-1:length(diff),1)];
        else
            %Normal scenario, we interpolate between the two closest points
            y = deltan_LP(min_index:max_index,1); 
            x = [ones(length(y),1), LP(min_index:max_index,1)]; 
        end
        b_deltan = x\y; %intercept, then slope
        %Now we calculate what the laser power would have to be
        LP_new = (injection-b_deltan(1))/b_deltan(2); 
        %Now we calculate what the corresponding generation would be
        flux_new = flux_fit(1)+(LP_new*flux_fit(2)); 
        G = flux_new.*(1-R)./thickness; 
        PL_uni_inj(i,j) = (injection/G) .* 1e6;
        LP_map(i,j) = LP_new; 
    end
end
figure;
imagesc(PL_uni_inj); 
axis off; 
axis('image');
colorbar;
colormap(gray);
title(['Lifetime at uniform injection level = ' num2str(injection,'%1.1E')]); 

            
        

