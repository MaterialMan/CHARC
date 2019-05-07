function l = recombDL(w,l,config)

% recombine Mask
Winner= w.M(:);
Loser = l.M(:);
pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.M = reshape(Loser,size(l.M));

% global parameters
temp_winner = [w.inputShift w.leakRate];
temp_loser = [l.inputShift l.leakRate];
pos = randi([1 length(temp_loser)],round(config.recRate*length(temp_loser)),1);
temp_loser(pos) = temp_winner(pos);

%l.Wscaling = temp_loser(1);                          
%l.inputScaling = temp_loser(1);                    
l.inputShift = temp_loser(1);                             
l.leakRate = temp_loser(2);

% reservoir parameters
temp_winner = [w.tau w.eta w.gamma w.p];
temp_loser = [l.tau l.eta l.gamma l.p];
pos = randi([1 length(temp_loser)],round(config.recRate*length(temp_loser)),1);
temp_loser(pos) = temp_winner(pos);

l.tau = temp_loser(1);
l.theta = l.tau/l.nInternalUnits;
l.eta = temp_loser(2);                    
l.gamma = temp_loser(3);                             
l.p = temp_loser(4);


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
