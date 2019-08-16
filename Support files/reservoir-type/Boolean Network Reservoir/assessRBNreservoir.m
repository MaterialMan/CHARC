function [final_states,individual]= assessRBNreservoir(individual,input_sequence,config)   


%if single input entry, add previous state
if size(input_sequence,1) == 1
    input_sequence = [zeros(size(input_sequence)); input_sequence];
end

for i= 1:config.num_reservoirs
    if size(input_sequence,1) == 2
        states{i} = individual.last_state{i};
    else
        states{i} = zeros(size(input_sequence,1),individual.nodes(i));
    end
    x{i} = zeros(size(input_sequence,1),individual.nodes(i));
end

%run RBN
[~, states] = individual.RBN_type{i}(individual,input_sequence);
    
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
    final_states = [final_states floor(heaviside(input_sequence))];
end

final_states = final_states(config.wash_out+1:end,:); % remove washout

% imagesc(final_states)
% drawnow