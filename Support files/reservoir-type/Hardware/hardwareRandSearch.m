%% Hardware Novelty Search using metrics 
% Author: M. Dale
% Date: 26/04/18
clear
rng(1,'twister');

config.material = 'B2S164'; %label material being used

% Evo settings
config.popSize =2000; %2000
config.numTests = 5; %5

config.metrics_used = [1 1 0]; %KR GR
config.leakOn = 1;

%Archive settings
config.k_neighbours = 15;
config.p_min = 3;
config.p_min_check = 200;

%general params
config.saveGen = 200; %200
config.startTime = datestr(now, 'HH:MM:SS');
figure1 =figure;
config.printGen = 2;

%hardware variables
config.num_electrodes =64; %how many electrodes in use
config.voltage_range =8; %no less/more than [-10V 10V]: prefereably higher/lower than [-8V 8V] to be safe
config.input_range = 16; %how many inputs to be used at one time. No more than 32. 16 is good default.
[read_session,switch_session] = createDaqSessions(0:config.num_electrodes-1,0:(config.num_electrodes/2)-1);
config.reg_param = 10e-5;

%% RUn MicroGA
for tests = 1:config.numTests
    
    clearvars -except config tests storeError figure1 figure2 stats_novelty_KQ stats_novelty_MC...
        recIndx mutIndx demeIndx popIndx all_databases total_space_covered read_session switch_session
    
    fprintf('\n Test: %d  ',tests);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    
    rng(tests,'twister');
    
    config.paramIndx=1;
    
    genotype = createGenotypeHardware(config.popSize,config.num_electrodes,config.voltage_range,config.input_range);

    tic;
    kernel_rank=[]; gen_rank=[];
    rank_diff=[]; MC=[];
    
    %% Evaluate population
    for pop_eval = 1:config.popSize
        

        [kernel_rank(pop_eval),gen_rank(pop_eval),~,MC(pop_eval),Mapping(pop_eval,:)] =getMetrics(switch_session,read_session,reshape(genotype(pop_eval,:,:),size(genotype,2),size(genotype,3))...
            ,config.num_electrodes/2,config.num_electrodes,config.reg_param,config.leakOn,config.metrics_used);
        
        if (mod(pop_eval,config.printGen) == 0)
            database_print = [kernel_rank;gen_rank; MC]';
            plotSearch(figure1,database_print,pop_eval)
            
            fprintf('\n Num=%d, KQ=%d, GR=%d,MC=%.3f, Outputs:\n',pop_eval,kernel_rank(pop_eval),gen_rank(pop_eval),MC(pop_eval))
            display(Mapping(pop_eval,:))
        end
        
        % print info
        if (mod(pop_eval,config.saveGen) == 0)
            
            %all search points
            database = [kernel_rank;gen_rank; MC]';
            database_ext = [kernel_rank;gen_rank; MC; Mapping]';
            database_genotype = genotype;
            
            %plotSearch(figure1,database,pop_eval)
            
            stats_novelty_KQ(tests,config.paramIndx,:) = [iqr(database(:,1)),mad(database(:,1)),range(database(:,1)),std(database(:,1)),var(database(:,1))];
            stats_novelty_MC(tests,config.paramIndx,:) = [iqr(database(:,2)),mad(database(:,2)),range(database(:,2)),std(database(:,2)),var(database(:,2))];
            
            total_space_covered(tests,config.paramIndx) = measureSearchSpace(database,100);
         
            all_databases{tests,config.paramIndx} = database;
            
           
            
            save(strcat('hardware_randSearch_',num2str(config.popSize),'_SN_',config.material,'_run_',num2str(tests),'.mat'),...
                'database_genotype','database','database_ext','all_databases','config','stats_novelty_KQ','stats_novelty_MC','total_space_covered','-v7.3');
            
            config.paramIndx = config.paramIndx+1;
        end
    end
    
    
end

%   save(strcat('hardware_randSearch_',num2str(config.popSize),'_SN_',config.material,'_run_',num2str(tests),'.mat'),...
%                 'database_genotype','database','all_databases','config','stats_novelty_KQ','stats_novelty_MC','total_space_covered','-v7.3');
%                   

function plotSearch(figureHandle,database, gen)

set(0,'CurrentFigure',figureHandle);
scatter3(database(:,1),database(:,2),database(:,3),20,1:length(database),'filled')
title(strcat('Gen:',num2str(gen)))
xlabel('KR')
ylabel('GR')
zlabel('MC')
colormap('copper')
title('Database')

drawnow
end
