function loser = recombDL(winner,loser,config)

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

% cycle through sub-reservoirs
for i = 1:config.num_reservoirs
    
    % input weights
    W= winner.input_weights{i}(:);
    L = loser.input_weights{i}(:);
    pos = randi([1 length(L)],ceil(config.rec_rate*length(L)),1);
    L(pos) = W(pos);
    loser.input_weights{i} = reshape(L,size(loser.input_weights{i}));
    
    % reservoir parameters
    temp_winner = [winner.eta(i) winner.gamma(i) winner.p(i)];
    temp_loser = [loser.eta(i) loser.gamma(i) loser.p(i)];
    pos = randi([1 length(temp_loser)],ceil(config.rec_rate*length(temp_loser)),1);
    temp_loser(pos) = temp_winner(pos);
    
    loser.eta(i) = temp_loser(1);
    loser.gamma(i) = temp_loser(2);
    loser.p(i) = temp_loser(3);
       
end

% for output weights
if config.evolve_output_weights
    W= winner.output_weights(:);
    L = loser.output_weights(:);
    pos = randi([1 length(L)],ceil(config.rec_rate*length(L)),1);
    L(pos) = W(pos);
    loser.output_weights = reshape(L,size(loser.output_weights));
end







