%% mutateGOL.m
% function to mutate the Game Of Life offspring reservoir. 
%
% This is called by the @config.mutateFcn pointer.
%
% Additional details:
% - Number of weights mutated is based on mut_rate; 50% chance to change existing weight or remove it

function offspring = mutateGOL(offspring,config)
     
% params - input scaling and leak rate
input_scaling = offspring.input_scaling(:);
pos =  randperm(length(input_scaling),sum(rand(length(input_scaling),1) < config.mut_rate));
input_scaling(pos) = 2*rand(length(pos),1)-1;
offspring.input_scaling = reshape(input_scaling,size(offspring.input_scaling));

leak_rate = offspring.leak_rate(:);
pos =  randperm(length(leak_rate),sum(rand(length(leak_rate),1) < config.mut_rate));
leak_rate(pos) = rand(length(pos),1);
offspring.input_scaling = reshape(leak_rate,size(offspring.leak_rate));

time_period = offspring.time_period(:);
pos =  randperm(length(time_period),sum(rand(length(time_period),1) < config.mut_rate));
time_period(pos) = randi([1 10],length(pos),1);
offspring.time_period = reshape(time_period,size(offspring.time_period));

boundary_condition = offspring.boundary_condition(:);
pos =  randperm(length(boundary_condition),sum(rand(length(boundary_condition),1) < config.mut_rate));
boundary_condition(pos) = randi([1 3],length(pos),1)-1;
offspring.boundary_condition = reshape(boundary_condition,size(offspring.boundary_condition));

% rules
birth_threshold = offspring.birth_threshold(:);
pos =  randperm(length(birth_threshold),sum(rand(length(birth_threshold),1) < config.mut_rate));
birth_threshold(pos) = randi([0 10],length(pos),1);
offspring.birth_threshold = reshape(birth_threshold,size(offspring.birth_threshold));

loneliness_threshold = offspring.loneliness_threshold(:);
pos =  randperm(length(loneliness_threshold),sum(rand(length(loneliness_threshold),1) < config.mut_rate));
loneliness_threshold(pos) = randi([0 5],length(pos),1);
offspring.loneliness_threshold = reshape(loneliness_threshold,size(offspring.loneliness_threshold));

overcrowding_threshold = offspring.overcrowding_threshold(:);
pos =  randperm(length(overcrowding_threshold),sum(rand(length(overcrowding_threshold),1) < config.mut_rate));
overcrowding_threshold(pos) = randi([1 5],length(pos),1);
offspring.overcrowding_threshold = reshape(overcrowding_threshold,size(offspring.overcrowding_threshold));

% conv filter
pad_size = offspring.pad_size(:);
pos =  randperm(length(pad_size),sum(rand(length(pad_size),1) < config.mut_rate));
pad_size(pos) = randi([1 10],length(pos),1);
offspring.pad_size = reshape(pad_size,size(offspring.pad_size));

stride = offspring.stride(:);
pos =  randperm(length(stride),sum(rand(length(stride),1) < config.mut_rate));
stride(pos) = randi([1 10],length(pos),1);
offspring.stride = reshape(stride,size(offspring.stride));


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
        
    input_widths = offspring.input_widths{i}(:);
    pos =  randperm(length(input_widths),sum(rand(length(input_widths),1) < config.mut_rate));
    input_widths(pos) = randi([1 4],length(pos),1);
    offspring.input_widths{i} = reshape(input_widths,size(offspring.input_widths{i}));

    % change kernels
    kernel_size = offspring.kernel_size(i);
    %kernel = offspring.kernel{i};
    pos =  randperm(length(kernel_size),sum(rand(length(kernel_size),1) < config.mut_rate));
    kernel_size(pos) = randi([1 10],length(pos),1);
    if length(pos) > 1
        offspring.kernel{pos} = ones(kernel_size(pos))./kernel_size(pos).^2; % summation filter
    end
    %offspring.kernel = kernel;
    offspring.kernel_size = reshape(kernel_size,size(offspring.kernel_size));

    
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


