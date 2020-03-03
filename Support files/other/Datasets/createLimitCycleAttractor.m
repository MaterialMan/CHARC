function [x, y] = createLimitCycleAttractor(mu, T, h ,data_points)

% initial value
x0 = [1; 1];

% run 4th order Runge-Kutta
[~,X] = rk4(@f,[0, T],x0,h);

% ode45 method
eps = 0.000001;
options = odeset('RelTol',eps,'AbsTol',[eps eps]);
sol = ode45(@f, 0:h:T, x0,options);
t = linspace(0,T,data_points);
X_ode = deval(sol,t)';

% plot attractor and compare
subplot(1,2,1)
plot(X(:,1),X(:,2));
subplot(1,2,2)
plot(X_ode(:,1),X_ode(:,2));
axis equal;
grid;
title(strcat('Van der Pol oscillator: mu ',num2str(mu)));
xlabel('X'); ylabel('Y');

x = X(:,1);
y = X(:,2);

    function dx = f(T, X)
        % Evaluates the right hand side of the Van der Pol oscillator
        % x' = y
        % y' = mu*(1 - x^2)*y - x

        dx = zeros(2,1);
        dx(1) = X(2);
        dx(2) = mu*(1-X(1).^2)*X(2) - X(1);

    end
end