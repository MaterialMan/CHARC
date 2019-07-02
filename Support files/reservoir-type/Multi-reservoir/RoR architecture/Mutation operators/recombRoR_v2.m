function loser = recombRoR_v2(winner,loser,config)

%% Infection phase
for i = 1:size(winner.nInternalUnits,2)
        
   % hyperparameters
    if rand < config.recRate
        loser.esnMinor(i).leakRate = winner.esnMinor(i).leakRate;
    end
    if rand < config.recRate
        loser.esnMinor(i).inputScaling = winner.esnMinor(i).inputScaling;
    end
    if rand < config.recRate
        loser.esnMinor(i).inputShift = winner.esnMinor(i).inputShift;
    end
    
    % input weights
    W= winner.esnMinor(i).inputWeights(:);
    L = loser.esnMinor(i).inputWeights(:);
    pos = randi([1 length(L)],ceil(config.recRate*length(L)),1);
    L(pos) = W(pos);
    loser.esnMinor(i).inputWeights = reshape(L,size(loser.esnMinor(i).inputWeights));
        
    for j = 1:size(winner.nInternalUnits,2)
        % connect weights
        %if rand < config.recRate
            W= winner.connectWeights{i,j}(:);
            L = loser.connectWeights{i,j}(:);
            pos = randi([1 length(L)],ceil(config.recRate*length(L)),1);
            L(pos) = W(pos);
            loser.connectWeights{i,j}(:) = reshape(L,size(loser.connectWeights{i,j}(:)));        
        %end
        % interRes sclaing
        if rand < config.recRate
            loser.interResScaling{i,j} = winner.interResScaling{i,j};
        end
    end
       
end

if config.evolveOutputWeights
    W= winner.outputWeights(:);
    L = loser.outputWeights(:);
    pos = randi([1 length(L)],ceil(config.recRate*length(L)),1);
    L(pos) = W(pos);
    loser.outputWeights = reshape(L,size(loser.outputWeights));
end

if config.evolvedOutputStates
    Winner= winner.state_loc(:);
    Loser = loser.state_loc(:);
    pos = randi([1 length(Loser)],ceil(config.recRate*length(Loser)),1);
    Loser(pos) = Winner(pos);
    loser.state_loc = reshape(Loser,size(loser.state_loc));
    % update percent
    loser.state_perc = sum(loser.state_loc)/loser.nTotalUnits;
end  

