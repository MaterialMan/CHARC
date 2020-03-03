%% Mutation operator used for wave-based reservoir systems
% Details:
% - number of weights mutated is based on mut_rate; 50% chance to change existing weight or remove it
% - 25% chance to change global parameters
function offspring = mutateWave(offspring,config)

% params - input scaling and leak rate
input_scaling = offspring.input_scaling(:);
pos =  randperm(length(input_scaling),sum(rand(length(input_scaling),1) < config.mut_rate));
input_scaling(pos) = 2*rand(length(pos),1)-1;
offspring.input_scaling = reshape(input_scaling,size(offspring.input_scaling));

leak_rate = offspring.leak_rate(:);
pos =  randperm(length(leak_rate),sum(rand(length(leak_rate),1) < config.mut_rate));
leak_rate(pos) = rand(length(pos),1);
offspring.leak_rate = reshape(leak_rate,size(offspring.leak_rate));

% wave parameters
time_period = offspring.time_period(:);
pos =  randperm(length(time_period),sum(rand(length(time_period),1) < config.mut_rate));
%time_period(pos) = randi([1 config.max_time_period],length(pos),1);
time_period = repmat(randi([1 config.max_time_period]),1,config.num_reservoirs);
offspring.time_period = reshape(time_period,size(offspring.time_period));

wave_speed = offspring.wave_speed(:);
pos =  randperm(length(wave_speed),sum(rand(length(wave_speed),1) < config.mut_rate));
wave_speed(pos) = randi([1 12],length(pos),1);
offspring.wave_speed = reshape(wave_speed,size(offspring.wave_speed));

damping_constant = offspring.damping_constant(:);
pos =  randperm(length(damping_constant),sum(rand(length(damping_constant),1) < config.mut_rate));
damping_constant(pos) = rand(length(pos),1);
offspring.damping_constant = reshape(damping_constant,size(offspring.damping_constant));

% cycle through all sub-reservoirs
for i = 1:config.num_reservoirs
    
    % boundary_conditions
    pos = randi([1 config.num_reservoirs]);
    %boundary_conditions = offspring.boundary_conditions(pos,:);
    offspring.boundary_conditions(pos,:) = config.boundary_conditions{randi([1 length(config.boundary_conditions)])};
    
    %pos =  randperm(length(boundary_conditions),sum(rand(length(boundary_conditions),1) < config.mut_rate));
    %boundary_conditions = boundary_conditions(randperm(length(boundary_conditions)));%round(rand(length(pos),1));
    %offspring.boundary_conditions(pos,:) = reshape(boundary_conditions,size(offspring.boundary_conditions(pos,:)));
   
    % input weights
    input_weights = offspring.input_weights{i}(:);
    pos =  randperm(length(input_weights),ceil(config.mut_rate*length(input_weights)));
    for n = 1:length(pos)
        input_weights(pos(n)) = mutateWeight(input_weights(pos(n)),config);
    end
    offspring.input_weights{i} = reshape(input_weights,size(offspring.input_weights{i}));
    
    input_widths = offspring.input_widths{i}(:);
    pos =  randperm(length(input_widths),sum(rand(length(input_widths),1) < config.mut_rate));
    input_widths(pos) = randi([1 4],length(pos),1);
    offspring.input_widths{i} = reshape(input_widths,size(offspring.input_widths{i}));
    
    % hidden weights
    for j = 1:config.num_reservoirs
        switch(config.wave_system)
            case 'fully-connected'
                if i~=j
                    W = offspring.W{i,j}(:);
                    % select weights to change
                    pos =  randperm(length(W),ceil(config.mut_rate*length(W)));
                    for n = 1:length(pos)
                        W(pos(n)) = mutateWeight(W(pos(n)),config);
                    end
                    offspring.W{i,j} = reshape(W,size(offspring.W{i,j}));
                end
            case 'pipeline'
                if j == i+1
                    W = offspring.W{i,j}(:);
                    % select weights to change
                    pos =  randperm(length(W),ceil(config.mut_rate*length(W)));
                    for n = 1:length(pos)
                        W(pos(n)) = mutateWeight(W(pos(n)),config);
                    end
                    offspring.W{i,j} = reshape(W,size(offspring.W{i,j}));
                end
        end
    end
    
    offspring.connectivity(i,j) = nnz(offspring.W{i,j})/offspring.total_units.^2;
    
end

% mutate output weights
if config.evolve_output_weights
    output_weights = offspring.output_weights(:);
    pos =  randperm(length(output_weights),ceil(config.mut_rate*length(output_weights)));
    
    for n = 1:length(pos)
        %         if rand > 0.75 % 75% chance to zero weight
        %             output_weights(pos(n)) = 0;
        %         else
        %             output_weights(pos(n)) = 2*rand-1;
        %         end
        input_weights(pos(n)) = input_weights(pos(n)) - randn*0.15;
    end
    offspring.output_weights = reshape(output_weights,size(offspring.output_weights));
end

end

function value = mutateWeight(value,config)

switch(config.mutate_type)
    case 'gaussian'
        value = value-randn*0.15;
        
    case 'uniform'
        if rand > 0.5 % 50% chance to zero weight
            value = 0;
        else
            value = 2*rand-1;
        end
end
end
