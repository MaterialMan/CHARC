%% Infection phase
function loser = recombWave(winner,loser,config)

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

% params -
W= winner.time_period(:);
L = loser.time_period(:);
pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));
L(pos) = W(pos);
loser.time_period = reshape(L,size(loser.time_period));

W= winner.wave_speed(:);
L = loser.wave_speed(:);
pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));
L(pos) = W(pos);
loser.wave_speed = reshape(L,size(loser.wave_speed));

W= winner.damping_constant(:);
L = loser.damping_constant(:);
pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));
L(pos) = W(pos);
loser.damping_constant = reshape(L,size(loser.damping_constant));

% cycle through sub-reservoirs
for i = 1:config.num_reservoirs
    
    % boundary conditions
    pos = randi([1 config.num_reservoirs]);
    W= winner.boundary_conditions(pos,:);
    loser.boundary_conditions(pos,:) = reshape(W,size(loser.boundary_conditions(pos,:)));
   
    
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
    
    % inner weights
    for j = 1:config.num_reservoirs
        W= winner.W{i,j}(:);
        L = loser.W{i,j}(:);
        pos = randperm(length(L),ceil(config.rec_rate*length(L)));
        L(pos) = W(pos);
        loser.W{i,j} = reshape(L,size(loser.W{i,j}));
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
