%% Mutation operator used for different reservoir systems
% Details:
% - number of weights mutated is based on mut_rate; 50% chance to change existing weight or remove it
% - 25% chance to change global parameters
function offspring = mutateRoR(offspring,config)
     
% params - input scaling and leak rate
input_scaling = offspring.input_scaling(:);
pos =  randperm(length(input_scaling),sum(rand(length(input_scaling),1) < config.mut_rate));
input_scaling(pos) = 2*rand(length(pos),1)-1;
offspring.input_scaling = reshape(input_scaling,size(offspring.input_scaling));

leak_rate = offspring.leak_rate(:);
pos =  randperm(length(leak_rate),sum(rand(length(leak_rate),1) < config.mut_rate));
leak_rate(pos) = rand(length(pos),1);
offspring.input_scaling = reshape(leak_rate,size(offspring.leak_rate));

% W scaling
W_scaling = offspring.W_scaling(:);
pos =  randperm(length(W_scaling),sum(rand(length(W_scaling),1) < config.mut_rate));
W_scaling(pos) = 2*rand(length(pos),1);
offspring.W_scaling = reshape(W_scaling,size(offspring.W_scaling));

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
        
    % hidden weights
    for j = 1:config.num_reservoirs
        W = offspring.W{i,j}(:);
        % select weights to change
        pos =  randperm(length(W),ceil(config.mut_rate*length(W)));
        for n = 1:length(pos)
            if rand < 0.5 % 50% chance to zero weight
                W(pos(n)) = 0;
            else
                W(pos(n)) = 2*rand-1;%0.5;
            end   
        end
        offspring.W{i,j} = reshape(W,size(offspring.W{i,j}));
    end
    
    % mutate activ fcns
    if size(offspring.activ_Fcn,2) > 1
        activFcn = offspring.activ_Fcn(i,:);
        pos =  randperm(length(activFcn),sum(rand(length(activFcn),1) < config.mut_rate));
        activFcn(pos) = {config.activ_list{randi([1 length(config.activ_list)],length(pos),1)}};
        offspring.activ_Fcn(i,:) = reshape(activFcn,size(offspring.activ_Fcn(i,:)));
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

% mutate feedback weights
if config.evolve_feedback_weights
    % feedback scaling
    feedback_scaling = offspring.feedback_scaling(:);
    pos =  randperm(length(feedback_scaling),sum(rand(length(feedback_scaling),1) < config.mut_rate));
    feedback_scaling(pos) = 2*rand(length(pos),1);
    offspring.feedback_scaling = reshape(feedback_scaling,size(offspring.feedback_scaling));

    feedback_weights = offspring.feedback_weights(:);
    pos =  randperm(length(feedback_weights),ceil(config.mut_rate*length(feedback_weights)));
 
    for n = 1:length(pos)
        if rand > 0.75 % 75% chance to zero weight
            feedback_weights(pos(n)) = 0;
        else
            feedback_weights(pos(n)) = 2*rand-1;
        end
    end
    offspring.feedback_weights = reshape(feedback_weights,size(offspring.feedback_weights));
end
