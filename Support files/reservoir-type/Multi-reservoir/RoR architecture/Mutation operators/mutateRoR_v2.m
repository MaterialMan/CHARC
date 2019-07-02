function genotype = mutateRoR_v2(genotype,config)

for i = 1:size(genotype.nInternalUnits,2)
   
    % mutate hyperparameters
    if rand < config.mutRate
        genotype.esnMinor(i).leakRate = rand;
    end
    if rand < config.mutRate
        genotype.esnMinor(i).inputScaling = 2*rand-1;
    end
    if rand < config.mutRate
        genotype.esnMinor(i).inputShift = 2*rand-1;
    end
    
    % mutate input weights
    if rand < config.mutRate
        win = genotype.esnMinor(i).inputWeights(:);
        pos =  randi([1 length(win)],ceil(config.mutRate*length(win)),1);
        win(pos) = 2*rand(length(pos),1)-1;
        genotype.esnMinor(i).inputWeights = reshape(win,size(genotype.esnMinor(i).inputWeights));
    end
    
    for j = 1:size(genotype.nInternalUnits,2)
        % mutate connect weights
        if rand < config.mutRate
            w = genotype.connectWeights{i,j}(:);
            pos =  randi([1 length(w)],ceil(config.mutRate*length(w)),1);
            w(pos) = 2*rand(length(pos),1)-1;
            genotype.connectWeights{i,j} = reshape(w,size(genotype.connectWeights{i,j}));
        end
        % mutate interRes sclaing
        if rand < config.mutRate
            genotype.interResScaling{i,j} = rand;
        end
    end
    
end

if config.evolveOutputWeights
    outputWeights = genotype.outputWeights(:);
    pos =  randi([1 length(outputWeights)],ceil(config.mutRate*length(outputWeights)),1);
    outputWeights(pos) = 2*rand(length(pos),1)-1;
    genotype.outputWeights = reshape(outputWeights,size(genotype.outputWeights));
end

% mutate states to use
if config.evolvedOutputStates
    % state_loc
    for i = 1:length(genotype.state_loc)
        if rand < config.mutRate
            genotype.state_loc(i) = round(rand);
        end
    end  
    % update percent
    genotype.state_perc = sum(genotype.state_loc)/genotype.nTotalUnits;
end