function [t,Y] = rk4_2(F_xy,tspan,x0,Sm,h)

% t = tspan(1):h:tspan(2);
% y = y0;
% 
% for n = 1:length(t)-1
%     
%     tp = t(n);
%      
%     k1 = dpdt(tp, y(n,:), Sm(n,:));
%     
%     k2 = dpdt(tp + 0.5*h, y(n,:) + 0.5*k1*h, Sm(n,:));
%     
%     k3 = dpdt(tp + 0.5*h, y(n,:) + 0.5*k2*h, Sm(n,:));
%     
%     k4 = dpdt(tp + h, y(n,:) + k3*h, Sm(n,:));
%     
%     y(n+1,:) = y(n,:) + (1/6)*((k1 + (2*k2) + (2*k3) + k4))*h;
%     
% end

t=tspan(1):h:tspan(2);
y=zeros(length(x0),length(t));
y(:,1)=x0;

for i=1:(length(t)-1)
    k1 = F_xy(t(i), y(:,i), Sm(i,:));
    
    k2 = F_xy(t(i) + 0.5*h, y(:,i) + 0.5*h*k1, Sm(i,:));
    
    k3 = F_xy((t(i) + 0.5*h), (y(:,i) + 0.5*h*k2), Sm(i,:));
    
    k4 = F_xy((t(i) + h), (y(:,i) + k3*h), Sm(i,:));
    
    y(:,i+1) = y(:,i) + (1/6)*(k1 + 2*k2 + 2*k3 + k4)*h;
end

Y=y';