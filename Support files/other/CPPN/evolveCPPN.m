%% Evolve CPPN to construct substrate for a specific task
% This script can be used to evolve any reservoir directly to a task. It
% uses the steady-state Microbial Genetic Algorithm to evolve the best
% solution.

% Author: M. Dale
% Date: 08/11/18
clear
close all

% add all subfolders to the path --> make all functions in subdirectories available
% addpath(genpath(pwd));

warning('off','all')
rng(1,'twister');

%% Setup
config.parallel = 1;                        % use parallel toolbox

%start paralllel pool if empty
if isempty(gcp) && config.parallel
    parpool; % create parallel pool
end

%% Evolutionary parameters
config.num_tests = 1;                        % num of runs
config.pop_size = 50;                       % large pop better
config.total_gens = 1000;                    % num of gens
config.mut_rate = 0.1;                       % mutation rate
config.deme_percent = 0.2;                  % speciation percentage
config.deme = round(config.pop_size*config.deme_percent);
config.rec_rate = 0.5;                       % recombination rate

%% substrate details
config_sub.pop_size = config.pop_size;
config_sub.num_nodes = {5,5,5,5,5}; % num of nodes in subreservoirs, e.g. config.num_nodes = {10,5,15}, would be 3 subreservoirs with n-nodes each
config_sub.res_type ='RoR';

config_sub = selectReservoirType(config_sub);       % get correct functions for type of reservoir
config_sub.parallel = config.parallel;                        % use parallel toolbox

%% CPPN details
config.res_type = 'ELM';                      % can use different hierarchical reservoirs. RoR_IA is default ESN.
config.num_nodes = {5,5,3};                  % num of nodes in subreservoirs, e.g. config.num_nodes = {10,5,15}, would be 3 subreservoirs with n-nodes each
config = selectReservoirType(config);       % get correct functions for type of reservoir
config.CPPN_inputs = 4;                     % coord of node A(x,y) and node B(x,y)
config.CPPN_outputs = length(config_sub.num_nodes)*2 +1; % Output 1: input layer, 2: hidden layer, 3: outputlayer

config.discrete = 0;               % binary input for discrete systems
config.nbits = 16;                       % if using binary/discrete systems
config.preprocess = 1;                   % basic preprocessing, e.g. scaling and mean variance
config.dataset = 'CPPN';                 % Task to evolve for

[config] = selectDataset(config);

% get any additional params stored in getDataSetInfo.m
[config] = getDataSetInfo(config);


%% Task parameters
config_sub.discrete = 0;               % binary input for discrete systems
config_sub.nbits = 16;                       % if using binary/discrete systems
config_sub.preprocess = 1;                   % basic preprocessing, e.g. scaling and mean variance
config_sub.dataset = 'NARMA10';                 % Task to evolve for

% get dataset
[config_sub] = selectDataset(config_sub);
[config_sub] = getDataSetInfo(config_sub);

%% general params
config.gen_print = 25;                       % gens to display achive and database
config.start_time = datestr(now, 'HH:MM:SS');
figure1 =figure;
config.save_gen = 1e5;                      % save at gen = saveGen
config.multi_offspring = 0;                  % multiple tournament selection and offspring in one cycle
config.num_sync_offspring = config.deme;      % length of cycle/synchronisation step
config.metrics = {'KR','GR','MC'};          % metrics to use
config.record_metrics = 0;                  % save metrics


