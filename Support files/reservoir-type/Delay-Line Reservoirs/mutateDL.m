function genotype = mutateDL(genotype,config)

% mutate Mask
M = genotype.M(:);
pos =  randi([1 length(M)],round(config.mutRate*length(M)),1);
M(pos) = 2*(round(rand(length(pos),1))*0.1)-0.1; %mutate between -0.1 and 0.1    %(2*rand(length(pos),1)-1)*0.1;%
genotype.M = reshape(M,size(genotype.M));

% global paramters
% if rand < config.mutRate
%     genotype.Wscaling = 2*rand;
% end
% if rand < config.mutRate
%     genotype.inputScaling = rand;
% end

if rand < config.mutRate
    genotype.inputShift = 2*rand-1;
end
if rand < config.mutRate
    genotype.leakRate = rand;
end

% reservoir parameters
% if rand < config.mutRate
%     genotype.tau = 600;%round(round(((genotype.nInternalUnits*2)-genotype.nInternalUnits*genotype.time_step)*rand+(genotype.nInternalUnits*genotype.time_step))/10)*10;%min([genotype.nInternalUnits*2 round(rand*10)*100]);%round(genotype.theta*genotype.nInternalUnits);  % lenght of delay line
%     genotype.theta = genotype.tau/genotype.nInternalUnits; % distance between virtual nodes
% end

if rand < config.mutRate
    genotype.eta = rand;
end

if rand < config.mutRate
    genotype.gamma = rand;
end

if rand < config.mutRate
    genotype.p = max([1 round(20*rand)]);
end

% mutate output weights
if config.evolveOutputWeights
    outputWeights = genotype.outputWeights(:);
    pos =  randi([1 length(outputWeights)],round(config.mutRate*length(outputWeights)),1);
    outputWeights(pos) = 2*rand(length(pos),1)-1;
    genotype.outputWeights = reshape(outputWeights,size(genotype.outputWeights));
end

% mutate states to use
if config.evolvedOutputStates
    % state_loc
    for i = 1:length(genotype.state_loc)
        if rand < config.mutRate
            genotype.state_loc(i) = round(rand);
        end
    end  
    % update percent
    genotype.state_perc = sum(genotype.state_loc)/genotype.nTotalUnits;
end

end
