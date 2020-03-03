function population = calc_crowding(population, fronts)

num_objectives = length( population(1).objectives );

for front = 1:length(fronts)
    
    front_individuals = fronts(front).individuals;
    front_population = population(front_individuals);
    num_individuals = length(front_individuals);
    objectives = vertcat(front_population.objectives);
    objectives = [objectives, front_individuals'];
    
    for i = 1:num_objectives
        
        objectives = sortrows(objectives, i);
        col_index = num_objectives+1;
        population( objectives(1, col_index) ).distance = Inf;  % the first individual
        population( objectives(num_individuals, col_index) ).distance = Inf; % the last individual
        
        min_objective = objectives(1, i);
        max_objective = objectives(num_individuals, i);
        
        for j = 2:(num_individuals-1)
            id = objectives(j, col_index);
            population(id).distance = population(id).distance +...
                (objectives(j+1, i) - objectives(j-1, i)) /...
                (max_objective - min_objective);
        end
        
    end
end

end
