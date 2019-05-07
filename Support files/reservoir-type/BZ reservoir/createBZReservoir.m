
function genotype = createBZReservoir(config)

genotype = [];
for res = 1:config.popSize
    
    genotype(res).trainError = 1;
    genotype(res).valError = 1;
    genotype(res).testError = 1;
    
    genotype(res).inputShift = 1;
    
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
    genotype(res).a = rand(genotype(res).size,genotype(res).size,2);
    genotype(res).b = rand(genotype(res).size,genotype(res).size,2);
    genotype(res).c = rand(genotype(res).size,genotype(res).size,2);
    
    %genotype(res).num_dots = randi([1 20]);
    genotype(res).time_interval = 1;
    genotype(res).dot_perc = 0.01;%rand;
    genotype(res).nTotalUnits = config.maxMinorUnits.^2;
    
    genotype(res).input_loc = zeros((genotype(res).size.^2)*3,1);
    genotype(res).input_loc(randperm(size(genotype(res).input_loc,1),round(randi([1 round(size(genotype(res).input_loc,1))])*genotype(res).dot_perc))) = 1;
    genotype(res).totalInputs = sum(genotype(res).input_loc);
    
    %inputweights
    if config.sparseInputWeights
        inputWeights = sprand((genotype(res).size.^2)*3,config.task_num_inputs, 0.1); %1/genotype.esnMinor(res,i).nInternalUnits
        inputWeights(inputWeights ~= 0) = ...
            2*inputWeights(inputWeights ~= 0)  - 1;
        genotype(res).w_in = inputWeights;
    else
        if config.restricedWeight
        for r = 1:config.task_num_inputs
            genotype(res).w_in(:,r) = datasample(0.2:0.2:1,(genotype(res).size.^2)*3);%2*rand((genotype(res).size.^2)*3,config.task_num_inputs)-1; %1/genotype.esnMinor(res,i).nInternalUnits
        end
        else
            genotype(res).w_in = 2*rand((genotype(res).size.^2)*3,config.task_num_inputs)-1; %1/genotype.esnMinor(res,i).nInternalUnits
        end
    end
    
    genotype(res).outputWeights = zeros(genotype(res).size*genotype(res).size*3,1);
    
    if config.evolvedOutputStates
        genotype(res).state_perc = 0.1;
        genotype(res).state_loc = zeros((genotype(res).size.^2)*3,1);
        genotype(res).state_loc(randperm(size(genotype(res).state_loc,1),round(randi([1 round(size(genotype(res).state_loc,1))])*genotype(res).state_perc))) = 1;
        genotype(res).totalStates = sum(genotype(res).state_loc);
    end
    
end