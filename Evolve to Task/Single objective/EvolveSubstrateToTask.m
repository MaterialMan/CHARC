%% Evolve substrate for a specific task
% This script can be used to evolve any reservoir directly to a task. It
% uses the steady-state Microbial Genetic Algorithm to evolve the best
% solution.

% Author: M. Dale
% Date: 08/11/18
clearvars -except config total_score recomb_list mut_list mut_j rec_i
close all

% add all subfolders to the path --> make all functions in subdirectories available
% addpath(genpath(pwd));

rng(1,'twister');

%% Setup
config.parallel = 1;                        % use parallel toolbox

%start paralllel pool if empty
if isempty(gcp) && config.parallel
    parpool; % create parallel pool
end

% type of network to evolve
config.res_type = 'RoR';                   % can use different hierarchical reservoirs. RoR_IA is default ESN.
config.num_nodes = 50;                   % num of nodes in subreservoirs, e.g. config.num_nodes = {10,5,15}, would be 3 subreservoirs with n-nodes each
config = selectReservoirType(config);       % get correct functions for type of reservoir

%% Evolutionary parameters
config.num_tests = 3;                        % num of runs
config.pop_size = 100;                       % large pop better
config.total_gens = 500;                    % num of gens
%config.mut_rate = 0.2;                       % mutation rate
config.deme_percent = 0.2;                  % speciation percentage
config.deme = round(config.pop_size*config.deme_percent);
%config.rec_rate = 0.5;                       % recombination rate

%% Task parameters
config.discrete = 0;               % binary input for discrete systems
config.nbits = 16;                       % if using binary/discrete systems
config.preprocess = 1;                   % basic preprocessing, e.g. scaling and mean variance
config.dataset = 'NARMA10';                 % Task to evolve for

% get dataset
[config] = selectDataset(config);

% get any additional params stored in getDataSetInfo.m
[config,figure3,figure4] = getDataSetInfo(config);

%% general params
config.gen_print = 1000;                       % after 'gen_print' generations display archive and database
config.start_time = datestr(now, 'HH:MM:SS');
figure1 =figure;
figure2 = figure;
config.save_gen = 25;                       % save data at generation = save_gen

config.multi_offspring = 0;                  % multiple tournament selection and offspring in one cycle
config.num_sync_offspring = config.deme;      % length of cycle/synchronisation step
config.metrics = {'KR','GR','MC'};          % metrics to use
config.record_metrics = 0;                  % save metrics

