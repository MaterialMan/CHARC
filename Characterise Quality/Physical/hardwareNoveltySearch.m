%% Hardware Novelty Search using metrics 
% Author: M. Dale
% Date: 26/04/18
clear
rng(1,'twister');

config.material = 'B2S164'; %label material being used

% Evo settings
config.popSize =5; 
config.deme = round(config.popSize*0.25); %sub-species increase diversity
config.numMutate = 0.1;    
config.recRate = 0.5;
config.numTests = 2;
config.totalGens = 5;
config.saveGen = config.totalGens/4;
config.metrics_used = [1 1 0]; %KR GR
config.paramIndx=1;
config.leakOn = 1;

%Archive settings
config.k_neighbours = 15;
config.p_min = 2;
config.p_min_check = 200;

%general params
config.genPrint = 1;
config.startTime = datestr(now, 'HH:MM:SS');
figure1 =figure;

%hardware variables
config.num_electrodes =64; %how many electrodes in use
config.voltage_range =7; %no less/more than [-10V 10V]: prefereably higher/lower than [-8V 8V] to be safe
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
    
    genotype = createGenotypeHardware(config.popSize,config.num_electrodes,config.voltage_range,config.input_range);

    tic;
    kernel_rank=[]; gen_rank=[];
    rank_diff=[]; MC=[];
    
    %% Evaluate population
    for pop_eval = 1:config.popSize
        [kernel_rank(pop_eval),gen_rank(pop_eval),~,MC(pop_eval),Mapping(pop_eval,:)] =getMetrics(switch_session,read_session,reshape(genotype(pop_eval,:,:),size(genotype,2),size(genotype,3))...
            ,config.num_electrodes/2,config.num_electrodes,config.reg_param,config.leakOn,config.metrics_used);
    end
    
    %% Create seed archive
    archive = [abs(kernel_rank-gen_rank); MC]';
    archive_genotype = genotype;
    
    %all search points
    database = [abs(kernel_rank-gen_rank); MC]';
    database_ext = [kernel_rank;gen_rank; MC;Mapping]';
    database_genotype = genotype;
    
    for i = 1:config.popSize
        storeError(tests,1,i) = findKNN(archive,archive(i,:),config.k_neighbours);
    end
    fprintf('Processing took: %.1f, Starting GA \n',toc)
    
    cnt_no_change = 1;
    
    for gen = 2:config.totalGens
        
        rng(gen,'twister');
        
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
        
        %calculate distances
        pop_metrics = [abs(kernel_rank-gen_rank);MC]';
        error_indv1 = findKNN([archive; pop_metrics],pop_metrics(indv1,:),config.k_neighbours);
        error_indv2 = findKNN([archive; pop_metrics],pop_metrics(indv2,:),config.k_neighbours);
        
        
        % Assess fitness of both and assign winner/loser - highest score
        % wins
        if error_indv1 > error_indv2
            winner=indv1; loser = indv2;
        else
            winner=indv2; loser = indv1;
        end
        
        %% Infection phase
         for i = 1:config.num_electrodes/2
            %recombine
            if rand < config.recRate
                if ~ismember(genotype(winner,i,1),genotype(loser,:,1)) %check if input already exists
                    genotype(loser,i,:) = genotype(winner,i,:);
                else
                    genotype(loser,i,2:end) = genotype(winner,i,2:end); %if it does swapp everthing else
                end
            end
         end
        
         %% Mutate
         for i = 1:size(genotype,2)
             for j = 1:size(genotype,3)
                 if rand < config.numMutate
                     switch(j)
                         case 1 % electrode
                             not_found = 1;
                             while(not_found)
                                 pos = randi([1 config.num_electrodes]);
                                 if ~ismember(pos,genotype(loser,:,1)) %is it in genotype
                                     not_found = 0;
                                 end
                             end
                             genotype(loser,i,j) = pos;
                         case 2 % num inputs
                             if sum(genotype(loser,:,2)) < 31
                                 %if rand < config.numMutate
                                     if sum(genotype(loser,:,2)) > 1 %should stop zero inputs
                                         genotype(loser,i,j) = ~genotype(loser,i,j);
                                     else
                                         genotype(loser,i,j) = 1;
                                     end
                                 %end
                             else
                                 genotype(loser,i,j) = 0;
                             end
                         case 3 %weighted input or static input
                             genotype(loser,i,j) = ~genotype(loser,i,j);
                         case 4 %weight value
                             not_found = 1;
                             while(not_found)
                                 temp= genotype(loser,i,j)+randn;
                                 if temp < config.voltage_range && temp > -config.voltage_range
                                     not_found = 0;
                                 end
                             end
                             genotype(loser,i,j) = temp;
                         case 5 %static value
                             not_found = 1;
                             while(not_found)
                                 temp= genotype(loser,i,j)+randn;
                                 if temp < config.voltage_range && temp > -config.voltage_range
                                     not_found = 0;
                                 end
                             end
                             genotype(loser,i,j) = temp;
                         case 6 %mutate LR
                             genotype(loser,1,j) = rand;
                         otherwise
                     end
                 end
             end
         end
         
         %double check input
         if sum(genotype(loser,:,2)) < 1
             genotype(loser,randi([1 32]),2) = 1;
         end
         
        
        %% Evaluate and update fitness
        storeError(tests,gen,:) = storeError(tests,gen-1,:);
        
        [kernel_rank(loser),gen_rank(loser),~,MC(loser),Mapping(loser,:)] =getMetrics(switch_session,read_session,reshape(genotype(loser,:,:),size(genotype,2),size(genotype,3))...
            ,config.num_electrodes/2,config.num_electrodes,config.reg_param,config.leakOn,config.metrics_used);
        
        %%  Re-Calculate pop rank
        pop_metrics = [abs(kernel_rank-gen_rank);MC]';
        pop_metrics_ext = [kernel_rank;gen_rank;kernel_rank-gen_rank;abs(kernel_rank-gen_rank); MC]';
        dist = findKNN([archive; pop_metrics],pop_metrics(loser,:),config.k_neighbours);
        
        % add to search archive
        database = [database; pop_metrics(loser,:)];
        database_ext = [database_ext; pop_metrics_ext(loser,:)];
        database_genotype = [database_genotype; genotype(loser,:,:)];
        
        
        %add to fitness archive
        if  dist > config.p_min || rand < 0.001 %storeError(tests,eval,loser)
            archive = [archive; pop_metrics(loser,:)];
            archive_genotype = [archive_genotype; genotype(loser,:,:)];
            cnt_change(gen) = 1;
            cnt_no_change(gen) = 0;
        else
            cnt_no_change(gen) = 1;
            cnt_change(gen) = 0;
        end
        
        %dynamically adapt p_min -- minimum novelty threshold
        if gen > config.p_min_check+1
            if sum(cnt_no_change(gen-config.p_min_check:gen)) > config.p_min_check-1 %not changing enough
                config.p_min = config.p_min - config.p_min*0.05;%minus 5%
                cnt_no_change(gen-config.p_min_check:gen) = zeros;%reset
            end
            if sum(cnt_change(gen-config.p_min_check:gen)) > 10 %too frequent
                config.p_min = config.p_min + config.p_min*0.1; %plus 20%
                cnt_change(gen-config.p_min_check:gen) = zeros; %reset
            end
        end
        
        % print info
        if (mod(gen,config.genPrint) == 0)
            fprintf('Gen %d, time taken: %.4f sec(s)\n Winner is %d, Loser is %d \n',gen,toc/config.genPrint,winner,loser);
            fprintf('Length of archive: %d, p_min; %d \n',length(archive), config.p_min);
            tic;
            plotSearch(figure1,archive,database,gen)
        end
        
        
        if mod(gen,config.saveGen) == 0
            %% ------------------------------ Save data -----------------------------------------------------------------------------------
            stats_novelty_KQ(tests,config.paramIndx,:) = [iqr(database(:,1)),mad(database(:,1)),range(database(:,1)),std(database(:,1)),var(database(:,1))];
            stats_novelty_MC(tests,config.paramIndx,:) = [iqr(database(:,2)),mad(database(:,2)),range(database(:,2)),std(database(:,2)),var(database(:,2))];
            
            total_space_covered(tests,config.paramIndx) = measureSearchSpace(database,100);
            
            all_databases{tests,config.paramIndx} = database;
            
            save(strcat('hardware_noveltySearch_',num2str(config.totalGens),'_SN_',config.material,'_run_',num2str(tests),'.mat'),...
                'database_genotype','database','all_databases','config','stats_novelty_KQ','stats_novelty_MC','total_space_covered','-v7.3');
            
            config.paramIndx = config.paramIndx+1;
        end
    end
    
end

save(strcat('hardware_noveltySearch_',num2str(config.totalGens),'_SN_',config.material,'.mat'),...
                'database_genotype','database','all_databases','config','stats_novelty_KQ','stats_novelty_MC','total_space_covered','-v7.3');
            
%% fitness function
function [avg_dist] = findKNN(metrics,Y,k_neighbours)
[~,D] = knnsearch(metrics,Y,'K',k_neighbours);
avg_dist = mean(D);
end

function plotSearch(figureHandle,archive,database, gen)

figure(figureHandle)
subplot(1,2,1)
scatter(archive(:,1),archive(:,2),20,1:length(archive),'filled')
title(strcat('Gen:',num2str(gen)))
xlabel('KR-GR')
ylabel('MC')
colormap('copper')
title('Fitness Archive')

subplot(1,2,2)
scatter(database(:,1),database(:,2),20,1:length(database),'filled')
title(strcat('Gen:',num2str(gen)))
xlabel('KR-GR')
ylabel('MC')
colormap('copper')
title('Database')

drawnow
end



