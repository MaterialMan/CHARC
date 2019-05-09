function genotype = mutateInstru(genotype,config)

%% change duration of instructions
configDuration = genotype.configDuration(:);
pos =  randperm(length(configDuration),round(config.mutRate*length(configDuration)));
configDuration(pos) = (round(10*rand(length(pos),1))+1)*100;
genotype.configDuration = reshape(configDuration,size(genotype.configDuration));

%% add/remove and change instructions
instrSeq = genotype.instrSeq(:);
if genotype.multiResInstru
    %can only change instrseq
    pos =  randperm(length(instrSeq),round(config.mutRate*length(instrSeq)));
    instrSeq(pos) = randi([1 length(config.database_genotype)],length(pos),1);
    genotype.instrSeq = reshape(instrSeq,size(genotype.instrSeq));
else
%     if round(rand) % mutate current gene
%         pos =  randperm(length(instrSeq),round(config.mutRate*length(instrSeq)));
%         instrSeq(pos) = randi([1 length(config.database_genotype)],length(pos),1);
%         genotype.instrSeq = reshape(instrSeq,size(genotype.instrSeq));
%         
%     elseif rand < 0.4 % add instruc 40% of time
%         pos =  randi([1 length(instrSeq)],1); % where to add instru
%         instrSeq = randi([1 length(config.database_genotype)],1); % what to add
%         genotype.instrSeq = [genotype.instrSeq(1:pos-1); instrSeq; genotype.instrSeq(pos:end)]; % add instr at pos
%         
%     else % remove instru 60% of time
%         if length(genotype.instrSeq) > 1% check more than one instru left
%             pos =  randi([1 length(instrSeq)],1); % where to add instru
%             genotype.instrSeq(pos) = [];
%         end
%     end
    
for i = 1:length(instrSeq)
    %add instr
    if rand < config.mutRate
         pos =  randi([1 length(instrSeq)],1); % where to add instru
        temp_instr = randi([1 length(config.database_genotype)],1); % what to add
        genotype.instrSeq = [genotype.instrSeq(1:pos); temp_instr; genotype.instrSeq(pos+1:end)]; % add instr at pos         
%         temp_instr = randi([1 length(config.database_genotype)],1);
%         genotype.instrSeq = [genotype.instrSeq; temp_instr];
    end
    %remove instr
    if rand < config.mutRate && length(genotype.instrSeq) > 1
        pos_instr = randi([1 length(genotype.instrSeq)],1);
        genotype.instrSeq(pos_instr) = [];
    end
    %replace inst
    if rand < config.mutRate
        pos_instr = randi([1 length(genotype.instrSeq)],1);
        temp_instr = randi([1 length(config.database_genotype)],1);
        genotype.instrSeq(pos_instr) = temp_instr;
    end
end
    
%      if round(rand) % mutate current gene
%         pos =  randperm(length(instrSeq),round(config.mutRate*length(instrSeq)));
%         instrSeq(pos) = randi([1 length(config.database_genotype)],length(pos),1);
%         genotype.instrSeq = reshape(instrSeq,size(genotype.instrSeq));
%         
%     elseif rand < 0.4 % add instruc 40% of time
%         pos =  randi([1 length(instrSeq)],1); % where to add instru
%         temp_instr = randi([1 length(config.database_genotype)],1); % what to add
%         genotype.instrSeq = [genotype.instrSeq(1:pos); temp_instr; genotype.instrSeq(pos+1:end)]; % add instr at pos
%         
%     else % remove instru 60% of time
%         if length(genotype.instrSeq) > 1% check more than one instru left
%             pos =  randi([1 length(instrSeq)],1); % where to add instru
%             genotype.instrSeq(pos) = [];
%         end
%     end
    
end

%% recalculate number of instr used
genotype.numInstr = length(genotype.instrSeq);


%% mutate output weights
if config.evolveOutputWeights
    outputWeights = genotype.outputWeights(:);
    pos =  randi([1 length(outputWeights)],round(config.mutRate*length(outputWeights)),1);
    outputWeights(pos) = 2*rand(length(pos),1)-1;
    genotype.outputWeights = reshape(outputWeights,size(genotype.outputWeights));
end

%% mutate states to use
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
