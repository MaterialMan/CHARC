%% CHARC framework
% Notes: Added extra flexibility. Can now evolve heirarchical networks and
% any other reservoir in the support files.

% Author: M. Dale
% Date: 18/02/19
clear
% add all subfolders to the path --> make all functions in subdirectories available
% addpath(genpath(pwd));

rng(1,'twister');

%start paralllel pool if empty
if isempty(gcp)
    parpool; % create parallel pool
end

%% Setup
% type of network to evolve
config.resType = 'RoR_IA';                   % can use different hierarchical reservoirs. RoR_IA is default ESN.
config.maxMinorUnits = 20;                   % num of nodes in subreservoirs
config.maxMajorUnits = 1;                   % num of subreservoirs. Default ESN should be 1.
config = selectReservoirType(config);       %get correct functions for type of reservoir

% Network details
config.startFull = 1;                       % start with max network size
config.alt_node_size = 0;                   % allow different network sizes
config.multiActiv = 0;                      % use different activation funcs
config.leakOn = 1;                          % add leak states
config.rand_connect =1;                     %radnomise networks
config.activList = {'tanh';'linearNode'};   % what activations are in use when multiActiv = 1
config.trainingType = 'Ridge';              %blank is psuedoinverse. Other options: Ridge, Bias,RLS
config.AddInputStates = 1;                  %add input to states
config.regParam = 10e-5;                    %training regulariser
config.metrics = {'KR','GR','MC'}; % metrics to use (and order of metrics)
config.voxel_size = 10;                      % when measuring quality, pick a suitable voxel size 

config.sparseInputWeights = 0;              % use sparse inputs
config.restricedWeight = 0;                 % restrict weights to defined values
config.nsga2 = 0;
config.evolvedOutputStates = 0;             %if evovled outputs are wanted

% dummy variables
config.trainInputSequence= [];
config.trainOutputSequence =[];
config.dataSet =[];

% get addition params for reservoir type
[config,figure3,figure4] = getDataSetInfo(config);

%% Evolutionary parameters
config.numTests = 1;                        % num of runs
config.popSize = 50;                       % large pop better
config.totalGens = 1000;                    % num of gens
config.mutRate = 0.1;                       % mutation rate
config.deme_percent = 0.2;                  % speciation percentage
config.deme = round(config.popSize*config.deme_percent);
config.recRate = 0.5;                       % recombination rate
config.evolveOutputWeights = 0;             % evolve rather than train

% NS parameters
config.k_neighbours = 10;                   % how many neighbours to check
config.p_min_start = 3;                           % novelty threshold. Start low.
config.p_min_check = 200;                   % change novelty threshold dynamically after "p_min_check" gens.


% general params
config.genPrint = 10;                       % gens to display achive and database
config.startTime = datestr(now, 'HH:MM:SS');
figure1 =figure;
config.saveGen = 200;                        % save at gen = saveGen
config.paramIndx = 1;                       % record database; start from 1

% prediction parameters
get_prediction_data = 0;                %gather task performances
config.taskList = {'NARMA10','NARMA30','Laser','NonChanEqRodan'}; % tasks to assess
config.discrete = 0;                    % binary input for discrete systems
config.nbits = 16;                       % if using binary/discrete systems
config.preprocess = 1;                   % basic preprocessing, e.g. scaling and mean variance