%% RUn MicroGA
for test = 1:config.num_tests
    
    clearvars -except config config_sub test storeError figure1 figure3 figure4
    
    fprintf('\n Test: %d  ',test);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    tic
    
    rng(test,'twister');
    
    % create initial population
    CPPN = config.createFcn(config);
    
    % create initial substrate
    substrate = config_sub.createFcn(config_sub);
    
    %Assess population
    if config.parallel
        ppm = ParforProgMon('Initial population: ', config.pop_size);
        parfor pop_indx = 1:config.pop_size
            warning('off','all')
            % assign weights through CPPN
            [substrate(pop_indx),~,CPPN(pop_indx),~] = assessCPPNonSubstrate(substrate(pop_indx),config_sub,CPPN(pop_indx),config);
            ppm.increment();
            %fprintf('\n i = %d, error = %.4f, took: %.4f\n',popEval,substrate(popEval).valError,toc);
        end
    else
        for pop_indx = 1:config.pop_size
            % assign weights through CPPN
            [substrate(pop_indx),~,CPPN(pop_indx),~] = assessCPPNonSubstrate(substrate(pop_indx),config_sub,CPPN(pop_indx),config);
            fprintf('\n i = %d, error = %.4f, took: %.4f\n',pop_indx,substrate(pop_indx).val_error,toc);
        end
    end
        
    % find an d print best individual
    [best(1),best_indv(1)] = min([substrate.val_error]);
    fprintf('\n Starting loop... Best error = %.4f\n',best);
    
    % store error that will be used as fitness in the GA
    store_error(test,1,:) = [substrate.val_error];%[genotype.trainError].*0.2  + [genotype.valError].*0.5 + [genotype.testError].*0.3;
    
    
    %% start GA
    for gen = 2:config.total_gens
        
        % define seed
        rng(gen,'twister');
        
        % reshape stored error to compare
        cmp_error = reshape(store_error(test,gen-1,:),1,size(store_error,3));
        
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
        CPPN(loser) = config.recFcn(CPPN(winner),CPPN(loser),config);
        CPPN(loser) = config.mutFcn(CPPN(loser),config);
        
        %% Evaluate and update fitness
        [substrate(loser),~,CPPN(loser),~] = assessCPPNonSubstrate(substrate(loser),config_sub,CPPN(loser),config);
        
        %update errors
        store_error(test,gen,:) =  store_error(test,gen-1,:);
        store_error(test,gen,loser) = substrate(loser).val_error;%[genotype(loser).trainError.*0.2  + genotype(loser).valError.*0.5 + genotype(loser).testError.*0.3];
        %genotype(loser).valError;
        best(gen)  = best(gen-1);
        best_indv(gen) = best_indv(gen-1);
        
        % print info
        if (mod(gen,config.gen_print) == 0)
            [best(gen),best_indv(gen)] = min(store_error(test,gen,:));
            fprintf('Gen %d, time taken: %.4f sec(s)\n  Winner: %.4f, Loser: %.4f, Best Error: %.4f \n',gen,toc/config.gen_print,substrate(winner).val_error,substrate(loser).val_error,best(gen));
            tic;
            % plot reservoir structure, task simulations etc.
            plotReservoirDetails(figure1,substrate,store_error,test,best_indv,gen,loser,config_sub)
        end
        
        %get metric details
        if config.record_metrics
            parfor pop_indx = 1:config.pop_size
                metrics(pop_indx,:) = getVirtualMetrics(genotype(pop_indx),config);
            end
        end
        
    end
end

% function [substrate,config_sub,CPPN,config] =assessCPPNonGraph(substrate,config_sub,CPPN,config)
% 
% 
% % add input weights to input sequence
% if size(substrate.w_in,2) < 2
%     inputSequence = [1 1; ones(length(substrate.w_in),1) (1:length(substrate.w_in))'];
% else
%     [I,J] = ind2sub(substrate.w_in,1:length(substrate.w_in));
%     inputSequence = [1 1; I J];
% end
% 
% % add hidden weights to input sequence
% if strcmp(config_sub.resType,'Graph')
%     inputSequence = [inputSequence; substrate.G.Edges.EndNodes+size(substrate.w_in,2)];
% else
%     [I,J] = ind2sub(substrate.w,1:length(substrate.w));
%     inputSequence = [inputSequence; I J];
% end
% 
% %normalise
% for i = 1:size(inputSequence,2)
%     inputSequence(inputSequence(:,i) ~= 0,i) = (inputSequence(inputSequence(:,i) ~= 0,i)-mean(inputSequence(:,i)))/(max(inputSequence(:,i))-min(inputSequence(:,i)));
% end
% 
% % run CPPN
% [testStates,CPPN] = config.assessFcn(CPPN,inputSequence,config);
% CPPN_weights = testStates*CPPN.outputWeights;
% 
% % reassign weights
% substrate.w_in = CPPN_weights(1:length(substrate.w_in),:);
% if strcmp(config_sub.resType,'Graph')
%     substrate.G.Edges.Weight = CPPN_weights(length(substrate.w_in)+1:end,:);
%     A = table2array(substrate.G.Edges);
%     substrate.w = zeros(size(substrate.G.Nodes,1));
%     
%     for j = 1:size(substrate.G.Edges,1)
%         substrate.w(A(j,1),A(j,2)) = A(j,3);
%     end
% else
%     substrate.w = CPPN_weights(length(substrate.w_in)+1:end,:);
% end
% %assess substrate on task
% substrate = config.testFcn(substrate,config_sub);
% end


