%% recombBZ.m
% Used to recombine BZ-specific parameters

function loser = recombBZ(winner,loser,config)

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

W= winner.a(:);
L = loser.a(:);
pos = randperm(length(L),ceil(config.rec_rate*length(L)));
L(pos) = W(pos);
loser.a = reshape(L,size(loser.a));

W= winner.b(:);
L = loser.b(:);
pos = randperm(length(L),ceil(config.rec_rate*length(L)));
L(pos) = W(pos);
loser.b = reshape(L,size(loser.b));

W= winner.c(:);
L = loser.c(:);
pos = randperm(length(L),ceil(config.rec_rate*length(L)));
L(pos) = W(pos);
loser.c = reshape(L,size(loser.c));

% cycle through sub-reservoirs
for i = 1:config.num_reservoirs
    
    for r = 1:3
        % input weights
        W= winner.input_weights{i,r}(:);
        L = loser.input_weights{i,r}(:);
        pos = randperm(length(L),ceil(config.rec_rate*length(L)));
        L(pos) = W(pos);
        loser.input_weights{i,r} = reshape(L,size(loser.input_weights{i,r}));
        
        % input widths
        W= winner.input_widths{i,r}(:);
        L = loser.input_widths{i,r}(:);
        pos = randperm(length(L),ceil(config.rec_rate*length(L)));
        L(pos) = W(pos);
        loser.input_widths{i,r} = reshape(L,size(loser.input_widths{i,r}));
        
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
