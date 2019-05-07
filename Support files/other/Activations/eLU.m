function y = eLU(x,a)
%exponential linear unit
if x > 0 
    y=x;
else
   y = a*(exp(x)-1);
end