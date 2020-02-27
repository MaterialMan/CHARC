%% CHARC framework in parallel
% The CHARC framework measures the quality of a reservoir substrate using
% the total number and diversity of behaviours realisable by different substrate configurations.
% To search for all realisable behaviours in the substrate's abstract behaviour space,
% we use novelty search and the microbial GA (a steady-state genetic
% algorithm). The search and fitness calculation is performed in this
% behaviour space and not the configuration space.
%
% To start 'runCHARC_parallel.m', define the substrate-to-test ('res_type'),
% behaviours to be measured ('metrics') and details of the
% genetic algorithm (population, generations etc.). After 'gen_print'
% generations, the script will display the behaviour space and where different
% reservoir configurations sit in this space.

% Author: M. Dale
% Date: 20/11/19

%function database = runCHARC_parallel(num_CPUs)
clear 
close all

num_CPUs = 4; % set if need be

% add all subfolders to the path --> make all functions in subdirectories available

%set random seed for experiments
rng(1,'twister');

%% Setup
config.parallel = 1;                        % use parallel toolbox
config.num_CPUs = num_CPUs;

%start paralllel pool if empty
if isempty(gcp) && config.parallel
    parpool('local',config.num_CPUs,'IdleTimeout', Inf); % create parallel pool
end

% type of network to evolve
config.res_type = 'RoR';                % state type of reservoir to use. E.g. 'RoR' (Reservoir-of-reservoirs/ESNs), 'ELM' (Extreme learning machine), 'Graph' (graph network of neurons), 'DL' (delay line reservoir) etc. Check 'selectReservoirType.m' for more.
config.num_nodes = [100];                  % num of nodes in each sub-reservoir, e.g. if config.num_nodes = {10,5,15}, there would be 3 sub-reservoirs with 10, 5 and 15 nodes each. For one reservoir, sate as a non-cell, e.g. config.num_nodes = 25
config = selectReservoirType(config);   % collect function pointers for the selected reservoir type

% Network details
config.metrics = {'KR','GR','linearMC'};       % behaviours that will be used; name metrics to use and order of metrics
config.voxel_size = 10;                  % when measuring quality, this will determine the voxel size. Depends on systems being compared. Rule of thumb: around 10 is good

% dummy variables for dataset; not used but still needed for functions to
% work
config.train_input_sequence= [];
config.train_output_sequence =[];
config.dataset = 'blank';

% get any additional params stored in getDataSetInfo.m. This might include:
% details on reservoir structure, extra task variables, etc.
[config] = getAdditionalParameters(config);

%% Evolutionary parameters
config.num_tests = 1;                        % num of tests/runs
config.pop_size = 100;                       % initail population size. Note: this will generally bias the search to elitism (small) or diversity (large)
config.total_gens = 500;                    % number of generations to evolve
config.mut_rate = 0.05;                       % mutation rate
config.deme_percent = 0.1;                   % speciation percentage; determines interbreeding distance on a ring.
config.deme = round(config.pop_size*config.deme_percent);
config.rec_rate = 0.5;                       % recombination rate

% Novelty search parameters
config.k_neighbours = 10;                   % how many neighbours to check, e.g 10-15 is a good rule-of-thumb
config.p_min_start = sqrt(sum(config.num_nodes));%sum(config.num_nodes)/10;                     % novelty threshold. In general start low. Reduce or increase depending on network size.
config.p_min_check = 100;                   % change novelty threshold dynamically after "p_min_check" generations.

% general params
config.gen_print = 50;                       % after 'gen_print' generations display archive and database
config.start_time = datestr(now, 'HH:MM:SS');
config.save_gen = inf;                       % save data at generation = save_gen
config.param_indx = 1;                      % index for recording database quality; start from 1
config.multi_offspring = 1;                 % CHARC with paralleised search , config.parallel must be 1
config.figure_array = [figure figure];

% prediction parameters
config.get_prediction_data = 0;             % collect task performances after experiment. Variables below are applied if '1'.
config.task_list = {'laser','narma_10'}; % tasks to assess

