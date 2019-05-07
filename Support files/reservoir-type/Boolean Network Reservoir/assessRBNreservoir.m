function [states,node]= assessRBNreservoir(genotype,inputSequence,config)   

node = genotype.node;                       % nodes in RBN
fHandle = genotype.RBNtype;                 % update routine
datalength = size(inputSequence,1);         % data length

% multiply by input weights
inputSequence = round((1+sign(inputSequence*genotype.w_in'))/2);

% evolve network in specified update mode
[node, states] = feval(fHandle,node,datalength,inputSequence,genotype);
states = states(:,2:end)';      

if config.leakOn      
    states = getLeakStates(states,genotype,config);
end

if config.evolvedOutputStates
    states= states(config.nForgetPoints+1:end,logical(genotype.state_loc));
else
    states= states(config.nForgetPoints+1:end,:);
end

if config.AddInputStates
    states = [ones(size(inputSequence(config.nForgetPoints+1:end,1))) inputSequence(config.nForgetPoints+1:end,:) states];
else
    %states = [ones(size(inputSequence(config.nForgetPoints+1:end,1))) states];
end
