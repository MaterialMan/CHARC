function states = collectDLStates(genotype,inputSequence,config)


% shift input range to be positive - scale between 0 and 1
inputSequence = rescale(inputSequence);

states = zeros(size(inputSequence,1),genotype.nInternalUnits);

% time multiplex input and mask
J =[]; I = [];
hold_str = 1; hold_end = genotype.tau/genotype.time_step;
theta_str =1; theta_end = floor(genotype.theta/genotype.time_step);

for n = 1:size(inputSequence,1)
    
    I(hold_str:hold_end,:) = repmat(inputSequence(n,:),genotype.tau/genotype.time_step,1);%.*genotype.inputScaling;
    
    hold_str = hold_end+1;
    hold_end = hold_end+genotype.tau/genotype.time_step;
    
    
    for t = 1:genotype.nInternalUnits
        
        %J(theta_str:theta_end,:) = I(theta_str:theta_end,:) + I(theta_str:theta_end,:)*genotype.M(t,:)';
        J(theta_str:theta_end,:) = I(theta_str:theta_end,:)*genotype.M(t,:)';
        
        theta_str = theta_end+1;
        theta_end = theta_end+floor(genotype.theta/genotype.time_step);
    end
    
end

%% Collect states
tau_steps = round(genotype.tau/genotype.time_step);

T_start = 1;
T_end = length(inputSequence);

input       = [J; 0];
x           = [repmat(genotype.x0,tau_steps,1);  zeros(length(J)-tau_steps, 1)];

for n = 0 : T_end - T_start-1
    
    hist_start      =  n * tau_steps + 1;
    hist_end        = ( n + 1 ) * tau_steps;
    
    x_old           = x(hist_start : hist_end );
    I               = genotype.gamma * input( hist_start: hist_end);
    
    [~,x(hist_start + tau_steps: hist_end+ tau_steps)] = rk4_2(@ddefun,[hist_start hist_end],...
        x(hist_start+ tau_steps-1),I+x_old,1);
    
end


if isreal(x)
    
    % reshape states
    for k = 1:size(inputSequence,1)
        for i = 1:genotype.nInternalUnits
            states(k,i) = x(round(k*genotype.tau/genotype.time_step - (genotype.nInternalUnits-i)*floor(genotype.theta/genotype.time_step)));%*(1/deltat));
        end
    end
else
    error('States are complex numbers -- use integers for P, or scale input sequence well above 0')
end



if config.leakOn
    states = getLeakStates(states,genotype,config);
end

if config.evolvedOutputStates
    states= states(config.nForgetPoints+1:end,logical(genotype.state_loc));
else
    states= states(config.nForgetPoints+1:end,:);
end

if config.AddInputStates
    states = [ones(size(inputSequence(config.nForgetPoints+1:end,1))) inputSequence(config.nForgetPoints+1:end,:) states];
else
    states = [ones(size(inputSequence(config.nForgetPoints+1:end,1))) states];
end



%% Mackey Glass fcn
    function dydt = ddefun(t,y,z)
        
        dydt = -genotype.T*y + (genotype.eta*z)/(1 + z^genotype.p);
        
    end

end
