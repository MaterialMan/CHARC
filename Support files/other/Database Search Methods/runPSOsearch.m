%% set parameters for tasks
config.rngState = 2;
config.taskList ={'NARMA30'};               % assign tasks. Can be multiple, e.g.  config.taskList ={'NARMA10', 'Laser', 'Iris'};, etc.
config.leakOn = 0;                          % add leak states
config.AddInputStates = 1;                  % add input to states
config.regParam = 10e-5;                    % training regulariser
config.sparseInputWeights = 0;              % use sparse inputs
config.restricedWeight = 0;                  % restrict weights between [0.2 0.4. 0.6 0.8 1]
config.evolvedOutputStates = 0;             % sub-sample the states to produce output (is evolved)
config.evolveOutputWeights = 0;             % evolve rather than train

config.discrete = 0;               % binary input for discrete systems
config.nbits = 16;                       % if using binary/discrete systems 
config.preprocess = 1;                   % basic preprocessing, e.g. scaling and mean variance
config.compare_to_rand_search = 1;        % if wanting to compare PSO to rand search

%% PSO and parameters 
config.swarm_size  = 10;
config.maxStall = 15;
config.maxIter =50;

config.InertiaRange = [0.1, 1.1];
config.SelfAdjustmentWeight = 1.49;
config.SocialAdjustmentWeight = 1.49;
config.MinNeigh = 0.25;
    
[final_error, final_metrics, best_indv, output] =  psoOnDatabase(config,database,database_genotype);

if config.compare_to_rand_search
    %% get task errors for all in the database - needed for random search
    %task_error = assessDBonTasks(config,database_genotype,database);
    
    %% Equivalent random search
    num_rand = output.funccount;
    indx = randi([1 length(database)],num_rand,1);
    rand_search = task_error.outputs(indx);
    best_rand = min(rand_search);
end