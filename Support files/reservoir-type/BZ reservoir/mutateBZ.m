%% mutateBZ.m
% Used to mutate BZ spcific parameters

function offspring = mutateBZ(offspring,config)

% params - input scaling and leak rate
input_scaling = offspring.input_scaling(:);
pos =  randperm(length(input_scaling),sum(rand(length(input_scaling),1) < config.mut_rate));
input_scaling(pos) = 2*rand(length(pos),1)-1;
offspring.input_scaling = reshape(input_scaling,size(offspring.input_scaling));

leak_rate = offspring.leak_rate(:);
pos =  randperm(length(leak_rate),sum(rand(length(leak_rate),1) < config.mut_rate));
leak_rate(pos) = rand(length(pos),1);
offspring.leak_rate = reshape(leak_rate,size(offspring.leak_rate));

a = offspring.a(:);
pos =  randperm(length(a),sum(rand(length(a),1) < config.mut_rate));
a(pos) = rand(length(pos),1);
offspring.a = reshape(a,size(offspring.a));

b = offspring.b(:);
pos =  randperm(length(b),sum(rand(length(b),1) < config.mut_rate));
b(pos) = rand(length(pos),1);
offspring.b = reshape(b,size(offspring.b));

c = offspring.c(:);
pos =  randperm(length(c),sum(rand(length(c),1) < config.mut_rate));
c(pos) = rand(length(pos),1);
offspring.c = reshape(c,size(offspring.c));


% cycle through all sub-reservoirs
for i = 1:config.num_reservoirs
    
    for r = 1:3
        % mutate input weights
        input_weights = offspring.input_weights{i,r};
        pos =  randperm(length(input_weights),ceil(config.mut_rate*length(input_weights)));
        for n = 1:length(pos)
            if rand < 0.5 % 50% chance to zero weight
                input_weights(pos(n)) = 0;
            else
                input_weights(pos(n)) = 2*rand-1;
            end
        end
        offspring.input_weights{i,r} = reshape(input_weights,size(offspring.input_weights{i,r}));
        
        
        input_widths = offspring.input_widths{i,r}(:);
        pos =  randperm(length(input_widths),sum(rand(length(input_widths),1) < config.mut_rate));
        input_widths(pos) = randi([1 4],length(pos),1);
        offspring.input_widths{i,r} = reshape(input_widths,size(offspring.input_widths{i,r}));
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


