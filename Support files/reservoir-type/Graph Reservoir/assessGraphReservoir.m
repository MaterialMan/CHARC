function [final_states,individual] = assessGraphReservoir(individual,input_sequence,config)

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
    
    % reset weights to correct graph structure 
    graph_indx{i} = logical(full(adjacency(individual.G{i})));
    individual.W{i,i}(~graph_indx{i}) = 0;
end

%% collect states
for n = 2:size(input_sequence,1)
    
    for i= 1:config.num_reservoirs
        
        for k= 1:config.num_reservoirs
            x{i}(n,:) = x{i}(n,:) + ((individual.W{i,k}*individual.W_scaling(i,k))*states{k}(n-1,:)')';            
        end
        
        if size(individual.activ_Fcn,2) > 1
            for p = 1:individual.nodes(i)            
               states{i}(n,p) = individual.activ_Fcn{p}(((individual.input_weights{i}(p,:)*individual.input_scaling(i))*([individual.bias_node input_sequence(n,:)])')+ x{i}(n,p)');
            end
        else
            states{i}(n,:) = individual.activ_Fcn{1}(((individual.input_weights{i}*individual.input_scaling(i))*([individual.bias_node input_sequence(n,:)])')+ x{i}(n,:)'); 
        end
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

final_states = final_states(config.wash_out+1:end,:); % remove washout    
  