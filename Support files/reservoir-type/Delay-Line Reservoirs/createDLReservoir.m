function population = createDLReservoir(config)


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
    
    %track total nodes in use
    population(pop_indx).total_units = 0;
    
        % iterate through subreservoirs
    for i = 1:config.num_reservoirs
        
        %define num of units
        population(pop_indx).nodes(i) = config.num_nodes(i);

        % Scaling and leak rate
        population(pop_indx).input_scaling(i) = 2*rand-1; %increases nonlinearity
        population(pop_indx).leak_rate(i) = rand;
        
        % mackey glass parameters: eta, gamma and p must be > 0
        population(pop_indx).eta(i) = rand;
        population(pop_indx).gamma(i) = rand;
        population(pop_indx).p(i) = randi([1 20]);
        population(pop_indx).x0(i) = 0; % initial value
        population(pop_indx).T(i) = 1; %time-scale of node
        population(pop_indx).time_step(i) = 0.1;
        
        % set reservoir specific parameters round(20*rand);
        population(pop_indx).tau(i) = config.tau(i); % length of delay line
        population(pop_indx).theta(i) = population(pop_indx).tau(i)/population(pop_indx).nodes(i); % distance between virtual nodes
                     
        
       %inputweights - MASK for DL, binary weights either [-0.1,0.1]
       if config.sparse_input_weights
           input_weights = sprand(population(pop_indx).nodes(i),  population(pop_indx).n_input_units, 0.1);
           input_weights(input_weights ~= 0) = ...
               2*input_weights(input_weights ~= 0)  - 1;
           if config.binary_weights
                population(pop_indx).input_weights{i} = sign(input_weights);
           else
               population(pop_indx).input_weights{i} = input_weights;
           end
       else      
           if config.binary_weights
                population(pop_indx).input_weights{i} = (sign(rand(population(pop_indx).nodes(i),  population(pop_indx).n_input_units)-0.5));
           else
                population(pop_indx).input_weights{i} = (2*rand(population(pop_indx).nodes(i),  population(pop_indx).n_input_units)-1);
           end
       end
          
        population(pop_indx).last_state{i} = zeros(1,population(pop_indx).nodes(i));
    
        population(pop_indx).total_units = population(pop_indx).total_units + population(pop_indx).nodes(i); 
    end
    

    % add rand output weights
    if config.add_input_states
        population(pop_indx).output_weights = 2*rand(population(pop_indx).total_units + population(pop_indx).n_input_units, population(pop_indx).n_output_units)-1;      
    else
        population(pop_indx).output_weights = 2*rand(population(pop_indx).total_units, population(pop_indx).n_output_units)-1;
    end
    
    population(pop_indx).behaviours = [];
end