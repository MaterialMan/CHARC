function y = LeakyReLU(x)
%Leaky ReLu node
if x > 0 
    y=x;
else
   y = 0.01*x;
end