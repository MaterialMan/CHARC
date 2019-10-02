function [x] = wrapToPi(a)
% Wraps angle in a, in radians, to the interval [-pi pi].
D=[a, a-2*pi, a+2*pi];
[out, ii] = min(abs(D));
x = D(ii);
end
