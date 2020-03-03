function [final_states,individual]= collectDLStates(individual,input_sequence,config,target_output)

%if single input entry, add previous state
if size(input_sequence,1) == 1
    input_sequence = [zeros(size(input_sequence)); input_sequence];
end

for i= 1:config.num_reservoirs
    if size(input_sequence,1) == 2
        individual.x0(i,:) = individual.last_state{i};
    end
    states{i} = zeros(size(input_sequence,1),individual.nodes(i));
end

% shift input range to be positive - scale between 0 and 1
input_sequence = rescale(input_sequence);

for i= 1:config.num_reservoirs
    
    % apply time multiplex input and mask
    J =[]; I = [];
    hold_str = 1; hold_end = individual.tau(i)/individual.time_step(i);
    theta_str =1; theta_end = floor(individual.theta(i)/individual.time_step(i));        
    
    for n = 1:size(input_sequence,1)
        
        I(hold_str:hold_end,:) = repmat(input_sequence(n,:),individual.tau(i)/individual.time_step(i),1);%.*genotype.inputScaling;
        
        hold_str = hold_end+1;
        hold_end = hold_end+individual.tau(i)/individual.time_step(i);
        
        
        for t = 1:individual.nodes(i)
            
            %J(theta_str:theta_end,:) = I(theta_str:theta_end,:) + I(theta_str:theta_end,:)*genotype.M(t,:)';
            J(theta_str:theta_end,:) = I(theta_str:theta_end,:)*individual.input_scaling(i)*individual.input_weights{i}(t,:);
            
            theta_str = theta_end+1;
            theta_end = theta_end+floor(individual.theta(i)/individual.time_step(i));
        end
        
    end
    
    %% Collect states
    tau_steps = round(individual.tau(i)/individual.time_step(i));
    
    T_start = 1;
    T_end = length(input_sequence);
    
    input       = [J; 0];
    x           = [repmat(individual.x0(i,:),tau_steps,1);  zeros(length(J)-tau_steps, 1)];
    
    for n = 0 : T_end - T_start-1
        
        hist_start      =  n * tau_steps + 1;
        hist_end        = ( n + 1 ) * tau_steps;
        
        x_old           = x(hist_start : hist_end );
        I               = individual.gamma(i) * input( hist_start: hist_end);
        
        [~,x(hist_start + tau_steps: hist_end+ tau_steps)] = rk4_2(@ddefun,[hist_start hist_end],...
            x(hist_start+ tau_steps-1),I + x_old, 1);       
    end
    
    if isreal(x)
        % reshape states
        for k = 1:size(input_sequence,1)
            for j = 1:individual.nodes(i)
                states{i}(k,j) = x(round(k*individual.tau(i)/individual.time_step(i) - (individual.nodes(i)-j)*floor(individual.theta(i)/individual.time_step(i))));%*(1/deltat));
            end
        end
    else
        error('States are complex numbers -- use integers for P, or scale input sequence well above 0')
    end
end

% get leak states
if config.leak_on
    states = getLeakStates(states,individual,input_sequence,config);
end

% concat all states for output weights
final_states = [];
for i= 1:config.num_reservoirs
    final_states = [final_states states{i}];
    
    %assign last state variable
    individual.last_state{i} = states{i}(end,:);
end

% concat input states
if config.add_input_states == 1
    final_states = [final_states input_sequence];
end

if size(input_sequence,1) == 2
    final_states = final_states(end,:); % remove washout
else
    final_states = final_states(config.wash_out+1:end,:); % remove washout
end

%% Mackey Glass fcn
    function dydt = ddefun(t,y,z)
        
        dydt = -individual.T(i)*y + (individual.eta(i)*z)/(1 + z^individual.p(i));
        
    end

end
