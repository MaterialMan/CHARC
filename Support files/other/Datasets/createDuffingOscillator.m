function [out] =createDuffingOscillator(data_length, data_struct, y0, T)
%This program in computed by S.Sabarathinam
%%Based on: Nonlinear Dynamics: Integrability, Chaos and Patterns,by M Lakshmanan, S Rajaseekar
% to see the double scroll chaotic attractor in this program
%to change the 'amp' value you can see the period doubling scenario

%time step and initial condition
%tspan = 0:0.1:data_length*0.1;
tspan = [0 data_length];
op=odeset('abstol',1e-9,'reltol',1e-9);
%[t,y] = ode45(@(t,x) f(t,x,data_struct.delta,data_struct.alpha,data_struct.beta,data_struct.gamma,data_struct.w),tspan,y0,op);
sol = ode45(@(t,x) f(t,x,data_struct.delta,data_struct.alpha,data_struct.beta,data_struct.gamma,data_struct.w),tspan,y0,op);
t = linspace(0,T,data_length);
y = deval(sol,t);

x1=y(1,:); x2=y(2,:);
subplot(1,2,1)
plot(-x1(data_length*0.2+1:end),-x2(data_length*0.2+1:end));  %plot the variable x and y
subplot(1,2,2)
plot(-x1(data_length*0.2+1:end))
out = y;

end

function dy = f(t,y,delta,alpha,beta,gamma,w)
x1 = y(1);    x2 = y(2);
dx1 = x2;
dx2 = -delta*x2- alpha*x1- beta*x1^3+ gamma*sin(w*t);
dy = [dx1; dx2];
end