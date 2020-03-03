function [final_states,individual] = collectELMStates(individual,input_sequence,config,target_output)

%% if single input entry, add previous state
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

% preassign activation function calls
if size(individual.activ_Fcn,2) > 1
    for i= 1:config.num_reservoirs
        for p = 1:length(config.activ_list)
            index{i,p} = findActiv({individual.activ_Fcn{i,:}},config.activ_list{p});
        end
    end
end

%equation: x(n) = f(Win*u(n) + S)
for n = 2:size(input_sequence,1)
    
    for i= 1:config.num_reservoirs
        
        if i == 1
            input = (individual.input_weights{i}*individual.input_scaling(i))*([individual.bias_node input_sequence(n,:)])';
        else
            indx = logical(eye(size(individual.W{i,i},1),size(individual.W{i,i},2)));
            individual.W{i,i}(indx) = 0;
            input = ([individual.bias_node states{i-1}(n,:)]*individual.W{i,i}'*individual.W_scaling(i,i))';
        end
        
        if size(individual.activ_Fcn,2) > 1
            for p = 1:length(config.activ_list)           
               states{i}(n,index{i,p}) = config.activ_list{p}(input(index{i,p},:));
            end
        else
            states{i}(n,:) = individual.activ_Fcn{1}(input); 
        end
        
    end
    
end


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

if config.add_input_states == 1
    final_states = [final_states input_sequence];
end

if size(input_sequence,1) == 2
    final_states = final_states(end,:); % remove washout
else
    final_states = final_states(config.wash_out+1:end,:); % remove washout
end