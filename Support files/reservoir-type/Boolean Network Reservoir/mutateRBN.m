function genotype = mutateRBN(genotype,config)

if rand < config.mutRate
    genotype.inputScaling = 2*rand;
end

% connectivity
% if ~strcmp(config.resType,'basicCA')
%     conn = genotype.conn(:);
%     pos =  randi([1 length(conn)],round(config.mutRate*length(conn)),1);
%     conn(pos) = round(rand(length(pos),1));
%     genotype.conn = reshape(conn,size(genotype.conn));
%     % check neighbours
%     genotype.node = assocNeighbours(genotype.node, genotype.conn);
% end

% rules
if ~config.mono_rule
    rules = genotype.rules(:);
    pos =  randi([1 length(rules)],round(config.mutRate*length(rules)),1);
    rules(pos) = round(rand(length(pos),1));
    genotype.rules = int8(reshape(rules,size(genotype.rules)));
else
    new_rule = genotype.rules(:,1);
    pos =  randi([1 length(new_rule)],round(config.mutRate*length(new_rule)),1);
    new_rule(pos) = round(rand(length(pos),1));
    genotype.rules = int8(repmat(new_rule,1,size(genotype.rules,2)));
end 

% check rules, etc.
genotype.node = assocRules(genotype.node, genotype.rules);


% w_in
w_in = genotype.w_in(:);
pos =  randi([1 length(w_in)],round(config.mutRate*length(w_in)),1);
if config.restricedWeight
    w_in(pos) = datasample(0.2:0.2:1,length(pos));%2*rand(length(pos),1)-1;
else
    w_in(pos) = 2*rand(length(pos),1)-1;
end
genotype.w_in = reshape(w_in,size(genotype.w_in));


% input_loc
for i = 1:length(genotype.input_loc)
    if rand < config.mutRate
        genotype.input_loc(i) = round(rand);
    end
end
genotype.totalInputs = sum(genotype.input_loc);

% initial states
if strcmp(config.resType,'basicCA')
    initialStates = genotype.initialStates(:);
    pos =  randi([1 length(initialStates)],round(config.mutRate*length(initialStates)),1);
    initialStates(pos) = round(rand(length(pos),1));
    genotype.initialStates = reshape(initialStates,size(genotype.initialStates));
end

if config.evolvedOutputStates
    if rand < config.mutRate %not really used, yet
        genotype.state_perc = rand;
    end
    
    % state_loc
    for i = 1:length(genotype.state_loc)
        if rand < config.mutRate
            genotype.state_loc(i) = round(rand);
        end
    end

end

