function pZero = polyfitZero(x,y,n)
z = y./x;
znozero = z(x~=0);xnozero = x(x~=0);
q = polyfit(xnozero,znozero,n-1);
pZero = conv([1 0],q);
end