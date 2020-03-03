function [x, y, z] = createLorenz(rho, sigma, beta, T, h, data_points)

% LORENZ Function generates the lorenz attractor of the prescribed values
% of parameters rho, sigma, beta
%
%   [x,y,z] = LORENZ(RHO,SIGMA,BETA,T)
%       x, y, z - output vectors of the strange attactor trajectories
%       RHO     - Rayleigh number
%       SIGMA   - Prandtl number
%       BETA    - parameter
%       T       - time interval

% Example.
%        [X Y Z] = lorenz(28, 10, 8/3);
%        plot3(X,Y,Z);

if nargin<3
    error('MATLAB:lorenz:NotEnoughInputs','Not enough input arguments.');
end

% initial value
x0 = [1; 1; 1];

% % run 4th order Runge-Kutta
% [~,X] = rk4(@f,[0, T],x0,h);

% ode45 method
eps = 0.000001;
options = odeset('RelTol',eps,'AbsTol',[eps eps eps/10]);
sol = ode45(@f, 0:h:T, x0,options);
t = linspace(0,T,data_points);
X_ode = deval(sol,t)';

% plot attractor and compare
% subplot(1,2,1)
% plot3(X(:,1),X(:,2),X(:,3));
% subplot(1,2,2)
plot3(X_ode(:,1),X_ode(:,2),X_ode(:,3));
axis equal;
grid;
title('Lorenz attractor');
xlabel('X'); ylabel('Y'); zlabel('Z');

x = X_ode(:,1);
y = X_ode(:,2);
z = X_ode(:,3);

    function dx = f(T, X)
        % Evaluates the right hand side of the Lorenz system
        % x' = sigma*(y-x)
        % y' = x*(rho - z) - y
        % z' = x*y - beta*z
        % typical values: rho = 28; sigma = 10; beta = 8/3;
        dx = zeros(3,1);
        dx(1) = sigma*(X(2) - X(1));
        dx(2) = X(1)*(rho - X(3)) - X(2);
        dx(3) = X(1)*X(2) - beta*X(3);
    end
end