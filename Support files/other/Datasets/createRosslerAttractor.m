function [x, y,z] = createRosslerAttractor(a,b,c, T, h, data_points)

% initial value
x0 = [1; 1; 1];

% run 4th order Runge-Kutta
[~,X] = rk4(@f,[0, T],x0,h);

% ode45 method
eps = 0.000001;
options = odeset('RelTol',eps,'AbsTol',[eps eps eps/10]);
sol = ode45(@f, 0:h:T, x0,options);
t = linspace(0,T,data_points);
X_ode = deval(sol,t)';

% plot attractor and compare
subplot(1,2,1)
plot3(X(:,1),X(:,2),X(:,3));
subplot(1,2,2)
plot3(X_ode(:,1),X_ode(:,2),X_ode(:,3));
axis equal;
grid;
title('Rossler attractor');
xlabel('X'); ylabel('Y'); zlabel('Z');

x = X(:,1);
y = X(:,2);
z = X(:,3);

    function dx = f(T, X)
        % Evaluates the right hand side of the Lorenz system
        % x' = -y-z
        % y' = x + ay
        % z' = b + z(x-c)
        % typical values: a = 0.2; b = 0.2; c = 5.7; or a = 0.1; b = 0.1; c = 14
        dx = zeros(3,1);
        dx(1) = -X(2) - X(3);
        dx(2) = X(1) + a*X(2);
        dx(3) = b + X(3)*(X(1)-c);  
    end
end