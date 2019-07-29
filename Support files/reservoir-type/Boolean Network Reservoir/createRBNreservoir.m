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
        population(pop_indx).nodes(i) = config.num_nodes(i);
        
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
    
        population(pop_indx).input_location{i} = round(rand(1,population(pop_indx).nodes(i)));
    
    end
    
    %track total nodes in use
    population(pop_indx).total_units = 0;
        
    %% weights and connectivity of all reservoirs
    for i= 1:config.num_reservoirs
               
        switch(config.res_type)
            
            case 'elementary_CA'

                % Define CA connectivity
                A = ones(population(pop_indx).nodes(i));
                B = tril(A,-2);
                C = triu(A, 2);
                D = B + C;
                D(1,config.num_nodes) = 0;
                D(config.num_nodes,1) = 0;
                D(find(D == 1)) = 2;
                D(find(D == 0)) = 1;
                D(find(D == 2)) = 0;
                CA_W{i}=D;
                
                population(pop_indx).initial_states{i} = round(rand(population(pop_indx).nodes(i),1));
                % pick random rule
                rules = repmat(round(rand(8,1)),1,population(pop_indx).nodes(i));
                population(pop_indx).rules{i} = initRules(rules);
                population(pop_indx).RBN_node{i} = initNodes(population(pop_indx).nodes(i),population(pop_indx).initial_states{i},zeros(population(pop_indx).nodes(i),1),zeros(population(pop_indx).nodes(i),1));
                %
            case '2D_CA'
                
                %         population(pop_indx).conn = zeros(config.maxMinorUnits); %needs to be sparse
                %         population(pop_indx).G = config.G;
                %         population(pop_indx).G.Edges.Weight = 2*rand(size(genotype(res).G.Edges,1),1)-1;
                %         A = table2array(genotype(res).G.Edges);
                %         for j = 1:size(genotype(res).G.Edges,1)
                %             genotype(res).conn(A(j,1),A(j,2)) = 1;%A(j,3);
                %             genotype(res).conn(A(j,2),A(j,1)) = 1;%A(j,3);
                %         end
                %         population(pop_indx).conn = sparse(genotype(res).conn);
                %
                %         population(pop_indx).initialStates = round(rand(config.maxMinorUnits,1));
                %         population(pop_indx).rules = config.rules;
                %         population(pop_indx).node = initNodes(genotype(res).size,genotype(res).initialStates,zeros(genotype(res).size,1),zeros(genotype(res).size,1));
                %
            otherwise
                
                population(pop_indx).RBN_node{i} = initNodes(population(pop_indx).nodes(i));
                %population(pop_indx).W{i} = initConnections(population(pop_indx).nodes(i), config.k);
                if config.mono_rule
                     population(pop_indx).rules{i} = int8(repmat(round(rand(2^config.k,1)),1,population(pop_indx).nodes(i)));
                else
                    population(pop_indx).rules{i} = initRules(population(pop_indx).nodes(i), config.k);
                end
        end
        

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
                        population(pop_indx).W{i,j} = CA_W{i};
                        
                    case '2D_CA'
                            
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
