
%% Evolve substrate for a specific task
% This script can be used to evolve any reservoir directly to a task. It
% uses the steady-state Microbial Genetic Algorithm to evolve the best
% solution.

% Author: M. Dale
% Date: 03/07/19
clear %vars -except population
close all

% add all subfolders to the path --> make all functions in subdirectories available
% addpath(genpath(pwd));

rng(1,'twister');

%% Setup
config.parallel = 1;                        % use parallel toolbox

%start paralllel pool if empty
if isempty(gcp) && config.parallel
    parpool('local',4,'IdleTimeout', Inf); % create parallel pool
end

% type of network to evolve
config.res_type = 'RoR';             % state type of reservoir(s) to use. E.g. 'RoR' (Reservoir-of-reservoirs/ESNs), 'ELM' (Extreme learning machine), 'Graph' (graph network with multiple functions), 'DL' (delay line reservoir) etc. Check 'selectReservoirType.m' for more.
config.num_nodes = [50];                   % num of nodes in each sub-reservoir, e.g. if config.num_nodes = [10,5,15], there would be 3 sub-reservoirs with 10, 5 and 15 nodes each.
config = selectReservoirType(config);         % collect function pointers for the selected reservoir type

%% Evolutionary parameters
config.num_tests = 1;                        % num of tests/runs
config.pop_size = 50;                       % initail population size. Note: this will generally bias the search to elitism (small) or diversity (large)
config.total_gens = 2000;                    % number of generations to evolve
config.mut_rate = 0.05;                       % mutation rate
config.deme_percent = 0.1;                   % speciation percentage; determines interbreeding distance on a ring.
config.deme = round(config.pop_size*config.deme_percent);
config.rec_rate = 0.5;                       % recombination rate
config.error_to_check = 'train&val&test';    % printed error includes all three errors

%% Task parameters
config.discrete = 0;               % select '1' for binary input for discrete systems
config.nbits = 16;                 % only applied if config.discrete = 1; if wanting to convert data for binary/discrete systems
config.dataset = 'attractor';          % Task to evolve for

% get any additional params. This might include:
% details on reservoir structure, extra task variables, etc.
config = getAdditionalParameters(config);

% get dataset information
config = selectDataset(config);

%% general params
config.gen_print = 10;                       % after 'gen_print' generations print task performance and show any plots
config.start_time = datestr(now, 'HH:MM:SS');
config.save_gen = inf;                       % save data at generation = save_gen
config.figure_array = [figure figure];

% Only necessary if wanting to parallelise the microGA algorithm
config.multi_offspring = 1;                 % multiple tournament selection and offspring in one cycle
config.num_sync_offspring = 4;%config.deme;    % length of cycle/synchronisation step

% type of metrics to apply; if necessary
config.metrics = {'KR','GR','linearMC','crossMC','quadMC'};          % list metrics to apply in cell array: see getVirtualMetrics.m for types of metrics available
config.record_metrics = 0;                  % save metrics

% additional pruning, if required
config.prune = 0;                           % after best individual is found prune the network to make more efficient
config.tolerance = [0 0 0];
config.prune_iterations = 500;

