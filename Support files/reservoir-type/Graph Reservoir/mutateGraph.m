function genotype = mutateGraph(genotype,config)

% w
if config.directedGraph
    for j = 1:length(genotype.w)
        if rand < config.mutRate
            Ne = neighbors(config.G,j);
            genotype.w(Ne,j) = 2*rand(length(Ne),1)-1;
            genotype.w(j,Ne) = 2*rand(1,length(Ne))-1;
        end
    end
else
    w = genotype.G.Edges.Weight;
    pos =  randi([1 length(w)],round(config.mutRate*length(w)),1);
    w(pos) = 2*rand(length(pos),1)-1;
    genotype.G.Edges.Weight = w;
    
    A = table2array(genotype.G.Edges);
    genotype.w = zeros(size(genotype.G.Nodes,1));
    
    for j = 1:size(genotype.G.Edges,1)
        genotype.w(A(j,1),A(j,2)) = A(j,3);
    end
end

% w_in
w_in = genotype.w_in(:);
pos =  randi([1 length(w_in)],round(config.mutRate*length(w_in)),1);
w_in(pos) = 2*rand(length(pos),1)-1;
genotype.w_in = reshape(w_in,size(genotype.w_in));

% input_loc
for i = 1:length(genotype.input_loc)
    if rand < config.mutRate
        genotype.input_loc(i) = round(rand);
    end
end

genotype.totalInputs = sum(genotype.input_loc);

if config.globalParams   
    if rand < config.mutRate
        genotype.Wscaling = 2*rand;
    end
    if rand < config.mutRate%alters network dynamics and memory, SR < 1 in almost all cases
        genotype.inputScaling = 2*rand-1;
    end
    if rand < config.mutRate%increases nonlinearity
        genotype.inputShift = 2*rand-1;
    end
    if rand < config.mutRate%adds bias/value shift to input signal
        genotype.leakRate = rand;
    end
end

if config.evolveOutputWeights
    outputWeights = genotype.outputWeights(:);
    pos =  randi([1 length(outputWeights)],round(config.mutRate*length(outputWeights)),1);
    outputWeights(pos) = 2*rand(length(pos),1)-1;
    genotype.outputWeights = reshape(outputWeights,size(genotype.outputWeights));
end

end
