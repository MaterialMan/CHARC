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

function viking_rand_SW(ID,undirected, reservoir_type, network_size,SW,P_rc)

% add all subfolders to the path --> make all functions in subdirectories available
addpath(genpath('/mnt/lustre/users/md596/working-branch/'));

%% Setup
config.undirected = undirected;
config.SW = SW;
config.P_rc = P_rc;

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
        K_num = 2;
    case 2 % torus
        config.res_type = 'Graph';                % state type of reservoir to use. E.g. 'RoR' (Reservoir-of-reservoirs/ESNs), 'ELM' (Extreme learning machine), 'Graph' (graph network of neurons), 'DL' (delay line reservoir) etc. Check 'selectReservoirType.m' for more.
        config.num_nodes = [network_size];                  % num of nodes in each sub-reservoir, e.g. if config.num_nodes = {10,5,15}, there would be 3 sub-reservoirs with 10, 5 and 15 nodes each. For one reservoir, sate as a non-cell, e.g. config.num_nodes = 25
        reservoir_type = 'torus';
        K_num = 2;
    case 3 % lattice
        config.res_type = 'Graph';                % state type of reservoir to use. E.g. 'RoR' (Reservoir-of-reservoirs/ESNs), 'ELM' (Extreme learning machine), 'Graph' (graph network of neurons), 'DL' (delay line reservoir) etc. Check 'selectReservoirType.m' for more.
        config.num_nodes = [network_size];                  % num of nodes in each sub-reservoir, e.g. if config.num_nodes = {10,5,15}, there would be 3 sub-reservoirs with 10, 5 and 15 nodes each. For one reservoir, sate as a non-cell, e.g. config.num_nodes = 25
        reservoir_type = 'lattice';
        K_num = 2;
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
config.pop_size = 10100;                       % initail population size. Note: this will generally bias the search to elitism (small) or diversity (large)
config.total_gens = 0;                    % number of generations to evolve
config.mut_rate = 0.1;                       % mutation rate
config.deme_percent = 0.2;                   % speciation percentage; determines interbreeding distance on a ring.
config.deme = round(config.pop_size*config.deme_percent);
config.rec_rate = 0.5;                       % recombination rate

% Novelty search parameters
config.k_neighbours = 10;                   % how many neighbours to check, e.g 10-15 is a good rule-of-thumb
config.p_min_start = 3;                     % novelty threshold. In general start low. Reduce or increase depending on network size.
config.p_min_check = 100;                   % change novelty threshold dynamically after "p_min_check" generations.

% general params
config.gen_print = 1000;                       % after 'gen_print' generations display archive and database
config.start_time = datestr(now, 'HH:MM:SS');
config.save_gen = config.total_gens;                       % save data at generation = save_gen
config.param_indx = 1;                      % index for recording database quality; start from 1

% prediction parameters
config.get_prediction_data = 0;             % collect task performances after experiment. Variables below are applied if '1'.
config.task_list = {'Laser'}; % tasks to assess
%config.discrete = 0;                        % binary or continious input to system
%config.nbits = 16;                          % set bit conversion if using binary/discrete systems
config.preprocess = 1;                      % apply basic preprocessing, e.g. scaling and mean variance

% run test
[database,quality,measures] = runTest(tests,config);

%save data
saveDatabase(measures,database,quality,tests,config,network_size,reservoir_type);

end

function [database,quality,measures] = runTest(tests,config)

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
    %rng(test + pop_indx,'twister');
%     G = WattsStrogatz(config.num_nodes,K_num,P_rc);
     [L(pop_indx),EGlob(pop_indx),CClosed(pop_indx),ELocClosed(pop_indx),COpen(pop_indx),ELocOpen(pop_indx)] = ...
         graphProperties(double(population(pop_indx).W{1,1} ~= 0));
%     
%     W = zeros(config.num_nodes);
%     W((adjacency(G) == 1)) = rand(nnz(adjacency(G)),1)-0.5;
%     population(pop_indx).W{1,1} = W;
    
    population(pop_indx).behaviours = getMetrics(population(pop_indx),config);
    fprintf('\n i = %d, took: %.4f\n',pop_indx,toc);
end

% record all measures
measures = [L;EGlob;CClosed;ELocClosed;COpen;ELocOpen];

% add population to database
database = population;

fprintf('Processing took: %.4f sec, Starting GA \n',toc(start))

% reset variables for novelty threshold
cnt_no_change = zeros(1,config.total_gens);
cnt_change = zeros(1,config.total_gens);
cnt_no_change(1) = 1;
config.p_min = config.p_min_start;

gen_tic = tic;

plot_behaviours = reshape([database.behaviours],length(population(1).behaviours),length(database))';
[quality,~]= measureSearchSpace(plot_behaviours,config.voxel_size);
        
end


function saveDatabase(measures,database,quality,test,config,network_size,reservoir_type)
config.figure_array =[];

if config.undirected
    direction = 'undirected';
else
    direction = 'directed';
end

% if test == 1 
%     save(strcat('/mnt/lustre/users/md596/working-branch/Ucnc retests/',reservoir_type,'/Results/',direction,'/rand_',num2str(network_size),'_run',num2str(test),'_networkSize_',config.res_type,'_undirected_',num2str(config.undirected),'SW_',num2str(config.SW),'Prc_',num2str(config.P_rc),'.mat'),...
%         'measures','database','config','quality','-v7.3');
% else
    save(strcat('/mnt/lustre/users/md596/working-branch/Ucnc retests/',reservoir_type,'/Results/',direction,'/rand_',num2str(network_size),'_run',num2str(test),'_networkSize_',config.res_type,'_undirected_',num2str(config.undirected),'SW_',num2str(config.SW),'Prc_',num2str(config.P_rc),'.mat'),...
        'measures','config','quality');
% end


end