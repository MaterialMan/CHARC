%% Infection phase - need to update
function loser = recombMM(winner,loser,config)

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

%% magnet params
W= winner.damping(:);
L = loser.damping(:);
pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));         
L(pos) = W(pos);
loser.damping = reshape(L,size(loser.damping));

W= winner.anisotropy(:);
L = loser.anisotropy(:);
pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));         
L(pos) = W(pos);
loser.anisotropy = reshape(L,size(loser.anisotropy));

W= winner.temperature(:);
L = loser.temperature(:);
pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));         
L(pos) = W(pos);
loser.temperature = reshape(L,size(loser.temperature));

W= winner.exchange(:);
L = loser.exchange(:);
pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));         
L(pos) = W(pos);
loser.exchange = reshape(L,size(loser.exchange));

W= winner.magmoment(:);
L = loser.magmoment(:);
pos = randperm(length(L),sum(rand(length(L),1) < config.rec_rate));         
L(pos) = W(pos);
loser.magmoment = reshape(L,size(loser.magmoment));

%% inputs
for i = 1:config.num_reservoirs
    
    % input weights
    W= winner.input_weights{i}(:);
    L = loser.input_weights{i}(:);
    pos = randperm(length(L),ceil(config.rec_rate*length(L)));    %sum(rand(length(L),1) < config.rec_rate)     
    L(pos) = W(pos);
    loser.input_weights{i} = reshape(L,size(loser.input_weights{i}));
 
    % input positions
    Wmin= winner.minpos{i}(:);
    Lmin = loser.minpos{i}(:);
    Wmax= winner.maxpos{i}(:);
    Lmax = loser.maxpos{i}(:);
    
    pos = randperm(length(Lmin),ceil(config.rec_rate*length(Lmin)));    %sum(rand(length(L),1) < config.rec_rate)     
    Lmin(pos) = Wmin(pos);
    Lmax(pos) = Wmax(pos);
    
    loser.minpos{i} = reshape(Lmin,size(loser.minpos{i}));
    loser.maxpos{i} = reshape(Lmax,size(loser.maxpos{i}));
    
end

%% %% fernandos code


% source_num = size(loser.minposx, 2);
% 
% for i = 1:source_num
%     if rand < config.rec_rate
%         loser.minposx(i) = winner.minposx(i);
%         loser.maxposx(i) = winner.maxposx(i);
%     end
% end
% 
% 
% for i = 1:source_num
%     if rand < config.rec_rate
%         loser.minposy(i) = winner.minposy(i);
%         loser.maxposy(i) = winner.maxposy(i);
%     end
% end

% if rand < config.rec_rate
%    loser.damping = winner.damping;
%    loser.anisotropy = winner.anisotropy;
%    loser.temperature = winner.temperature;
%    loser.exchange = winner.exchange;
%    loser.magmoment = winner.magmoment;
% end


% for i = 1:source_num
%     if rand < config.rec_rate
%         loser.input_weights(i) = winner.input_weights(i);
%     end
% end
