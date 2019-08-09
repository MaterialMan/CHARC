function population = createCNT(config)

%setup DAQ cards
[read_session,switch_session] = createDaqSessions(0:config.num_output_electrodes-1,0:config.num_input_electrodes-1);

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
    
    population(pop_indx).read_session = read_session;
    population(pop_indx).switch_session = switch_session;
    
    % iterate through subreservoirs
    for i = 1:config.num_reservoirs
        
        %define num of units
        population(pop_indx).nodes(i) = config.num_nodes(i);
        
        % Scaling and leak rate
        population(pop_indx).input_scaling(i) = config.volt_range*2*rand-config.volt_range; %increases nonlinearity
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
        
                     
        population(pop_indx).last_state{i} = zeros(1,population(pop_indx).nodes(i));
    end
    
    %track total nodes in use
    population(pop_indx).total_units = 0;
    
    
    %% weights and connectivity of all reservoirs
     for i= 1:config.num_reservoirs
         
         population(pop_indx).electrode_type(i,:) = zeros(population(pop_indx).nodes(i),1);
         population(pop_indx).electrode_type(i,randi([1 population(pop_indx).nodes(i)])) = 1;
         
         population(pop_indx).config_voltage(i,:) = 2*rand(population(pop_indx).nodes(i),1)-1;
         
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