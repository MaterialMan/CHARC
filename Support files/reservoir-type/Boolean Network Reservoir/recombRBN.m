function loser = recombRBN(winner,loser,config)

% params - input_scaling, leak_rate,
W= winner.input_scaling(:);
L = loser.input_scaling(:);
pos = randi([1 length(L)],ceil(config.rec_rate*length(L)),1);
L(pos) = W(pos);
loser.input_scaling = reshape(L,size(loser.input_scaling));

W= winner.leak_rate(:);
L = loser.leak_rate(:);
pos = randi([1 length(L)],ceil(config.rec_rate*length(L)),1);
L(pos) = W(pos);
loser.leak_rate = reshape(L,size(loser.leak_rate));

W= winner.RBN_type;
L = loser.RBN_type;
pos = randi([1 length(L)],ceil(config.rec_rate*length(L)),1);
L(pos) = W(pos);
loser.RBN_type = reshape(L,size(loser.RBN_type));

W= winner.W_scaling;
L = loser.W_scaling;
pos = randi([1 length(L)],ceil(config.rec_rate*length(L)),1);
L(pos) = W(pos);
loser.W_scaling = reshape(L,size(loser.W_scaling));


for i = 1:config.num_reservoirs

  % input weights
    W= winner.input_weights{i}(:);
    L = loser.input_weights{i}(:);
    pos = randi([1 length(L)],ceil(config.rec_rate*length(L)),1);
    L(pos) = W(pos);
    loser.input_weights{i} = reshape(L,size(loser.input_weights{i}));
        
   
    % rules
    if config.mono_rule
        W= winner.rules{i}(:,1);
        L = loser.rules{i}(:,1);
        pos = randi([1 length(L)],ceil(config.rec_rate*length(L)),1);
        L(pos) = W(pos);
        loser.rules{i} = int8(repmat(L,1,size(loser.rules{i},2)));
    else
        W= winner.rules{i}(:);
        L = loser.rules{i}(:);
        pos = randi([1 length(L)],ceil(config.rec_rate*length(L)),1);
        L(pos) = W(pos);
        loser.rules{i} = int8(reshape(L,size(loser.rules{i})));       
    end

    % swap nodes          
    W = winner.RBN_node{i};
    L = loser.RBN_node{i};
    pos = randi([1 length(L)],ceil(config.rec_rate*length(L)),1);
    L(pos) = W(pos);
    loser.RBN_node{i} = L;
    
    % reformate W
    loser.W{i,i} = getAdjacenyMatrix(loser,i,config);
    
    % inner weights % recombing connecting weights
    for j = 1:config.num_reservoirs
        if i ~= j
            W= winner.W{i,j}(:);
            L = loser.W{i,j}(:);
            pos = randi([1 length(L)],ceil(config.rec_rate*length(L)),1);
            L(pos) = W(pos);
            loser.W{i,j} = reshape(L,size(loser.W{i,j}));
        end
    end  
    
    % check and update rules, etc.
    loser.RBN_node{i} = assocRules(loser.RBN_node{i}, loser.rules{i});
    %loser.RBN_node{i} = assocNeighbours(loser.RBN_node{i}, loser.W{i,i});
      
end

% %%rules
% if ~config.mono_rule
%     Winner= w.rules(:);
%     Loser = l.rules(:);
%     pos = randi([1 length(Loser)],ceil(config.recRate*length(Loser)),1);
%     Loser(pos) = Winner(pos);
%     l.rules = int8(reshape(Loser,size(l.rules)));
% else
%     Winner= w.rules(:,1);
%     Loser = l.rules(:,1);
%     pos = randi([1 length(Loser)],ceil(config.recRate*length(Loser)),1);
%     Loser(pos) = Winner(pos);
%     l.rules = int8(repmat(Loser,1,size(l.rules,2)));
% end

% % nodes
% Winner= w.node(:);
% Loser = l.node(:);
% pos = randi([1 length(Loser)],round(config.recRate*length(Loser)),1);
% Loser(pos) = Winner(pos);
% l.node = reshape(Loser,size(l.node));

% input weights
% Winner= w.w_in(:);
% Loser = l.w_in(:);
% pos = randi([1 length(Loser)],ceil(config.recRate*length(Loser)),1);
% Loser(pos) = Winner(pos);
% l.w_in = reshape(Loser,size(l.w_in));
% 
% % input location
% Winner= w.input_loc;
% Loser = l.input_loc;
% pos = randi([1 length(Loser)],ceil(config.recRate*length(Loser)),1);
% Loser(pos) = Winner(pos);
% l.input_loc = Loser;
% l.totalInputs = sum(l.input_loc); %update input loc total
% 
% if strcmp(config.resType,'basicCA')
%     % initial states
%     Winner= w.initialStates;
%     Loser = l.initialStates;
%     pos = randi([1 length(Loser)],ceil(config.recRate*length(Loser)),1);
%     Loser(pos) = Winner(pos);
%     l.initialStates = Loser;           
% end

% for output weights
if config.evolve_output_weights
    W= winner.output_weights(:);
    L = loser.output_weights(:);
    pos = randi([1 length(L)],ceil(config.rec_rate*length(L)),1);
    L(pos) = W(pos);
    loser.output_weights = reshape(L,size(loser.output_weights));
end