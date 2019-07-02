%% Mutation operator used for different reservoir systems
% Details:
% - number of weights mutated is based on mut_rate; 50% chance to change existing weight or remove it
% - 25% chance to change global parameters
function offspring = mutateRoR(offspring,config)

% params - input scaling and leak rate
input_scaling = offspring.input_scaling(:);
pos =  randi([1 length(input_scaling)],rand < 0.25,1);
input_scaling(pos) = 2*rand(length(pos),1)-1;
offspring.input_scaling = reshape(input_scaling,size(offspring.input_scaling));

leak_rate = offspring.leak_rate(:);
pos =  randi([1 length(leak_rate)],rand < 0.25,1);
leak_rate(pos) = rand(length(pos),1);
offspring.input_scaling = reshape(leak_rate,size(offspring.leak_rate));

% cycle through all sub-reservoirs
for i = 1:config.num_reservoirs

    % input weights
    input_weights = offspring.input_weights{i};
    pos =  randi([1 length(input_weights)],ceil(config.mut_rate*length(input_weights)),1);
    for n = 1:length(pos)
        if rand < 0.5 % 50% chance to zero weight
            input_weights(pos(i)) = 0;
        else
            input_weights(pos(i)) = 2*rand-1;
        end
    end
    offspring.input_weights{i} = reshape(input_weights,size(offspring.input_weights{i}));
        
    % W scaling
    W_scaling = offspring.W_scaling(i,:);
    pos =  randi([1 length(W_scaling)],rand < 0.25,1);
    W_scaling(pos) = 2*rand(length(pos),1);
    offspring.W_scaling(i,:) = reshape(W_scaling,size(offspring.W_scaling(i,:)));

    % hidden weights
    for j = 1:config.num_reservoirs
        W = offspring.W{i,j}(:);
        % select weights to change
        pos =  randi([1 length(W)],ceil(config.mut_rate*length(W)),1);
        for n = 1:length(pos)
            if rand < 0.5 % 50% chance to zero weight
                W(pos(i)) = 0;
            else
                W(pos(i)) = rand-0.5;
            end   
        end
        offspring.W{i,j} = reshape(W,size(offspring.W{i,j}));
    end
end

% mutate output weights
if config.evolve_output_weights
    output_weights = offspring.output_weights(:);
    pos =  randi([1 length(output_weights)],ceil(config.mut_rate*length(output_weights)),1);
     for n = 1:length(pos)
        if rand > 0.75 % 75% chance to zero weight
            output_weights(pos(i)) = 0;
        else
            output_weights(pos(i)) = 2*rand-1;
        end
    end
    offspring.output_weights = reshape(output_weights,size(offspring.output_weights));
end


