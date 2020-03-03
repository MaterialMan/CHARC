function[final_states,individual] = collectEnsembleStates(individual,input_sequence,config,target_output)

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

% preassign activation function calls
if size(individual.activ_Fcn,2) > 1
    for i= 1:config.num_reservoirs
        for p = 1:length(config.activ_list)
            index{i,p} = findActiv({individual.activ_Fcn{i,:}},config.activ_list{p});
        end
    end
end

%equation: x{i}(n) = f(Win*u(n) + W_ii*x{i}(n-1)),
for n = 2:size(input_sequence,1)
    
    for i= 1:config.num_reservoirs
        
        x{i}(n,:) = x{i}(n,:) + ((individual.W{i,i}*individual.W_scaling(i,i))*states{i}(n-1,:)')';

        if size(individual.activ_Fcn,2) > 1
            for p = 1:length(config.activ_list)           
               states{i}(n,index{i,p}) = config.activ_list{p}(((individual.input_weights{i}(index{i,p},:)*individual.input_scaling(i))*([individual.bias_node input_sequence(n,:)])')+ x{i}(n,index{i,p})');
            end
        else
            states{i}(n,:) = individual.activ_Fcn{1}(((individual.input_weights{i}*individual.input_scaling(i))* ([individual.bias_node input_sequence(n,:)])') + x{i}(n,:)'); 
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