%% Run MicroGA
for tests = 1:config.numTests
    
    clearvars -except config get_prediction_data tests storeError figure1 figure2 stats_novelty_KQ stats_novelty_MC total_space_covered all_databases

    fprintf('\n Test: %d  ',tests);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    tic 
    
    rng(tests,'twister');
    
    config.paramIndx=1;
    
    % create population of reservoirs
    genotype = config.createFcn(config);
    
    % intialise metrics
    metrics = [];
    
    %% Evaluate population and assess novelty
    ppm = ParforProgMon('Initial population: ', config.popSize);
    parfor popEval = 1:config.popSize
        metrics(popEval,:) = getVirtualMetrics(genotype(popEval),config);
        ppm.increment();
    end
    
    %% Create NS archive from initial population
    archive = metrics;
    archive_genotype = genotype;
    
    % Add all search points to db
    database = metrics;
    database_genotype = genotype;     

    fprintf('Processing took: %.4f sec, Starting GA \n',toc)
    
    % reset variables
    cnt_no_change = 1;
    config.p_min = config.p_min_start;
    
    % start generational loop
    for gen = 2:config.totalGens

        rng(gen,'twister');
              
        % Tournment selection - pick two individuals. Second within in deme
        % range of the first
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
        
        %calculate distances in behaviour space using KNN search
        pop_metrics = metrics;
        error_indv1 = findKNN([archive; pop_metrics],pop_metrics(indv1,:),config.k_neighbours);
        error_indv2 = findKNN([archive; pop_metrics],pop_metrics(indv2,:),config.k_neighbours);
             
        % Assess fitness of both and assign winner/loser - highest score
        % wins
        if error_indv1 > error_indv2
            winner=indv1; loser = indv2;
        else
            winner=indv2; loser = indv1;
        end
        
        %% Infection and mutation phase 
        % mix winner and loser first
        genotype(loser) = config.recFcn(genotype(winner),genotype(loser),config);
        % mutate offspring/loser
        genotype(loser) = config.mutFcn(genotype(loser),config);
        
        %% Evaluate and update fitness of offspring/loser       
        metrics(loser,:)= getVirtualMetrics(genotype(loser),config);
           
        % Store behaviours   
        pop_metrics = metrics;       
        
        % calculate offsprings neighbours in behaviour space - using
        % population and archive
        dist = findKNN([archive; pop_metrics],pop_metrics(loser,:),config.k_neighbours);
        
        % add offspring details to database 
        database = [database; pop_metrics(loser,:)];
        database_genotype = [database_genotype genotype(loser)];

        %add offspring to archive under conditions
        if  dist > config.p_min || rand < 0.001 
            archive = [archive; pop_metrics(loser,:)];
            cnt_change(gen) = 1;
            cnt_no_change(gen) = 0;
        else
            cnt_no_change(gen) = 1;
            cnt_change(gen) = 0;            
        end
        
        %dynamically adapt p_min -- minimum novelty threshold
        if gen > config.p_min_check+1
            if sum(cnt_no_change(gen-config.p_min_check:gen)) > config.p_min_check-1 % i.e. if not changing enough
                config.p_min = config.p_min - config.p_min*0.05; %minus 5%
                cnt_no_change(gen-config.p_min_check:gen) = zeros; %reset
            end
            if sum(cnt_change(gen-config.p_min_check:gen)) > 10 % i.e. is too frequent
                config.p_min = config.p_min + config.p_min*0.1; %plus 10%
                cnt_change(gen-config.p_min_check:gen) = zeros; %reset                
            end
        end
        
        % print info
        if (mod(gen,config.genPrint) == 0)
            fprintf('Gen %d, time taken: %.4f sec(s)\n Winner is %d, Loser is %d \n',gen,toc/config.genPrint,winner,loser);
            fprintf('Length of archive: %d, p_min; %d \n',length(archive), config.p_min);
            tic;
            plotSearch(figure1,database,gen,config)        % plot details
%             if strcmp(config.resType,'Graph')
%                 plotGridNeuron(figure3,genotype,storeError,tests,winner,loser,config)
%             end
        end
    
        % safe details to disk
       if mod(gen,config.saveGen) == 0
            %% ------------------------------ Save data -----------------------------------------------------------------------------------
            [total_space_covered(tests,config.paramIndx),~]= measureSearchSpace(database,config.voxel_size);
            
            all_databases{tests,config.paramIndx} = database;
            config.paramIndx = config.paramIndx+1;
            
            if strcmp(config.resType,'Graph')
                save(strcat('substrate_',config.substrate,'_run',num2str(tests),'_gens',num2str(config.totalGens),'_Nres_',num2str(config.N),'_directed',num2str(config.directedGraph),'_self',num2str(config.self_loop),'_nSize.mat'),...
                    'all_databases','database_genotype','genotype','config','total_space_covered','-v7.3');     
            else
                save(strcat('Framework_substrate_',config.resType,'_run',num2str(tests),'_gens',num2str(config.totalGens),'_',num2str(config.maxMajorUnits),'Nres_',num2str(config.maxMinorUnits),'_nSize.mat'),...
                    'all_databases','database_genotype','genotype','config','total_space_covered','-v7.3');
            end
       end
    end
    
    if get_prediction_data
        pred_dataset = assessDBonTasks(config,database_genotype,database,tests);
    end
end

%% fitness function
function [avg_dist] = findKNN(metrics,Y,k_neighbours)
[~,D] = knnsearch(metrics,Y,'K',k_neighbours);
avg_dist = mean(D);
end

function plotSearch(figureHandle,database, gen,config)

set(0,'currentFigure',figureHandle)
title(strcat('Gen:',num2str(gen)))
v = 1:length(config.metrics);
C = nchoosek(v,2);

if size(C,1) > 3
    num_plot_x = size(C,1)/2;
    num_plot_y = 2;
else
    num_plot_x = 3;
    num_plot_y = 1;
end

for i = 1:size(C,1)
    subplot(num_plot_x,num_plot_y,i)
    scatter(database(:,C(i,1)),database(:,C(i,2)),20,1:length(database),'filled')
    
    xlabel(config.metrics(C(i,1)))
    ylabel(config.metrics(C(i,2)))
    colormap('copper')
end

drawnow
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
