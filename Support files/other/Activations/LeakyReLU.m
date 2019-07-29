function y = LeakyReLU(x)
%Leaky ReLu node
y = 0.01*x;
y(x > 0) = x(x > 0);