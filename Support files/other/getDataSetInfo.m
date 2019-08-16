%% Define additional params for particular reservoirs and tasks
% overflow for params that can be changed
function [config,figure3,figure4] = getDataSetInfo(config)
                         
figure3= 0; figure4 = 0;
if ~isfield(config,'nsga2')
    config.task_num_inputs = size(config.train_input_sequence,2);
    config.task_num_outputs = size(config.train_output_sequence,2);
end

%% Network details
config.num_reservoirs = length(config.num_nodes);% num of subreservoirs. Default ESN should be 1.
config.leak_on = 1;                           % add leak states
config.add_input_states = 1;                  %add input to states
config.sparse_input_weights = 0;              % use sparse inputs
config.evolve_output_weights = 0;             % evolve rather than train

%config.activeFcn = 'tanh';                   % default activation function
config.multi_activ = 0;                      % use different activation funcs
config.activ_list = {'tanh'};                % what activations are in use when multiActiv = 1
config.training_type = 'Ridge';              % blank is psuedoinverse. Other options: Ridge, Bias,RLS

%% change/add parameters depending on reservoir type
switch(config.res_type)
    
    case 'ELM'
        config.leak_on = 0;                           % add leak states

    case 'BZ'
        config.plot_BZ =0;
        config.fft = 0;
        config.BZ_figure1 = figure;
        config.BZ_figure2 = figure;
        
    case 'Graph'
        config.graph_type= 'fullLattice';            % Define substrate
        % Examples: 'Hypercube','Cube'
        % 'Torus','L-shape','Bucky','Barbell','Ring'
        % 'basicLattice','partialLattice','fullLattice','basicCube','partialCube','fullCube',ensembleLattice,ensembleCube,ensembleShape
        
        % node details and connectivity
        config.nearest_neighbour = 0;           % choose radius of nearest neighbour, or set to 0 for direct neighbour.
%        config.directed_graph = 0;               % directed graph (i.e. weight for all directions).
        config.self_loop = 1;                   % give node a loop to self.
        config = getShape(config);              % call function to make graph.
        figure3= figure;
        
    case 'DNA'
        config.tau = 20;                         % settling time
        config.step_size = 1;                   % step size for ODE solver
        config.concat_states = 0;                % use all states
        
    case 'RBN'
        config.k = 2;
        config.mono_rule = 1;
        
        mode = 'DGARBN';
        switch mode
            case 'CRBN'
                config.RBNtype = @evolveCRBN;
            case 'ARBN'
                config.RBNtype = @evolveARBN;
            case 'DARBN'
                config.RBNtype = @evolveDARBN;
            case 'GARBN'
                config.RBNtype = @evolveGARBN;
            case 'DGARBN'
                config.RBNtype = @evolveDGARBN;
            otherwise
                error('Unknown update mode. Type ''help displayEvolution'' to see supported modes')
        end
        
    case 'basicCA'
        % update type
        config.RBN_type = @evolveCRBN;
        config.mono_rule = 0;               %stick to rule rule set, individual cells cannot have different rules
        
        % Define CA connectivity
        A = ones(config.num_nodes);
        B = tril(A,-2);
        C = triu(A, 2);
        D = B + C;
        D(1,config.num_nodes) = 0;
        D(config.num_nodes,1) = 0;
        D(find(D == 1)) = 2;
        D(find(D == 0)) = 1;
        D(find(D == 2)) = 0;
        config.conn = initConnections(D);
        
        % define rules - 2 cell update
        for i=1:config.num_nodes
            rules(:,i) = [1 0 1 0 0 1 0 1]';
        end
        config.rules = initRules(rules);
        
    case '2dCA'
        % update type
        mode = 'CRBN';
        
        switch mode
            case 'CRBN'
                config.RBNtype = @evolveCRBN;
            case 'ARBN'
                config.RBNtype = @evolveARBN;
            case 'DARBN'
                config.RBNtype = @evolveDARBN;
            case 'GARBN'
                config.RBNtype = @evolveGARBN;
            case 'DGARBN'
                config.RBNtype = @evolveDGARBN;
        end
        
        config.mono_rule = 1;                   %stick to rule rule set, individual cells cannot have different rules
        config.rule_type = 'Moores';
        
        % Define CA connectivity
        config.graph_type= 'fullLattice';    % Define substrate
        config.self_loop = 1;                   % give node a loop to self.
        config.directed_graph = 0;               % directed graph (i.e. weight for all directions).
                    
        % define rules
        switch(config.rule_type)
            case 'Moores'
