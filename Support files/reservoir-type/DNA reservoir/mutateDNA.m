function genotype = mutateDNA(genotype,config)

if rand < config.mutRate
    genotype.inputScaling = 2*rand;
end

% h the fraction of the reactor chamber that is well-mixed
h = genotype.H(:);
pos =  randi([1 length(h)],ceil(config.mutRate*length(h)),1);
h(pos) = rand(length(pos),1);
genotype.H = reshape(h,size(genotype.H));

% volume of the reactor; V in nL
v = genotype.V(:).*1e+8;
pos =  randi([1 length(v)],ceil(config.mutRate*length(v)),1);
v(pos) = rand(length(pos),1);
genotype.V = reshape(v,size(genotype.V)).*1e-8;

% initial concentrations: S
P0 = genotype.P0(:);
pos =  randi([1 length(P0)],ceil(config.mutRate*length(P0)),1);
P0(pos) = randi([0 1000],length(pos),1);
genotype.P0 = reshape(P0,size(genotype.P0));

% initial concentrations: P
S0 = genotype.S0(:);
pos =  randi([1 length(S0)],ceil(config.mutRate*length(S0)),1);
S0(pos) = randi([0 1000],length(pos),1);
genotype.S0 = reshape(S0,size(genotype.S0));

% gate concentrations
GateCon = genotype.GateCon(:);
pos =  randi([1 length(GateCon)],ceil(config.mutRate*length(GateCon)),1);
GateCon(pos) = randi([0 2500],length(pos),1);
genotype.GateCon = reshape(GateCon,size(genotype.GateCon));


% input weights
w_in = genotype.w_in(:);
pos =  randi([1 length(w_in)],ceil(config.mutRate*length(w_in)),1);
if config.restricedWeight
    w_in(pos) = datasample(0.2:0.2:1,length(pos));%2*rand(length(pos),1)-1;
else
    w_in(pos) = 2*rand(length(pos),1)-1;
end
genotype.w_in = reshape(w_in,size(genotype.w_in));

% % input_loc
% for i = 1:length(genotype.input_loc)
%     if rand < config.mutRate
%         genotype.input_loc(i) = round(rand);
%     end
% end
% genotype.totalInputs = sum(genotype.input_loc);


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

