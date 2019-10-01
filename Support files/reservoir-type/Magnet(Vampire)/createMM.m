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
    
    if config.damping_parameter == 'dynamic' % random damping s.t. chance of small range 0.01-0.1 = chance of large range 0.1-1
        if rand < 0.5 
            population(pop_indx).damping = 0.01 + (0.1-0.01)*rand;
        else
            population(pop_indx).damping = 0.1 + (1-0.1)*rand;
        end
    else
        population(pop_indx).damping = config.damping_parameter;
    end
    
    if config.anisotropy_parameter == 'dynamic' % random anisotropy s.t. chance of small range 1e-25-1e-24 = chance of large range 1e-24-1e-23
        if rand < 0.5 
            population(pop_indx).anisotropy = 1e-25 + (1e-24-1e-25)*rand;
        else
            population(pop_indx).anisotropy = 1e-24 + (1e-23-1e-24)*rand;
        end
    else
        population(pop_indx).anisotropy = config.anisotropy_parameter;
    end
    
    if config.temperature_parameter == 'dynamic'
        population(pop_indx).temperature = normrnd(300,50); % Gaussian distribution with mean at room T
        if population(pop_indx).temperature < 0
            population(pop_indx).temperature = 0;
        end
    else
        population(pop_indx).temperature = config.temperature_parameter;
    end
    
    if config.exchange_parameter == 'dynamic' % flat distribution in sensible physical range
        population(pop_indx).exchange = 1e-21 + (10e-21-1e-21)*rand;
    else
        population(pop_indx).exchange = config.exchange_parameter;
    end

    if config.magmoment_parameter == 'dynamic' % flat distribution in sensible physical range
        population(pop_indx).magmoment = 0.5 + (7-0.5)*rand;
    else
        population(pop_indx).magmoment = config.magmoment_parameter;
    end
    
    population(pop_indx).total_units = config.num_nodes;
    
    % set positions of magnetic sources. Need maxpos > minpos
    population(pop_indx).minposx = rand(1, 2);
    population(pop_indx).maxposx(1) = population(pop_indx).minposx(1)+0.1+(0.9-population(pop_indx).minposx(1))*rand; % +0.1 to ensure at least 1 cell is covered
    population(pop_indx).maxposx(2) = population(pop_indx).minposx(2)+0.1+(0.9-population(pop_indx).minposx(2))*rand;
    population(pop_indx).minposy = rand(1, 2);
    population(pop_indx).maxposy(1) = population(pop_indx).minposy(1)+0.1+(0.9-population(pop_indx).minposy(1))*rand;
    population(pop_indx).maxposy(2) = population(pop_indx).minposy(2)+0.1+(0.9-population(pop_indx).minposy(2))*rand;
    
    population(pop_indx).signalmagnitude = rand(1,2); % set random field strength
    
    % add rand output weights
    if config.add_input_states
        population(pop_indx).output_weights = 2*rand(population(pop_indx).total_units + population(pop_indx).n_input_units, population(pop_indx).n_output_units)-1;      
    else
        population(pop_indx).output_weights = 2*rand(population(pop_indx).total_units, population(pop_indx).n_output_units)-1;
    end
    
    population(pop_indx).behaviours = [];
    
end
