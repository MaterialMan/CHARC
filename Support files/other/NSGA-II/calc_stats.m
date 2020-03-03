function state = calc_stats(state, population)

rank_vector = vertcat(population.rank);
rank_vector = sort(rank_vector);
state.front_count = rank_vector(length(population));
state.f1_count = length( find(rank_vector==1) );

end
