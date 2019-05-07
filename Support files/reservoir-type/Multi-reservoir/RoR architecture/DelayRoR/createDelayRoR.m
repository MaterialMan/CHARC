function genotype = createDelayRoR(config)


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
        genotype(res).esnMinor(i).spectralRadius = 2*rand; %alters network dynamics and memory, SR < 1 in almost all cases
        genotype(res).esnMinor(i).inputScaling = 2*rand-1; %increases nonlinearity
        genotype(res).esnMinor(i).inputShift = 1; %adds bias/value shift to input signal
        genotype(res).esnMinor(i).leakRate = rand;
        genotype(res).esnMinor(i).Dmax = randi([1 50]);
        
       %inputweights
        if config.sparseInputWeights
            inputWeights = sprand(genotype(res).esnMinor(i).nInternalUnits,  genotype(res).nInputUnits+1, 0.1); 
            inputWeights(inputWeights ~= 0) = ...
                2*inputWeights(inputWeights ~= 0)  - 1;
            genotype(res).esnMinor(i).inputWeights = inputWeights;
        else
            genotype(res).esnMinor(i).inputWeights = 2*rand(genotype(res).esnMinor(i).nInternalUnits,  genotype(res).nInputUnits+1)-1; 
        end
        
        %create delay points
        genotype(res).esnMinor(i).Dw = randi([1 genotype(res).esnMinor(i).Dmax],1,genotype(res).esnMinor(i).Dmax);

         %initialise new reservoir - rand for random initialised, but set if
        %want to start with a good basis
        if config.rand_connect
            genotype(res).esnMinor(i).connectivity = max([10/genotype(res).esnMinor(i).nInternalUnits rand]);%(10/esnMinor(res,i).nInternalUnits);
        else
            genotype(res).esnMinor(i).connectivity = (10/genotype(res).esnMinor(i).nInternalUnits);
        end
        
        genotype(res).esnMinor(i).internalWeights_UnitSR = generate_internal_weights(genotype(res).esnMinor(i).nInternalUnits, ...
            genotype(res).esnMinor(i).connectivity);
        genotype(res).esnMinor(i).internalWeights = genotype(res).esnMinor(i).spectralRadius * genotype(res).esnMinor(i).internalWeights_UnitSR;
        %esnMinor(res,i).outputWeights = zeros(esnMajor(res).nOutputUnits, esnMinor(res,i).nInternalUnits + esnMajor(res).nInputUnits);
        
        delayWeights = sprand(1, genotype(res).esnMinor(i).Dmax, genotype(res).esnMinor(i).connectivity);
        delayWeights(delayWeights ~= 0) = ...
            delayWeights(delayWeights ~= 0)  - 0.5;
        
        genotype(res).esnMinor(i).delayWeights = delayWeights;
            
        %assign different activations, if necessary
        if config.multiActiv 
            activPositions = randi(length(config.ActivList),1,genotype(res).esnMinor(i).nInternalUnits);
            for act = 1:length(activPositions)
                genotype(res).reservoirActivationFunction{i,act} = config.ActivList{activPositions(act)};
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
            genotype(res).InnerConnectivity = 1/genotype(res).esnMinor(i).nInternalUnits; %min([10/esnMinor(res,i).nInternalUnits 1]);%min([1/esnMajor(res).nInternalUnits 1]);%rand;
            internalWeights = sprand(genotype(res).esnMinor(i).nInternalUnits, genotype(res).esnMinor(j).nInternalUnits, genotype(res).InnerConnectivity);
            internalWeights(internalWeights ~= 0) = ...
                internalWeights(internalWeights ~= 0)  - 0.5;
                        
            val = (2*rand-1);%/10;
            genotype(res).interResScaling{i,j} = val;
            
            if i==j %new
                genotype(res).connectWeights{i,j} = genotype(res).esnMinor(j).internalWeights;
                
                genotype(res).interResScaling{i,j} = 1;
            else
                genotype(res).connectWeights{i,j} = internalWeights*genotype(res).interResScaling{i,j};%*esnMinor(res,i).inputScaling;%*esnMinor(res,i).connectRho{j};%(2.0 * rand(esnMinor(res,i).nInternalUnits, esnMinor(res,j).nInternalUnits)- 1.0);
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