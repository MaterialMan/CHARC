function new_population = extract_population(config, combined_population)

popSize = length(combined_population) / 2;
new_population = combined_population(1:popSize);
rank_vector = vertcat(combined_population.rank);

n = 0;   % Number of individuals in the next population
current_rank = 1;
individuals = find(rank_vector == current_rank);
num_individuals = length(individuals); % Number of individuals in the current front

while( n + num_individuals <= popSize )
    
    new_population( n+1 : n+num_individuals ) = combined_population( individuals );
    n = n + num_individuals;
    current_rank = current_rank + 1;
    individuals = find(rank_vector == current_rank);
    num_individuals = length(individuals);
    
end

% If the number of individuals in the next front plus the number of individuals
% in the current front is greater than the population size, then select the
% best individuals by corwding distance.

if( n < popSize )
    if(~isempty(config.ref_points))
        distance = vertcat(combined_population(individuals).pref_dist);
        distance = [distance, individuals];
        distance = sortrows( distance, 1);
        % Select the individuals with smallest preference distance
        idxSelect  = distance( 1:popSize-n, 2);
        new_population(n+1 : popSize) = combined_population(idxSelect);
    else
        distance = vertcat(combined_population(individuals).distance);
        distance = [distance, individuals];
        % Sort the individuals in descending order of crowding
        % distance in the front.
        distance = flipud( sortrows( distance, 1) );
        % Select the (popsize-n) individuals with largest crowding distance.
        idxSelect  = distance( 1:popSize-n, 2);
        new_population(n+1 : popSize) = combined_population(idxSelect);
    end
end

end
