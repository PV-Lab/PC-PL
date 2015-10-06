%Determine the number of points to exclude. Deltan and PL intensity should
%be stored as vectors in the workspace. 

[m,n] = size(deltan); 

for i = 0:floor((m/2))
    
    deltan_now = deltan(1:(m-i),1); 
    PL_now = PL(1:(m-i),1);
    
    [pnow] = polyfitn(deltan_now,PL_now,2);

    fit(i+1) = pnow.R2; 
    
end

figure;
plot(fit,'.');
ylim([0.99 1.01]);