%% RUn MicroGA
for test = 1:config.num_tests
    
    clearvars -except config test best storeError figure1 figure3 figure4 config total_score recomb_list mut_list mut_j rec_i
    
    fprintf('\n Test: %d  ',test);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    tic
    
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
            fprintf('\n i = %d, error = %.4f, took: %.4f\n',pop_indx,population(pop_indx).val_error,toc);
        end
    end
    
    % find an d print best individual
    [best(test,1),best_indv(test,1)] = min([population.val_error]);
    fprintf('\n Starting loop... Best error = %.4f\n',best(test,1));
    
    % store error that will be used as fitness in the GA
    store_error(test,1,:) = [population.val_error];
    
    %% start GA
    for gen = 2:config.total_gens
        
        % define seed
        rng(gen,'twister');
        
        % reshape stored error to compare
        cmp_error = reshape(store_error(test,gen-1,:),1,size(store_error,3));
        
        % Num of offspring to evolve
        if config.multi_offspring   
            parfor p = 1:config.num_sync_offspring
                % Tournment selection - pick two individuals
                equal = 1;
                while(equal)
                    indv_1 = randi([1 config.pop_size]);
                    indv_2 = indv_1+randi([1 config.deme]);
                    if indv_2 > config.pop_size
                        indv_2 = indv_2- config.pop_size;
                    end
                    if indv_1 ~= indv_2
                        equal = 0;
                    end
                end
                
                % Assess fitness of both and assign winner/loser - highest score
                % wins
                if cmp_error(indv_1) < cmp_error(indv_2)
                    w=indv_1; l(p) = indv_2;
                else
                    w=indv_2; l(p) = indv_1;
                end
                
                %% Infection phase
                par_loser{p} = config.recFcn(population(w),population(l(p)),config);
                par_loser{p} = config.mutFcn(par_loser{p},config);
                
                %% Evaluate and update fitness
                par_loser{p} = config.testFcn(par_loser{p},config);
            end
            
            [U,ia,ic]  = unique(l);                                  % find unique losers
            population(l(ia)) = [par_loser{ia}];                        % replace losers (does not replace replicates)
            
            %update errors
            store_error(test,gen,:) =  store_error(test,gen-1,:);
            store_error(test,gen,l(ia)) = [population(l(ia)).val_error];
            best(test,gen)  = best(test,gen-1);
            best_indv(test,gen) = best_indv(test,gen-1);
            
            % print info
            if (mod(gen,config.gen_print) == 0)
                [best(test,gen),best_indv(test,gen)] = min(store_error(test,gen,:));
                fprintf('Gen %d, time taken: %.4f sec(s)\n Best Error: %.4f \n',gen,toc/config.gen_print,best);
                tic;
                
               plotReservoirDetails(figure1,population,store_error,test,best_indv,gen,loser,config)
            end
            
        else
            
            % Tournment selection - pick two individuals
            equal = 1;
            while(equal)
                indv1 = randi([1 config.pop_size]);
                indv2 = indv1+randi([1 config.deme]);
                if indv2 > config.pop_size
                    indv2 = indv2- config.pop_size;
                end
                if indv1 ~= indv2
                    equal = 0;
                end
            end
            
            % Assess fitness of both and assign winner/loser - highest score
            % wins
            if cmp_error(indv1) < cmp_error(indv2)
                winner=indv1; loser = indv2;
            else
                winner=indv2; loser = indv1;
            end
            
            % Infection and mutation to get offspring
            population(loser) = config.recFcn(population(winner),population(loser),config);
            population(loser) = config.mutFcn(population(loser),config);
            
            %% Evaluate and update fitness
            [population(loser)] = config.testFcn(population(loser),config);
            
            %update errors
            store_error(test,gen,:) =  store_error(test,gen-1,:);
            store_error(test,gen,loser) = population(loser).val_error;
            
            best(test,gen)  = best(test,gen-1);
            best_indv(test,gen) = best_indv(test,gen-1);
            
            % print info
            if (mod(gen,config.gen_print) == 0)
                [best(test,gen),best_indv(test,gen)] = min(store_error(test,gen,:));
                fprintf('Gen %d, time taken: %.4f sec(s)\n  Winner: %.4f, Loser: %.4f, Best Error: %.4f \n',gen,toc/config.gen_print,population(winner).val_error,population(loser).val_error,best(test,gen));
                tic;
                % plot reservoir structure, task simulations etc.
                plotReservoirDetails(figure1,population,store_error,test,best_indv,gen,loser,config)
            end
        end
        
        %save data
        if mod(gen,config.save_gen) == 0
           %saveData(population,store_error,test,config)
        end
    end
    
    %get metric details
    if config.record_metrics
        parfor pop_indx = 1:config.pop_size
            metrics(pop_indx,:) = getVirtualMetrics(population(pop_indx),config);
        end
    end
end

function saveData(population,store_error,tests,config)

switch(config.res_type)
    case 'Graph'
        save(strcat('substrate_',config.graph_type,'_run',num2str(tests),'_gens',num2str(config.total_gens),'_Nres_',num2str(config.N),'_directed',num2str(config.directed_graph),'_self',num2str(config.self_loop),'_nSize.mat'),...
            'population','store_error','config','-v7.3');
    otherwise
        save(strcat('Framework_substrate_',config.res_type,'_run',num2str(tests),'_gens',num2str(config.total_gens),'_',num2str(sum(config.num_reservoirs)),'Nres_',num2str(config.num_nodes),'_nSize.mat'),...
            'population','store_error','config','-v7.3');
end
end


