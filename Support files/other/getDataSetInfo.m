%% Define additional params for particular reservoirs and tasks
function [config,figure3,figure4] = getDataSetInfo(config)

%% overflow for params that can be changed
figure3= 0; figure4 = 0;
if ~config.nsga2
    config.task_num_inputs = size(config.trainInputSequence,2);
    config.task_num_outputs = size(config.trainOutputSequence,2);
end

%% ESN params
config.startFull = 1;                       % start with max network size
config.alt_node_size = 0;                   % allow different network sizes
config.multiActiv = 0;                      % use different activation funcs
config.rand_connect = 1;                    % randomise networks
config.activList = {'sign'};   % what activations are in use when multiActiv = 1
config.trainingType = 'Ridge';              % blank is psuedoinverse. Other options: Ridge, Bias,RLS


%% ELM params
if strcmp(config.resType,'ELM')
    config.topology = 'standard';
    config.startFull = 1;                       % start with max network size
    config.alt_node_size = 0;                   % allow different network sizes
    config.activeFcn = 'tanh';
    config.multiActiv = 0;                      % use different activation funcs
    config.activList = {'tanh';'linearNode'};   % what activations are in use when multiActiv = 1
    config.trainingType = 'Ridge';              % blank is psuedoinverse. Other options: Ridge, Bias,RLS
    config.allStates = 1;                       % use all states of neurons (1) or only final layer (0)
    config.gaussWeights = 0;                    % use gaussian weights (1) or uniform dist (0)
end

%% Bz reservoir
if strcmp(config.resType,'BZ')
    config.plotBZ =0;
    config.fft = 0;
    config.BZfigure1 = figure;
    config.BZfigure2 = figure; 
end

%% Graph params
if strcmp(config.resType,'Graph')
    
    config.substrate= 'Lattice';            % Define substrate
    % Examples: 'Lattice', 'Hypercube',
    % 'Torus','L-shape','Bucky','Barbell','Ring'
    
    config.NGrid = config.maxMinorUnits;    % Number of nodes
    config.num_ensemble = 1;                % number of lattices
    
    % substrate params
    config.N_rings = config.maxMajorUnits;     % used with Torus     
    config.latticeType = 'fullCube';        % see creatLattice.m for different types.
    config.ruleType = config.latticeType;       % used with Torus, 5 neighbours (Von Neumann) or 8 neighbours (Moore's)
    
    % Examples: 'basicLattice','partialLattice','fullLattice','basicCube','partialCube','fullCube',
    
    % node details and connectivity
    config.actvFunc = 'tanh';               % decide activation fcn of node.
    config.plotStates = 0;                  % plot states in real-time.
    config.nearest_neighbour = 0;           % choose radius of nearest neighbour, or set to 0 for direct neighbour.
    config.directedGraph = 0;               % directed graph (i.e. weight for all directions).
    config.self_loop = 1;                   % give node a loop to self.
    config.inputEval = 0;                   % add input directly to node, otherwise node takes inputs value.
    config = getShape(config);              % call function to make graph.
    config.globalParams = 1;                % add global scaling parameters and leakrate
    figure3= figure;
    
    config.maxMinorUnits = config.N;
end

%% DNA reservoir
if strcmp(config.resType,'DNA')
    config.tau = 20;                         % settling time
    config.step_size = 1;                   % step size for ODE solver 
    config.concatStates = 0;                % use all states
end

%% RBN reservoir
if strcmp(config.resType,'RBN')
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
end

%% 1-D CA reservoir
if strcmp(config.resType,'basicCA')
    % update type 
    config.RBNtype = @evolveCRBN;
    config.mono_rule = 0;               %stick to rule rule set, individual cells cannot have different rules
    
    % Define CA connectivity
    A = ones(config.maxMinorUnits);
    B = tril(A,-2);
    C = triu(A, 2);
    D = B + C;
    D(1,config.maxMinorUnits) = 0;
    D(config.maxMinorUnits,1) = 0;
    D(find(D == 1)) = 2;
    D(find(D == 0)) = 1;
    D(find(D == 2)) = 0;
    config.conn = initConnections(D);
    
    % define rules - 2 cell update
    for i=1:config.maxMinorUnits
        rules(:,i) = [1 0 1 0 0 1 0 1]';
    end
    config.rules = initRules(rules);
end

%% 2-D CA reservoir
if strcmp(config.resType,'2dCA')
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
    config.ruleType = 'Moores';
    
    % Define CA connectivity
    config.substrate= 'Lattice';    % Define substrate
    config.latticeType = 'fullLattice';        % must be 'full' for Moores and 'basic' for vonNeumann
    config.self_loop = 1;                   % give node a loop to self.
    config.directedGraph = 0;               % directed graph (i.e. weight for all directions).
    config.num_ensemble = 1;                % number of lattices
    config.NGrid = config.maxMinorUnits;    % Number of nodes
    
    % substrate params
    config.N_rings = config.maxMinorUnits;  % used with Torus  

    % define rules 
    switch(config.ruleType)
        case 'Moores'
            switch(config.latticeType)
                case 'fullCube'
                    config.maxMinorUnits = config.NGrid.^3;
%                     base_rule = round(rand(1,2^(8*3+1)))';
                case 'fullLattice'
                    config.maxMinorUnits = config.NGrid*config.N_rings;
                    base_rule = round(rand(1,2^9))';
                case 'ensembleLattice'
                    config.maxMinorUnits = config.NGrid*config.N_rings * config.num_ensemble;
                    base_rule = round(rand(1,2^9))';
                case 'ensembleCube'
                    config.maxMinorUnits = config.NGrid.^3 * config.num_ensemble;
%                     base_rule = round(rand(1,2^(8*3+1)))';
            end
 
            for i=1:config.maxMinorUnits
                if  config.mono_rule
                    rules(:,i) = base_rule;
                else
                    rules(:,i) =round(rand(1,length(base_rule)))';
                end
            end
            
        case 'VonNeu'
            switch(config.latticeType)
                case 'basicCube'
                    config.maxMinorUnits = config.NGrid.^3;
                case 'basicLattice'
                    config.maxMinorUnits = config.NGrid*config.N_rings;
            end
            
            base_rule = round(rand(1,2^5))';
            for i=1:config.maxMinorUnits
                if  config.mono_rule
                    rules(:,i) = base_rule;
                else
                    rules(:,i) = round(rand(1,2^5))';
                end
            end
    end
      
    config = getShape(config);              % call function to make graph.
    config.rules = initRules(rules);
end

%% delay-line reservoirs
% if strcmp(config.resType,'DL')
%     config.DLtype = 'mackey_glass2';%'ELM';%'virtualNodes';
%     %config.tau = 100;
% end

%% Task bottom of list
if strcmp(config.dataSet,'autoencoder')
    config.leakOn = 0;                          % add leak states
    config.AddInputStates = 0; 
    figure3= figure; figure4 = figure;
    config.sparseInputWeights = 0;
end
  
if strcmp(config.dataSet,'poleBalance')
    config.time_steps = 300;
    config.simpleTask = 2;
    config.pole_tests = 10;
    config.velocity = 1;
    config.runSim = 0;
    config.testFcn = @poleBalance;
    config.evolveOutputWeights = 1;
end

if strcmp(config.dataSet,'BinaryNbitAdder')   
    if strcmp(config.resType,'Graph')
        %config.directedGraph = 1;               % directed graph (i.e. weight for all directions).
        %config.self_loop = 1;
    end
end

