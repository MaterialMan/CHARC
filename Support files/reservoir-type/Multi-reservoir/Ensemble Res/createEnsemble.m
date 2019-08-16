function population =createEnsemble(config)

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
        
              
        %assign different activations, if necessary
        if config.multi_activ 
            activ_positions = randi(length(config.activ_list),1,population(pop_indx).nodes(i));
            for act = 1:length(activ_positions)
                population(pop_indx).activ_Fcn{i,act} = config.activ_list{activ_positions(act)};
            end
        else
            population(pop_indx).activ_Fcn = config.activ_list;   
        end
        
        population(pop_indx).last_state{i} = zeros(1,population(pop_indx).nodes(i));
    end
    
    %track total nodes in use
    population(pop_indx).total_units = 0;
    
    
    %% weights and connectivity of all reservoirs
    for i= 1:config.num_reservoirs
        
        for j= 1:config.num_reservoirs
            
            if i==j
                population(pop_indx).connectivity(i,j) =  10/population(pop_indx).nodes(i);%max([10/population(indx).nodes(i) rand]);
                
                internal_weights = sprand(population(pop_indx).nodes(i), population(pop_indx).nodes(i), population(pop_indx).connectivity(i,j));
                internal_weights(internal_weights ~= 0) = ...
                    internal_weights(internal_weights ~= 0)  - 0.5;
                
                % assign scaling for inner weights
                population(pop_indx).W_scaling(i,j) = rand;
                population(pop_indx).W{i,j} = internal_weights;
            else
                population(pop_indx).W{i,j} = 0;
            end
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