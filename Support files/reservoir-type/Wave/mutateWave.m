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
offspring.input_scaling = reshape(leak_rate,size(offspring.leak_rate));

% wave parameters
time_period = offspring.time_period(:);
pos =  randperm(length(time_period),sum(rand(length(time_period),1) < config.mut_rate));
time_period(pos) = randi([1 10],length(pos),1);
offspring.time_period = reshape(time_period,size(offspring.time_period));

wave_speed = offspring.wave_speed(:);
pos =  randperm(length(wave_speed),sum(rand(length(wave_speed),1) < config.mut_rate));
wave_speed(pos) = randi([1 20],length(pos),1);
offspring.wave_speed = reshape(wave_speed,size(offspring.wave_speed));

damping_constant = offspring.damping_constant(:);
pos =  randperm(length(damping_constant),sum(rand(length(damping_constant),1) < config.mut_rate));
damping_constant(pos) = rand(length(pos),1);
offspring.damping_constant = reshape(damping_constant,size(offspring.damping_constant));

boundary_conditions = offspring.boundary_conditions(:);
pos =  randperm(length(boundary_conditions),sum(rand(length(boundary_conditions),1) < config.mut_rate));
boundary_conditions(pos) = round(rand(length(pos),1));
offspring.boundary_conditions = reshape(boundary_conditions,size(offspring.boundary_conditions));


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


