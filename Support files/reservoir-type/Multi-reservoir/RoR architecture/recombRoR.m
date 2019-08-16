%% Infection phase
function loser = recombRoR(winner,loser,config)

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

% params - W_scaling
W= winner.W_scaling(:);
L = loser.W_scaling(:);
pos = randperm(length(L),ceil(config.rec_rate*length(L)));
L(pos) = W(pos);
loser.W_scaling = reshape(L,size(loser.W_scaling));

% cycle through sub-reservoirs
for i = 1:config.num_reservoirs
    
    % input weights
    W= winner.input_weights{i}(:);
    L = loser.input_weights{i}(:);
    pos = randperm(length(L),ceil(config.rec_rate*length(L)));         
    L(pos) = W(pos);
    loser.input_weights{i} = reshape(L,size(loser.input_weights{i}));
       
    % inner weights
    for j = 1:config.num_reservoirs
        W= winner.W{i,j}(:);
        L = loser.W{i,j}(:);
        pos = randperm(length(L),ceil(config.rec_rate*length(L)));         
        L(pos) = W(pos);
        loser.W{i,j} = reshape(L,size(loser.W{i,j}));
    end   
    
    % mutate activ fcns
    if size(loser.activ_Fcn,2) > 1
        W= winner.activ_Fcn(i,:);
        L = loser.activ_Fcn(i,:);
        pos = randperm(length(L),ceil(config.rec_rate*length(L)));         
        L(pos) = W(pos);
        loser.activ_Fcn(i,:) = reshape(L,size(loser.activ_Fcn(i,:)));
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
