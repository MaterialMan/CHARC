function[final_states,individual] = collectCNTStates(individual,input_sequence,config,target_output)

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
    weighted_input = (((individual.input_weights{i}*individual.input_scaling(i))*([repmat(individual.bias_node,size(input_sequence,1),1) input_sequence])')+ x{i}')';

    % add weighted inputs
    input_2_CNT = weighted_input(:,individual.electrode_type(i,:) == 1);
    % add config signals
    input_2_CNT = [input_2_CNT repmat(individual.config_voltage(:, individual.electrode_type(i,:) == 2)*individual.input_scaling(i),size(input_2_CNT,1),1)];
    
    % Append zeros to any unused input channels
    [len,wid]=size(input_2_CNT);
    if wid < config.num_input_electrodes
        input_2_CNT = [input_2_CNT zeros(len,config.num_input_electrodes-wid)];
    end
    
    % collect states
    for rep_test = 1:3
        individual.read_session.queueOutputData([zeros(10,config.num_input_electrodes); input_2_CNT; zeros(10,config.num_input_electrodes)]);    
        t_states(rep_test,:,:) = individual.read_session.startForeground;%startBackground;%
    end
    
    %remove excess data points
    state_comp = t_states(:,11:end-10,:); %was 150
    
    %avg state readings
    states{i} = reshape(median(state_comp),size(state_comp,2),size(state_comp,3));
    

    % remove states with no connectivity, trim states (remove reset zero
    % inputs), remove input electrodes
    %states{i} = states{i}(11:end-10,:);
    states{i}(std(state_comp) > 0.1) = zeros; 
    states{i}(states{i} < - 4.8) = zeros;    
    states{i}(:,individual.electrode_type(i,:) > 1) = zeros;
    
%     plot(states{i})
%     drawnow
end

release(individual.read_session);

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