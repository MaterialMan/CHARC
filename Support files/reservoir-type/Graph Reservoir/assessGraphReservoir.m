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
end

%% collect states
for n = 2:size(input_sequence,1)
    
    for i= 1:config.num_reservoirs
        for k= 1:config.num_reservoirs
            if i ==k % remove excess weights added through mutation
                % find indices for graph weights
                graph_indx = logical(full(adjacency(individual.G{i})));
                % assign weights
                individual.W{i,k}(~graph_indx) = 0;
            end
            x{i}(n,:) = x{i}(n,:) + ((individual.W{i,k}*individual.W_scaling(i,k))*states{k}(n-1,:)')';
        end
        
        if iscell(individual.activ_Fcn)
            for p = 1:individual.nodes(i)            
                states{i}(n,p) = feval(individual.activ_Fcn{p},((individual.input_weights{i}(p,:)*individual.input_scaling(i))*([individual.bias_node input_sequence(n,:)])')+ x{i}(n,p)'); 
            end
        else
            states{i}(n,:) = feval(individual.activ_Fcn,((individual.input_weights{i}*individual.input_scaling(i))*([individual.bias_node input_sequence(n,:)])')+ x{i}(n,:)'); 
        end
    end
end

% for t= 2:size(inputSequence,1)
%     x(t,:) = feval(config.actvFunc,genotype.w_in*genotype.inputScaling*inputSequence(t,:)' + (genotype.w*genotype.Wscaling*x(t-1,:)'));
% end

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
  