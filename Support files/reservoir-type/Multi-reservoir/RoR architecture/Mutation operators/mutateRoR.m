function genotype = mutateRoR(genotype,config)

for i = 1:size(genotype.nInternalUnits,2)
    
    %mutate nodes
%     if round(rand) && ~config.multiActiv && config.alt_node_size
%         for p = randi([1 10])
%             if rand < config.numMutate
%                 [esnMinor,esnMajor] = mutateLoser_nodes(esnMinor,esnMajor,1,i,config.maxMinorUnits);
%             end
%         end
%     end
    
    %mutate scales and hyperparameters
    if rand < config.mutRate
        [temp_esnMinor,genotype] = mutateLoser_hyper_init(genotype.esnMinor,genotype,1,i);
        genotype.esnMinor = temp_esnMinor;
        if config.multiActiv
            actNum = randperm(length(genotype.reservoirActivationFunction),length(genotype.reservoirActivationFunction)*config.mutRate);
            activPositions = randi(length(config.activList),1,length(genotype.reservoirActivationFunction)*config.mutRate);
            for act = 1:length(actNum)
                genotype.reservoirActivationFunction{i,act} = config.activList(activPositions(act))';
            end
        end
    end
    
    %mutate weights
    for j = 1:genotype.esnMinor(i).nInternalUnits
        if rand < config.mutRate
            [temp_esnMinor,genotype] = mutateLoser_weights(genotype.esnMinor,genotype,1,i);
            genotype.esnMinor = temp_esnMinor;
        end
    end
end

if config.evolveOutputWeights
    outputWeights = genotype.outputWeights(:);
    pos =  randi([1 length(outputWeights)],round(config.mutRate*length(outputWeights)),1);
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
