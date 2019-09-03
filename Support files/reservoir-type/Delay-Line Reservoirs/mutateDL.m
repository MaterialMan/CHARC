function offspring = mutateDL(offspring,config)

% params - input scaling and leak rate
input_scaling = offspring.input_scaling(:);
pos =  randi([1 length(input_scaling)],rand < 0.25,1);
input_scaling(pos) = 2*rand(length(pos),1)-1; % between [-1, 1]
offspring.input_scaling = reshape(input_scaling,size(offspring.input_scaling));

leak_rate = offspring.leak_rate(:);
pos =  randi([1 length(leak_rate)],rand < 0.25,1);
leak_rate(pos) = rand(length(pos),1); % between [0, 1]
offspring.input_scaling = reshape(leak_rate,size(offspring.leak_rate));

% DL  parameters
eta  = offspring.eta(:);
pos =  randi([1 length(eta)],rand < 0.25,1);
eta(pos) = rand(length(pos),1); % between [0, 1]
offspring.eta  = reshape(eta,size(offspring.eta));

gamma  = offspring.gamma(:);
pos =  randi([1 length(gamma)],rand < 0.25,1);
gamma(pos) = rand(length(pos),1); % between [0, 1]
offspring.gamma  = reshape(gamma,size(offspring.gamma));

p  = offspring.p(:);
pos =  randi([1 length(p)],rand < 0.25,1);
p(pos) = max([1 round(20*rand(length(pos),1))]); % between [1, 20]
offspring.p  = reshape(p,size(offspring.p));

% cycle through all sub-reservoirs
for i = 1:config.num_reservoirs
    
    % input weights
    input_weights = offspring.input_weights{i};
    pos =  randi([1 length(input_weights)],ceil(config.mut_rate*length(input_weights)),1);
    for n = 1:length(pos)
        if rand < 0.5 % 50% chance to zero weight
            input_weights(pos(n)) = 0;
        else
            if config.binary_weights
                input_weights(pos(n)) = sign(2*rand-1);
            else
                input_weights(pos(n)) = 2*rand-1; % between [-1, 1]
            end
        end
    end
    offspring.input_weights{i} = reshape(input_weights,size(offspring.input_weights{i}));    
end

% mutate output weights
if config.evolve_output_weights
    output_weights = offspring.output_weights(:);
    pos =  randi([1 length(output_weights)],ceil(config.mut_rate*length(output_weights)),1);
    for n = 1:length(pos)
        if rand > 0.75 % 75% chance to zero weight
            output_weights(pos(n)) = 0;
        else
            output_weights(pos(n)) = 2*rand-1;
        end
    end
    offspring.output_weights = reshape(output_weights,size(offspring.output_weights));
end



