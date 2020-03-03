function y = eLU(x,a)
%exponential linear unit
y=x;
y(x > 0) = a*(exp(x(x > 0))-1);
