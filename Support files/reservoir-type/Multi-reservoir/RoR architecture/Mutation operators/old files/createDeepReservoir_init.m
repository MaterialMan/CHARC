function[esnMajor, esnMinor]=createDeepReservoir_init(trainInputSequence,trainOutputSequence,numRes,maxMinorUnits,maxMajorUnits,startFull,mutateActiv,randConnect)

if nargin < 6
    startFull = 0;
end
if nargin < 7
    mutateActiv = 0;
end
if nargin < 8
    randConnect = 0;
end
%% Reservoir Parameters
for res = 1:numRes
    % Assign neuron/model type (options: 'plain' and 'leaky', so far... 'feedback', 'multinetwork', 'LeakyBias')
    %esnMajor(res).type = ''; %blank is standard sigmoid, subSample is only use a number of neuron states
    esnMajor(res).trainingType = 'Ridge'; %blank is psuedoinverse. Other options: Ridge, Bias,RLS
    esnMajor(res).AddInputStates = 1;
    esnMajor(res).regParam = 10e-5;
    esnMajor(res).range = 2;
    esnMajor(res).inputShift = 1;
    
    if startFull
        minMajorUnits = maxMajorUnits; %maxMinorUnits = 100;
        minMinorUnits = maxMinorUnits;
    else
        minMajorUnits = 1;
        minMinorUnits = 5;
    end
    
    esnMajor(res).nInternalUnits = randi([minMajorUnits maxMajorUnits]);
    
    %assign different activations, if necessary
    for n = 1:esnMajor(res).nInternalUnits
        if mutateActiv
            if n > 1
                activList = {'ReLU';'tanh';'softplus';'logistic'};%;{'linearNode'}
                tempActiv = char(activList(randi([1 length(activList)])));
                esnMajor(res).reservoirActivationFunction{n} = tempActiv;
            else
                activList = 'linearNode';
                esnMajor(res).reservoirActivationFunction = activList;
            end
            
        else
            esnMajor(res).reservoirActivationFunction = 'tanh';
            break
        end
    end
    
    if isempty(trainInputSequence)
        esnMajor(res).nInputUnits = 1;
        esnMajor(res).nOutputUnits = 1;
    else
        esnMajor(res).nInputUnits = size(trainInputSequence,2);
        esnMajor(res).nOutputUnits = size(trainOutputSequence,2);
    end
    
    % rand number of inner ESN's
    for i = 1: esnMajor(res).nInternalUnits
        
        %define num of units
        esnMinor(res,i).nInternalUnits = randi([minMinorUnits maxMinorUnits]);
          
        % Scaling
        esnMinor(res,i).spectralRadius = normrnd(1,0.25);%0.9+randn*0.1; %alters network dynamics and memory, SR < 1 in almost all cases
        esnMinor(res,i).inputScaling = normrnd(0,0.25);%0+randn*0.1; %increases nonlinearity
        esnMinor(res,i).inputShift = 1; %adds bias/value shift to input signal
        esnMinor(res,i).leakRate = abs(normrnd(0,0.25));%0.5+randn*0.1;
        
        %weights
        esnMinor(res,i).inputWeights = 2*rand(esnMinor(res,i).nInternalUnits, esnMajor(res).nInputUnits+1)-1; %1/esnMinor(res,i).nInternalUnits
        
        %(2.0 * rand(esnMinor(res,i).nInternalUnits, esnMajor(res).nInputUnits+1)- 1.0);%*esn.inputScaling;
        %initialise new reservoir - rand for random initialised, but set if
        %want to start with a good basis
        if randConnect
            esnMinor(res,i).connectivity = rand;%max([minMinorUnits/esnMinor(res,i).nInternalUnits rand]);%(10/esnMinor(res,i).nInternalUnits);
        else
            esnMinor(res,i).connectivity = (10/esnMinor(res,i).nInternalUnits);
        end
        esnMinor(res,i).internalWeights_UnitSR = generate_internal_weights(esnMinor(res,i).nInternalUnits, ...
            esnMinor(res,i).connectivity);
        esnMinor(res,i).internalWeights = esnMinor(res,i).spectralRadius * esnMinor(res,i).internalWeights_UnitSR;
        %esnMinor(res,i).outputWeights = zeros(esnMajor(res).nOutputUnits, esnMinor(res,i).nInternalUnits + esnMajor(res).nInputUnits);
        
    end
    
    %% connectivity to other reservoirs
    for i= 1:esnMajor(res).nInternalUnits
        for j= 1:esnMajor(res).nInternalUnits
            esnMajor(res).InnerConnectivity = 1/esnMinor(res,i).nInternalUnits; %min([10/esnMinor(res,i).nInternalUnits 1]);%min([1/esnMajor(res).nInternalUnits 1]);%rand;
            internalWeights = sprand(esnMinor(res,i).nInternalUnits, esnMinor(res,j).nInternalUnits, esnMajor(res).InnerConnectivity);
            internalWeights(internalWeights ~= 0) = ...
                internalWeights(internalWeights ~= 0)  - 0.5;
            val = (2*rand-1);%/10;
            esnMajor(res).interResScaling{i,j} = val;
            
            if i==j %new
                esnMajor(res).connectWeights{i,j} = esnMinor(res,j).internalWeights;
                esnMajor(res).interResScaling{i,j} = 1;
            else
                esnMajor(res).connectWeights{i,j} = internalWeights*esnMajor(res).interResScaling{i,j};%*esnMinor(res,i).inputScaling;%*esnMinor(res,i).connectRho{j};%(2.0 * rand(esnMinor(res,i).nInternalUnits, esnMinor(res,j).nInternalUnits)- 1.0);
            end
        end
    end
    
end