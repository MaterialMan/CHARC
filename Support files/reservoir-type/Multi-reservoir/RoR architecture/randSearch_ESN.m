%% Novelty Search using metrics
% Author: M. Dale
% Date: 22/03/18

clearvars -except config 
rng(1,'twister');

% type of network to evolve
config.resType = 'RoR_IA'; % can use different hierarchical reservoirs. RoR_IA is default ESN.
config.maxMajorUnits=1; % num of subreservoirs. Default ESN should be 1.

%Evolutionary parameters
config.numTests = 10; %num of runs
config.popSize =2000; %large pop better

% Network details
config.startFull = 1; % start with max network size
config.alt_node_size = 0; % allow different network sizes
config.multiActiv = 0; % use different activation funcs
config.leakOn = 1;
config.rand_connect =1; %radnomise networks
config.activList = {'tanh';'linearNode'}; % what activations are in use when multiActiv = 1

% general params
config.startTime = datestr(now, 'HH:MM:SS');
figure1 = figure;

for resSize = [200] %ESN sizes to test: [25 50 100 200]
    
    config.maxMinorUnits= resSize; %num of nodes in subreservoirs
    
%% RUn MicroGA
for tests = 1:config.numTests
    
     clearvars -except config tests storeError figure1 all_databases stats_novelty_KQ stats_novelty_MC total_space_covered...
           
    fprintf('\n Test: %d, node size: %d. ',tests,config.maxMinorUnits);
    fprintf('Processing....%s \n',datestr(now, 'HH:MM:SS'))
    tic 
    
    rng(tests,'twister');
    
    config.startClk = tic;
    
    config.paramIndx = 1; %record database; start from 1
    
    switch(config.resType)
        case 'RoR'
            [esnMajor, esnMinor] =createDeepReservoir_extWeights([],[],config.popSize,config.maxMinorUnits,config.maxMajorUnits,config.startFull,config.multiActiv,config.rand_connect,config.activList);
        case 'RoR_IA'
            [esnMajor, esnMinor] =createDeepReservoir_extWeights([],[],config.popSize,config.maxMinorUnits,config.maxMajorUnits,config.startFull,config.multiActiv,config.rand_connect,config.activList);
        case 'pipeline'
            [esnMajor, esnMinor] =createDeepReservoir_pipeline([],[],config.popSize,config.maxMinorUnits,config.maxMajorUnits,config.startFull,config.multiActiv,config.rand_connect,config.activList);
        case 'pipeline_IA'
            [esnMajor, esnMinor] =createDeepReservoir_pipeline([],[],config.popSize,config.maxMinorUnits,config.maxMajorUnits,config.startFull,config.multiActiv,config.rand_connect,config.activList);
        case 'Ensemble'
            [esnMajor, esnMinor] =createDeepReservoir_ensemble([],[],config.popSize,config.maxMinorUnits,config.maxMajorUnits,config.startFull,config.multiActiv,config.rand_connect,config.activList);
    end
    
    kernel_rank=[]; gen_rank=[];
    rank_diff=[]; MC=[];
    
    %% Evaluate population
    parfor popEval = 1:config.popSize
        [~, kernel_rank(popEval), gen_rank(popEval)] = DeepRes_KQ_GR_LE(esnMajor(popEval),esnMinor(popEval,:),config.resType,[1 1 0]);
        MC(popEval) = DeepResMemoryTest(esnMajor(popEval),esnMinor(popEval,:),config.resType);  
    end
    
    % Add all search points to db
    database = [kernel_rank;gen_rank; MC]';
    database_ext = [kernel_rank;gen_rank;kernel_rank-gen_rank;abs(kernel_rank-gen_rank); MC]';

    for paramIndx = 1:10
        
        rnge = 1:paramIndx*(config.popSize/10);
        % ------------------------------ Save data -----------------------------------------------------------------------------------
        stats_novelty_KQ(tests,paramIndx,:) = [iqr(database(rnge,1)),mad(database(rnge,1)),range(database(rnge,1)),std(database(rnge,1)),var(database(rnge,1))];
        stats_novelty_MC(tests,paramIndx,:) = [iqr(database(rnge,2)),mad(database(rnge,2)),range(database(rnge,2)),std(database(rnge,2)),var(database(rnge,2))];
        
        total_space_covered(tests,paramIndx) = measureSearchSpace(database(rnge,:),config.maxMinorUnits*config.maxMajorUnits);
        
        all_databases{tests,paramIndx} = database(rnge,:);
        
    end
    
    config.endClk = toc(config.startClk);
    config.endTime = datetime; 
    
    save(strcat('randSearch_3DGPU_Nres_',num2str(config.maxMinorUnits),'.mat'),...
        'all_databases','database_ext','config','stats_novelty_KQ','stats_novelty_MC','total_space_covered','-v7.3');
    
    plotParameter(figure1,all_databases{tests,paramIndx},[esnMinor.spectralRadius])
    
end

end