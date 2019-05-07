function [config, population] = calc_prefdist(config, population, fronts)

num_objectives = length( population(1).objectives );

ref_points = config.ref_points;
ref_weight = config.ref_weight;      % weight factor of objectives

if(isempty(ref_weight))
    ref_weight = ones(1, num_objectives);
end

epsilon = config.ref_epsilon;
num_ref_points = size(ref_points, 1);

% Determine the normalized factor
%
% Set use_fmm true to use the maximum and minimum value in the front
% as the normalized factor.
use_fmm = false;

if(strcmpi(config.use_ndist, 'ever') )
    % 1) Find possible (not current population) maximum and minimum value
    %     of each objective.
    objectives = vertcat(population.objectives);
    if( ~isfield(config, 'ref_obj_max_tmp') )
        config.ref_obj_max_tmp = max(objectives);
        config.ref_obj_min_tmp = min(objectives);
    else
        obj_max = max(objectives);
        obj_min = min(objectives);
        for i = 1:num_objectives
            if(config.ref_obj_max_tmp(i) < obj_max(i))
                config.ref_obj_max_tmp(i) = obj_max(i);
            end
            if(config.ref_obj_min_tmp(i) > obj_min(i))
                config.ref_obj_min_tmp(i) = obj_min(i);
            end
        end
        clear obj_max obj_min;
    end
    obj_max_min = config.ref_obj_max_tmp - config.ref_obj_min_tmp;
    clear objectives;
    
elseif( strcmpi(config.use_ndist, 'front') )
    use_fmm = true;
elseif( strcmpi(config.use_ndist, 'no') )
    obj_max_min = ones(1,num_objectives);
end

for front = 1:length(fronts)
    % Step1: Calculate the weighted Euclidean distance in each front
    individuals = fronts(front).individuals;
    num_individuals = length(individuals);
    front_population = population(individuals);
    front_objectives = vertcat(front_population.objectives);
    
    if(use_fmm)
        % Normalisation factor for the current front.
        obj_max_min = max(front_objectives) - min(front_objectives);
    end
    
    % Weighted normalised Euclidean distance
    norm_dist = calc_wnorm_dist(front_objectives, ref_points,...
        obj_max_min, ref_weight);
    
    % Assign the preference distance
    prefd_matrix = zeros(num_individuals, num_ref_points);
    
    for i = 1:num_ref_points
        [~,ix] = sort(norm_dist(:, i));
        prefd_matrix(ix, i) = 1:num_individuals;
    end
    
    pref_dist = min(prefd_matrix, [], 2);
    clear ix
    
    % Epsilon clearing strategy
    remaining_individuals = 1:num_individuals;
    while(~isempty(remaining_individuals))
        % Select one remaining individual
        objectives_remain = front_objectives( remaining_individuals, :);
        selected_index = randi( [1,length(remaining_individuals)] );
        selected_objectives = objectives_remain(selected_index, :);
        
        % Calc normalized Euclidean distance to the selected points
        dist_sel = calc_wnorm_dist(objectives_remain, selected_objectives, obj_max_min, ref_weight);
        
        % Process the individuals within the epsilon-neighborhood
        idx = find( dist_sel <= epsilon );     % idx : index in idxRemain
        if(length(idx) == 1)    % the only individual is the selected one
            remaining_individuals(selected_index)=[];
        else
            for i=1:length(idx)
                if( idx(i)~=selected_index )
                    idInIdxRemain = idx(i);     % idx is the index in idxRemain vector
                    id = remaining_individuals(idInIdxRemain);
                    
                    % *Increase the preference distance to discourage the individuals
                    % to remain in the selection.
                    pref_dist(id) = pref_dist(id) + round(num_individuals/2);
                end
            end
            remaining_individuals(idx) = [];
        end
        
    end
    
    % Save the preference distance
    for i=1:num_individuals
        id = individuals(i);
        population(id).pref_dist = pref_dist(i);
    end
end
end
