%% CHARC framework
% The CHARC framework measures the quality of a reservoir substrate using
% the total number and diversity of behaviours realisable by different substrate configurations.
% To search for all realisable behaviours in the substrate's abstract behaviour space,
% we use novelty search and the microbial GA (a steady-state genetic
% algorithm). The search and fitness calculation is performed in this
% behaviour space and not the configuration space.
%
% To start 'runCHARC.m', define the substrate-to-test ('res_type'),
% behaviours to be measured ('metrics') and details of the
% genetic algorithm (population, generations etc.). After 'gen_print'
% generations, the script will display the behaviour space and where different
% reservoir configurations sit in this space.

% Author: M. Dale
% Date: 03/07/19

function [database,config] = viking_charc(ID,undirected, reservoir_type, network_size,SW,P_rc)

% add all subfolders to the path --> make all functions in subdirectories available
addpath(genpath('/mnt/lustre/users/md596/working-branch/'));

%% Setup
config.undirected = undirected;
config.SW = SW;
config.P_rc = P_rc;
config.WattsStrogartz = 0;

%set random seed for experiments
rng(ID,'twister');

scurr = rng;
tests = scurr.Seed;

% type of network to evolve
switch(reservoir_type)
    case 1 % ring
        config.res_type = 'Graph';                % state type of reservoir to use. E.g. 'RoR' (Reservoir-of-reservoirs/ESNs), 'ELM' (Extreme learning machine), 'Graph' (graph network of neurons), 'DL' (delay line reservoir) etc. Check 'selectReservoirType.m' for more.
        config.num_nodes = [network_size.^2];                  % num of nodes in each sub-reservoir, e.g. if config.num_nodes = {10,5,15}, there would be 3 sub-reservoirs with 10, 5 and 15 nodes each. For one reservoir, sate as a non-cell, e.g. config.num_nodes = 25
        reservoir_type = 'ring';
    case 2 % torus
        config.res_type = 'Graph';                % state type of reservoir to use. E.g. 'RoR' (Reservoir-of-reservoirs/ESNs), 'ELM' (Extreme learning machine), 'Graph' (graph network of neurons), 'DL' (delay line reservoir) etc. Check 'selectReservoirType.m' for more.
        config.num_nodes = [network_size];                  % num of nodes in each sub-reservoir, e.g. if config.num_nodes = {10,5,15}, there would be 3 sub-reservoirs with 10, 5 and 15 nodes each. For one reservoir, sate as a non-cell, e.g. config.num_nodes = 25
        reservoir_type = 'torus';
    case 3 % lattice
        config.res_type = 'Graph';                % state type of reservoir to use. E.g. 'RoR' (Reservoir-of-reservoirs/ESNs), 'ELM' (Extreme learning machine), 'Graph' (graph network of neurons), 'DL' (delay line reservoir) etc. Check 'selectReservoirType.m' for more.
        config.num_nodes = [network_size];                  % num of nodes in each sub-reservoir, e.g. if config.num_nodes = {10,5,15}, there would be 3 sub-reservoirs with 10, 5 and 15 nodes each. For one reservoir, sate as a non-cell, e.g. config.num_nodes = 25
        reservoir_type = 'lattice';
    case 4 % esn
        config.res_type = 'RoR';                % state type of reservoir to use. E.g. 'RoR' (Reservoir-of-reservoirs/ESNs), 'ELM' (Extreme learning machine), 'Graph' (graph network of neurons), 'DL' (delay line reservoir) etc. Check 'selectReservoirType.m' for more.
        config.num_nodes = [network_size.^2];                  % num of nodes in each sub-reservoir, e.g. if config.num_nodes = {10,5,15}, there would be 3 sub-reservoirs with 10, 5 and 15 nodes each. For one reservoir, sate as a non-cell, e.g. config.num_nodes = 25
        reservoir_type = 'esn';
end

fprintf('Reservoir: %s, Size: %d, undirected: %d, run: %d \n',reservoir_type,network_size,undirected,ID)

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
switch(reservoir_type)
    case 'esn'
        [config] = getAdditionalParameters_esn(config);
    case 'torus'
        [config] = getAdditionalParameters_torus(config);
    case 'ring'
        [config] = getAdditionalParameters_ring(config);
    case 'lattice'
        [config] = getAdditionalParameters_lattice(config);
end

%% Evolutionary parameters
config.num_tests = 1;                        % num of tests/runs
config.pop_size = 10;                       % initail population size. Note: this will generally bias the search to elitism (small) or diversity (large)
config.total_gens = 10;                    % number of generations to evolve
config.mut_rate = 0.1;                       % mutation rate
config.deme_percent = 0.2;                   % speciation percentage; determines interbreeding distance on a ring.
config.deme = round(config.pop_size*config.deme_percent);
config.rec_rate = 0.5;                       % recombination rate

% Novelty search parameters
config.k_neighbours = 10;                   % how many neighbours to check, e.g 10-15 is a good rule-of-thumb
config.p_min_start = 3;                     % novelty threshold. In general start low. Reduce or increase depending on network size.
config.p_min_check = 100;                   % change novelty threshold dynamically after "p_min_check" generations.

