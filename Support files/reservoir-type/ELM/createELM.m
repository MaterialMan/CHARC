function genotype = createELM(config)


%% Reservoir Parameters
for res = 1:config.popSize
    % Assign neuron/model type (options: 'plain' and 'leaky', so far... 'feedback', 'multinetwork', 'LeakyBias')
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
    
    % how many subreservoirs
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
        % bias
        genotype(res).esnMinor(i).bias = 2*rand(genotype(res).esnMinor(i).nInternalUnits,1)-1; %adds bias/value shift to input signal
        % Scaling
        genotype(res).esnMinor(i).spectralRadius = 2*rand; %alters network dynamics
        genotype(res).esnMinor(i).inputScaling = 2*rand-1; %increases nonlinearity
    
        %assign different activations, if necessary
        if config.multiActiv 
            activPositions = randi(length(config.ActivList),1,genotype(res).esnMinor(i).nInternalUnits);
            for act = 1:length(activPositions)
                genotype(res).reservoirActivationFunction{i,act} = config.ActivList{activPositions(act)};
            end
        else
            genotype(res).reservoirActivationFunction = config.activeFcn;   
        end
    end
    

    genotype(res).nTotalUnits = 0;
    
    %% connectivity to other reservoirs
    for i= 1:genotype(res).nInternalUnits
        for j= 1:genotype(res).nInternalUnits
            
            genotype(res).esnMinor(i).connRatio = rand;
            
            if i==j
                if i ==1
                    if config.gaussWeights
                        genotype(res).connectWeights{i,j} = randn(genotype(res).nInputUnits ,genotype(res).esnMinor(i).nInternalUnits);
                    else
                        genotype(res).connectWeights{i,j} = rand(genotype(res).nInputUnits ,genotype(res).esnMinor(i).nInternalUnits);
                    end
                else
                    if config.gaussWeights
                        genotype(res).connectWeights{i,j} = randn(genotype(res).esnMinor(i-1).nInternalUnits ,genotype(res).esnMinor(i).nInternalUnits);
                    else
                        genotype(res).connectWeights{i,j} = sprand(genotype(res).esnMinor(i-1).nInternalUnits ,genotype(res).esnMinor(i).nInternalUnits,genotype(res).esnMinor(i).connRatio);
                    end
                end
            else
                genotype(res).connectWeights{i,j} = 0;
            end
        end
            genotype(res).nTotalUnits = genotype(res).nTotalUnits + genotype(res).esnMinor(i).nInternalUnits; 
    end
    

    if config.AddInputStates
        genotype(res).outputWeights = zeros(genotype(res).nTotalUnits+genotype(res).nInputUnits+1,genotype(res).nOutputUnits);      
    else
        genotype(res).outputWeights = zeros(genotype(res).nTotalUnits+1,genotype(res).nOutputUnits);
    end
end