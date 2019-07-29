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
    RBN_type{pos} = config.rule_list{randi(length(pos),1)};
    offspring.RBN_type = RBN_type;
end

% cycle through all sub-reservoirs
for i = 1:config.num_reservoirs
    
    % add/remove input locations
    input_loc = offspring.input_location{i};
    pos =  randperm(length(input_loc),ceil(config.mut_rate*length(input_loc)));
    input_loc(pos) = round(rand(length(pos),1));
    offspring.input_location{i} = reshape(input_loc,size(offspring.input_location{i}));
    
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
    
    % mutate initial conditions of CA
    if strcmp(config.res_type,'elementary_CA')
        initial_states = offspring.initial_states{i}(:);
        pos =  randperm(length(initial_states),ceil(config.mut_rate*length(initial_states)));  
        initial_states(pos) = round(rand(length(pos),1));
        offspring.initial_states{i} = reshape(initial_states,size(offspring.initial_states{i}));
    end
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

% %% rules
% if ~config.mono_rule
%     rules = genotype.rules(:);
%     pos =  randi([1 length(rules)],ceil(config.mutRate*length(rules)),1);
%     rules(pos) = round(rand(length(pos),1));
%     genotype.rules = int8(reshape(rules,size(genotype.rules)));
% else
%     new_rule = genotype.rules(:,1);
%     pos =  randi([1 length(new_rule)],ceil(config.mutRate*length(new_rule)),1);
%     new_rule(pos) = round(rand(length(pos),1));
%     genotype.rules = int8(repmat(new_rule,1,size(genotype.rules,2)));
% end
%
% % check rules, etc.
% genotype.node = assocRules(genotype.node, genotype.rules);
%
%
% % w_in
% w_in = genotype.w_in(:);
% pos =  randi([1 length(w_in)],ceil(config.mutRate*length(w_in)),1);
% if config.restricedWeight
%     w_in(pos) = datasample(0.2:0.2:1,length(pos));%2*rand(length(pos),1)-1;
% else
%     w_in(pos) = 2*rand(length(pos),1)-1;
% end
% genotype.w_in = reshape(w_in,size(genotype.w_in));
%
%
% % input_loc
% for i = 1:length(genotype.input_loc)
%     if rand < config.mutRate
%         genotype.input_loc(i) = round(rand);
%     end
% end
% genotype.totalInputs = sum(genotype.input_loc);
%
% % initial states
% if strcmp(config.resType,'basicCA')
%     initialStates = genotype.initialStates(:);
%     pos =  randi([1 length(initialStates)],ceil(config.mutRate*length(initialStates)),1);
%     initialStates(pos) = round(rand(length(pos),1));
%     genotype.initialStates = reshape(initialStates,size(genotype.initialStates));
% end
%
% if config.evolvedOutputStates
%     if rand < config.mutRate %not really used, yet
%         genotype.state_perc = rand;
%     end
%
%     % state_loc
%     for i = 1:length(genotype.state_loc)
%         if rand < config.mutRate
%             genotype.state_loc(i) = round(rand);
%         end
%     end
%
% end
%
