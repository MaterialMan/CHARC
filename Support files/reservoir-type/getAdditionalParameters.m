%% Define additional params for particular reservoirs and tasks
% overflow for params that can be changed. This is called by all main scripts
function [config] = getAdditionalParameters(config)

%% Set Default parameters
config.mutate_type = 'gaussian';            %options: 'gaussian', 'uniform'. Type of distribution new weight is chosen from.
config.num_reservoirs = length(config.num_nodes);% num of subreservoirs. Default ESN should be 1.
config.leak_on = 1;                           % add leak states

% define connectivities
config.add_input_states = 1;                  %add input to states
config.sparse_input_weights = 1;              % use sparse inputs
for i = 1:length(config.num_nodes)            % apply to all reservoirs, 0 to 1 sparsity of input weights
    config.sparsity(i) = 1/config.num_nodes(i);
end
config.internal_sparsity = 0.1;
config.input_weight_initialisation = 'norm';     % e.g.,  'norm', 'uniform', 'orth', etc. must be same length as number of subreservoirs
config.connecting_sparsity = 0.1;
config.internal_weight_initialisation = 'norm';  % e.g.,  'norm', 'uniform', 'orth', etc.  must be same length as number of subreservoirs

config.evolve_output_weights = 0;             % evolve rather than train
config.evolve_feedback_weights = 0;             % find suitable feedback weights
config.feedback_weight_initialisation = 'orth';
config.feedback_connectivity = 0.1;

% node functionality
config.multi_activ = 0;                      % use different activation funcs
config.activ_list = {@tanh};                 % what activations are in use -- MUST match number of reservoirs!!
config.training_type = 'Ridge';              % blank is psuedoinverse. Other options: Ridge, Bias,RLS
config.undirected = 0;                       % by default all networks are directed
config.undirected_ensemble = 0;              % by default all inter-network weights are directed

% default reservoir input scale
config.scaler = 1;                          % this may need to change for different reservoir systems that don't fit to the typical neuron range, e.g. [-1 1]
config.discrete = 0;

% preprocessing performed on input data
if strcmp(config.dataset,'test_pulse')
    config.preprocess = 0;
else
    config.preprocess = 'scaling';
end

% simulation details
config.run_sim = 0;
config.film = 0;                            %record simulation

% iir filter params (not currently in use)
config.iir_filter_on = 0;                       % add iir filters to states **not in use yet
config.iir_filter_order = 2 + 1; 

%% Change/add parameters depending on reservoir type
% This section is for additional parameters needed for different reservoir
% types. If something is not here, it is most likely in the
% reservoir-specific @createFcn

res_type = config.res_type;