% general params
config.gen_print = 10;                       % after 'gen_print' generations display archive and database
config.start_time = datestr(now, 'HH:MM:SS');
config.figure_array = [figure figure];
config.save_gen = config.total_gens;                       % save data at generation = save_gen
config.param_indx = 1;                      % index for recording database quality; start from 1

% prediction parameters
config.get_prediction_data = 0;             % collect task performances after experiment. Variables below are applied if '1'.
config.task_list = {'Laser'}; % tasks to assess
%config.discrete = 0;                        % binary or continious input to system
%config.nbits = 16;                          % set bit conversion if using binary/discrete systems
config.preprocess = 1;                      % apply basic preprocessing, e.g. scaling and mean variance

% run test
%[database_history,database,quality] = runTest(tests,config);
[~,database,~] = runTest(tests,config);

%save data
%saveDatabase(database_history,database,quality,tests,config,network_size,reservoir_type);

end

function [database_history,database,quality] = runTest(tests,config)

%% Run experiments
warning('off','all')
fprintf('\n Test: %d  ',tests);
fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
start=tic;

% update random seed
rng(tests,'twister');

% Reset database counter
config.param_indx=1;

% create population of reservoirs
population = config.createFcn(config);

% Evaluate population and assess novelty
for pop_indx = 1:config.pop_size
    tic
    population(pop_indx).behaviours = getMetrics(population(pop_indx),config);
    fprintf('\n i = %d, took: %.4f\n',pop_indx,toc);
end

% establish archive from initial population
archive = reshape([population.behaviours],length(population(1).behaviours),config.pop_size)';

% add population to database
database = population;
plotSearch(database,1,config)

fprintf('Processing took: %.4f sec, Starting GA \n',toc(start))

% reset variables for novelty threshold
cnt_no_change = zeros(1,config.total_gens);
cnt_change = zeros(1,config.total_gens);
cnt_no_change(1) = 1;
config.p_min = config.p_min_start;

gen_tic = tic;

% start generational loop
for gen = 2:config.total_gens
    
    rng(gen,'twister');
    
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
        fprintf('Gen %d, time taken: %.4f sec(s)\n Winner is %d, Loser is %d \n',gen,toc(gen_tic)/config.gen_print,winner,loser);
        fprintf('Length of archive: %d, p_min; %d \n',length(archive), config.p_min);
        
        plotSearch(database,gen,config)        % plot details
        
        % measure voxel count and quality
        plot_behaviours = reshape([database.behaviours],length(population(1).behaviours),length(database))';
        [quality(config.param_indx),~]= measureSearchSpace(plot_behaviours,config.voxel_size);
        
        
        % add database to history of databases
        database_history{config.param_indx} = plot_behaviours;
        config.param_indx = config.param_indx+1; % add to saved database counter
        
        plotQuality(quality,config);
        
        gen_tic = tic;
    end
    
end

% run entire database on set tasks to get performance of behaviours
if config.get_prediction_data
    all_behaviours = reshape([database.behaviours],length(population(1).behaviours),length(database))';
    pred_dataset{tests} = assessDBonTasks(config,database,all_behaviours,tests);
end

end



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
% lr = [database.leak_rate]';
%param = 1:length(all_behaviours);
param = [database.connectivity];

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
    
    % Replace with desired parameter:
    % scatter(all_behaviours(:,C(i,1)),all_behaviours(:,C(i,2)),20,lr,'filled')
    
    xlabel(config.metrics(C(i,1)))
    ylabel(config.metrics(C(i,2)))
    colormap(copper)
end

drawnow
end

%% plot quality
function plotQuality(quality,config)

set(0,'currentFigure',config.figure_array(2))
plot(1:length(quality),quality)
xticks(1:2:length(quality))
xl = xticklabels;
for i = 1:length(xl)
    xticklab(i) = str2num(xl{i});
end
xticklabels(xticklab*config.gen_print)
xlabel('Generation')
ylabel('Quality')

end

function saveDatabase(database_history,database,quality,test,config,network_size,reservoir_type)
config.figure_array =[];

if config.undirected
    direction = 'undirected';
else
    direction = 'directed';
end

if test == 1 
    save(strcat('/mnt/lustre/users/md596/working-branch/Ucnc retests/',reservoir_type,'/Results/',direction,'/substrate_',num2str(network_size),'_run',num2str(test),'_networkSize_',config.res_type,'_undirected_',num2str(config.undirected),'SW_',num2str(config.SW),'Prc_',num2str(config.P_rc),'.mat'),...
        'database_history','database','config','quality','-v7.3');
else
    save(strcat('/mnt/lustre/users/md596/working-branch/Ucnc retests/',reservoir_type,'/Results/',direction,'/substrate_',num2str(network_size),'_run',num2str(test),'_networkSize_',config.res_type,'_undirected_',num2str(config.undirected),'SW_',num2str(config.SW),'Prc_',num2str(config.P_rc),'.mat'),...
        'database_history','config','quality');
end


end