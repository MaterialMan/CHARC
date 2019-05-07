function genotype = createDNAreservoir(config)

genotype = [];
for res = 1:config.popSize
    
    genotype(res).trainError = 1;
    genotype(res).valError = 1;
    genotype(res).testError = 1;
    genotype(res).inputShift = 1;
    genotype(res).inputScaling = 2*rand;
    
    if isempty(config.trainInputSequence)
        genotype(res).nInputUnits = 1;
        genotype(res).nOutputUnits = 1;
        config.task_num_inputs = 1;
        config.task_num_outputs = 1;
    else
        genotype(res).nInputUnits = size(config.trainInputSequence,2);
        genotype(res).nOutputUnits = size(config.trainOutputSequence,2);
        config.task_num_inputs = size(config.trainInputSequence,2);
        config.task_num_outputs =size(config.trainOutputSequence,2);
    end
    
    genotype(res).size = config.maxMinorUnits;
    genotype(res).Beta = 5e-7;                      % is the reaction rate constant; ? = 5 × 10-7 nM s-1
    genotype(res).e = 8.8750e-11;                   %e is the efflux rate; e = 8.8750×10-2 nL s-1
    genotype(res).H = 0.7849;                       % h the fraction of the reactor chamber that is well-mixed; h = 0.7849
    genotype(res).V = 7.54e-9;                      % volume of the reactor; V = 7.54 nL
    genotype(res).tau = config.tau;                         % time step
    genotype(res).GateCon = repmat(2500,genotype(res).size,1);      % gate concentrations, nM Units
    genotype(res).washout = 500;                                    %intial washout period for system
    genotype(res).Sm0 = repmat(5.45e-6,genotype(res).size,1);       %initial base concentrations, nmol
    
    %initial concentrations
    genotype(res).S0 = [1000 zeros(1,genotype(res).size-1)];
    genotype(res).P0 = zeros(1,genotype(res).size);
    
    genotype(res).nTotalUnits = genotype(res).size;
    genotype(res).leakRate = rand;
    
    % add input locations
    %     genotype(res).input_loc = zeros((genotype(res).size.^2)*3,1);
    %     genotype(res).input_loc(randperm(size(genotype(res).input_loc,1),round(randi([1 round(size(genotype(res).input_loc,1))])*genotype(res).dot_perc))) = 1;
    %     genotype(res).totalInputs = sum(genotype(res).input_loc);
    %
    
    %inputweights
    if config.sparseInputWeights
        inputWeights = sprand((genotype(res).size),config.task_num_inputs, 0.1); 
        inputWeights(inputWeights ~= 0) = ...
            2*inputWeights(inputWeights ~= 0)  - 1;
        genotype(res).w_in = inputWeights;
    else
        if config.restricedWeight
            for r = 1:config.task_num_inputs
                genotype(res).w_in(:,r) = datasample(0.2:0.2:1,(genotype(res).size));
            end
        else
            genotype(res).w_in = 2*rand((genotype(res).size),config.task_num_inputs)-1;
        end
    end
    
    genotype(res).outputWeights = zeros(genotype(res).size*genotype(res).tau+config.task_num_inputs,config.task_num_outputs);
    
    if config.evolvedOutputStates
        genotype(res).state_perc = 0.1;
        genotype(res).state_loc = zeros(genotype(res).size*genotype(res).tau,1);
        genotype(res).state_loc(randperm(size(genotype(res).state_loc,1),round(randi([1 round(size(genotype(res).state_loc,1))])*genotype(res).state_perc))) = 1;
        genotype(res).totalStates = sum(genotype(res).state_loc);
    end
    
end