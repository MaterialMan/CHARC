function states = getLeakStates(states,genotype,config)

leakStates = zeros(size(states));

for n = 2:size(states,1)
    leakStates(n,:) = (1-genotype.leakRate)*leakStates(n-1,:)+ genotype.leakRate*states(n,:);
end

states = leakStates;

if config.discrete
    states = round((1+sign(states))/2);
end