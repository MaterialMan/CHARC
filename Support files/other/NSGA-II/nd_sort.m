function [config, population] = nd_sort(config, population)

% individual.dcount: The number of individuals which
% dominate this individual
%
% individual.dset(:): The set of individuals that this
% individual dset

num_individuals = length(population);
individuals = repmat(struct('dcount',0, 'dset', []),[1,num_individuals]);

for i = 1:num_individuals
    population(i).rank = 0;
    population(i).distance = 0;
    population(i).pref_dist = 0;
end

% Calculate the domination matrix for improved efficiency.
num_violations = zeros(num_individuals, 1);
violation_sum = zeros(num_individuals, 1);
for i = 1:num_individuals
    num_violations(i) = population(i).num_violations;
    violation_sum(i) = population(i).violation_sum;
end

objectives = vertcat(population(:).objectives);
domination_matrix = calc_dommat(num_violations, violation_sum, objectives);

% Compute dcount and dset for each individual
for p = 1:num_individuals-1
    for q = p+1:num_individuals
        if(domination_matrix(p, q) == 1)          % p dominates q
            individuals(q).dcount = individuals(q).dcount + 1;
            individuals(p).dset = [individuals(p).dset , q];
        elseif(domination_matrix(p, q) == -1)     % q dominates p
            individuals(p).dcount = individuals(p).dcount + 1;
            individuals(q).dset = [individuals(q).dset , p];
        end
    end
end

% The first front(rank = 1)
fronts = struct('individuals',[]);
fronts(1).individuals = [];
for i = 1:num_individuals
    if( individuals(i).dcount == 0 )
        population(i).rank = 1;
        fronts(1).individuals = [fronts(1).individuals, i];
    end
end

% Calculate pareto rank for each of the individuals
front = 1;
while( ~isempty(fronts(front).individuals) )
    Q = [];
    for p = fronts(front).individuals
        for q = individuals(p).dset
            individuals(q).dcount = individuals(q).dcount -1;
            if( individuals(q).dcount == 0 )
                population(q).rank = front+1;
                Q = [Q, q];
            end
        end
    end
    front = front + 1;
    fronts(front).individuals = Q;
end
fronts(front) = [];

if(isempty(config.ref_points))
    population = calc_crowding(population, fronts);
else
    [config, population] = calc_prefdist(config, population, fronts);
end

end

