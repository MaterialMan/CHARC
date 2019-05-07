%% Mackey Glass equation
% x_t = state variable
% x_t_minus_tau = state variable at time t - tau
% eta = feedback strength
% T = time-scale parameter
% p = exponential -- sets nonlinearity of equation

function x_dot = mackeyGlass2(x_t, x_t_minus_tau, eta, T, p, J)

    x_dot = -T*x_t + (eta*(x_t_minus_tau + J))/...
                    (1 + (x_t_minus_tau + J)^p);
    
end