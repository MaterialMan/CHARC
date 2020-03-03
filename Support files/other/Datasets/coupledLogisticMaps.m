%% Coupled Logistic Maps
function coupledLogisticMaps(x0,a,b,b_range)
% Input variables:
%   initial conditions                  = x0
%   parameter                           = a
%   coupling parameter                  = b
%   range to plot bifurcation diagram   = b_range 
%
% Examples:
%   Spiral -- Phase portraits: x = 0.68, y = 0.66, a = 2, b = 0.68 --> Bifurcation diagram: b = 0:0.01:1
%       coupledLogisticMaps([0.68 0.66],2,0.68,0:0.01:1)
%
%   Four circles -- Phase portraits: x = 0.68, y = 0.66, a = 3.432, b = -0.3 --> Bifurcation diagram: b = -0.3:0.01:0
%       coupledLogisticMaps([0.68 0.66],3.432,-0.3,-0.3:0.01:0)
%
%   Ring -- Phase portraits: x = 0.84, y = 0.43, a = 3.6, b = -0.3  --> Bifurcation diagram: b = -0.1:0.001:0.01
%       coupledLogisticMaps([0.84 0.43],3.6,-0.069,-0.1:0.001:0.01)  

time_steps = 200;
x = x0(1);
y = x0(2);

% run coupled lattice
for i = 1:time_steps
    x(i+1,:) = a*y(i,:)*(1-y(i,:)) + b*(x(i,:) -y(i,:)); 
    y(i+1,:) = a*x(i,:)*(1-x(i,:)) + b*(y(i,:) -x(i,:));
end

subplot(1,2,1)
scatter(x,y,'.')
title('Phase portrait')

%% bifurcation diagram
b = b_range;
c_b = []; c_x =[];
time_steps = 200;

% collect states of coupled lattice
for i = 1:length(b)-1
 for j = 1:time_steps  
    x(j+1) = a*y(j)*(1-y(j)) + b(i)*(x(j) -y(j)); 
    y(j+1) = a*x(j)*(1-x(j)) + b(i)*(y(j) -x(j));
    c_b(j,i) = b(i);
 end
 c_b(j+1,i)= b(i);
 c_x(:,i) =  x(1:end);
end

c_b = c_b(100:end,:);
c_x =  c_x(100:end,:);
subplot(1,2,2)
scatter(c_b(:),c_x(:),'.')
title('Bifurcation diagram')