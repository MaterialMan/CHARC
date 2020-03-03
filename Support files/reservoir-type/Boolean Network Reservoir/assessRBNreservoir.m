function [final_states,individual]= assessRBNreservoir(individual,input_sequence,config,target_output)   


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
    
    % modify input signal
    input{i} = [input_sequence repmat(individual.bias_node(i),size(input_sequence,1),1)]*(individual.input_weights{i}*individual.input_scaling(i))';
    
    % time multiplex -
    input_mul{i} = zeros(size(input_sequence,1)*individual.time_period(i),size(input{i},2),size(input{i},3));
    if individual.time_period > 1
        input_mul{i}(mod(1:size(input_mul{i},1),individual.time_period(i)) == 1,:,:) = input{i};
    else
        input_mul{i} = input{i};
    end
    
    % change input widths
%     for n = 1:size(input_mul{i},1)
%             m = reshape(input_mul{i}(n,:),config.num_nodes(i),config.num_nodes(i));
%             f_pos = find(m);
%             input_matrix_2d = m;
%             for p = 1:length(f_pos)
%                 t = zeros(size(m));
%                 t(f_pos(p)) = m(f_pos(p));
%                 [t] = adjustInputShape(t,individual.input_widths{i}(f_pos(p)));
%                 input_matrix_2d = input_matrix_2d + t;
%             end
%             input_mul{i}(n,:) = input_matrix_2d(:);
%     end
    
    x{i} = zeros(size(input_sequence,1),individual.nodes(i));

    %run RBN
    [~, states] = individual.RBN_type{i}(individual,input_mul{i});

end

%need to check! deplex to get states
if individual.time_period(i) > 1
    states{i} = states{i}(mod(1:size(states{i},1),individual.time_period(i)) == 1,:);
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
    final_states = [final_states floor(heaviside(input_sequence))];
end

if size(input_sequence,1) == 2
    final_states = final_states(end,:); % remove washout
else
    final_states = final_states(config.wash_out+1:end,:); % remove washout
end