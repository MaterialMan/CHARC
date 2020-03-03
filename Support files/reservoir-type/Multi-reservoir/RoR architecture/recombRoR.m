%% Infection phase
function loser = recombRoR(winner,loser,config)

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
    pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));     %sum(rand(length(L),1) < config.rec_rate)     
    L(pos) = W(pos);
    loser.input_weights{i} = reshape(L,size(loser.input_weights{i}));
       
    % inner weights
    for j = 1:config.num_reservoirs
        if (config.undirected_ensemble && i ~= j) || (config.undirected && i == j)
            W= triu(winner.W{i,j});
            L = triu(loser.W{i,j});
            f = find(W);
            pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate)); 
            %pos = randperm(length(f),ceil(config.rec_rate*length(f)));
            L(f(pos)) = W(f(pos));
            L = triu(L)+triu(L,1)';
            loser.W{i,j} = L;
        else             
            W= winner.W{i,j}(:);
            L = loser.W{i,j}(:);
            pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate)); 
            %pos = randperm(length(L),ceil(config.rec_rate*length(L)));
            L(pos) = W(pos);
            loser.W{i,j} = reshape(L,size(loser.W{i,j}));
        end        
    end   
    
    % mutate activ fcns
    if config.multi_activ
        W= winner.activ_Fcn(i,:);
        L = loser.activ_Fcn(i,:);
        pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));          
        L(pos) = W(pos);
        loser.activ_Fcn(i,:) = reshape(L,size(loser.activ_Fcn(i,:)));
    else
        W= winner.activ_Fcn;
        L = loser.activ_Fcn;
        pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));          
        L(pos) = W(pos);
        loser.activ_Fcn = reshape(L,size(loser.activ_Fcn));
    end
    
    
    if config.iir_filter_on
        for k = 1:size(winner.iir_weights,2)
            W= winner.iir_weights{i,k};
            L = loser.iir_weights{i,k};
            pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate)); 
            L(pos,:) = W(pos,:);
            loser.iir_weights{i,k} = reshape(L,size(loser.iir_weights{i,k}));
        end
    end
end

% for output weights
if config.evolve_output_weights
    W= winner.output_weights(:);
    L = loser.output_weights(:);
    pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));          
    L(pos) = W(pos);
    loser.output_weights = reshape(L,size(loser.output_weights));
end

% for feedback weights
if config.evolve_feedback_weights
    % params - W_scaling
    W= winner.feedback_scaling(:);
    L = loser.feedback_scaling(:);
    pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate)); 
    L(pos) = W(pos);
    loser.feedback_scaling = reshape(L,size(loser.feedback_scaling));

    W= winner.feedback_weights(:);
    L = loser.feedback_weights(:);
    pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));         
    L(pos) = W(pos);
    loser.feedback_weights = reshape(L,size(loser.feedback_weights));
end