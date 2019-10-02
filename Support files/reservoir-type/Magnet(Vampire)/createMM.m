function population = createMM(config)


%% Reservoir Parameters
for pop_indx = 1:config.pop_size
    
    % add performance records
    population(pop_indx).train_error = 1;
    population(pop_indx).val_error = 1;
    population(pop_indx).test_error = 1;
    
    
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
        
        population(pop_indx).system_size(i) = population(pop_indx).nodes(i);
        
        %% global params
        population(pop_indx).input_scaling{i}= rand; % not sure about range?
        population(pop_indx).leak_rate{i} = rand;
        
        %% Input params
        % set positions of magnetic sources. Need maxpos > minpos
        num_input_loc = 2;
        population(pop_indx).minpos{i} = rand(2, num_input_loc); %[x y]
        %population(pop_indx).minposy = rand(1, num_input_loc);
        
        for pos_i = 1:num_input_loc
            population(pop_indx).maxpos{i}(:,pos_i) = population(pop_indx).minpos{i}(:,pos_i)+0.1+(0.9-population(pop_indx).minpos{i}(:,pos_i))*rand; % +0.1 to ensure at least 1 cell is covered
            %    population(pop_indx).maxposy(pos_i) = population(pop_indx).minposy(pos_i)+0.1+(0.9-population(pop_indx).minposy(pos_i))*rand;
        end
        
        population(pop_indx).input_weights{i}= rand(num_input_loc,population(pop_indx).n_input_units); % set random field strength
        
        population(pop_indx).last_state{i} = zeros(1,population(pop_indx).nodes(i));

        %% magnet params
        if config.damping_parameter == 'dynamic' % random damping s.t. chance of small range 0.01-0.1 = chance of large range 0.1-1
            if rand < 0.5
                population(pop_indx).damping(i) = 0.01 + (0.1-0.01)*rand;
            else
                population(pop_indx).damping(i) = 0.1 + (1-0.1)*rand;
            end
        else
            population(pop_indx).damping(i) = config.damping_parameter;
        end
        
        if config.anisotropy_parameter == 'dynamic' % random anisotropy s.t. chance of small range 1e-25-1e-24 = chance of large range 1e-24-1e-23
            if rand < 0.5
                population(pop_indx).anisotropy(i) = 1e-25 + (1e-24-1e-25)*rand;
            else
                population(pop_indx).anisotropy(i) = 1e-24 + (1e-23-1e-24)*rand;
            end
        else
            population(pop_indx).anisotropy(i) = config.anisotropy_parameter;
        end
        
        if config.temperature_parameter == 'dynamic'
            population(pop_indx).temperature(i) = normrnd(300,50); % Gaussian distribution with mean at room T
            if population(pop_indx).temperature(i) < 0
                population(pop_indx).temperature(i) = 0;
            end
        else
            population(pop_indx).temperature(i) = config.temperature_parameter;
        end
        
        if config.exchange_parameter == 'dynamic' % flat distribution in sensible physical range
            population(pop_indx).exchange(i) = 1e-21 + (10e-21-1e-21)*rand;
        else
            population(pop_indx).exchange(i) = config.exchange_parameter;
        end
        
        if config.magmoment_parameter == 'dynamic' % flat distribution in sensible physical range
            population(pop_indx).magmoment(i) = 0.5 + (7-0.5)*rand;
        else
            population(pop_indx).magmoment(i) = config.magmoment_parameter;
        end
        
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
