function genotype = createInstruReservoir(config)

% place in evolve scripts
% load('Framework_substrate_RoR_IA_run1_gens200_1Nres_25_nSize.mat');
% config.database_genotype = database_genotype;

genotype = [];

for i = 1:config.popSize
    
    % assign dummy training variables
    genotype(i).trainError = 1;
    genotype(i).valError = 1;
    genotype(i).testError = 1;
    
    % define size of network
    genotype(i).nInternalUnits = config.maxMajorUnits;
    genotype(i).nTotalUnits = config.database_genotype(1).nTotalUnits; 
    
    % if mutli-reservoir, switch to multi instru reseervoir
    if genotype(i).nInternalUnits > 1
        genotype(i).multiResInstru = 1;
    else
        genotype(i).multiResInstru = 0;
    end
    
    % define number of inputs and outputs 
    if isempty(config.trainInputSequence)
        genotype(i).nInputUnits = 1;
        genotype(i).nOutputUnits = 1;
    else
        genotype(i).nInputUnits = size(config.trainInputSequence,2);
        genotype(i).nOutputUnits = size(config.trainOutputSequence,2);
    end
    
    % define duration of each instruction/configuration
    genotype(i).configDuration = (round(10*rand(length(config.database_genotype),1))+1)*100; %100 is arbitary number, it can be different
    
    % define which instruction/configuration to get from database
    if genotype(i).multiResInstru
        % number of instructions to cycle through
        genotype(i).numInstr = genotype(i).nInternalUnits;
        genotype(i).instrSeq = randi([1 length(config.database_genotype)],genotype(i).numInstr,1); %1000 is arbitary number, it can be different
    
        % interweights
        genotype(i).res(1).inputWeights = 2*rand(genotype(i).nTotalUnits,  genotype(i).nInputUnits+1)-1; % assign first set of inputweights as normal
        for k = 2: genotype(i).nInternalUnits
            connectivity =10/genotype(i).nTotalUnits;% 0.01; %min([10/genotype.esnMinor(i).nInternalUnits 1]);%min([1/genotype(res).nInternalUnits 1]);%rand;
            inputWeights = sprand(genotype(i).nTotalUnits, genotype(i).nTotalUnits+1, connectivity);
            inputWeights(inputWeights ~= 0) = ...
                inputWeights(inputWeights ~= 0)  - 0.5;
            genotype(i).res(k).inputWeights = inputWeights;%*esn.inputScaling;
        end
    
    else
        % number of instructions to cycle through
        genotype(i).numInstr = 1;%randi([1 10]);
        genotype(i).instrSeq = randi([1 length(config.database_genotype)],genotype(i).numInstr,1); %1000 is arbitary number, it can be different
    end
    
    % dummy outputweights
    genotype(i).outputWeights = zeros(genotype(i).nTotalUnits+genotype(i).nInputUnits+1,genotype(i).nOutputUnits);

    %add leak rate
    genotype(i).leakRate =rand;
    
    if config.evolvedOutputStates
        genotype(i).state_perc = 1; %start full
        genotype(i).state_loc = zeros(genotype(i).nTotalUnits,1);
        genotype(i).state_loc(randperm(size(genotype(i).state_loc,1),round(randi([1 round(size(genotype(i).state_loc,1))])*genotype(i).state_perc))) = 1;
        genotype(i).totalStates = sum(genotype(i).state_loc);
    end
end
