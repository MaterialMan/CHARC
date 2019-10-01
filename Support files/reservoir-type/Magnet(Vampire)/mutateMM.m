%% Mutation operator used for magnetic film

function offspring = mutateMM(offspring,config)

source_num = size(offspring.minposx, 2);

% choose new random position for source
for i = 1:source_num
    if rand < config.mut_rate
        offspring.minposx(i) = rand;
        offspring.maxposx(i) = offspring.minposx(i)+0.1+(0.9-offspring.minposx(i))*rand;
    end
end

% for all physical parameters, choose new one from original distribution
for i = 1:source_num
    if rand < config.mut_rate
        offspring.minposy(i) = rand;
        offspring.maxposy(i) = offspring.minposy(i)+0.1+(0.9-offspring.minposy(i))*rand;
    end
end

if config.damping_parameter == 'dynamic'
    if rand < config.mut_rate
        if rand < 0.5 vary
            offspring.damping = 0.01 + (0.1-0.01)*rand;
        else
            offspring.damping = 0.1 + (1-0.1)*rand;
        end
    end
end

if config.anisotropy_parameter == 'dynamic'
    if rand < config.mut_rate
        if rand < 0.5 
            offspring.anisotropy = 1e-25 + (1e-24-1e-25)*rand;
        else
            offspring.anisotropy = 1e-24 + (1e-23-1e-24)*rand;
        end
    end
end

if config.temperature_parameter == 'dynamic'
    if rand < config.mut_rate
        offspring.temperature = normrnd(300,100);
        if offspring.temperature < 0
            offspring.temperature = 0;
        end
    end
end

if config.exchange_parameter == 'dynamic'
    if rand < config.mut_rate
        offspring.exchange = 1e-21 + (10e-21-1e-21)*rand;
    end
end

if config.magmoment_parameter == 'dynamic'
    if rand < config.mut_rate
        offspring.magmoment = 0.5 + (5-0.5)*rand;
    end
end

% change field strength by a small constant
for i = 1:source_num
    if rand < config.mut_rate
        if rand < 0.5
            offspring.signalmagnitude(i) = offspring.signalmagnitude(i) + 0.3;
        else
            offspring.signalmagnitude(i) = offspring.signalmagnitude(i) - 0.3;
        end
    end
end
