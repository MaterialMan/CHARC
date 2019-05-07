function l = recombInstru(w,l,config)

% recombine duration of instruc
Winner= w.configDuration(:);
Loser = l.configDuration(:);
pos = randperm(length(Loser),round(config.recRate*length(Loser)));
Loser(pos) = Winner(pos);
l.configDuration = reshape(Loser,size(l.configDuration));

% recombine instruc Sequence
Winner= w.instrSeq(:);
Loser = l.instrSeq(:);
pos = randperm(min([length(Loser) length(Winner)]),round(config.recRate*min([length(Loser) length(Winner)])));%randi([1 min([length(Loser) length(Winner)])],round(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.instrSeq = reshape(Loser,size(l.instrSeq));

if config.evolveOutputWeights
    Winner= w.outputWeights(:);
    Loser = l.outputWeights(:);
    pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
    Loser(pos) = Winner(pos);
    l.outputWeights = reshape(Loser,size(l.outputWeights));
end

if config.evolvedOutputStates
    Winner= w.state_loc(:);
    Loser = l.state_loc(:);
    pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
    Loser(pos) = Winner(pos);
    l.state_loc = reshape(Loser,size(l.state_loc));
    % update percent
    l.state_perc = sum(l.state_loc)/l.nTotalUnits;
end

end
