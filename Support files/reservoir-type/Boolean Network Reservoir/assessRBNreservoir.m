function [states,node]= assessRBNreservoir(genotype,inputSequence,config)   

%if single input entry, add previous state  -- not integrated
% if size(inputSequence,1) == 1
%     inputSequence = [zeros(size(inputSequence)); inputSequence];
% end
% 
% % add last state
% if size(inputSequence,1) == 2
%     states = genotype.last_state;
% else
%     states = zeros(size(inputSequence,1),genotype.nTotalUnits);
% end

%% RBN
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
    states = [inputSequence(config.nForgetPoints+1:end,:) states];
end
