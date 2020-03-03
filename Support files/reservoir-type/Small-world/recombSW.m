%% Infection phase
function loser = recombSW(winner,loser,config)

% params - input_scaling, leak_rate,
W= winner.input_scaling(:);
L = loser.input_scaling(:);
pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));
L(pos) = W(pos);
loser.input_scaling = reshape(L,size(loser.input_scaling));

W= winner.leak_rate(:);
L = loser.leak_rate(:);
pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));
L(pos) = W(pos);
loser.leak_rate = reshape(L,size(loser.leak_rate));

% params - W_scaling
W= winner.W_scaling(:);
L = loser.W_scaling(:);
pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));
L(pos) = W(pos);
loser.W_scaling = reshape(L,size(loser.W_scaling));

% cycle through sub-reservoirs
for i = 1:config.num_reservoirs
    
    % input weights
    W= winner.input_weights{i}(:);
    L = loser.input_weights{i}(:);
    pos = randperm(length(L),ceil(config.rec_rate*length(L)));    %sum(rand(length(L),1) < config.rec_rate)
    L(pos) = W(pos);
    loser.input_weights{i} = reshape(L,size(loser.input_weights{i}));
    
    % inner weights
    for j = 1:config.num_reservoirs
        switch(config.SW_type)
            
            case 'topology'
                
                % change base graph
                W= winner.W{i,j};
                L = loser.W{i,j};
                f = find(adjacency(config.G{i,j}));
                pos = randperm(length(f),ceil(config.rec_rate*length(f)));
                L(f(pos)) = W(f(pos));
                loser.W{i,j} = L;
                
            case 'topology_plus_weights'
                % change SW weights - problem: will add more connections
                W_weights = winner.W{i,j};  % current graph
                L_weights = loser.W{i,j};  % current graph
                base_W_0 = adjacency(config.G{i,j});
                pos_chng = find(~base_W_0); % non-base weights
                
                w = find(W_weights(pos_chng));
                l = find(L_weights(pos_chng));
                
                pos = randperm(length(l),ceil(config.rec_rate*length(l)));
                L_weights(pos_chng(l(pos))) = W_weights(pos_chng(w(pos)));
                
                if length(find(W_weights(pos_chng))) ~= length(find(L_weights(pos_chng)))
                    error('SW not working');
                end
                loser.W{i,j} = L_weights;
                
                % change base graph
                W= winner.W{i,j};
                L = loser.W{i,j};
                f = find(adjacency(config.G{i,j}));
                pos = randperm(length(f),ceil(config.rec_rate*length(f)));
                L(f(pos)) = W(f(pos));
                loser.W{i,j} = L;
                
                %loser.connectivity = nnz(loser.W{i,j})/(length(loser.W{i,j}).^2);
            case 'watts_strogartz'
                % must maintain same number of total connections
                W= winner.W{i,j}(:);
                L = loser.W{i,j}(:);
                pos1 = randperm(length(L),ceil(config.rec_rate*length(L)));
                pos2 = randperm(length(L),ceil(config.rec_rate*length(L)));
                nnz_chk1 = nnz(L(pos1));
                nnz_chk2 = nnz(W(pos2));
                while(nnz_chk1 ~= nnz_chk2)
                    pos2 = randperm(length(W),ceil(config.rec_rate*length(W)));
                    nnz_chk2 = nnz(W(pos2));
                end
                L(pos2) = W(pos1);
        end
    end
    
    % mutate activ fcns
    if config.multi_activ
        W= winner.activ_Fcn(i,:);
        L = loser.activ_Fcn(i,:);
        pos = randperm(length(L),ceil(config.rec_rate*length(L)));
        L(pos) = W(pos);
        loser.activ_Fcn(i,:) = reshape(L,size(loser.activ_Fcn(i,:)));
    else
        W= winner.activ_Fcn;
        L = loser.activ_Fcn;
        pos = randperm(length(L),ceil(config.rec_rate*length(L)));
        L(pos) = W(pos);
        loser.activ_Fcn = reshape(L,size(loser.activ_Fcn));
    end
end

% for output weights
if config.evolve_output_weights
    W= winner.output_weights(:);
    L = loser.output_weights(:);
    pos = randperm(length(L),ceil(config.rec_rate*length(L)));
    L(pos) = W(pos);
    loser.output_weights = reshape(L,size(loser.output_weights));
end

% for feedback weights
if config.evolve_feedback_weights
    % params - W_scaling
    W= winner.feedback_scaling(:);
    L = loser.feedback_scaling(:);
    pos = randperm(length(L),ceil(config.rec_rate*length(L)));
    L(pos) = W(pos);
    loser.feedback_scaling = reshape(L,size(loser.feedback_scaling));
    
    W= winner.feedback_weights(:);
    L = loser.feedback_weights(:);
    pos = randperm(length(L),ceil(config.rec_rate*length(L)));
    L(pos) = W(pos);
    loser.feedback_weights = reshape(L,size(loser.feedback_weights));
end