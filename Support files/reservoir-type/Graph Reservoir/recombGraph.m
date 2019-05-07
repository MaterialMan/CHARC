function l = recombGraph(w,l,config)

% recombine
if config.directedGraph
    Winner= w.w(:);
    Loser = l.w(:);
    pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
    Loser(pos) = Winner(pos);
    l.w = reshape(Loser,size(l.w));
else
    Winner = w.G.Edges.Weight;
    Loser = l.G.Edges.Weight;
    pos =  randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
    Loser(pos) = Winner(pos);
    l.G.Edges.Weight = Loser;
    
    A = table2array(l.G.Edges);
    l.w = zeros(size(l.G.Nodes,1));
    
    for j = 1:size(l.G.Edges,1)
        l.w(A(j,1),A(j,2)) = A(j,3);
    end
end

Winner= w.w_in(:);
Loser = l.w_in(:);
pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.w_in = reshape(Loser,size(l.w_in));

Winner= w.input_loc;
Loser = l.input_loc;
pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.input_loc = Loser;

if config.globalParams
    temp_winner = [w.Wscaling w.inputScaling w.inputShift w.leakRate];
    temp_loser = [l.Wscaling l.inputScaling l.inputShift l.leakRate];
    pos = randi([1 length(temp_loser)],round(config.recRate*length(temp_loser)),1);
    temp_loser(pos) = temp_winner(pos);
    
    l.Wscaling = temp_loser(1);                          %alters network dynamics and memory, SR < 1 in almost all cases
    l.inputScaling = temp_loser(2);                    %increases nonlinearity
    l.inputShift = temp_loser(3);                             %adds bias/value shift to input signal
    l.leakRate = temp_loser(4);
end

if config.evolveOutputWeights
    Winner= w.outputWeights(:);
    Loser = l.outputWeights(:);
    pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
    Loser(pos) = Winner(pos);
    l.outputWeights = reshape(Loser,size(l.outputWeights));
end

end
