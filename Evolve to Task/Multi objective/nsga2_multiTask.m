%% Multi-Objective evolution using the Non-dominated Sorting Genetic Algorithm (NSGA-II)
% - Works with any reservoir type on the path
% - Requires at least 2 tasks (defined in config.dataSet)
% - parallel evaluation available through "config.parallel = 1"
% - pareto front based on training and validation error

% Author: Matt Dale
% Date:   20/11/18

%% Setup
% type of network to evolve
config.res_type = 'ELM';                     % can use different hierarchical reservoirs or substrate. RoR_IA is default ESN.
config.res_type = 'RoR';                % state type of reservoir to use. E.g. 'RoR' (Reservoir-of-reservoirs/ESNs), 'ELM' (Extreme learning machine), 'Graph' (graph network of neurons), 'DL' (delay line reservoir) etc. Check 'selectReservoirType.m' for more.
config.num_nodes = 50;                  % num of nodes in each sub-reservoir, e.g. if config.num_nodes = {10,5,15}, there would be 3 sub-reservoirs with 10, 5 and 15 nodes each. For one reservoir, sate as a non-cell, e.g. config.num_nodes = 25
config = selectReservoirType(config);   % collect function pointers for the selected reservoir type 

%% Evolutionary parameters
config.num_tests = 1;                        % num of tests/runs
config.pop_size = 100;                       % initail population size. Note: this will generally bias the search to elitism (small) or diversity (large)
config.max_generations = 1000;                    % number of generations to evolve 
config.mut_rate = 0.1;                       % mutation rate
config.rec_rate = 0.5;                       % recombination rate

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
config.dataset = {'Iris'};       %make they have the same number of inputs and outputs
config.num_objectives = length(config.dataset);

for n = 1:config.num_objectives
    [data{n}] = selectDataset(config);
end

config.data = data;
config = getDataSetInfo(config);
config.trainInputSequence =[];

for run = 1:config.num_tests
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

