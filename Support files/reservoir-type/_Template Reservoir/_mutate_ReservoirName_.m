%% mutate_ReservoirName_.m
% Template function to mutate the offspring reservoir. Use this as a guide when
% creating a new reservoir.
%
% How this function looks at the end depends on the reservoir. However,
% everything below is typically needed to work with all master scripts.
%
% This is called by the @config.mutateFcn pointer.
%
% Additional details:
% - Number of weights mutated is based on mut_rate; 50% chance to change existing weight or remove it

function offspring = mutate_ReservoirName_(offspring,config)
     
% params - input scaling and leak rate
input_scaling = offspring.input_scaling(:);
pos =  randperm(length(input_scaling),sum(rand(length(input_scaling),1) < config.mut_rate));
input_scaling(pos) = 2*rand(length(pos),1)-1;
offspring.input_scaling = reshape(input_scaling,size(offspring.input_scaling));

leak_rate = offspring.leak_rate(:);
pos =  randperm(length(leak_rate),sum(rand(length(leak_rate),1) < config.mut_rate));
leak_rate(pos) = rand(length(pos),1);
offspring.input_scaling = reshape(leak_rate,size(offspring.leak_rate));

% mutate other parameters - template below
% temp_variable_name = offspring.parameter(:);
% pos =  randperm(length(temp_variable_name),sum(rand(length(temp_variable_name),1) < config.mut_rate));
% temp_variable_name (pos) = 2*rand(length(pos),1);
% offspring.parameter = reshape(temp_variable_name,size(offspring.parameter));


% cycle through all sub-reservoirs
for i = 1:config.num_reservoirs

    % mutate input weights
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
        
    % Add additional sub-reservoir specific changes
    % e.g., connection matrix 'W'
    %     for j = 1:config.num_reservoirs
    %         W = offspring.W{i,j}(:);
    %         % select weights to change
    %         pos =  randperm(length(W),ceil(config.mut_rate*length(W)));
    %         for n = 1:length(pos)
    %             if rand < 0.5 % 50% chance to zero weight
    %                 W(pos(n)) = 0;
    %             else
    %                 W(pos(n)) = 2*rand-1;
    %             end   
    %         end
    %         offspring.W{i,j} = reshape(W,size(offspring.W{i,j}));
    %     end
    
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


