%% CHARC framework
% Notes: Can now evolve heirarchical networks and
% any other reservoir in the support files.

% Author: M. Dale
% Date: 18/02/19
clear
close all
% add all subfolders to the path --> make all functions in subdirectories available
% addpath(genpath(pwd));

%set random seed for experiments
rng(1,'twister');

%% Setup
config.parallel = 1;                        % use parallel toolbox

%start paralllel pool if empty
if isempty(gcp) && config.parallel
    parpool; % create parallel pool
end

% type of network to evolve
config.res_type = 'RoR_IA';                   % can use different hierarchical reservoirs. RoR_IA is default ESN.
config.num_nodes = 50;                   % num of nodes in subreservoirs, e.g. config.num_nodes = {10,5,15}, would be 3 subreservoirs with n-nodes each
config = selectReservoirType(config);       %get correct functions for type of reservoir

% Network details
config.metrics = {'KR','GR','MC'};       % behaviours to use defined by given metrics (and order of metrics)
config.voxel_size = 10;                      % when measuring quality, pick a suitable voxel size 

% dummy variables for dataset
config.train_input_sequence= [];
config.train_output_sequence =[];
config.dataset = 'blank';

% get addition params for reservoir type
[config,figure3,figure4] = getDataSetInfo(config);

%% Evolutionary parameters
config.num_tests = 1;                        % num of runs
config.pop_size = 50;                       % large pop better
config.total_gens = 1000;                    % num of gens
config.mut_rate = 0.1;                       % mutation rate
config.deme_percent = 0.2;                  % speciation percentage
config.deme = round(config.pop_size*config.deme_percent);
config.rec_rate = 0.5;                       % recombination rate

% Novelty search parameters
config.k_neighbours = 10;                   % how many neighbours to check, e.g 10-15 is a good rule-of-thumb
config.p_min_start = 3;                     % novelty threshold. In general start low. Reduce or increase depending on network size.
config.p_min_check = 200;                   % change novelty threshold dynamically after "p_min_check" generations.

% general params
config.gen_print = 25;                       % after 'gen_print' generations display archive and database
config.start_time = datestr(now, 'HH:MM:SS');
figure1 =figure;
figure2 = figure;
config.save_gen = 25;                       % save data at generation = save_gen
config.param_indx = 1;                       % record databases; start from 1

% prediction parameters
config.get_prediction_data = 0;                % gather task performances as well, if desired. Use following details if on.
config.task_list = {'NARMA10','NARMA30','Laser','NonChanEqRodan'}; % tasks to assess
config.discrete = 0;                    % binary or continious input to system
config.nbits = 16;                       % set bit conversion if using binary/discrete systems
config.preprocess = 1;                   % apply basic preprocessing, e.g. scaling and mean variance