%                 switch(config.lattice_type)
%                     case 'fullCube'
%                         config.num_nodes = config.N_Grid.^3;
%                         %                     base_rule = round(rand(1,2^(8*3+1)))';
%                     case 'fullLattice'
%                         config.num_nodes = config.N_Grid*config.N_rings;
%                         base_rule = round(rand(1,2^9))';
%                     case 'ensembleLattice'
%                         config.num_nodes = config.NGrid*config.N_rings * config.num_ensemble;
%                         base_rule = round(rand(1,2^9))';
%                     case 'ensembleCube'
%                         config.num_nodes = config.N_Grid.^3 * config.num_ensemble;
%                         %                     base_rule = round(rand(1,2^(8*3+1)))';
%                 end
                
                for i=1:config.num_nodes
                    if  config.mono_rule
                        rules(:,i) = base_rule;
                    else
                        rules(:,i) =round(rand(1,length(base_rule)))';
                    end
                end
                
                
            case 'VonNeu'
%                 switch(config.lattice_type)
%                     case 'basicCube'
%                         config.maxMinorUnits = config.N_Grid.^3;
%                     case 'basicLattice'
%                         config.maxMinorUnits = config.N_Grid*config.N_rings;
%                 end
                
                base_rule = round(rand(1,2^5))';
                for i=1:config.num_nodes
                    if  config.mono_rule
                        rules(:,i) = base_rule;
                    else
                        rules(:,i) = round(rand(1,2^5))';
                    end
                end
        end
        
        config = getShape(config);              % call function to make graph.
        config.rules = initRules(rules);
        
    case 'DL'
        
        config.preprocess = 0;
        
    otherwise
        
end


%% Task parameters
switch(config.dataset)
    
    case 'autoencoder'
        config.leak_on = 0;                          % add leak states
        config.add_input_states = 0;
        figure3= figure; figure4 = figure;
        config.sparse_input_weights = 0;
        
    case 'poleBalance'
        config.time_steps = 1000;
        config.simple_task = 2;
        config.pole_tests = 3;
        config.velocity = 1;
        config.run_sim = 0;
        config.testFcn = @poleBalance;
        config.evolve_output_weights = 1;
        
    case 'robot'
        % type of task
        config.robot_behaviour = 'explore_maze';    %select behaviour/file to simulate
        config.time_steps = 1500;                    % sim time
        %sensors
        config.sensor_range = 0.5;                 % range of lidar
        config.evolve_sensor_range = 0;             % use leakRate parameter as proxy for sensor range (evolvable)
        config.sensor_radius = 2*pi;
        % sim parameters
        config.run_sim = 0;                          % whether to run/watch sim
        config.robot_tests = 2;                     % how many tests to conduct: to provide avg fitness
        config.show_robot_tests = 2;                % how many tests to watch/check visually
        config.sim_speed = 5;                       % speed of sim result/visualisation. e.g. if =2, 2x speed
        config.testFcn = @robot;                    % assess fcn for robot tasks
        config.evolve_output_weights = 1;             % must be on; unsupervised/reinforcement problem
        config.figureHandle = figure;               % fig for sim
        %environment
        config.bounds_x = 5;                        % scaler for extending bounds of environment
        config.bounds_y = 5;
        config.num_obstacles = 0;                   % number of obstacles to place in environment
        config.num_target_points = 1000;            % grid of target points used for fitness calculation
        config.maze_size = 5;                       % if maze, the size and complexity of maze
        % Go to selectDataset.m to change num_sensors
        
    case 'CPPN'
        config.leak_on = 0;                          % add leak states
        config.add_input_states = 0;                  % add input to states
        config.sparse_input_weights = 0;              % use sparse inputs
        config.evolve_output_weights = 1;             % evolve rather than train
        
        config.multi_activ = 1;                      % use different activation funcs
        config.activ_list = {'tanh','linearNode','sawtooth','symFcn','sin','cos','gaussDist'};

    otherwise
        
end


