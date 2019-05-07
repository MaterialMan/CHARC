function genotype = mutateRoRdelay(genotype,config)

for i = 1:size(genotype.nInternalUnits,2)
    
    %mutate nodes
    %     if round(rand) && ~config.multiActiv && config.alt_node_size
    %         for p = randi([1 10])
    %             if rand < config.numMutate
    %                 [esnMinor,esnMajor] = mutateLoser_nodes(esnMinor,esnMajor,1,i,config.maxMinorUnits);
    %             end
    %         end
    %     end
    
    D_w = genotype.esnMinor(i).delayWeights(:);
    pos =  randi([1 length(D_w)],round(config.mutRate*length(D_w)),1);
    D_w(pos) = 2*rand(length(pos),1)-1;
    genotype.esnMinor(i).delayWeights = reshape(D_w,size(genotype.esnMinor(i).delayWeights));
    
    D = genotype.esnMinor(i).Dw(:);
    pos =  randi([1 length(D)],round(config.mutRate*length(D)),1);
    D(pos) = randi([1 genotype.esnMinor(i).Dmax],length(pos),1)-1;
    genotype.esnMinor(i).Dw = reshape(D,size(genotype.esnMinor(i).Dw));
    
    %mutate scales and hyperparameters
    if rand < config.mutRate
        [temp_esnMinor,genotype] = mutateLoser_hyper_init(genotype.esnMinor,genotype,1,i);
        genotype.esnMinor = temp_esnMinor;
        if config.multiActiv
            actNum = randperm(length(esnMajor.reservoirActivationFunction),length(esnMajor.reservoirActivationFunction)*config.numMutate);
            activPositions = randi(length(config.activList),1,length(esnMajor.reservoirActivationFunction)*config.numMutate);
            for act = 1:length(actNum)
                esnMajor.reservoirActivationFunction{i,act} = config.activList(activPositions(act))';
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

end
