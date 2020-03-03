function y = paraReLU(x,leakRate)
%Parametric ReLu node
y=x;
y(x > 0) = leakRate*x(x > 0);
