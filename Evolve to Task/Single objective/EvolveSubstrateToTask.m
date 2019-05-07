%% Evolve substrate for a specific task
% This script can be used to evolve any reservoir directly to a task. It
% uses the steady-state Microbial Genetic Algorithm to evolve the best
% solution.

% Author: M. Dale
% Date: 08/11/18
clear

% add all subfolders to the path --> make all functions in subdirectories available
% addpath(genpath(pwd));

%load('Framework_substrate_RoR_IA_run1_gens2000_1Nres_100_nSize.mat');
%config.database_genotype = database_genotype;

warning('off','all')
rng(1,'twister');

%% Setup
% type of network to evolve
config.resType = 'RoR_IA';                      % can use different hierarchical reservoirs. RoR_IA is default ESN.
config.maxMinorUnits = 20;                  % num of nodes in subreservoirs
config.maxMajorUnits = 1;                   % num of subreservoirs. Default ESN should be 1.
config = selectReservoirType(config);       % get correct functions for type of reservoir
config.nsga2 = 0;                           % not using NSGA
config.parallel = 1;                        % use parallel toolbox

%% Network details
config.leakOn = 1;                          % add leak states
config.AddInputStates = 1;                  % add input to states
config.regParam = 10e-5;                    % training regulariser
config.sparseInputWeights = 0;              % use sparse inputs
config.restricedWeight = 0;                 % restrict weights between [0.2 0.4. 0.6 0.8 1]
config.evolvedOutputStates = 0;             % sub-sample the states to produce output (is evolved)
config.evolveOutputWeights = 0;             % evolve rather than train

%% Evolutionary parameters
config.numTests = 1;                        % num of runs
config.popSize = 200;                       % large pop better
config.totalGens = 2000;                    % num of gens
config.mutRate = 0.1;                       % mutation rate
config.deme_percent = 0.2;                  % speciation percentage
config.deme = round(config.popSize*config.deme_percent);
config.recRate = 0.5;                       % recombination rate

%% Task parameters
config.discrete = 0;               % binary input for discrete systems
config.nbits = 16;                       % if using binary/discrete systems 
config.preprocess = 1;                   % basic preprocessing, e.g. scaling and mean variance
config.dataSet = 'poleBalance';                 % Task to evolve for

% get dataset 
[config] = selectDataset(config);

% get any additional params stored in getDataSetInfo.m 
[config,figure3,figure4] = getDataSetInfo(config);

%% general params
config.genPrint = 10;                       % gens to display achive and database
config.startTime = datestr(now, 'HH:MM:SS');
figure1 =figure;
config.saveGen = 1000;                      % save at gen = saveGen
config.multiOffspring = 0;                  % multiple tournament selection and offspring in one cycle
config.numSyncOffspring = config.deme;      % length of cycle/synchronisation step
config.metrics = {'KR','GR','MC'};          % metrics to use
config.record_metrics = 0;                  % save metrics

