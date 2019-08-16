%% Mutation operator used for different reservoir systems
% Details:
% - number of weights mutated is based on mut_rate; 50% chance to change existing weight or remove it
% - 25% chance to change global parameters
function offspring = mutateCNT(offspring,config)
     
% params - input scaling and leak rate
input_scaling = offspring.input_scaling(:);
pos =  randperm(length(input_scaling),sum(rand(length(input_scaling),1) < config.mut_rate));
input_scaling(pos) = 2*rand(length(pos),1)-1;
offspring.input_scaling = reshape(input_scaling,size(offspring.input_scaling));

leak_rate = offspring.leak_rate(:);
pos =  randperm(length(leak_rate),sum(rand(length(leak_rate),1) < config.mut_rate));
leak_rate(pos) = rand(length(pos),1);
offspring.input_scaling = reshape(leak_rate,size(offspring.leak_rate));

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
        
    % electrode_type
    electrode_type = offspring.electrode_type(i,:);
    pos =  randperm(length(electrode_type),ceil(config.mut_rate*length(electrode_type)));
    for n = 1:length(pos)
        if rand < 0.5 % 50% chance to zero weight
            if sum(electrode_type > 0) >= 2 
                electrode_type(pos(n)) = 0;
            end
        else
            if sum(electrode_type > 0) <= 31
                if rand < 0.5
                    electrode_type(pos(n)) = 1;
                else
                    electrode_type(pos(n)) = 2;
                end
            end
        end
    end
    offspring.electrode_type(i,:) = reshape(electrode_type,size(offspring.electrode_type(i,:)));
       
    % config_voltage
    config_voltage = offspring.config_voltage(i,:);
    pos =  randperm(length(config_voltage),sum(rand(length(config_voltage),1) < config.mut_rate));
    leak_rate(pos) = rand(length(pos),1);
    offspring.config_voltage(i,:) = reshape(config_voltage,size(offspring.config_voltage(i,:)));
end

% mutate output weights
if config.evolve_output_weights
    output_weights = offspring.output_weights(:);
    pos =  randperm(length(output_weights),ceil(config.mut_rate*length(output_weights)),1);
 
    for n = 1:length(pos)
        if rand > 0.75 % 75% chance to zero weight
            output_weights(pos(n)) = 0;
        else
            output_weights(pos(n)) = 2*rand-1;
        end
    end
    offspring.output_weights = reshape(output_weights,size(offspring.output_weights));
end


