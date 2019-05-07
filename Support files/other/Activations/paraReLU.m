function y = paraReLU(x,leakRate)
%Parametric ReLu node
if x > 0 
    y=x;
else
   y = leakRate*x;
end