%% CHARC framework
% Notes: Added extra flexibility. Can now evolve heirarchical networks and
% any other reservoir in the support files.

% Author: M. Dale
% Date: 07/11/18
clear
rng(1,'twister');

%% Setup
% type of network to evolve
config.resType = 'RoR';                   % can use different hierarchical reservoirs. RoR_IA is default ESN.
config.maxMinorUnits = 25;                   % num of nodes in subreservoirs
config.maxMajorUnits = 1;                   % num of subreservoirs. Default ESN should be 1.
config = selectReservoirType(config);       %get correct functions for type of reservoir

% Network details
config.startFull = 1;                       % start with max network size
config.alt_node_size = 0;                   % allow different network sizes
config.multiActiv = 0;                      % use different activation funcs
config.leakOn = 0;                          % add leak states
config.rand_connect =1;                     %radnomise networks
config.activList = {'tanh';'linearNode'};   % what activations are in use when multiActiv = 1
config.trainingType = 'Ridge';              %blank is psuedoinverse. Other options: Ridge, Bias,RLS
config.AddInputStates = 0;                  %add input to states
config.regParam = 10e-5;                    %training regulariser
config.use_metric =[1 1 1];                 %metrics to use = [KR GR LE]

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
config.popSize = 200;                       % large pop better
config.totalGens = 1000;                    % num of gens
config.mutRate = 0.1;                       % mutation rate
config.deme_percent = 0.2;                  % speciation percentage
config.deme = round(config.popSize*config.deme_percent);
config.recRate = 0.5;                       % recombination rate
config.evolveOutputWeights = 0;             % evolve rather than train

% NS parameters
config.k_neighbours = 10;                   % how many neighbours to check
config.p_min = 3;                           % novelty threshold. Start low.
config.p_min_check = 250;                   % change novelty threshold dynamically after "p_min_check" gens.

% general params
config.genPrint = 10;                       % gens to display achive and database
config.startTime = datestr(now, 'HH:MM:SS');
figure1 =figure;
config.saveGen = 25;                        % save at gen = saveGen
config.paramIndx = 1;                       % record database; start from 1

%% Run MicroGA
for tests = 1:config.numTests
    
    clearvars -except config tests storeError figure1 figure2 stats_novelty_KQ stats_novelty_MC total_space_covered all_databases

    fprintf('\n Test: %d  ',tests);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    tic 
    
    rng(tests,'twister');
    
    config.paramIndx=1;
    
    % create population of reservoirs
    genotype = config.createFcn(config);
    
    % intialise metrics
    kernel_rank=[]; gen_rank=[];
    rank_diff=[]; MC=[];
    
    %% Evaluate population and assess novelty
    parfor popEval = 1:config.popSize
        [gen_rank(popEval), kernel_rank(popEval), ~] = metricKQGRLE(genotype(popEval),config);
        MC(popEval) = metricMemory(genotype(popEval),config);
         fprintf('\n indv: %d  ',popEval);
    end
    
    %% Create NS archive from initial population
    archive = [kernel_rank;gen_rank; MC]';
    archive_genotype = genotype;
    
    % Add all search points to db
    database = [kernel_rank;gen_rank; MC]';
    database_ext = [kernel_rank;gen_rank;kernel_rank-gen_rank;abs(kernel_rank-gen_rank); MC]';
    database_genotype = genotype;
            
    storeError(tests,1,:) = archive(:,3); 

    fprintf('Processing took: %.4f sec, Starting GA \n',toc)
    
    % reset variables
    cnt_no_change = 1;
    config.p_min = 3;
    
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
        pop_metrics = [kernel_rank;gen_rank;MC]';
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
        [gen_rank(loser), kernel_rank(loser), ~] = metricKQGRLE(genotype(loser),config);
        MC(loser) = metricMemory(genotype(loser),config);
           
        % Store behaviours   
        pop_metrics = [kernel_rank;gen_rank;MC]'; 
        storeError(tests,gen,:) = pop_metrics(:,3); 
        
        % store all metrics for later use
        pop_metrics_ext = [kernel_rank;gen_rank;kernel_rank-gen_rank;abs(kernel_rank-gen_rank);MC]';
        
        % calculate offsprings neighbours in behaviour space - using
        % population and archive
        dist = findKNN([archive; pop_metrics],pop_metrics(loser,:),config.k_neighbours);
        
        % add offspring details to database 
        database = [database; pop_metrics(loser,:)];
        database_ext = [database_ext; pop_metrics_ext(loser,:)]; % extended database for learning phase
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
            plotSearch(figure1,archive,database,gen)        % plot details
