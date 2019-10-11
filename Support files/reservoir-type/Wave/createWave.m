function population = createWave(config)


%% Reservoir Parameters
for pop_indx = 1:config.pop_size

    % add performance records
    population(pop_indx).train_error = 1;
    population(pop_indx).val_error = 1;
    population(pop_indx).test_error = 1;
    
    % add single bias node
    population(pop_indx).bias_node = 0;
    
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
        
        %addtional paramters
        population(pop_indx).time_period(i) = randi([1 10]);
        population(pop_indx).wave_speed(i) = randi([1 12]);
        population(pop_indx).damping_constant(i) = rand;
        population(pop_indx).time_step(i) = 0.05;
        
        % fix = 1: All boundary points have a constant value of 1
        % cont = 1; Eliminate the wave and bring elements to their steady state.
        % connect = 1; Water flows across the edges and comes back from the opposite side
        bc = zeros(1,3); bc(randi([1 3])) = 1;
        population(pop_indx).boundary_conditions(i,:) = bc;
        
        
       %inputweights
       input_weights = sprand(population(pop_indx).nodes(i),  population(pop_indx).n_input_units+1, 0.01);
       input_weights(input_weights ~= 0) = ...
           2*input_weights(input_weights ~= 0)  - 1;
       population(pop_indx).input_weights{i} = input_weights;
       
       widths = ceil(abs(randn(length(input_weights),1))*2); %less likely to get big inputs
            widths(widths > round(sqrt(population(pop_indx).nodes(i))/8)) = round(sqrt(population(pop_indx).nodes(i))/8);% cap at 1/6 size of space 
            population(pop_indx).input_widths{i} = widths; %size of the inputs; pin-point or broad
       
        population(pop_indx).last_state{i} = zeros(2,population(pop_indx).nodes(i));
    end
    
    %track total nodes in use
    population(pop_indx).total_units = 0;
       
    %% weights and connectivity of all reservoirs - not currently is use!!
    for i= 1:config.num_reservoirs
        
%         for j= 1:config.num_reservoirs
%             
%             population(pop_indx).connectivity(i,j) =  10/population(pop_indx).nodes(i); 
%             
%             internal_weights = sprand(population(pop_indx).nodes(i), population(pop_indx).nodes(j), population(pop_indx).connectivity(i,j));
%             internal_weights(internal_weights ~= 0) = ...
%                 internal_weights(internal_weights ~= 0)  - 0.5;
%             
%             % assign scaling for inner weights 
%             population(pop_indx).W_scaling(i,j) = 2*rand;            
%             population(pop_indx).W{i,j} = internal_weights; 
% 
%         end
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