%% Run MicroGA - start tests
for tests = 1:config.num_tests
    
    clearvars -except config get_prediction_data tests storeError figure1 figure2 stats_novelty_KQ stats_novelty_MC total_space_covered all_databases

    fprintf('\n Test: %d  ',tests);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    tic 
    
    % update random seed
    rng(tests,'twister');
    
    config.param_indx=1;
    
    % create population of reservoirs
    population = config.createFcn(config);    
    
    %% Evaluate population and assess novelty
    ppm = ParforProgMon('Initial population: ', config.pop_size);
    parfor pop_indx = 1:config.pop_size
        population(pop_indx).behaviours = getVirtualMetrics(population(pop_indx),config);
        ppm.increment();
    end
    
    %% Create NS archive from initial population    
    archive = reshape([population.behaviours],length(config.metrics),config.pop_size)'; % only keep archive of found behaviours
    
    % Add all search points to db
    database = population;     
    
    fprintf('Processing took: %.4f sec, Starting GA \n',toc)
    
    % reset variables
    cnt_no_change = 1;
    config.p_min = config.p_min_start;
    
    % start generational loop
    for gen = 2:config.total_gens

        rng(gen,'twister');
              
        % Tournment selection - pick two individuals. Second within in deme
        % range of the first
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
        
        %calculate distances in behaviour space using KNN search
        pop_behaviours = reshape([population.behaviours],length(config.metrics),config.pop_size)'; 
        error_indv1 = findKNN([archive; pop_behaviours],pop_behaviours(indv1,:),config.k_neighbours);
        error_indv2 = findKNN([archive; pop_behaviours],pop_behaviours(indv2,:),config.k_neighbours);
             
        % Assess fitness of both and assign winner/loser - highest score
        % wins
        if error_indv1 > error_indv2
            winner=indv1; loser = indv2;
        else
            winner=indv2; loser = indv1;
        end
        
        %% Infection and mutation phase 
        % mix winner and loser first
        population(loser) = config.recFcn(population(winner),population(loser),config);
        % mutate offspring/loser
        population(loser) = config.mutFcn(population(loser),config);
        
        %% Evaluate and update fitness of offspring/loser       
        population(loser).behaviours = getVirtualMetrics(population(loser),config);
           
        % Store behaviours   
        pop_behaviours(loser,:) = population(loser).behaviours;       
        
        % calculate offsprings neighbours in behaviour space - using
        % population and archive
        dist = findKNN([archive; pop_behaviours],population(loser).behaviours,config.k_neighbours);
        
        % add offspring details to database 
        database = [database population(loser)];

        %add offspring to archive under conditions
        if  dist > config.p_min || rand < 0.001 
            archive = [archive; pop_behaviours(loser,:)];
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
        if (mod(gen,config.gen_print) == 0)
            fprintf('Gen %d, time taken: %.4f sec(s)\n Winner is %d, Loser is %d \n',gen,toc/config.gen_print,winner,loser);
            fprintf('Length of archive: %d, p_min; %d \n',length(archive), config.p_min);
            tic;

            plotSearch(figure1,database,gen,config)        % plot details
        end
    
        % safe details to disk
       if mod(gen,config.save_gen) == 0
            %% ------------------------------ Save data -----------------------------------------------------------------------------------
            % measure voxel count and quality at this stage to gather
            plot_behaviours = reshape([database.behaviours],length(config.metrics),length(database))'; 
            % generational data
            [quality(tests,config.param_indx),~]= measureSearchSpace(plot_behaviours,config.voxel_size);
            % add database to history of databases
            database_history{tests,config.param_indx} = plot_behaviours;
            config.param_indx = config.param_indx+1; % add to saved database counter
            
            plotQuality(figure2,quality,config);
            
            if strcmp(config.res_type,'Graph')
                save(strcat('substrate_',config.substrate,'_run',num2str(tests),'_gens',num2str(config.total_gens),'_Nres_',num2str(config.N),'_directed',num2str(config.directed_graph),'_self',num2str(config.self_loop),'_nSize.mat'),...
                    'database_history','database','config','quality','-v7.3');     
            else
                save(strcat('Framework_substrate_',config.res_type,'_run',num2str(tests),'_gens',num2str(config.total_gens),'_',num2str(config.num_reservoirs),'Nres_',num2str(config.num_nodes),'_nSize.mat'),...
                    'database_history','database','config','quality','-v7.3');
            end
       end
    end
    
    % run entire database on set tasks to get performance of behaviours
    if config.get_prediction_data
        all_behaviours = reshape([database.behaviours],length(config.metrics),length(database))';
        pred_dataset = assessDBonTasks(config,database,all_behaviours,tests);
    end
end


%% fitness function for novelty search
function [avg_dist] = findKNN(behaviours,Y,k_neighbours)
[~,D] = knnsearch(behaviours,Y,'K',k_neighbours);
avg_dist = mean(D);
end

%% plot the behaviour space
function plotSearch(figureHandle,database, gen,config)

all_behaviours = reshape([database.behaviours],length(config.metrics),length(database))';

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
    scatter(all_behaviours(:,C(i,1)),all_behaviours(:,C(i,2)),20,1:length(all_behaviours),'filled')
    
    xlabel(config.metrics(C(i,1)))
    ylabel(config.metrics(C(i,2)))
    colormap('copper')
end

drawnow
end

%% plot quality
function plotQuality(figureHandle,quality,config)

set(0,'currentFigure',figureHandle)
plot(1:length(quality),quality)
xticks(1:length(quality))
xticklabels((1:length(quality))*config.save_gen)
xlabel('Generation')
ylabel('Quality')

end