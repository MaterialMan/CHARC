function f = gaussDist(x, mu, s)

if nargin < 2
    mu = 0;
    s = 1;
end

p1 = -.5 * ((x - mu)/s) .^ 2;
p2 = (s * sqrt(2*pi));
f = exp(p1) ./ p2; 