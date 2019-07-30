function[final_states,individual] = collectCNTStates(individual,input_sequence,config)

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


for i= 1:config.num_reservoirs

    % reset switch
    setUpSwitch(individual.switch_session, individual.electrode_type(i,:));

    % queue output
    input_sequence = (((individual.input_weights{i}*individual.input_scaling(i))*([individual.bias_node input_sequence(n,:)])')+ x{i}(n,:)');

    input_sequence = input_sequence(:, individual.electrode_type(i,:) > 0);
    
    % collect states
    %individual.read_session.queueOutputData([zeros(25,maxInputs);input_sequence; zeros(10,maxInputs)]);
    individual.read_session.queueOutputData(input_sequence);
    
    states = read_session.startForeground;%startBackground;%
    
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

final_states = final_states(config.wash_out+1:end,:); % remove washout