%% Run experiments
for test = 1:config.num_tests
    
    clearvars -except config test best best_indv store_error population
    
    warning('off','all')
    fprintf('\n Test: %d  ',test);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    tic
    
    % tracker for sim plot
    last_best = 1;
    
    %set random seed
    rng(test,'twister');
    
    % create initial population
    population = config.createFcn(config);
    
    %Assess population
    if config.parallel % use parallel toolbox - faster
        ppm = ParforProgMon('Initial population: ', config.pop_size);
        parfor pop_indx = 1:config.pop_size
            warning('off','all')
            population(pop_indx) = config.testFcn(population(pop_indx),config);
            ppm.increment();
        end
    else
        for pop_indx = 1:config.pop_size
            tic
            population(pop_indx) = config.testFcn(population(pop_indx),config);
            fprintf('\n i = %d, error = %.4f, took: %.4f\n',pop_indx,getError(config.error_to_check,population(pop_indx)),toc);
        end
    end
    
    % find and print best individual
    [best(test,1),best_indv(test,1)] = min(getError(config.error_to_check,population));
    fprintf('\n Starting loop... Best error = %.4f\n',best(test,1));
    
    % store error that will be used as fitness in the GA
    store_error(test,1,:) = getError(config.error_to_check,population);
    
    %% start GA
    for gen = 2:config.total_gens
        
        % redefine seed - some functions/scripts may reset the seed
        rng(gen,'twister');
        
        % reshape stored error to compare errors
        cmp_error = reshape(store_error(test,gen-1,:),1,size(store_error,3));
        
        % Num of offspring to evolve
        if config.multi_offspring
            store_indv = []; w = []; l=[];  timer = 1;% keep track of tournaments
            for p = 1:floor(config.pop_size/2)-1
                % Tournment selection - pick two individuals
                equal = 1;
                while(equal) % find pair who are within deme range
                    timer = timer+1;
                    indv_1 = randi([1 config.pop_size]);
                    indv_2 = indv_1 + randi([1 config.deme])*2*round(rand)-1;
                    if indv_2 > config.pop_size % loop around, i.e population is on a ring
                        indv_2 = indv_2 - config.pop_size;
                    end
                    if indv_1 ~= indv_2 && indv_2 ~= 0 % contiue if not the same
                        if (ismember(indv_1,store_indv) || ismember(indv_2,store_indv)) && timer <= factorial(config.pop_size)/factorial(config.pop_size-2)
                            equal = 1;
                        else
                            store_indv = [store_indv; [indv_1 indv_2]];
                            equal = 0;
                        end
                    end
                end
                % Assess fitness of both and assign winner/loser
                if cmp_error(indv_1) < cmp_error(indv_2)
                    w(p)=indv_1; l(p) = indv_2;
                else
                    w(p)=indv_2; l(p) = indv_1;
                end
            end
            
            if config.num_sync_offspring > length(l) % make sure not larger than number of tournaments
                config.num_sync_offspring = length(l);
            end
            
             for p = 1:config.num_sync_offspring
                rng(gen + p,'twister')
                % Infection and mutation phase
                par_loser{p} = config.recFcn(population(w(p)),population(l(p)),config);
                par_loser{p} = config.mutFcn(par_loser{p},config);
             end    
            
            parfor p = 1:config.num_sync_offspring
                %% Evaluate and update fitness of loser
                par_loser{p} = config.testFcn(par_loser{p},config);
            end
            
            population(l(1:config.num_sync_offspring)) = [par_loser{1:config.num_sync_offspring}];   % replace losers (does not replace replicates)
            
            clearvars par_loser
            
            %update errors
            store_error(test,gen,:) =  store_error(test,gen-1,:);
            store_error(test,gen,l(1:config.num_sync_offspring)) = getError(config.error_to_check,population(l(1:config.num_sync_offspring)));
            
            % update best individual and error
            [best(test,gen),best_indv(test,gen)] = min(store_error(test,gen,:));
            
            % print info
            if (mod(gen,config.gen_print) == 0)
                fprintf('Gen %d, time taken: %.4f sec(s)\n Best Error: %.4f \n',gen,toc/config.gen_print,best(test,gen));
                tic;
                if best_indv(test,gen) ~= last_best
                   plotReservoirDetails(population,best_indv(test,:),gen,best_indv(test,gen-1),config); 
                end
                last_best = best_indv(gen);
            end
            
        else
            
            config.parallel = 0;
            
            % Tournment selection - pick two individuals
            equal = 1;
            while(equal) % find pair who are within deme range
                indv1 = randi([1 config.pop_size]);
                indv2 = indv1 + randi([1 config.deme]);
                if indv2 > config.pop_size
                    indv2 = indv2 - config.pop_size; %loop around population ring if too big
                end
                if indv1 ~= indv2
                    equal = 0;
                end
            end
            
            % Assess fitness of both and assign winner/loser
            if cmp_error(indv1) < cmp_error(indv2)
                winner=indv1; loser = indv2;
            else
                winner=indv2; loser = indv1;
            end
            
            % Infection and mutation. Place offspring in loser position
            population(loser) = config.recFcn(population(winner),population(loser),config);
            population(loser) = config.mutFcn(population(loser),config);
            
            %% Evaluate and update fitness
            [population(loser)] = config.testFcn(population(loser),config);
            
            %update errors
            store_error(test,gen,:) =  store_error(test,gen-1,:);
            store_error(test,gen,loser) = getError(config.error_to_check,population(loser));%population(loser).val_error;
            [best(test,gen),best_indv(test,gen)] = min(store_error(test,gen,:));
            
            % print info
            if (mod(gen,config.gen_print) == 0) 
                fprintf('Gen %d, time taken: %.4f sec(s)\n  Winner: %.4f, Loser: %.4f, Best Error: %.4f \n',gen,toc/config.gen_print,getError(config.error_to_check,population(winner)),getError(config.error_to_check,population(loser)),best(test,gen));
                tic;
                %if best_indv(gen) ~= last_best
                    % plot reservoir structure, task simulations etc.
                    plotReservoirDetails(population,best_indv(test,:),gen,loser,config);
               %end

                last_best = best_indv(gen);
            end
        end
        
        %save data
        if mod(gen,config.save_gen) == 0
            saveData(population,store_error,config)
        end
        
        % if found best, stop
        if best(test,gen) == 0
            return;
        end
    end
    
    % apply metrics to final population
    if config.record_metrics
        parfor pop_indx = 1:config.pop_size
            metrics(pop_indx,:) = getMetrics(population(pop_indx),config);
        end
    end
    
    if config.prune
        rng(1,'twister')
        pop_error = [population.train_error]+ [population.val_error]+[population.test_error];
        
        [~,indx] = sort(pop_error);
        
        parfor p = 1:4
            [Pruned_best_individual{p},old_W_fitness(p),old_Win_fitness(p),full_W{p}] = maxPruning(@testReservoir,{'train_error','val_error','test_error'},population(indx(p))...
                ,[population(indx(p)).train_error population(indx(p)).val_error population(indx(p)).test_error]...
                ,config.tolerance,config);
        end
        % plotReservoirDetails(population,best_indv,gen,loser,config)
    end
end

function saveData(population,store_error,config)
config.figure_array =[];
if iscell(config.res_type)
    res_type ='Heterotic';
else
    res_type = config.res_type;
end
save(strcat('EvolveToTask_substrate_',res_type,'_run',num2str(config.num_tests),'_gens',num2str(config.total_gens),'_',num2str(sum(config.num_reservoirs)),'Nres.mat'),...
    'population','store_error','config','-v7.3');
end


