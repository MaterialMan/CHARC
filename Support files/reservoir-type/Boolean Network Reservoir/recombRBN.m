function loser = recombRBN(winner,loser,config)

% params - input_scaling, leak_rate,
W= winner.input_scaling(:);
L = loser.input_scaling(:);
pos = randperm(length(L),ceil(config.rec_rate*length(L)));
L(pos) = W(pos);
loser.input_scaling = reshape(L,size(loser.input_scaling));

W= winner.leak_rate(:);
L = loser.leak_rate(:);
pos = randperm(length(L),ceil(config.rec_rate*length(L)));
L(pos) = W(pos);
loser.leak_rate = reshape(L,size(loser.leak_rate));

W= winner.RBN_type;
L = loser.RBN_type;
pos = randperm(length(L),ceil(config.rec_rate*length(L)));
L(pos) = W(pos);
loser.RBN_type = reshape(L,size(loser.RBN_type));

W= winner.W_scaling;
L = loser.W_scaling;
pos = randperm(length(L),ceil(config.rec_rate*length(L)));
L(pos) = W(pos);
loser.W_scaling = reshape(L,size(loser.W_scaling));

W= winner.time_period;
L = loser.time_period;
pos = randperm(length(L),ceil(config.rec_rate*length(L)));
L(pos) = W(pos);
loser.time_period = reshape(L,size(loser.time_period));



for i = 1:config.num_reservoirs
    
    % input weights
    W= winner.input_weights{i}(:);
    L = loser.input_weights{i}(:);
    pos = randperm(length(L),ceil(config.rec_rate*length(L)));
    L(pos) = W(pos);
    loser.input_weights{i} = reshape(L,size(loser.input_weights{i}));
    
    % input widths
    W= winner.input_widths{i}(:);
    L = loser.input_widths{i}(:);
    pos = randperm(length(L),ceil(config.rec_rate*length(L)));
    L(pos) = W(pos);
    loser.input_widths{i} = reshape(L,size(loser.input_widths{i}));
    
    % rules
    if config.mono_rule
        W= winner.rules{i}(:,1);
        L = loser.rules{i}(:,1);
        pos = randperm(length(L),ceil(config.rec_rate*length(L)));
        L(pos) = W(pos);
        loser.rules{i} = int8(repmat(L,1,size(loser.rules{i},2)));
    else
        W= winner.rules{i}(:);
        L = loser.rules{i}(:);
        pos = randperm(length(L),ceil(config.rec_rate*length(L)));
        L(pos) = W(pos);
        loser.rules{i} = int8(reshape(L,size(loser.rules{i})));
    end
    
    if strcmp(config.res_type,'RBN')
        % swap nodes
        W = winner.RBN_node{i};
        L = loser.RBN_node{i};
        pos = randperm(length(L),ceil(config.rec_rate*length(L)));
        L(pos) = W(pos);
        loser.RBN_node{i} = L;
        
        % reformate W
        loser.W{i,i} = getAdjacenyMatrix(loser,i,config);
    end
    
    % inner weights % recombing connecting weights
    for j = 1:config.num_reservoirs
        if i ~= j
            W= winner.W{i,j}(:);
            L = loser.W{i,j}(:);
            pos = randperm(length(L),ceil(config.rec_rate*length(L)));
            L(pos) = W(pos);
            loser.W{i,j} = reshape(L,size(loser.W{i,j}));
        end
    end
    
    % initial states
    W= winner.initial_states{i}(:);
    L = loser.initial_states{i}(:);
    pos = randperm(length(L),ceil(config.rec_rate*length(L)));
    L(pos) = W(pos);
    loser.initial_states{i} = reshape(L,size(loser.initial_states{i}));
    for s=1:length(loser.RBN_node{i}) % update initial states
        loser.RBN_node{i}(s).state = int8(loser.initial_states{i}(s));
    end
    
    % check and update rules, etc.
    loser.RBN_node{i} = assocRules(loser.RBN_node{i}, loser.rules{i});
    %loser.RBN_node{i} = assocNeighbours(loser.RBN_node{i}, loser.W{i,i});
    
    
end

% for output weights
if config.evolve_output_weights
    W= winner.output_weights(:);
    L = loser.output_weights(:);
    pos = randi([1 length(L)],ceil(config.rec_rate*length(L)),1);
    L(pos) = W(pos);
    loser.output_weights = reshape(L,size(loser.output_weights));
end