function [t,y] = rk4_2(dpdt,tspan,y0,Sm,h)

if nargin < 4, error('at least 4 input arguments required'), end
if any(diff(tspan)<=0), error('tspan not ascending order'), end

t = tspan(1):h:tspan(2);
y = y0;

for n = 1:length(t)-1
    
    tp = t(n);
     
    k1 = dpdt(tp, y(n,:), Sm(n,:));
    
    k2 = dpdt(tp + 0.5*h, y(n,:) + 0.5*k1*h, Sm(n,:));
    
    k3 = dpdt(tp + 0.5*h, y(n,:) + 0.5*k2*h, Sm(n,:));
    
    k4 = dpdt(tp + h, y(n,:) + k3*h, Sm(n,:));
    
    y(n+1,:) = y(n,:) + (1/6)*((k1 + (2*k2) + (2*k3) + k4))*h;
    
end

