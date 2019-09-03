function [t,Y] = rk4(F_xy,tspan,x0,h)

t=tspan(1):h:tspan(2);
y=zeros(length(x0),length(t));
y(:,1)=x0;

for i=1:(length(t)-1)
    k1 = F_xy(t(i),y(:,i));
    
    k2 = F_xy(t(i) + 0.5*h, y(:,i) + 0.5*h*k1);
    
    k3 = F_xy((t(i) + 0.5*h), (y(:,i) + 0.5*h*k2));
    
    k4 = F_xy((t(i) + h), (y(:,i) + k3*h));
    
    y(:,i+1) = y(:,i) + (1/6)*(k1 + 2*k2 + 2*k3 + k4)*h;
end

Y=y';

