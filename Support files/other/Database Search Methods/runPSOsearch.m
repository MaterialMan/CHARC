%% set parameters for tasks
config.rngState = 1;
config.task_list = {'narma_10'};               % assign tasks. Can be multiple, e.g.  config.taskList ={'NARMA10', 'Laser', 'Iris'};, etc.
config.error_to_check = 'train&val&test';

config.compare_to_rand_search = 0;        % if wanting to compare PSO to rand search

%% PSO and parameters 
config.swarm_size  = 10;
config.maxStall = 15;
config.maxIter = 50;

config.InertiaRange = [0.1, 1.1];
config.SelfAdjustmentWeight = 1.49;
config.SocialAdjustmentWeight = 1.49;
config.MinNeigh = 0.25;
    
all_behaviours = reshape([database.behaviours],length(database(1).behaviours),length(database))';
[final_error, final_metrics, best_indv, output] =  psoOnDatabase(config,all_behaviours,database);

if config.compare_to_rand_search
    %% get task errors for all in the database - needed for random search
    all_behaviours = reshape([database.behaviours],length(database(1).behaviours),length(database))';
    task_error = assessDBonTasks(config,database,all_behaviours);
    
    %% Equivalent random search
    num_rand = output.funccount;
    indx = randi([1 length(database)],num_rand,1);
    rand_search = task_error.outputs(indx);
    best_rand = min(rand_search);
end