function offspring = mutateRBN(offspring,config)

% params - input scaling and leak rate
input_scaling = offspring.input_scaling(:);
pos =  randperm(length(input_scaling),sum(rand(length(input_scaling),1) < config.mut_rate));
input_scaling(pos) = 2*rand(length(pos),1)-1;
offspring.input_scaling = reshape(input_scaling,size(offspring.input_scaling));

leak_rate = offspring.leak_rate(:);
pos =  randperm(length(leak_rate),sum(rand(length(leak_rate),1) < config.mut_rate));
leak_rate(pos) = rand(length(pos),1);
offspring.input_scaling = reshape(leak_rate,size(offspring.leak_rate));

% change evaluation method
RBN_type = offspring.RBN_type;
pos =  randperm(length(RBN_type),sum(rand(length(RBN_type),1) < config.mut_rate));
if ~isempty(pos)
    RBN_type(pos) = config.rule_list(randi([1 length(config.rule_list)],length(pos),1));
    offspring.RBN_type = RBN_type;
end

% cycle through all sub-reservoirs
for i = 1:config.num_reservoirs
      
    % input weights
    input_weights = offspring.input_weights{i};
    pos =  randperm(length(input_weights),ceil(config.mut_rate*length(input_weights)));
    for n = 1:length(pos)
        if rand < 0.5 % 50% chance to zero weight
            input_weights(pos(n)) = 0;
        else
            input_weights(pos(n)) = 2*rand-1;
        end
    end
    offspring.input_weights{i} = reshape(input_weights,size(offspring.input_weights{i}));
    
    
    % rules
    if config.mono_rule
        rules = offspring.rules{i}(:,1);
        pos =  randperm(length(rules),double(rand < config.mut_rate));
        rules(pos) = round(rand(length(pos),1));
        offspring.rules{i} = int8(repmat(rules,1,size(offspring.rules{i},2)));
    else
        rules = offspring.rules{i}(:);
        pos =  randperm(length(rules),ceil(config.mut_rate*length(rules)));
        rules(pos) = round(rand(length(pos),1));
        offspring.rules{i} = int8(reshape(rules,size(offspring.rules{i})));
    end
    
    % hidden weights
    for j = 1:config.num_reservoirs
        
        if i == j
            if strcmp(config.res_type,'RBN')
                % mutate RBN node inputs
                RBN_inputs = [offspring.RBN_node{i}.input];
                pos =  randperm(length(RBN_inputs),ceil(config.mut_rate*length(RBN_inputs)));
                RBN_inputs(pos) = randi([1 offspring.nodes(j)],length(pos),1);
                RBN_inputs = reshape(RBN_inputs,offspring.nodes(i),config.k);
                for k = 1:length(RBN_inputs)
                    offspring.RBN_node{i}(k).input = RBN_inputs(k,:);%reshape(RBN_inputs,offspring.nodes(i),config.k);
                end
                offspring.W{i,j} = getAdjacenyMatrix(offspring,i,config);
            end
        else
            W = offspring.W{i,j}(:);
            % select weights to change
            pos =  randperm(length(W),ceil(config.mut_rate*length(W)));  
            for n = 1:length(pos)
                if rand < 0.5 % 50% chance to zero weight
                    W(pos(n)) = 0;
                else
                    W(pos(n)) = 1;
                end
            end
            offspring.W{i,j} = reshape(W,size(offspring.W{i,j}));
        end
    end
    
    % check and update rules, etc.
    offspring.RBN_node{i} = assocRules(offspring.RBN_node{i}, offspring.rules{i});
    %offspring.RBN_node{i} = assocNeighbours(offspring.RBN_node{i}, offspring.W{i,i});
    
    % mutate evolution time of CA
    time_period = offspring.time_period(i);
    pos =  randperm(length(time_period),ceil(config.mut_rate*length(time_period)));
    time_period(pos) = randi([1 10],length(pos),1);
    offspring.time_period(i) = reshape(time_period,size(offspring.time_period(i)));

end



% mutate output weights
if config.evolve_output_weights
    output_weights = offspring.output_weights(:);
    pos =  randperm(length(output_weights),ceil(config.mut_rate*length(output_weights)));  
    for n = 1:length(pos)
        if rand > 0.75 % 75% chance to zero weight
            output_weights(pos(n)) = 0;
        else
            output_weights(pos(n)) = 2*rand-1;
        end
    end
    offspring.output_weights = reshape(output_weights,size(offspring.output_weights));
end

