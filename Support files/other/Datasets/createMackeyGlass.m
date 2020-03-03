function x = createMackeyGlass(tau, gamma, beta, p, T, data_points)

% MackeyGlass Function generates the Mackey-Glass attractor of the prescribed values
% of parameters tau, gamma, beta, p
%
%   [x,y,z] = LORENZ(tau, gamma, beta, p, T, h)
%       x       - output vectors of the MG attactor trajectories
%       tau     - delay
%       gamma   - current state multiplier
%       beta    - delay multiplier
%       p       - exponent
%       T       - time interval
%       h       - integration time step

% Example.
%        [x] = createMackeyGlass(17, 0.1, 0.2, 10, [0 1000]);
%        plot(x);

if nargin<3
    error('MATLAB:lorenz:NotEnoughInputs','Not enough input arguments.');
end

% dde23 method
sol = dde23(@f,tau,0.5,[0, T]);
t = linspace(tau,T,data_points);
x = deval(sol,t);
plot(x);
title('MG attractor');
xlabel('t'); ylabel(''); 


    function dxdt = f(t,x,Z)        
        dxdt = (beta*Z)/(1 + Z^p) - gamma*x;             

    end
end