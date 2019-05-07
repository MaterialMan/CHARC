function loser = recombELM(winner,loser,config)

%% Infection phase
for i = 1:winner.nInternalUnits
    
    %recombine inputscaling
    if rand < config.recRate
        loser.esnMinor(i).inputScaling = winner.esnMinor(i).inputScaling;    
    end
    
    %recombine spectral radius
    if rand < config.recRate
        loser.esnMinor(i).spectralRadius = winner.esnMinor(i).spectralRadius;    
    end
    
    % bias
    W= winner.esnMinor(i).bias(:);
    L = loser.esnMinor(i).bias(:);
    pos = randi([1 length(L)],round(config.recRate*length(L)),1);
    L(pos) = W(pos);
    loser.esnMinor(i).bias = reshape(L,size(loser.esnMinor(i).bias));
        
    %Reorder
    [temp_esnMinor, loser] = reorderELMminor(loser.esnMinor, loser); 
    loser.esnMinor = temp_esnMinor;
    
    if config.evolveOutputWeights
        W= winner.outputWeights(:);
        L = loser.outputWeights(:);
        pos = randi([1 length(L)],round(config.recRate*length(L)),1);
        L(pos) = W(pos);
        loser.outputWeights = reshape(L,size(loser.outputWeights));
    end
end