%% RUn MicroGA
for test = 1:config.numTests
    
    clearvars -except config test storeError figure1 figure3 figure4
    
    fprintf('\n Test: %d  ',test);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    tic
    
    rng(test,'twister');
    
    % create initial population 
    genotype = config.createFcn(config);
    
    %Assess population
    if config.parallel % use parallel toolbox - faster
        parfor popEval = 1:config.popSize
            warning('off','all')
            genotype(popEval) = config.testFcn(genotype(popEval),config);
            fprintf('\n i = %d, error = %.4f\n',popEval,genotype(popEval).valError);
        end
    else
        for popEval = 1:config.popSize
            tic
            genotype(popEval) = config.testFcn(genotype(popEval),config);
            fprintf('\n i = %d, error = %.4f, took: %.4f\n',popEval,genotype(popEval).valError,toc);
        end
    end
    
    % find an d print best individual
    [best(1),best_indv(1)] = min([genotype.valError]);    
    fprintf('\n Starting loop... Best error = %.4f\n',best);
    
    % store error that will be used as fitness in the GA
    storeError(test,1,:) = [genotype.valError];%[genotype.trainError].*0.2  + [genotype.valError].*0.5 + [genotype.testError].*0.3;
    
    %% start GA
    for gen = 2:config.totalGens
        
        % define seed
        rng(gen,'twister');
        
        % reshape stored error to compare
        cmpError = reshape(storeError(test,gen-1,:),1,size(storeError,3));
        
        % Num of offspring to evolve
        if config.multiOffspring

            parfor p = 1:config.numSyncOffspring  
                % Tournment selection - pick two individuals
                equal = 1;
                while(equal)
                    indv_1 = randi([1 config.popSize]);
                    indv_2 = indv_1+randi([1 config.deme]);
                    if indv_2 > config.popSize
                        indv_2 = indv_2- config.popSize;
                    end
                    if indv_1 ~= indv_2
                        equal = 0;
                    end
                end
                
                % Assess fitness of both and assign winner/loser - highest score
                % wins
                if cmpError(indv_1) < cmpError(indv_2)
                    w=indv_1; l(p) = indv_2;
                else
                    w=indv_2; l(p) = indv_1;
                end
                
                %% Infection phase
                parLoser{p} = config.recFcn(genotype(w),genotype(l(p)),config);
                parLoser{p} = config.mutFcn(parLoser{p},config);
                
                %% Evaluate and update fitness
                parLoser{p} = config.testFcn(parLoser{p},config);
            end
            
            [U,ia,ic]  = unique(l);                                  % find unique losers
            genotype(l(ia)) = [parLoser{ia}];                        % replace losers (does not replace replicates)
            
            %update errors
            storeError(test,gen,:) =  storeError(test,gen-1,:);
            storeError(test,gen,l(ia)) = [genotype(l(ia)).valError];
            best(gen)  = best(gen-1);
            best_indv(gen) = best_indv(gen-1);
            
            % print info
            if (mod(gen,config.genPrint) == 0)
                [best(gen),best_indv(gen)] = min(storeError(test,gen,:));
                fprintf('Gen %d, time taken: %.4f sec(s)\n Best Error: %.4f \n',gen,toc/config.genPrint,best);
                tic;
                
                if strcmp(config.resType,'Graph')
                    plotGridNeuron(figure1,genotype,storeError,test,best_indv,l(1),config)
                end
                
                if strcmp(config.dataSet,'autoencoder')
                    plotAEWeights(figure3,figure4,config.testInputSequence,genotype(best_indv),config)
                end
            end
            
        else
            
            % Tournment selection - pick two individuals
            equal = 1;
            while(equal)
                indv1 = randi([1 config.popSize]);
                indv2 = indv1+randi([1 config.deme]);
                if indv2 > config.popSize
                    indv2 = indv2- config.popSize;
                end
                if indv1 ~= indv2
                    equal = 0;
                end
            end
            
            % Assess fitness of both and assign winner/loser - highest score
            % wins
            if cmpError(indv1) < cmpError(indv2)
                winner=indv1; loser = indv2;
            else
                winner=indv2; loser = indv1;
            end
            
            % Infection and mutation to get offspring
            genotype(loser) = config.recFcn(genotype(winner),genotype(loser),config);
            genotype(loser) = config.mutFcn(genotype(loser),config);
            
            %% Evaluate and update fitness
            [genotype(loser)] = config.testFcn(genotype(loser),config);
            
            %update errors
            storeError(test,gen,:) =  storeError(test,gen-1,:);
            storeError(test,gen,loser) = genotype(loser).valError;%[genotype(loser).trainError.*0.2  + genotype(loser).valError.*0.5 + genotype(loser).testError.*0.3];
            %genotype(loser).valError;
            best(gen)  = best(gen-1);
            best_indv(gen) = best_indv(gen-1);
            
            % print info
            if (mod(gen,config.genPrint) == 0)
                [best(gen),best_indv(gen)] = min(storeError(test,gen,:));
                fprintf('Gen %d, time taken: %.4f sec(s)\n  Winner: %.4f, Loser: %.4f, Best Error: %.4f \n',gen,toc/config.genPrint,genotype(winner).valError,genotype(loser).valError,best(gen));
                tic;
                if strcmp(config.resType,'basicCA') 
                    figure(figure1)
                    imagesc(loserStates');
                end
                if strcmp(config.resType,'Graph') || strcmp(config.resType,'2dCA')
                    plotGridNeuron(figure1,genotype,storeError,test,best_indv(gen),loser,config)
                end
                
                if strcmp(config.resType,'BZ')
                    plotBZ(config.BZfigure1,genotype,best_indv(gen),loser,config)
                end
                if strcmp(config.dataSet,'autoencoder')
                    plotAEWeights(figure3,figure4,config.testInputSequence,genotype(best_indv(gen)),config)
                end
            end
        end
        
        if mod(gen,config.saveGen) == 0
            %% ------------------------------ Save data -----------------------------------------------------------------------------------
            if strcmp(config.resType,'Graph')
                save(strcat('Task_',config.dataSet,'_substrate_',config.substrate,'_run',num2str(test),'_gens',num2str(config.totalGens),'_Nres_',num2str(config.N),'_directed',num2str(config.directedGraph),'_self',num2str(config.self_loop),'_nSize.mat'),...
                    'genotype','config','storeError','-v7.3');
            else
                save(strcat('Task_',config.dataSet,'_substrate_',config.resType,'_run',num2str(test),'_gens',num2str(config.totalGens),'_',num2str(config.maxMajorUnits),'Nres_',num2str(config.maxMinorUnits),'_nSize.mat'),...
                    'genotype','config','storeError','-v7.3');
            end
        end
    end
    
    %get metric details 
    if config.record_metrics
        parfor popEval = 1:config.popSize
            metrics(popEval,:) = getVirtualMetrics(genotype(popEval),config);
        end
    end
end

function plotGridNeuron(figure1,genotype,storeError,test,best_indv,loser,config)

set(0,'currentFigure',figure1)
subplot(2,2,[1 2])
imagesc(reshape(storeError(test,:,:),size(storeError,2),size(storeError,3)))
set(gca,'YDir','normal')
colormap(bluewhitered)
colorbar
ylabel('Generations')
xlabel('Individual')


subplot(2,2,3)
if config.plot3d
    p = plot(genotype(best_indv).G,'NodeLabel',{},'Layout','force3');
else
    p = plot(genotype(best_indv).G,'NodeLabel',{},'Layout','force');
end
p.NodeColor = 'black';
p.MarkerSize = 1;
if ~config.directedGraph
    p.EdgeCData = genotype(best_indv).G.Edges.Weight;
end
highlight(p,logical(genotype(best_indv).input_loc),'NodeColor','g','MarkerSize',3)
colormap(bluewhitered)
xlabel('Best weights')

subplot(2,2,4)
if config.plot3d
    p = plot(genotype(loser).G,'NodeLabel',{},'Layout','force3');
else
    p = plot(genotype(loser).G,'NodeLabel',{},'Layout','force');
end
if ~config.directedGraph
    p.EdgeCData = genotype(loser).G.Edges.Weight;
end
p.NodeColor = 'black';
p.MarkerSize = 1;
highlight(p,logical(genotype(loser).input_loc),'NodeColor','g','MarkerSize',3)
colormap(bluewhitered)
xlabel('Loser weights')

pause(0.01)
drawnow
end

function plotBZ(figure1,genotype,best_indv,loser,config)
set(0,'currentFigure',figure1)
if config.evolvedOutputStates
  
    subplot(2,3,1)
    imagesc(reshape(genotype(best_indv).input_loc(1:genotype(best_indv).size.^2),genotype(best_indv).size,genotype(best_indv).size))
    title('Input Location')
    
    subplot(2,3,2)
    imagesc(reshape(genotype(best_indv).input_loc((genotype(best_indv).size.^2)+1:(genotype(best_indv).size.^2)*2),genotype(best_indv).size,genotype(best_indv).size))
    title('Input Location')
    
     subplot(2,3,3)
    imagesc(reshape(genotype(best_indv).input_loc(((genotype(best_indv).size.^2)*2)+1:(genotype(best_indv).size.^2)*3),genotype(best_indv).size,genotype(best_indv).size))
     title('Input Location')
    
    subplot(2,3,4)
    imagesc(reshape(genotype(best_indv).state_loc(1:genotype(best_indv).size.^2),genotype(best_indv).size,genotype(best_indv).size))
    title('Output Location')
    
    subplot(2,3,5)
    imagesc(reshape(genotype(best_indv).state_loc((genotype(best_indv).size.^2)+1:(genotype(best_indv).size.^2)*2),genotype(best_indv).size,genotype(best_indv).size))
    title('Output Location')
    
     subplot(2,3,6)
    imagesc(reshape(genotype(best_indv).state_loc(((genotype(best_indv).size.^2)*2)+1:(genotype(best_indv).size.^2)*3),genotype(best_indv).size,genotype(best_indv).size))
     title('Output Location')
else
    set(0,'currentFigure',figure1)
    subplot(2,3,1)
    imagesc(reshape(genotype(best_indv).input_loc(1:genotype(best_indv).size.^2),genotype(best_indv).size,genotype(best_indv).size))
    title('Input Location (Best)')
    
    subplot(2,3,2)
    imagesc(reshape(genotype(best_indv).input_loc((genotype(best_indv).size.^2)+1:(genotype(best_indv).size.^2)*2),genotype(best_indv).size,genotype(best_indv).size))
    title('Input Location (Best)')
    
     subplot(2,3,3)
    imagesc(reshape(genotype(best_indv).input_loc(((genotype(best_indv).size.^2)*2)+1:(genotype(best_indv).size.^2)*3),genotype(best_indv).size,genotype(best_indv).size))
     title('Input Location (Best)')
     
     subplot(2,3,4)
    imagesc(reshape(genotype(loser).input_loc(1:genotype(loser).size.^2),genotype(loser).size,genotype(loser).size))
    title('Input Location (loser)')
    
    subplot(2,3,5)
    imagesc(reshape(genotype(loser).input_loc((genotype(loser).size.^2)+1:(genotype(loser).size.^2)*2),genotype(loser).size,genotype(loser).size))
    title('Input Location (loser)')
    
     subplot(2,3,6)
    imagesc(reshape(genotype(loser).input_loc(((genotype(loser).size.^2)*2)+1:(genotype(loser).size.^2)*3),genotype(loser).size,genotype(loser).size))
     title('Input Location (loser)')
    
end
drawnow
end