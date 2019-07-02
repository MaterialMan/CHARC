function l = recombDNA(w,l,config)

if rand < config.recRate
    l.inputScaling = w.inputScaling;
end

% h the fraction of the reactor chamber that is well-mixed
Winner= w.H(:);
Loser = l.H(:);
pos = randi([1 length(Loser)],ceil(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.H = reshape(Loser,size(l.H));

% volume of the reactor; V in nL
Winner= w.V(:);
Loser = l.V(:);
pos = randi([1 length(Loser)],ceil(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.V = reshape(Loser,size(l.V));

% initial concentrations: P
Winner= w.P0(:);
Loser = l.P0(:);
pos = randi([1 length(Loser)],ceil(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.P0 = reshape(Loser,size(l.P0));

% initial concentrations: S
Winner= w.S0(:);
Loser = l.S0(:);
pos = randi([1 length(Loser)],ceil(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.S0 = reshape(Loser,size(l.S0));

% gate concentrations
Winner= w.GateCon(:);
Loser = l.GateCon(:);
pos = randi([1 length(Loser)],ceil(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.GateCon = reshape(Loser,size(l.GateCon));

% input weights
Winner= w.w_in(:);
Loser = l.w_in(:);
pos = randi([1 length(Loser)],ceil(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.w_in = reshape(Loser,size(l.w_in));

% input locations
% Winner= w.input_loc;
% Loser = l.input_loc;
% pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
% Loser(pos) = Winner(pos);
% l.input_loc = Loser;

% location of states to use - i.e. subsample states
if config.evolvedOutputStates
    Winner= w.state_loc;
    Loser = l.state_loc;
    pos = randi([1 length(Loser)],ceil(config.recRate*length(Loser)),1);
    Loser(pos) = Winner(pos);
    l.state_loc = Loser;
end