%% Run experiments
for tests = 1:config.num_tests
    
    clearvars -except config tests figure1 figure2 quality database_history pred_dataset
    
    warning('off','all')
    fprintf('\n Test: %d  ',tests);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    tic
    
    % update random seed
    rng(tests,'twister');
    
    % Reset database counter
    config.param_indx=1;
    
    % create population of reservoirs
    population = config.createFcn(config);
    
    % Evaluate population and assess novelty
    if config.parallel
        ppm = ParforProgMon('Initial population: ', config.pop_size);
        parfor pop_indx = 1:config.pop_size
            warning('off','all')
            population(pop_indx).behaviours = getMetrics(population(pop_indx),config);
            ppm.increment();
        end
    else
        for pop_indx = 1:config.pop_size
            tic
            population(pop_indx).behaviours = getMetrics(population(pop_indx),config);
            fprintf('\n i = %d, took: %.4f\n',pop_indx,toc);
        end
    end
    % establish archive from initial population
    archive = reshape([population.behaviours],length(population(1).behaviours),config.pop_size)';
    
    % add population to database
    database = population;
    plotSearch(database,1,config)
    
    fprintf('Processing took: %.4f sec, Starting GA \n',toc)
    
    % reset variables for novelty threshold
    cnt_no_change = 1;
    config.p_min = config.p_min_start;
    db_cnt = length(population)+1;
    
    % start generational loop
    for gen = 2:config.total_gens
        
        rng(gen,'twister');
        
        if config.multi_offspring
            winner = []; loser=[]; store_indv = [];  % keep track of tournaments
            for p = 1:floor(config.pop_size/2)%config.num_sync_offspring
                % Tournment selection - pick two individuals
                equal = 1; timer = 1; 
                while(equal) % find pair who are within deme range
                    timer = timer+1;
                    indv_1 = randi([1 config.pop_size]);
                    indv_2 = indv_1 + randi([1 config.deme])*2*round(rand)-1;
                    if indv_2 > config.pop_size % loop around, i.e population is on a ring
                        indv_2 = indv_2 - config.pop_size;
                    end
                    if indv_1 ~= indv_2 && indv_2 ~= 0 % contiue if not the same
                        if (ismember(indv_1,store_indv) || ismember(indv_2,store_indv)) && timer <= factorial(config.pop_size)/factorial(config.pop_size-2)
                            equal = 1;
                        else
                            store_indv = [store_indv; [indv_1 indv_2]];
                            equal = 0;
                        end
                    end
                end
                
                %calculate distances in behaviour space using KNN search
                pop_behaviours = reshape([population.behaviours],length(population(1).behaviours),config.pop_size)';
                fit_indv1 = findKNN([archive; pop_behaviours],pop_behaviours(indv_1,:),config.k_neighbours);
                fit_indv2 = findKNN([archive; pop_behaviours],pop_behaviours(indv_2,:),config.k_neighbours);
                
                % Assess fitness of both and assign winner/loser - highest score
                % wins
                if fit_indv1 > fit_indv2
                    winner(p)=indv_1; loser(p) = indv_2;
                else
                    winner(p)=indv_2; loser(p) = indv_1;
                end
            end
            
            if config.num_CPUs > length(loser) % make sure not larger than number of tournaments
                config.num_CPUs = length(loser);
            end
            
            % initialise offspring holder
            offspring = cell(1,config.num_CPUs);
            % create offspring
            for p = 1:config.num_CPUs
               % rng(gen + p,'twister')
                % Infection and mutation phase
                offspring{p} = config.recFcn(population(winner(p)),population(loser(p)),config);
                offspring{p} = config.mutFcn(offspring{p},config);
            end
            
            % Evaluate and update fitness of offspring/loser
            parfor p = 1:config.num_CPUs
                offspring{p}.behaviours = getMetrics(offspring{p},config);
            end
            
            % replace losers in population
            population(loser(1:config.num_CPUs)) = [offspring{1:config.num_CPUs}];   % replace losers (does not replace replicates)
            
            fit_offspring = zeros(1,config.num_CPUs);
            for p = 1:config.num_CPUs
                
                % add offspring details to database
                database(db_cnt) = offspring{p};
                db_cnt = db_cnt +1;
                % reset behaviours of population for fitness assessment
                pop_behaviours(loser(p),:) = offspring{p}.behaviours;
                
                % calculate offsprings neighbours in behaviour space - using
                % population and archive
                fit_offspring(p) = findKNN([archive; pop_behaviours],offspring{p}.behaviours,config.k_neighbours);
                
                %add offspring to archive under conditions
                if  fit_offspring(p) > config.p_min || rand < 0.001 % random chance of being added to archive
                    if length(archive) < 150
                        archive(end+1,:) = pop_behaviours(loser(p),:);
                    else
                        archive = [archive(2:end,:); pop_behaviours(loser(p),:)]; % pop & push
                    end
                    cnt_change(gen) = 1;
                    cnt_no_change(gen) = 0;
                else
                    cnt_no_change(gen) = 1;
                    cnt_change(gen) = 0;
                end
                
                offspring{p} = [];
            end
            
            
        else
            % Tournment selection - pick two individuals.
            equal = 1;
            while(equal)
                indv1 = randi([1 config.pop_size]);
                indv2 = indv1+randi([1 config.deme]); %Second within in deme range of the first
                if indv2 > config.pop_size
                    indv2 = indv2- config.pop_size;
                end
                if indv1 ~= indv2
                    equal = 0;
                end
            end
            
            %calculate distances in behaviour space using KNN search
            pop_behaviours = reshape([population.behaviours],length(population(1).behaviours),config.pop_size)';
            fit_indv1 = findKNN([archive; pop_behaviours],pop_behaviours(indv1,:),config.k_neighbours);
            fit_indv2 = findKNN([archive; pop_behaviours],pop_behaviours(indv2,:),config.k_neighbours);
            
            % Assess fitness of both and assign winner/loser - highest score
            % wins
            if fit_indv1 > fit_indv2
                winner=indv1; loser = indv2;
            else
                winner=indv2; loser = indv1;
            end
            
            %% Infection and mutation phase
            % winner infects loser
            offspring = config.recFcn(population(winner),population(loser),config);
            
            % mutate offspring/loser
            offspring = config.mutFcn(offspring,config);
            
            %% Evaluate and update fitness of offspring/loser
            offspring.behaviours = getMetrics(offspring,config);
            
            % Store behaviours
            population(loser) = offspring;
            pop_behaviours(loser,:) = offspring.behaviours;
            
            % calculate offsprings neighbours in behaviour space - using
            % population and archive
            fit_offspring = findKNN([archive; pop_behaviours],offspring.behaviours,config.k_neighbours);
            
            % add offspring details to database
            database(config.pop_size + gen-1) = offspring;
            
            %add offspring to archive under conditions
            if  fit_offspring > config.p_min || rand < 0.001 % random chance of being added to archive
                if length(archive) < 150
                    archive(end+1,:) = pop_behaviours(loser,:);
                else
                    archive = [archive(2:end,:); pop_behaviours(loser,:)]; % pop & push
                end
                cnt_change(gen) = 1;
                cnt_no_change(gen) = 0;
            else
                cnt_no_change(gen) = 1;
                cnt_change(gen) = 0;
            end
            
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
            %fprintf('Gen %d, time taken: %.4f sec(s)\n Winner is %d, Loser is %d \n',gen,toc/config.gen_print,winner,loser);
            fprintf('Gen %d, time taken: %.4f sec(s)\n',gen,toc/config.gen_print);
            fprintf('Length of archive: %d, p_min; %d \n',length(archive), config.p_min);
            tic;
            plotSearch(database,gen,config)        % plot details
            
            % measure voxel count and quality
            plot_behaviours = reshape([database.behaviours],length(population(1).behaviours),length(database))';
            [quality(tests,config.param_indx),~]= measureSearchSpace(plot_behaviours,config.voxel_size);
            % add database to history of databases
            database_history{tests,config.param_indx} = plot_behaviours;
            config.param_indx = config.param_indx+1; % add to saved database counter
            
            plotQuality(quality,config);
        end
        
        % safe details to disk
        if mod(gen,config.save_gen) == 0
            saveData(database_history,database,quality,tests,config);
        end
    end
    
    % run entire database on set tasks to get performance of behaviours
    if config.get_prediction_data
        all_behaviours = reshape([database.behaviours],length(database(1).behaviours),length(database))';
        pred_dataset{tests} = assessDBonTasks(config,database,all_behaviours);
        
        database_history = pred_dataset;
        saveData(database_history,database,quality,tests,config);
    end
