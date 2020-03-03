function population = crossoverNSGAII(config, population)

for individual = 1:2:length(population)
    
    parent1 = population(individual);
    parent2 = population(individual+1);
    
    % Create children
    child1 = parent1;
    child2 = parent2;

    % crossover
    child1.variables = config.recFcn(parent1.variables,parent2.variables,config);
    child2.variables = config.recFcn(parent2.variables,parent1.variables,config);
                     
    %% final checks
    if isequal(child1, parent1) ~= 1
        child1.evaluated = 0;
    end
    
    if isequal(child2, parent2) ~= 1
        child2.evaluated = 0;
    end
    %
    population(individual) = child1;
    population(individual+1) = child2;
    
end
end

