function population = createGraphReservoir(config)

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
    
    
    %%
    population(i).nTotalUnits = config.N;
    
    population(i).w = zeros(config.N); %needs to be sparse
    if config.directedGraph
        population(i).G = config.G;
        for j= 1:config.N
            if config.nearest_neighbour > 0
                Ne = nearest(G,j,config.nearest_neighbour);
            else
                Ne = neighbors(config.G,j);
            end
            population(i).w(Ne,j) = 2*rand(length(Ne),1)-1;
            population(i).w(j,Ne) = 2*rand(1,length(Ne))-1;
        end
    else
        population(i).G = config.G;
        population(i).G.Edges.Weight = 2*rand(size(population(i).G.Edges,1),1)-1;
        
        A = table2array(population(i).G.Edges);
        for j = 1:size(population(i).G.Edges,1)
            population(i).w(A(j,1),A(j,2)) = A(j,3);
        end
    end
    population(i).w = sparse(population(i).w);
    
    %inputweights
    if config.sparseInputWeights
        inputWeights = sprand(config.N,config.task_num_inputs, 0.1); %1/genotype.esnMinor(res,i).nInternalUnits
        inputWeights(inputWeights ~= 0) = ...
                2*inputWeights(inputWeights ~= 0)  - 1;
        population(i).w_in = inputWeights;
    else
        population(i).w_in = 2*rand(config.N,config.task_num_inputs)-1; %1/genotype.esnMinor(res,i).nInternalUnits
    end
    
    %genotype(i).w_out = zeros(config.N,config.task_num_outputs);
    population(i).input_loc = zeros(config.N,1);
    population(i).input_loc(randperm(config.N,randi([1 round(config.N)]))) = 1;
    population(i).totalInputs = sum(population(i).input_loc);
    if config.AddInputStates
        population(i).outputWeights = zeros(config.N+population(i).nInputUnits,config.task_num_outputs);
    else
        population(i).outputWeights = zeros(config.N,config.task_num_outputs);
    end

    %genotype(i).regParam = 10e-7;
    
    if config.globalParams
        population(i).Wscaling = 2*rand;                          %alters network dynamics and memory, SR < 1 in almost all cases
        population(i).inputScaling = 2*rand-1;                    %increases nonlinearity
        population(i).inputShift = 1;                             %adds bias/value shift to input signal
        population(i).leakRate = rand;
    end
    
    population(i).last_state = zeros(1,population(i).nTotalUnits);
end