end
config.finish_time = datestr(now, 'HH:MM:SS');

%end % function end

%% fitness function for novelty search
function [avg_dist] = findKNN(behaviours,Y,k_neighbours)
[~,D] = knnsearch(behaviours,Y,'K',k_neighbours);
avg_dist = mean(D);
end

%% plot the behaviour space
function plotSearch(database, gen,config)

all_behaviours = reshape([database.behaviours],length(database(1).behaviours),length(database))';

% Add specific parameter to observe here
% Example: plot a particular parameter:
% param = [database.leak_rate]';
param = 1:length(all_behaviours);
% param = [database.connectivity]';

set(0,'currentFigure',config.figure_array(1))
title(strcat('Gen:',num2str(gen)))
v = 1:length(config.metrics);
C = nchoosek(v,2);

if size(C,1) > 3
    num_plot_x = ceil(size(C,1)/2);
    num_plot_y = 2;
else
    num_plot_x = 3;
    num_plot_y = 1;
end

for i = 1:size(C,1)
    subplot(num_plot_x,num_plot_y,i)
    scatter(all_behaviours(:,C(i,1)),all_behaviours(:,C(i,2)),20,param,'filled')
    
    xlabel(config.metrics(C(i,1)))
    ylabel(config.metrics(C(i,2)))
    colormap('jet')
end
colorbar
drawnow
end

%% plot quality
function plotQuality(quality,config)

set(0,'currentFigure',config.figure_array(2))
plot(1:length(quality),quality)
xticks(1:config.gen_print:length(quality))
xl = xticklabels;
for i = 1:length(xl)
    xticklab(i) = str2num(xl{i});
end
xticklabels(xticklab*config.gen_print)
xlabel('Generation')
ylabel('Quality')

end

function saveData(database_history,database,quality,tests,config)
config.figure_array =[];
save(strcat('Framework_substrate_',config.res_type,'_run',num2str(tests),'_gens',num2str(config.total_gens),'_',num2str(config.num_reservoirs),'Nres_'),...
    'database_history','database','config','quality','-v7.3');

end
