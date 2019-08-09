function population = createRBNreservoir(config)


%% Reservoir Parameters
for pop_indx = 1:config.pop_size
    
    % add performance records
    population(pop_indx).train_error = 1;
    population(pop_indx).val_error = 1;
    population(pop_indx).test_error = 1;
    
    % add single bias node
    %population(pop_indx).bias_node = 1;
    
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
        if strcmp(config.res_type,'2D_CA')
            population(pop_indx).nodes(i) = config.num_nodes(i).^2;
        else
            population(pop_indx).nodes(i) = config.num_nodes(i);
        end
        
        % Scaling and leak rate
        population(pop_indx).input_scaling(i) = 2*rand-1; %increases nonlinearity
        population(pop_indx).leak_rate(i) = rand;
        
        %inputweights
        if config.sparse_input_weights
            input_weights = sprand(population(pop_indx).nodes(i),  population(pop_indx).n_input_units, 0.1);
            input_weights(input_weights ~= 0) = ...
                2*input_weights(input_weights ~= 0)  - 1;
            population(pop_indx).input_weights{i} = input_weights;
        else
            population(pop_indx).input_weights{i} = 2*rand(population(pop_indx).nodes(i),  population(pop_indx).n_input_units)-1;
        end
        
        
        %assign different activations, if necessary
        population(pop_indx).RBN_type{i} = config.rule_list{randi([1 length(config.rule_list)])};% more than one rule & evolve config.RBN_type{i};
        
        population(pop_indx).last_state{i} = zeros(1,population(pop_indx).nodes(i));
      
        population(pop_indx).time_period(i) = randi([1 10]);
    end
    
    %track total nodes in use
    population(pop_indx).total_units = 0;
        
    %% weights and connectivity of all reservoirs
    for i= 1:config.num_reservoirs
               
        population(pop_indx).initial_states{i} = round(rand(population(pop_indx).nodes(i),1));
        
        switch(config.res_type)
            
            case 'elementary_CA'

                % Define CA connectivity
                config.graph_type= repmat({'Ring'},1,config.num_reservoirs);     % Define substrate
                config.self_loop = ones(1,config.num_reservoirs);                   % give node a loop to self.
                config = getShape(config);              % call function to make graph.
                
               % population(pop_indx).initial_states{i} = round(rand(population(pop_indx).nodes(i),1));
                % pick random rule
                rules = repmat(round(rand(8,1)),1,population(pop_indx).nodes(i));
                population(pop_indx).rules{i} = initRules(rules);

            case '2D_CA'
                
                % Define CA connectivity
                config.graph_type= repmat({'fullLattice'},1,length(population(pop_indx).nodes));     % Define substrate
                config.self_loop = ones(1,config.num_reservoirs);                   % give node a loop to self.
                %config.directed_graph = 0;               % directed graph (i.e. weight for all directions).
                config = getShape(config);              % call function to make graph.
                
               % population(pop_indx).initial_states{i} = round(rand(population(pop_indx).nodes(i),1));
                % pick random rule
                switch(config.rule_type)
                    case 'Moores' % 9 input RBN
                        if config.mono_rule
                            rules = repmat(round(rand(2^9,1)),1,population(pop_indx).nodes(i));
                        else
                            rules = round(rand(2^9,population(pop_indx).nodes(i)));
                        end
                    case 'VonN' % 5 input RBN
                        if config.mono_rule
                            rules = repmat(round(rand(2^5,1)),1,population(pop_indx).nodes(i));
                        else
                            rules = round(rand(2^5,population(pop_indx).nodes(i)));
                        end
                        
                end
                population(pop_indx).rules{i} = initRules(rules);
             
            otherwise
                
                %population(pop_indx).RBN_node{i} = initNodes(population(pop_indx).nodes(i));
                %population(pop_indx).W{i} = initConnections(population(pop_indx).nodes(i), config.k);
                if config.mono_rule
                     population(pop_indx).rules{i} = int8(repmat(round(rand(2^config.k,1)),1,population(pop_indx).nodes(i)));
                else
                    population(pop_indx).rules{i} = initRules(population(pop_indx).nodes(i), config.k);
                end
        end
        
        %initialise nodes
        population(pop_indx).RBN_node{i} = initNodes(population(pop_indx).nodes(i),population(pop_indx).initial_states{i},randi([1 4],population(pop_indx).nodes(i),1),randi([1 4],population(pop_indx).nodes(i),1));              
                       

        for j= 1:config.num_reservoirs
            
            population(pop_indx).connectivity(i,j) =  10/population(pop_indx).nodes(i); 
            
            internal_weights = sprand(population(pop_indx).nodes(i), population(pop_indx).nodes(j), population(pop_indx).connectivity(i,j));
            internal_weights(internal_weights ~= 0) = ...
                internal_weights(internal_weights ~= 0)  - 0.5;
            
            % assign scaling for inner weights 
            population(pop_indx).W_scaling(i,j) = 2*rand;   
            if i == j
                switch(config.res_type)
                    
                    case 'elementary_CA'
                        population(pop_indx).W{i,j} = full(adjacency(config.G{i}));%CA_W{i};
                        
                    case '2D_CA'
                        population(pop_indx).W{i,j} = full(adjacency(config.G{i}));
                        
                    otherwise
                        population(pop_indx).W{i,j} = initConnections(population(pop_indx).nodes(i), config.k);     
                end
            else
                population(pop_indx).W{i,j} = internal_weights; 
            end
        end    
        
        population(pop_indx).RBN_node{i} = assocRules(population(pop_indx).RBN_node{i}, population(pop_indx).rules{i});
        population(pop_indx).RBN_node{i} = assocNeighbours(population(pop_indx).RBN_node{i}, population(pop_indx).W{i,i});
        
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
