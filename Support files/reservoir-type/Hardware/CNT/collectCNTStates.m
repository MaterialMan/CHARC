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
    weighted_input = (((individual.input_weights{i}*individual.input_scaling(i))*([individual.bias_node input_sequence(n,:)])')+ x{i}(n,:)');

    % set non-inputs to zero
    input_2_CNT = zeros(weighted_input);
    % add weighted inputs
    input_2_CNT(:,individual.electrode_type(i,:) == 1) = weighted_input(:, individual.electrode_type(i,:) == 1);
    % add config signals
    input_2_CNT(:,individual.electrode_type(i,:) == 2) = individual.config_voltage(:, individual.electrode_type(i,:) == 2)*individual.input_scaling(i);
    
    % collect states
    %individual.read_session.queueOutputData([zeros(25,maxInputs);input_sequence; zeros(10,maxInputs)]);
    individual.read_session.queueOutputData(input_2_CNT);
    
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