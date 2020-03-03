%% Infection phase
function loser = recombCNT(winner,loser,config)

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


% cycle through sub-reservoirs
for i = 1:config.num_reservoirs
    
    % input weights
    W= winner.input_weights{i}(:);
    L = loser.input_weights{i}(:);
    pos = randperm(length(L),ceil(config.rec_rate*length(L)));         
    L(pos) = W(pos);
    loser.input_weights{i} = reshape(L,size(loser.input_weights{i}));
       
    % electrode_type
    W= winner.electrode_type(i,:);
    L = loser.electrode_type(i,:);
    pos = randperm(length(L),ceil(config.rec_rate*length(L)));         
    L(pos) = W(pos);
    loser.electrode_type(i,:) = reshape(L,size(loser.electrode_type(i,:)));
       
    % config voltage
    W= winner.config_voltage(i,:);
    L = loser.config_voltage(i,:);
    pos = randperm(length(L),ceil(config.rec_rate*length(L)));         
    L(pos) = W(pos);
    loser.config_voltage(i,:) = reshape(L,size(loser.config_voltage(i,:)));
              
end

% for output weights
if config.evolve_output_weights
    W= winner.output_weights(:);
    L = loser.output_weights(:);
    pos = randperm(length(L),ceil(config.rec_rate*length(L)));         
    L(pos) = W(pos);
    loser.output_weights = reshape(L,size(loser.output_weights));
end
