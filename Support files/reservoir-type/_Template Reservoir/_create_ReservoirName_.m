%% create_ReservoirName_.m
% Template function to define reservoir parameters. Use this as a guide when
% creating a new reservoir.
%
% How this function looks at the end depends on the reservoir. However,
% everything below is typically needed to work with all master scripts.
% Tip: Try maintain ordering as structs keep this ordering.

% This is called by the @config.createFcn pointer.

function population = create_ReservoirName_(config)

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
        
        % input weights
        switch(config.input_weight_initialisation)
            case 'norm' % normal distribution
                if config.sparse_input_weights
                    input_weights = sprandn(population(pop_indx).nodes(i),  population(pop_indx).n_input_units+1, 0.1);
                else
                    input_weights = randn(population(pop_indx).nodes(i),  population(pop_indx).n_input_units+1);
                end
            case 'uniform' % uniform dist between -1 and 1
                if config.sparse_input_weights
                    input_weights = sprand(population(pop_indx).nodes(i),  population(pop_indx).n_input_units+1, 0.1);
                    input_weights(input_weights ~= 0) = ...
                        2*input_weights(input_weights ~= 0)  - 1;
                else
                    input_weights = 2*rand(population(pop_indx).nodes(i),  population(pop_indx).n_input_units+1)-1;
                end
        end
        population(pop_indx).input_weights{i} = input_weights;
        
        
        % add other necessary parameters
        % e.g., population(pop_indx).param1(i) = rand
        
        
        % individual should keep track of final state for certain tasks
        population(pop_indx).last_state{i} = zeros(1,population(pop_indx).nodes(i));
    end
    
    %track total nodes in use
    population(pop_indx).total_units = 0;
    
    
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
