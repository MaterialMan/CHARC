function loser = recombRoR(winner,loser,config)

%% Infection phase
for i = 1:size(winner.nInternalUnits,2)
    
    %recombine
    if rand < config.recRate
        loser.esnMinor(i) = winner.esnMinor(i);
        
        %update esnMajor weights and major internal units
        loser= changeMajorWeights(loser,i,loser.esnMinor);
    end
    
    %Reorder
    [temp_esnMinor, loser] = reorderESNMinor_ext(loser.esnMinor, loser);
    loser.esnMinor = temp_esnMinor;
       
end

if config.evolveOutputWeights
    W= winner.outputWeights(:);
    L = loser.outputWeights(:);
    pos = randi([1 length(L)],round(config.recRate*length(L)),1);
    L(pos) = W(pos);
    loser.outputWeights = reshape(L,size(loser.outputWeights));
end

if config.evolvedOutputStates
    Winner= winner.state_loc(:);
    Loser = loser.state_loc(:);
    pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
    Loser(pos) = Winner(pos);
    loser.state_loc = reshape(Loser,size(loser.state_loc));
    % update percent
    loser.state_perc = sum(loser.state_loc)/loser.nTotalUnits;
end