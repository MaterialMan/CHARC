function new_population = selectionNSGAII(config, population)

num_individuals = length(population);
selected_individuals = zeros(1, num_individuals);
randnum = randi(num_individuals, [1, 2 * num_individuals]);

j = 1;
for i = 1:2:(2*num_individuals)
    
    p1 = randnum(i);
    p2 = randnum(i+1);
    
    if(~isempty(config.ref_points))
        if(  (population(p1).rank  < population(p2).rank) || ...
                ((population(p1).rank == population(p2).rank) &&...
                (population(p1).pref_dist < population(p2).pref_dist)))
            selected_individuals(j) = p1;
        else
            selected_individuals(j) = p2;
        end
    else
        if((population(p1).rank < population(p2).rank) ||...
                ((population(p1).rank == population(p2).rank) &&...
                (population(p1).distance > population(p2).distance) ))
            selected_individuals(j) = p1;
        else
            selected_individuals(j) = p2;
        end
    end
    j = j + 1;
end

new_population = population(selected_individuals);

end
