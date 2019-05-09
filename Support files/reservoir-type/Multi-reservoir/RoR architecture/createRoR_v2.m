function genotype = createRoR_v2(config)

%% Reservoir Parameters
for res = 1:config.popSize
    % Assign neuron/model type (options: 'plain' and 'leaky', so far... 'feedback', 'multinetwork', 'LeakyBias')
    %esnMajor(res).type = ''; %blank is standard sigmoid, subSample is only use a number of neuron states
    genotype(res).trainError = 1;
    genotype(res).valError = 1;
    genotype(res).testError = 1;
    
    genotype(res).inputShift = 1;
    
    if config.startFull
        config.minMajorUnits = config.maxMajorUnits; %maxMinorUnits = 100;
        config.minMinorUnits = config.maxMinorUnits;
    else
        config.minMajorUnits = 1;
        config.minMinorUnits = 2;
    end
    
    genotype(res).nInternalUnits = randi([config.minMajorUnits config.maxMajorUnits]);
    
    if isempty(config.trainInputSequence) 
        genotype(res).nInputUnits = 1;
        genotype(res).nOutputUnits = 1;
    else
        genotype(res).nInputUnits = size(config.trainInputSequence,2);
        genotype(res).nOutputUnits = size(config.trainOutputSequence,2);
    end
    
    % rand number of inner ESN's
    for i = 1: genotype(res).nInternalUnits
        
        %define num of units
        genotype(res).esnMinor(i).nInternalUnits = randi([config.minMinorUnits config.maxMinorUnits]);
        
        % Scaling
        genotype(res).esnMinor(i).inputScaling = 2*rand-1; %increases nonlinearity
        genotype(res).esnMinor(i).inputShift = 1; %adds bias/value shift to input signal
        genotype(res).esnMinor(i).leakRate = rand;
        
       %inputweights
        if config.sparseInputWeights
            inputWeights = sprand(genotype(res).esnMinor(i).nInternalUnits,  genotype(res).nInputUnits+1, 0.1); 
            inputWeights(inputWeights ~= 0) = ...
                2*inputWeights(inputWeights ~= 0)  - 1;
            genotype(res).esnMinor(i).inputWeights = inputWeights;
        else
            genotype(res).esnMinor(i).inputWeights = 2*rand(genotype(res).esnMinor(i).nInternalUnits,  genotype(res).nInputUnits+1)-1; 
        end
        
         %initialise new reservoir - rand for random initialised, but set if
        %want to start with a good basis
        if config.rand_connect
            genotype(res).esnMinor(i).connectivity = max([10/genotype(res).esnMinor(i).nInternalUnits rand]);
        else
            genotype(res).esnMinor(i).connectivity = (10/genotype(res).esnMinor(i).nInternalUnits);
        end
        
        %assign different activations, if necessary
        if config.multiActiv 
            activPositions = randi(length(config.activList),1,genotype(res).esnMinor(i).nInternalUnits);
            for act = 1:length(activPositions)
                genotype(res).reservoirActivationFunction{i,act} = config.activList{activPositions(act)};
            end
        else
            genotype(res).reservoirActivationFunction = 'tanh';    
        end
    end
    
    %end
    genotype(res).nTotalUnits = 0;
    
    %% connectivity to other reservoirs
    for i= 1:genotype(res).nInternalUnits
        for j= 1:genotype(res).nInternalUnits
 
            % create weights
            genotype(res).connectWeights{i,j} = generate_internal_weights(genotype(res).esnMinor(i).nInternalUnits, ...
            genotype(res).esnMinor(i).connectivity);
        
            genotype(res).interResScaling{i,j} = 2*rand-1;
        end
            genotype(res).nTotalUnits = genotype(res).nTotalUnits + genotype(res).esnMinor(i).nInternalUnits; 
    end
    

    % add dummy outputweights
    if config.AddInputStates
        genotype(res).outputWeights = zeros(genotype(res).nTotalUnits+genotype(res).nInputUnits+1,genotype(res).nOutputUnits);      
    else
        genotype(res).outputWeights = zeros(genotype(res).nTotalUnits+1,genotype(res).nOutputUnits);
    end
    
    if config.evolvedOutputStates
        genotype(res).state_perc = 1; % start full
        genotype(res).state_loc = zeros(genotype(res).nTotalUnits,1);
        genotype(res).state_loc(randperm(size(genotype(res).state_loc,1),round(randi([1 round(size(genotype(res).state_loc,1))])*genotype(res).state_perc))) = 1;
        genotype(res).totalStates = sum(genotype(res).state_loc);
    end
    
    genotype(res).metrics = [];
end