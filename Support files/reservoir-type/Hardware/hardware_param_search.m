%% Hardware Novelty Search using metrics - for prediction
% Author: M. Dale
% Date: 26/04/18
% cd ../..
% datadir='\Hardware';
% cd(datadir);

clearvars -except config figure1 figure2 stats_novelty_KQ stats_novelty_MC ...
    recIndx mutIndx demeIndx popIndx all_search_archives total_space_covered...
    read_session switch_session


%% RUn MicroGA
for tests = 1:config.numTests
    
    clearvars -except config figure1 figure2 stats_novelty_KQ stats_novelty_MC ...
    recIndx mutIndx demeIndx popIndx all_search_archives total_space_covered...
    read_session switch_session tests

    fprintf('\n Test: %d  ',tests);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    
    rng(tests,'twister');
    
    genotype = createGenotypeHardware(config.popSize,config.num_electrodes,config.voltage_range,config.input_range);

    tic;
    kernel_rank=[]; gen_rank=[];
    rank_diff=[]; MC=[];
    
    %% Evaluate population
    for pop_eval = 1:config.popSize
        [kernel_rank(pop_eval),gen_rank(pop_eval),~,MC(pop_eval)] =getMetrics(switch_session,read_session,reshape(genotype(pop_eval,:,:),size(genotype,2),size(genotype,3))...
            ,config.num_electrodes/2,config.num_electrodes,config.reg_param,config.leakOn,config.metrics_used);
    end
    
    %% Create seed archive
    seed_archive = [abs(kernel_rank-gen_rank); MC]';
    archive = seed_archive;
    archive_genotype = genotype;
    
    %all search points
    search_archive = seed_archive;
    search_archive_genotype = genotype;
    
    for i = 1:config.popSize
        storeError(tests,1,i) = findKNN(seed_archive,seed_archive(i,:),config.k_neighbours);
    end
    fprintf('Processing took: %.1f, Starting GA \n',toc)
    
    cnt_no_change = 1;
    
    for epoch = 2:config.numEpoch
        
        rng(epoch,'twister');
        
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
        storeError(tests,epoch,:) = storeError(tests,epoch-1,:);
        
        [kernel_rank(loser),gen_rank(loser),~,MC(loser)] =getMetrics(switch_session,read_session,reshape(genotype(loser,:,:),size(genotype,2),size(genotype,3))...
            ,config.num_electrodes/2,config.num_electrodes,config.reg_param,config.leakOn,config.metrics_used);
        
        %%  Re-Calculate pop rank
        pop_metrics = [abs(kernel_rank-gen_rank);MC]';
        dist = findKNN([archive; pop_metrics],pop_metrics(loser,:),config.k_neighbours);
        
        % add to search archive
        search_archive = [search_archive; pop_metrics(loser,:)];
        search_archive_genotype = [search_archive_genotype; genotype(loser,:,:)];
        
        
        %add to fitness archive
        if  dist > config.p_min || rand < 0.001 %storeError(tests,eval,loser)
            archive = [archive; pop_metrics(loser,:)];
            archive_genotype = [archive_genotype; genotype(loser,:,:)];
            cnt_change(epoch) = 1;
            cnt_no_change(epoch) = 0;
        else
            cnt_no_change(epoch) = 1;
            cnt_change(epoch) = 0;
        end
        
        %dynamically adapt p_min -- minimum novelty threshold
        if epoch > config.p_min_check+1
            if sum(cnt_no_change(epoch-config.p_min_check:epoch)) > config.p_min_check-1 %not changing enough
                config.p_min = config.p_min - config.p_min*0.05;%minus 5%
                cnt_no_change(epoch-config.p_min_check:epoch) = zeros;%reset
            end
            if sum(cnt_change(epoch-config.p_min_check:epoch)) > 10 %too frequent
                config.p_min = config.p_min + config.p_min*0.1; %plus 20%
                cnt_change(epoch-config.p_min_check:epoch) = zeros; %reset
            end
        end
        
        % print info
        if (mod(epoch,config.genPrint) == 0)
            fprintf('Gen %d, time taken: %.4f sec(s)\n Winner is %d, Loser is %d \n',epoch,toc/config.genPrint,winner,loser);
            fprintf('Length of archive: %d, p_min; %d \n',length(archive), config.p_min);
            tic;
            plotSearch(figure1,archive,search_archive,epoch)
        end
        
        
        if mod(epoch,config.saveGen) == 0
            %% ------------------------------ Save data -----------------------------------------------------------------------------------
            stats_novelty_KQ(config.paramIndx,:) = [iqr(search_archive(:,1)),mad(search_archive(:,1)),range(search_archive(:,1)),std(search_archive(:,1)),var(search_archive(:,1))];
            stats_novelty_MC(config.paramIndx,:) = [iqr(search_archive(:,2)),mad(search_archive(:,2)),range(search_archive(:,2)),std(search_archive(:,2)),var(search_archive(:,2))];
            
            total_space_covered(config.paramIndx) = measureSearchSpace(search_archive,100);
            
            all_search_archives{config.paramIndx} = search_archive;
            
            save(strcat('hardware_senAnal_SN_',config.material,'.mat'),...
                'search_archive_genotype','search_archive','archive_genotype','all_search_archives','config','stats_novelty_KQ','stats_novelty_MC','total_space_covered','-v7.3');
           
        end
    end
end

     
%% fitness function
function [avg_dist] = findKNN(metrics,Y,k_neighbours)
[~,D] = knnsearch(metrics,Y,'K',k_neighbours);
avg_dist = mean(D);
end

function plotSearch(figureHandle,archive,search_archive, epoch)

figure(figureHandle)
subplot(1,2,1)
scatter(archive(:,1),archive(:,2),20,1:length(archive),'filled')
title(strcat('Gen:',num2str(epoch)))
xlabel('KR-GR')
ylabel('MC')
colormap('copper')
title('Fitness Archive')

subplot(1,2,2)
scatter(search_archive(:,1),search_archive(:,2),20,1:length(search_archive),'filled')
title(strcat('Gen:',num2str(epoch)))
xlabel('KR-GR')
ylabel('MC')
colormap('copper')
title('Search Archive')

drawnow
end



