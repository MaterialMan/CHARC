function genotype = createGraphReservoir(config)

genotype = [];
for i = 1:config.popSize
    
    genotype(i).trainError = 1;
    genotype(i).valError = 1;
    genotype(i).testError = 1;
    
    genotype(i).inputShift = 1;
    
    if isempty(config.trainInputSequence)
        genotype(i).nInputUnits = 1;
        genotype(i).nOutputUnits = 1;
        config.task_num_inputs = 1;
        config.task_num_outputs = 1;
    else
        genotype(i).nInputUnits = size(config.trainInputSequence,2);
        genotype(i).nOutputUnits = size(config.trainOutputSequence,2);
        config.task_num_inputs = size(config.trainInputSequence,2);
        config.task_num_outputs =size(config.trainOutputSequence,2);
    end
    genotype(i).nTotalUnits = config.N;
    
    genotype(i).w = zeros(config.N); %needs to be sparse
    if config.directedGraph
        genotype(i).G = config.G;
        for j= 1:config.N
            if config.nearest_neighbour > 0
                Ne = nearest(G,j,config.nearest_neighbour);
            else
                Ne = neighbors(config.G,j);
            end
            genotype(i).w(Ne,j) = 2*rand(length(Ne),1)-1;
            genotype(i).w(j,Ne) = 2*rand(1,length(Ne))-1;
        end
    else
        genotype(i).G = config.G;
        genotype(i).G.Edges.Weight = 2*rand(size(genotype(i).G.Edges,1),1)-1;
        
        A = table2array(genotype(i).G.Edges);
        for j = 1:size(genotype(i).G.Edges,1)
            genotype(i).w(A(j,1),A(j,2)) = A(j,3);
        end
    end
    genotype(i).w = sparse(genotype(i).w);
    
    %inputweights
    if config.sparseInputWeights
        inputWeights = sprand(config.N,config.task_num_inputs, 0.1); %1/genotype.esnMinor(res,i).nInternalUnits
        inputWeights(inputWeights ~= 0) = ...
                2*inputWeights(inputWeights ~= 0)  - 1;
        genotype(i).w_in = inputWeights;
    else
        genotype(i).w_in = 2*rand(config.N,config.task_num_inputs)-1; %1/genotype.esnMinor(res,i).nInternalUnits
    end
    
    %genotype(i).w_out = zeros(config.N,config.task_num_outputs);
    genotype(i).input_loc = zeros(config.N,1);
    genotype(i).input_loc(randperm(config.N,randi([1 round(config.N)]))) = 1;
    genotype(i).totalInputs = sum(genotype(i).input_loc);
    if config.AddInputStates
        genotype(i).outputWeights = zeros(config.N+genotype(i).nInputUnits+1,config.task_num_outputs);
    else
        genotype(i).outputWeights = zeros(config.N+1,config.task_num_outputs);
    end

    %genotype(i).regParam = 10e-7;
    
    if config.globalParams
        genotype(i).Wscaling = 2*rand;                          %alters network dynamics and memory, SR < 1 in almost all cases
        genotype(i).inputScaling = 2*rand-1;                    %increases nonlinearity
        genotype(i).inputShift = 1;                             %adds bias/value shift to input signal
        genotype(i).leakRate = rand;
    end
end
end