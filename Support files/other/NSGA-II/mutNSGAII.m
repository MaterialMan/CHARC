function population = mutNSGAII(config, population)


for individual = 1:length(population)
    
    % Perform mutation.
    parent = population(individual);
    child = parent;
    
    child.variables = config.mutFcn(child.variables,config);
     
    if isequal(parent, child) ~= 1
        child.evaluated = 0;
    end
    
    population(individual) = child;
    
end
end

