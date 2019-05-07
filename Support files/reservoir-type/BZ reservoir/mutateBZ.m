function genotype = mutateBZ(genotype,config)


a = genotype.a(:);
pos =  randi([1 length(a)],round(config.mutRate*length(a)),1);
a(pos) = rand(length(pos),1);
genotype.a = reshape(a,size(genotype.a));

b = genotype.b(:);
pos =  randi([1 length(b)],round(config.mutRate*length(b)),1);
b(pos) = rand(length(pos),1);
genotype.b = reshape(a,size(genotype.b));

c = genotype.c(:);
pos =  randi([1 length(c)],round(config.mutRate*length(c)),1);
c(pos) = rand(length(pos),1);
genotype.c = reshape(c,size(genotype.c));

% w_in
w_in = genotype.w_in(:);
pos =  randi([1 length(w_in)],round(config.mutRate*length(w_in)),1);
if config.restricedWeight
    w_in(pos) = datasample(0.2:0.2:1,length(pos));%2*rand(length(pos),1)-1;
else
    w_in(pos) = 2*rand(length(pos),1)-1;
end
genotype.w_in = reshape(w_in,size(genotype.w_in));

% input_loc
for i = 1:length(genotype.input_loc)
    if rand < config.mutRate
        genotype.input_loc(i) = round(rand);
    end
end

if rand < config.mutRate %not really used, yet
    genotype.dot_perc = rand;
end

if config.evolvedOutputStates
    
    if rand < config.mutRate %not really used, yet
        genotype.state_perc = rand;
    end
    
    % state_loc
    for i = 1:length(genotype.state_loc)
        if rand < config.mutRate
            genotype.state_loc(i) = round(rand);
        end
    end

end

genotype.totalInputs = sum(genotype.input_loc);