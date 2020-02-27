%% createGOL.m
% function to define Game of Life reservoir parameters. 

% This is called by the @config.createFcn pointer.

function population = createGOL(config)

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
        population(pop_indx).nodes(i) = config.num_nodes(i).^2;
        
        % Scaling and leak rate
        population(pop_indx).input_scaling(i) = 2*rand-1; %increases nonlinearity
        population(pop_indx).leak_rate(i) = rand;
        
        % input weights
        if config.sparse_input_weights
            input_weights = sprand(population(pop_indx).nodes(i),  population(pop_indx).n_input_units+1, 0.005);
            input_weights(input_weights ~= 0) = ...
                2*input_weights(input_weights ~= 0)  - 1;
            population(pop_indx).input_weights{i} = input_weights;
            
            widths = ceil(abs(randn(length(input_weights),1))*2); %less likely to get big inputs
            widths(widths > round(sqrt(population(pop_indx).nodes(i))/8)) = round(sqrt(population(pop_indx).nodes(i))/8);% cap at 1/6 size of space 
            population(pop_indx).input_widths{i} = widths; %size of the inputs; pin-point or broad
        else
            population(pop_indx).input_weights{i} = 2*rand(population(pop_indx).nodes(i),  population(pop_indx).n_input_units+1)-1;
        end
         
        
        % add other necessary parameters
        % e.g., population(pop_indx).param1(i) = rand
        population(pop_indx).time_period(i) = randi([1 5]);
       
        population(pop_indx).boundary_condition(i) = randi([1 3])-1; 
        
        %population(pop_indx).survival_threshold(i) = randi([0 5]); %an alive cell live if it has n alive neighbors
        population(pop_indx).birth_threshold(i) = randi([1 5]); % a dead cell will be alive if it has n alive neighbors, Conways: 3
        population(pop_indx).loneliness_threshold(i) = randi([1 5]); %alive cell dies if it has n alive neighbors, Conways: 1
        population(pop_indx).overcrowding_threshold(i) = randi([1 5]); %alive cell dies if it has n or more alive neighbors, Conways: 4
        
        % for convolve state filters
        population(pop_indx).pad_size(i) = randi([1 10]);
        population(pop_indx).stride(i) = randi([1 10]);
        population(pop_indx).kernel_size(i) = randi([1 10]);
        population(pop_indx).kernel{i} = ones(population(pop_indx).kernel_size(i))/population(pop_indx).kernel_size(i)^2; % summation filter
              
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
