%% assess_ReservoirName_.m
% Template function to collect reservoir states. Use this as a guide when
% creating a new reservoir.
%
% How this function looks at the end depends on the reservoir. However,
% everything below is typically needed to work with all master scripts.
%
% This is called by the @config.assessFcn pointer.

function[final_states,individual] = assess_ReservoirName_(individual,input_sequence,config)

%if single input entry, add previous state
if size(input_sequence,1) == 1
    input_sequence = [zeros(size(input_sequence)); input_sequence];
end

% pre-allocate state matrices
for i= 1:config.num_reservoirs
    if size(input_sequence,1) == 2
        states{i} = individual.last_state{i};
    else
        states{i} = zeros(size(input_sequence,1),individual.nodes(i));
    end
    x{i} = zeros(size(input_sequence,1),individual.nodes(i));
end

% pre-assign anything that can be calculated before running the reservoir


% Calculate reservoir states - general state equation for multi-reservoir system: x(n) = f(Win*u(n) + S)
for n = 2:size(input_sequence,1)
    
    for i= 1:config.num_reservoirs % cycle through sub-reservoirs
        
        for k= 1:config.num_reservoirs % collect previous states of all sub-reservoirs and multiply them by the connecting matrices `W`
            x{i}(n,:) = x{i}(n,:) + ((individual.W{i,k}*individual.W_scaling(i,k))*states{k}(n-1,:)')';
        end
        
        % Calaculate current state when combined with input signal.
        % This line will depend on the reservoir, below is just an example: 
        % ... states{i}(n,:) = individual.activ_Fcn{1}(((individual.input_weights{i}*individual.input_scaling(i))*([individual.bias_node input_sequence(n,:)])')+ x{i}(n,:)');
            
    end
end

% Add leak states, if used
if config.leak_on
    states = getLeakStates(states,individual,input_sequence,config);
end

% Concat all states for output weights
final_states = [];
for i= 1:config.num_reservoirs
    final_states = [final_states states{i}];
    
    %assign last state variable
    individual.last_state{i} = states{i}(end,:);
end

% Concat input states
if config.add_input_states == 1
    final_states = [final_states input_sequence];
end

% Remove washout and output final states
final_states = final_states(config.wash_out+1:end,:); 