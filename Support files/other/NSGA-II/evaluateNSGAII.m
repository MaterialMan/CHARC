function [population, state] = evaluateNSGAII(config, population, state)

eval_times = zeros(1, length(population));

if config.parallel
    cnt = [];
    
    parfor i = 1:length(population)
        warning('off','all')
        
        individual = population(i);
        
        if individual.evaluated
            continue;
        end
        
        start_time = tic;
        variables = individual.variables;
        
        y = config.objective_function(variables,config);
        
        constraints = config.constraints_function(y,config);
        eval_times(i) = toc(start_time);
        
        cnt(i) = 1;
        %state.eval_count = state.eval_count + 1;
        
        % Save the objective values and constraint violations
        individual.objectives = y;
        individual.constraints= constraints;
        individual.evaluated = 1;
        
        if(~isempty(individual.constraints) )
            idx = find( constraints );
            if( ~isempty(idx) )
                individual.num_violations = length(idx);
                individual.violation_sum = sum( abs(constraints) );
            else
                individual.num_violations = 0;
                individual.violation_sum = 0;
            end
        end
        population(i) = individual;    
    end
    
    state.eval_count = sum(cnt);
else
    for i = 1:length(population)
        
        individual = population(i);
        
        if individual.evaluated
            continue;
        end
        
        start_time = tic;
        variables = individual.variables;
        
        y = config.objective_function(variables,config);
        
        constraints = config.constraints_function(y,config);
        eval_times(i) = toc(start_time);
        
        state.eval_count = state.eval_count + 1;
        
        % Save the objective values and constraint violations
        individual.objectives = y;
        individual.constraints= constraints;
        individual.evaluated = 1;
        
        if(~isempty(individual.constraints) )
            idx = find( constraints );
            if( ~isempty(idx) )
                individual.num_violations = length(idx);
                individual.violation_sum = sum( abs(constraints) );
            else
                individual.num_violations = 0;
                individual.violation_sum = 0;
            end
        end
        population(i) = individual;
        
    end
end

state.av_evalt   = sum(eval_times) / sum(eval_times ~= 0);

end
