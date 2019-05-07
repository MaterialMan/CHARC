function genotype = createDLReservoir(config)

genotype = [];

% create and loop through the population
for i = 1:config.popSize
    
    % assign dummy training variables
    genotype(i).trainError = 1;
    genotype(i).valError = 1;
    genotype(i).testError = 1;
    
    % define size of network
    genotype(i).nInternalUnits = config.maxMinorUnits;
    genotype(i).nTotalUnits = genotype(i).nInternalUnits; 
    
    % define number of inputs and outputs 
    if isempty(config.trainInputSequence)
        genotype(i).nInputUnits = 1;
        genotype(i).nOutputUnits = 1;
    else
        genotype(i).nInputUnits = size(config.trainInputSequence,2);
        genotype(i).nOutputUnits = size(config.trainOutputSequence,2);
    end
    
    %set inputweights
    if config.sparseInputWeights % sparse weights
        inputWeights = sprand(genotype(i).nInternalUnits,genotype(i).nInputUnits, 0.1); %1/genotype.esnMinor(res,i).nInternalUnits
        inputWeights(inputWeights ~= 0) = ...
            2*inputWeights(inputWeights ~= 0)  - 1;
        genotype(i).M = inputWeights;
    else % non-sparse weights
        % the correct one reported in the literature
        genotype(i).M = 2*(round(rand(genotype(i).nInternalUnits,genotype(i).nInputUnits))*0.1)-0.1;
        
        % random
        %genotype(i).M = 2*rand(genotype(i).nInternalUnits,genotype(i).nInputUnits)-1;
    end
    
    
    % set global scaling parameters for weights
    %genotype(i).Wscaling = 2*rand;                          %alters network dynamics and memory, SR < 1 in almost all cases
    genotype(i).inputScaling = rand;                    % increases nonlinearity
    genotype(i).inputShift = 1;                             % adds bias/value shift to input signal
    genotype(i).leakRate = rand;
    
    genotype(i).reservoirActivationFunction = 'MG_dde23';%'mackey_glass3';    % func to calculate states 
    
    % mackey glass parameters: eta, gamma and p must be > 0
    genotype(i).eta = rand;
    genotype(i).gamma = rand;
    genotype(i).p = 1;  
    genotype(i).x0 = 0.01;
    genotype(i).T = 1; %time-scale of node
    genotype(i).time_step = 0.1;
    
     % set reservoir specific parameters round(20*rand);	
    genotype(i).tau = 80; % lenght of delay line
    genotype(i).theta = genotype(i).tau/genotype(i).nInternalUnits; % distance between virtual nodes

    
    % dummy outputweights
    genotype(i).outputWeights = zeros(genotype(i).nInternalUnits+genotype(i).nInputUnits,genotype(i).nOutputUnits);
end