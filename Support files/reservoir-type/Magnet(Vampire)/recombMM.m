%% Infection phase
function loser = recombMM(winner,loser,config)

source_num = size(loser.minposx, 2);

for i = 1:source_num
    if rand < config.rec_rate
        loser.minposx(i) = winner.minposx(i);
        loser.maxposx(i) = winner.maxposx(i);
    end
end


for i = 1:source_num
    if rand < config.rec_rate
        loser.minposy(i) = winner.minposy(i);
        loser.maxposy(i) = winner.maxposy(i);
    end
end

if rand < config.rec_rate
   loser.damping = winner.damping;
   loser.anisotropy = winner.anisotropy;
   loser.temperature = winner.temperature;
   loser.exchange = winner.exchange;
   loser.magmoment = winner.magmoment;
end


for i = 1:source_num
    if rand < config.rec_rate
        loser.signalmagnitude(i) = winner.signalmagnitude(i);
    end
end
