function y = ReLU(x)
%ReLu node
y = zeros(size(x));
y(x > 0) = x(x > 0);

