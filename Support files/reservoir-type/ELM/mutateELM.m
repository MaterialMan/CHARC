function genotype = mutateELM(genotype,config)

for i = 1:genotype.nInternalUnits
    
    %mutate nodes
    %     if round(rand) && ~config.multiActiv && config.alt_node_size
    %         for p = randi([1 10])
    %             if rand < config.numMutate
    %                 [esnMinor,esnMajor] = mutateLoser_nodes(esnMinor,esnMajor,1,i,config.maxMinorUnits);
    %             end
    %         end
    %     end


    % mutate inputscaling
    b = genotype.esnMinor(i).inputScaling;
    pos =  randi([1 length(b)],round(config.mutRate*length(b)),1);
    b(pos) = 2*rand(length(pos),1)-1;
    genotype.esnMinor(i).inputScaling = b;
    
    % mutate spectral radius
    b = genotype.esnMinor(i).spectralRadius;
    pos =  randi([1 length(b)],round(config.mutRate*length(b)),1);
    b(pos) = 2*rand(length(pos),1)-1;
    genotype.esnMinor(i).spectralRadius = b;
    
    % mutate bias
    b = genotype.esnMinor(i).bias;
    pos =  randi([1 length(b)],round(config.mutRate*length(b)),1);
    b(pos) = 2*rand(length(pos),1)-1;
    genotype.esnMinor(i).bias = b;
      
    %mutate scales and hyperparameters
    if rand < config.mutRate
        if config.multiActiv
            actNum = randperm(length(esnMajor.reservoirActivationFunction),length(esnMajor.reservoirActivationFunction)*config.numMutate);
            activPositions = randi(length(config.activList),1,length(esnMajor.reservoirActivationFunction)*config.numMutate);
            for act = 1:length(actNum)
                esnMajor.reservoirActivationFunction{i,act} = config.activList(activPositions(act))';
            end
        end
    end
    
    %mutate weights
    w = genotype.connectWeights{i,i}(:);
    pos =  randi([1 length(w)],round(config.mutRate*length(w)),1);
    w(pos) = 2*rand(length(pos),1)-1;
    genotype.connectWeights{i,i} = reshape(w,size(genotype.connectWeights{i,i}));
    
end

if config.evolveOutputWeights
    outputWeights = genotype.outputWeights(:);
    pos =  randi([1 length(outputWeights)],round(config.mutRate*length(outputWeights)),1);
    outputWeights(pos) = 2*rand(length(pos),1)-1;
    genotype.outputWeights = reshape(outputWeights,size(genotype.outputWeights));
end

end
