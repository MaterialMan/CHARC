function population = createDNAreservoir(config)

%% Reservoir Parameters
for pop_indx = 1:config.pop_size
    
    % add performance records
    population(pop_indx).train_error = 1;
    population(pop_indx).val_error = 1;
    population(pop_indx).test_error = 1;
    
    % add single bias node
    population(pop_indx).bias_node = 1;
    
    % assign input/output count
    if isempty(config.train_input_sequence)
        population(pop_indx).n_input_units = 1;
        population(pop_indx).n_output_units = 1;
    else
        population(pop_indx).n_input_units = size(config.train_input_sequence,2);
        population(pop_indx).n_output_units = size(config.train_output_sequence,2);
    end
    
    % iterate through subreservoirs
    for i = 1:config.num_reservoirs
        
        %define num of units
        population(pop_indx).nodes(i) = config.num_nodes(i);
        
        
        % Scaling and leak rate
        population(pop_indx).input_scaling(i) = 2*rand-1; %increases nonlinearity
        population(pop_indx).leak_rate(i) = rand;
        
        
        %inputweights
        if config.sparse_input_weights
            input_weights = sprand(population(pop_indx).nodes(i),  population(pop_indx).n_input_units+1, 0.1);
            input_weights(input_weights ~= 0) = ...
                2*input_weights(input_weights ~= 0)  - 1;
            population(pop_indx).input_weights{i} = input_weights;
        else
            population(pop_indx).input_weights{i} = 2*rand(population(pop_indx).nodes(i),  population(pop_indx).n_input_units+1)-1;
        end
        
        %add other necessary parameters
        % e.g., population(pop_indx).param1(i) = rand
        population(pop_indx).Beta(i) = 5e-7;                      % is the reaction rate constant; ? = 5 × 10-7 nM s-1
        population(pop_indx).e(i) = 8.8750e-11;                   %e is the efflux rate; e = 8.8750×10-2 nL s-1
        population(pop_indx).H(i) = 0.7849;                       % h the fraction of the reactor chamber that is well-mixed; h = 0.7849
        population(pop_indx).V(i) = 7.54e-9;                      % volume of the reactor; V = 7.54 nL
        population(pop_indx).tau(i) = config.tau;                         % time step
        population(pop_indx).GateCon{i} = repmat(2500,population(pop_indx).nodes(i),1);      % gate concentrations, nM Units
        %population(pop_indx).washout(i) = 500;                                    %intial washout period for system
        population(pop_indx).Sm0{i} = repmat(5.45e-6,population(pop_indx).nodes(i),1);       %initial base concentrations, nmol
        
        %initial concentrations
        population(res).S0{i} = [1000 zeros(1,population(pop_indx).nodes(i)-1)];
        population(res).P0{i} = zeros(1,population(pop_indx).nodes(i));
        
        population(pop_indx).last_state{i} = zeros(1,population(pop_indx).nodes(i));
        
    end
    
    %% weights and connectivity of all reservoirs
    for i= 1:config.num_reservoirs
        
        for j= 1:config.num_reservoirs
            
            % If used, add internal connectivity weights 'W{i==j}' of networks here
            
            % Assign scaling for inner weights here, e.g. 'W_scaling(i) = rand'
            
            % If multiple reservoirs are connected, add connectivity weight matrix
            % `W{i!=j}` here. This should be place in off-diagnal positions
            
            
        end
        % count total nodes including sub-reservoir nodes
        population(pop_indx).total_units = population(pop_indx).total_units + population(pop_indx).nodes(i);
    end
    
    
    % Add random output weights - these are typically trained for tasks but
    % can be evolved as well
    if config.add_input_states
        population(pop_indx).output_weights = 2*rand(population(pop_indx).total_units + population(pop_indx).n_input_units, population(pop_indx).n_output_units)-1;
    else
        population(pop_indx).output_weights = 2*rand(population(pop_indx).total_units, population(pop_indx).n_output_units)-1;
    end
    
    % Add placeholder for behaviours
    population(pop_indx).behaviours = [];
    
end