%             if strcmp(config.resType,'Graph')
%                 plotGridNeuron(figure3,genotype,storeError,tests,winner,loser,config)
%             end
        end
    
        % safe details to disk
       if mod(gen,config.saveGen) == 0
            %% ------------------------------ Save data -----------------------------------------------------------------------------------
            stats_novelty_KQ(tests,config.paramIndx,:) = [iqr(database(:,1)),mad(database(:,1)),range(database(:,1)),std(database(:,1)),var(database(:,1))];
            stats_novelty_MC(tests,config.paramIndx,:) = [iqr(database(:,2)),mad(database(:,2)),range(database(:,2)),std(database(:,2)),var(database(:,2))];
            
            total_space_covered(tests,config.paramIndx) = measureSearchSpace({database},config.maxMinorUnits*config.maxMajorUnits);
            
            all_databases{tests,config.paramIndx} = database;
            config.paramIndx = config.paramIndx+1;
            
            if strcmp(config.resType,'Graph')
                save(strcat('substrate_',config.substrate,'_run',num2str(tests),'_gens',num2str(config.totalGens),'_Nres_',num2str(config.N),'_directed',num2str(config.directedGraph),'_self',num2str(config.self_loop),'_nSize.mat'),...
                    'all_databases','genotype','database_ext','config','stats_novelty_KQ','stats_novelty_MC','total_space_covered','-v7.3');     
            else
                save(strcat('Framework_substrate_',config.resType,'_run',num2str(tests),'_gens',num2str(config.totalGens),'_',num2str(config.maxMajorUnits),'Nres_',num2str(config.maxMinorUnits),'_nSize.mat'),...
                    'all_databases','genotype','database_ext','config','stats_novelty_KQ','stats_novelty_MC','total_space_covered','-v7.3');
            end
       end
    end
end

%% fitness function
function [avg_dist] = findKNN(metrics,Y,k_neighbours)
[~,D] = knnsearch(metrics,Y,'K',k_neighbours);
avg_dist = mean(D);
end

function plotSearch(figureHandle,archive,database, gen)

%archive
set(0,'CurrentFigure',figureHandle);
subplot(2,3,1)
scatter(archive(:,1),archive(:,2),20,1:length(archive),'filled')
title(strcat('Gen:',num2str(gen)))
xlabel('KR')
ylabel('GR')
colormap('copper')

subplot(2,3,2)
scatter(archive(:,1),archive(:,3),20,1:length(archive),'filled')
xlabel('KR')
ylabel('MC')
colormap('copper')
title('Fitness Archive')

subplot(2,3,3)
scatter(archive(:,2),archive(:,3),20,1:length(archive),'filled')
xlabel('GR')
ylabel('MC')
colormap('copper')


%% database
subplot(2,3,4)
scatter(database(:,1),database(:,2),20,1:length(database),'filled')
xlabel('KR')
ylabel('GR')
colormap('copper')

subplot(2,3,5)
scatter(database(:,1),database(:,3),20,1:length(database),'filled')
xlabel('KR')
ylabel('MC')
colormap('copper')
title('Database')

subplot(2,3,6)
scatter(database(:,2),database(:,3),20,1:length(database),'filled')
xlabel('GR')
ylabel('MC')
colormap('copper')

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
