%% Multi-Objective evolution using the Non-dominated Sorting Genetic Algorithm (NSGA-II)
% - Works with any reservoir type on the path
% - Requires at least 2 tasks (defined in config.dataSet)
% - parallel evaluation available through "config.parallel = 1"
% - pareto front based on training and validation error

% Author: Matt Dale
% Date:   20/11/18

%% Setup
% type of network to evolve
config.resType = 'ELM';                     % can use different hierarchical reservoirs or substrate. RoR_IA is default ESN.
config.maxMinorUnits = 10;                   % num of nodes in subreservoirs
config.maxMajorUnits = 1;                   % num of subreservoirs. Default ESN should be 1.
config = selectReservoirType(config);       % get correct functions for type of reservoir

%% Network details
config.leakOn = 0;                          % add leak states
config.AddInputStates = 1;                  % add input to states
config.regParam = 10e-5;                    % training regulariser
config.sparseInputWeights = 0;              % use sparse inputs
config.restricedWeight =0;                  % restrict weights between [0.2 0.4. 0.6 0.8 1]
config.evolvedOutputStates = 0;             % sub-sample the states to produce output (is evolved)
config.evolveOutputWeights = 0;             % evolve rather than train

%% Evolutionary parameters
config.numTests = 1;                        % num of runs
config.popSize = 50;                         % large pop usually better
config.max_generations = 20;                % num of gens
config.mutRate = 0.1;                       % mutation rate
config.recRate = 0.5;                       % corssover rate

%% General params
config.parallel = 1;                        % use parallel toolbox
config.update_interval = 1;                 % gens to display achive and database
config.startTime = datestr(now, 'HH:MM:SS');
config.save_interval = config.max_generations/2;% save at gen = saveGen
saveResults = [];

%% NSGA params
config.objective_function = @fitnessNSGAII;
config.constraints_function = @constraints_function;
config.nsga2 = 1;
config.ref_vals = [];
config.ref_points = [];
config.num_constraints = 0;

%% Get datasets
config.dataSet = {'poleBalance', 'Iris'};       %make they have the same number of inputs and outputs
config.num_objectives = length(config.dataSet);

for n = 1:config.num_objectives
    [data{n}.trainInputSequence,data{n}.trainOutputSequence,data{n}.valInputSequence,data{n}.valOutputSequence,...
        data{n}.testInputSequence,data{n}.testOutputSequence,data{n}.nForgetPoints,data{n}.errType] = selectDataset(config.dataSet{n});
end
config.data = data;
config = getDataSetInfo(config);
config.trainInputSequence =[];

for run = 1:config.numTests
    %% Define other structures
    state = struct(...
        'current_generation', 1,...
        'eval_count', 0,...
        'f1_count', 0,...
        'front_count', 0,...
        'av_evalt', 0,...
        'run_time', 0);
    
    individual = struct(...
        'variables', config.createFcn(config), ...
        'objectives', zeros(1,config.num_objectives), ...
        'constraints', zeros(1,config.num_constraints),...
        'rank', 0,...
        'distance', 0,...
        'num_violations', 0,...
        'violation_sum', 0,...
        'evaluated', 0,...
        'pref_dist',0);
    
    results = struct(...
        'state', [],...
        'populations', [],...
        'ref_individual',[],...
        'rng_state', [],...
        'F',struct('cdata',0,'colormap',0),...
        'config',[]);
    
    %% loaded_results = load('results.mat')
    start_time = tic;
    rng(run, 'simdTwister');
    results.rng_state = rng;
    tic
    
    % Evaluate and store the reference individual
    if ~isempty(config.ref_vals)
        ref_individual = individual;
        ref_individual.variables = config.ref_vals;
        [ref_individual(1), ~] = evaluateNSGAII(config, [ref_individual], state);
        results.ref_individual = ref_individual;
    end
    
    %% Generate and evaluate the initial population
    population = repmat(individual,[1,config.popSize]);
    results.populations = repmat(population, [config.max_generations, 1]);
    results.state = repmat(state, [config.max_generations, 1]);
    
    %create population
    genotype = config.createFcn(config);
    for i = 1:length(population)
        population(i).variables = genotype(i);
    end
    
    %evaluate each individual
    [population, state] = evaluateNSGAII(config, population, state);
    [config, population] = nd_sort(config, population);
    
    state = calc_stats(state, population);
    state.run_time = toc(start_time);
    
    results.state(state.current_generation) = state;
    results.populations(state.current_generation, :) = population;
    results.config = config;
    
    results.F = plot_front(population, results.ref_individual, unique(vertcat(population.rank)), config.num_objectives, true,state.current_generation,results.F,config);
    
    %% Start evolution loop
    while(state.current_generation < config.max_generations)
        
        state.current_generation = state.current_generation + 1;
        
        new_population = selectionNSGAII(config, population);
        new_population = crossoverNSGAII(config, new_population);
        new_population = mutNSGAII(config, new_population);
        [new_population, state] = evaluateNSGAII(config, new_population, state);
        
        combined_population = [population, new_population];
        [config, combined_population] = nd_sort(config, combined_population);
        population = extract_population(config, combined_population);
        
        state = calc_stats(state, population);
        state.run_time = toc(start_time);
        
        results.state(state.current_generation) = state;
        results.populations(state.current_generation, :) = population;
        results.config = config;
        
        % Safe to save and stop below this point
        if mod(state.current_generation, config.update_interval) == 0
            results.F = plot_front(population,results.ref_individual, unique(vertcat(population.rank)),config.num_objectives, true,state.current_generation,results.F,config);
            fprintf('Generation: %d, Time: %.2f\n', state.current_generation,toc);
            tic
        end
        if mod(state.current_generation, config.save_interval) == 0
            save(strcat('NSGAII_Task_',config.dataSet{1},'_substrate_',config.resType,'_',num2str(config.maxMajorUnits),'Nres_',num2str(config.maxMinorUnits),'_nSize.mat'),...
                'genotype','config','results','-v7.3');
        end
    end
    
    % save each run
    saveResults{run} = results;
end