switch(res_type)
    
    case 'ELM'
        config.leak_on = 1;                           % add leak states
        
    case 'BZ'
        %config.plot_BZ =0;
        config.fft = 0;
        config.sparse_input_weights = 1;
 
        config.evolve_output_weights = 0;             % evolve rather than train
        
    case 'Graph'
        
        config.graph_type= {'fullLattice'};            % Define substrate. Add graph type to cell array for multi-reservoirs
        % Examples: 'Hypercube','Cube'
        % 'Torus','L-shape','Bucky','Barbell','Ring',
        % 'basicLattice','partialLattice','fullLattice','basicCube','partialCube','fullCube',ensembleLattice,ensembleCube,ensembleShape
        config.self_loop = [1];               % give node a loop to self. Must be defined as array.
        
        if length(config.graph_type) ~= length(config.num_nodes) && length(config.self_loop) ~= length(config.num_nodes)
            error('Number of graph types does not match number of reservoirs. Add more.')
        end
        
        % node details and connectivity
        config.SW_type = 'topology';                                % maintain the base topology through evolution
        config.ensemble_graph = 0;                                  % no connections between mutli-graph reservoirs
        [config,config.num_nodes] = getShape(config);               % call function to make graph.
        
    case 'DNA'
        config.tau = 20;                         % settling time
        config.step_size = 1;                   % step size for ODE solver
        config.concat_states = 0;                % use all states
        
    case 'RBN'
        
        config.k = 2; % number of inputs
        config.mono_rule = 1; % use one rule for every cell/reservoir
        config.rule_list = {@evolveCRBN}; %list of evaluation types: {'CRBN','ARBN','DARBN','GARBN','DGARBN'};
        config.leak_on = 0;
        config.discrete = 1;
        
    case 'elementary_CA'
        % update type
        config.k = 3;
        config.mono_rule = 1;               %stick to rule rule set, individual cells cannot have different rules
        config.rule_list = {@evolveCRBN}; %list of evaluation types: {'CRBN','ARBN','DARBN','GARBN','DGARBN'};
        config.leak_on = 0;
        config.discrete = 1;
        config.torus_rings = 1;
        config.rule_type = 0;
        
    case '2D_CA'
        % update type
        config.sparse_input_weights = 1;
        config.mono_rule = 1;               %stick to rule rule set, individual cells cannot have different rules
        config.rule_list = {@evolveCRBN}; %list of evaluation types: {'CRBN','ARBN','DARBN','GARBN','DGARBN'};
        config.leak_on = 0;
        config.rule_type = 'Moores';
        config.discrete = 1;
        config.torus_rings = 1;
        
    case 'DL'
        %     config.DLtype = 'mackey_glass2';%'ELM';%'virtualNodes';
        %     %config.tau = 100;
        config.preprocess = 0;
        config.tau = config.num_nodes.*0.2; % keep 0.2 separation at all sizes
        config.binary_weights = 0;
        
    case 'CNT'
        
        config.volt_range = 5;
        config.num_input_electrodes = 64;
        config.num_output_electrodes = 32;
        config.discrete = 0;
        
    case 'Wave'      
        
        config.leak_on = 1;                           % add leak states
        config.add_input_states = 1;                  %add input to states
        config.sim_speed = 1; % xfactor
        config.time_step = 0.05;
        config.bias_node = 0;
        config.max_time_period = 10;
        % [1 0 0] = fix: All boundary points have a constant value of 1
        % [0 1 0] = cont; Eliminate the wave and bring elements to their steady state.
        % [0 0 1] = connect; Water flows across the edges and comes back from the opposite side
        config.boundary_conditions = {[1 0 0],[0 1 0],[0 0 1]}; %add more as cell, if needed
        config.wave_system = 'ensemble';% type of multi-res system. Choices "ensemble", "fully-connected", "pipeline"
        
        if length(config.num_nodes) == 1
            config.wave_system = 'ensemble'; % no effect on system if one material
        end
        
        
    case 'GOL'
        config.leak_on = 1;                           % add leak states
        config.add_input_states = 1;                  %add input to states
        config.sparse_input_weights = 1;
        config.discrete = 0;
        
    case 'SW'
        
        config.graph_type= {'Ring'};            % Define substrate. Add graph type to cell array for multi-reservoirs
        % Examples: 'Hypercube','Cube'
        % 'Torus','L-shape','Bucky','Barbell','Ring',
        % 'basicLattice','partialLattice','fullLattice','basicCube','partialCube','fullCube',ensembleLattice,ensembleCube,ensembleShape
        config.self_loop = [1];               % give node a loop to self. Must be defined as array.
        
        if length(config.graph_type) ~= length(config.num_nodes) && length(config.self_loop) ~= length(config.num_nodes)
            error('Number of graph types does not match number of reservoirs. Add more in getDataSetInfo.m')
        end
        
        % node details and connectivity
        config.ensemble_graph = 0;                                  % no connections between mutli-graph reservoirs
        config.P_rc = 0.1;                                         % percentage of random connections or connection probability. Used for Small World Networks
        [config,config.num_nodes] = getShape(config);               % call function to make graph.
        
        config.SW_type = 'topology_plus_weights';                    %options: 'topology_plus_weights', 'watts_strogartz'
        
    case 'Pipeline'
        config.add_input_states = 0; 
    otherwise
        
end

%% Task parameters - now apply task-specific parameters
% If a task requires additional parameters, or resetting from defaults, add
% here.
switch(config.dataset)
    
    case 'autoencoder'
        config.leak_on = 0;                          % add leak states
        config.add_input_states = 0;
        config.figure_array = [config.figure_array figure];
        config.sparse_input_weights = 0;
        
    case 'pole_balance'
        config.time_steps = 1000;
        config.simple_task = 2;
        config.pole_tests = 2;
        config.velocity = 1;
        config.run_sim = 0;
        config.testFcn = @poleBalance;
        config.evolve_output_weights = 1;
        config.add_input_states = 0;                  %add input to states
        
    case 'robot'
        % type of task
        config.robot_behaviour = 'explore_maze';    %select behaviour/file to simulate
        config.time_steps = 500;                    % sim time
        %sensors
        config.sensor_range = 0.5;                 % range of lidar
        config.evolve_sensor_range = 0;             % use leakRate parameter as proxy for sensor range (evolvable)
        config.sensor_radius = 2*pi;
        % sim parameters
        config.run_sim = 0;                          % whether to run/watch sim
        config.robot_tests = 1;                     % how many tests to conduct: to provide avg fitness
        config.show_robot_tests = config.robot_tests; % how many tests to watch/check visually
        config.sim_speed = 25;                       % speed of sim result/visualisation. e.g. if =2, 2x speed
        config.testFcn = @robot;                    % assess fcn for robot tasks
        config.evolve_output_weights = 1;             % must be on; unsupervised/reinforcement problem
        
        %environment
        config.bounds_x = 5;                        % scaler for extending bounds of environment
        config.bounds_y = 5;
        config.num_obstacles = 0;                   % number of obstacles to place in environment
        config.num_target_points = 1000;            % grid of target points used for fitness calculation
        config.maze_size = 5;                       % if maze, the size and complexity of maze
        % Go to selectDataset.m to change num_sensors
        
    case 'attractor'
        config.leak_on = 0;                          % add leak states
        config.add_input_states = 0;
        config.figure_array = [config.figure_array figure];
        config.sparse_input_weights = 0;
        
        config.attractor_type = 'lorenz';
        config.evolve_output_weights = 1;
        config.evolve_feedback_weights = 1;
        config.assessFcn = @collectRoRStatesFeedback;
        config.preprocess = 0;
        
    case {'MSO1','MSO2','MSO3','MSO4','MSO5','MSO6','MSO7','MSO8','MSO9','MSO10','MSO11','MSO12'}  %MSO'
        
        config.preprocess = 0;
    otherwise
        
end


