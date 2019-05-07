function l = recombRBN(w,l,config)

if rand < config.recRate
    l.inputScaling = w.inputScaling;
end

%connectivity
% if ~strcmp(config.resType,'basicCA')
%     Winner= w.conn(:);
%     Loser = l.conn(:);
%     pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
%     Loser(pos) = Winner(pos);
%     l.conn = reshape(Loser,size(l.conn));
% end

%rules
if ~config.mono_rule
    Winner= w.rules(:);
    Loser = l.rules(:);
    pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
    Loser(pos) = Winner(pos);
    l.rules = int8(reshape(Loser,size(l.rules)));
else
    Winner= w.rules(:,1);
    Loser = l.rules(:,1);
    pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
    Loser(pos) = Winner(pos);
    l.rules = int8(repmat(Loser,1,size(l.rules,2)));
end

% % nodes
% Winner= w.node(:);
% Loser = l.node(:);
% pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
% Loser(pos) = Winner(pos);
% l.node = reshape(Loser,size(l.node));

% check rules, etc.
l.node = assocRules(l.node, l.rules);
l.node = assocNeighbours(l.node, l.conn);
    
% input weights
Winner= w.w_in(:);
Loser = l.w_in(:);
pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.w_in = reshape(Loser,size(l.w_in));

% input location
Winner= w.input_loc;
Loser = l.input_loc;
pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
Loser(pos) = Winner(pos);
l.input_loc = Loser;
l.totalInputs = sum(l.input_loc); %update input loc total

if strcmp(config.resType,'basicCA')
    % initial states
    Winner= w.initialStates;
    Loser = l.initialStates;
    pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
    Loser(pos) = Winner(pos);
    l.initialStates = Loser;           
end

if config.evolvedOutputStates
    Winner= w.state_loc;
    Loser = l.state_loc;
    pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
    Loser(pos) = Winner(pos);
    l.state_loc = Loser;
end