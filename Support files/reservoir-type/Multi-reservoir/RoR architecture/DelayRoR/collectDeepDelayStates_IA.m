function[statesExt] = collectDeepDelayStates_IA(genotype,inputSequence,config)

%% Collect states for plain ESN
for i= 1:genotype.nInternalUnits
    states{i} = zeros(size(inputSequence,1),genotype.esnMinor(i).nInternalUnits);
    x{i} = zeros(size(inputSequence,1),genotype.esnMinor(i).nInternalUnits);
end

if iscell(genotype.reservoirActivationFunction) 
    activ = genotype.reservoirActivationFunction;
    A    = cell(1, genotype.esnMinor(i).nInternalUnits);
    A(:) = {'tanh'};
    B    = cell(1, genotype.esnMinor(i).nInternalUnits);
    B(:) = {'linearNode'};

end
    
%equation: x(n) = f(Win*u(n) + S)
for i= 1:genotype.nInternalUnits
    temp_states = [];
    for n = genotype.esnMinor(i).Dmax+2:length(inputSequence(:,1))
        for k= 1:genotype.nInternalUnits
            x{i}(n,:) = x{i}(n,:) + ((genotype.connectWeights{i,k}*states{k}(n-1,:)')');
        end
        
        x{i}(n,:) = x{i}(n,:) + genotype.esnMinor(i).delayWeights*states{k}(n-genotype.esnMinor(i).Dw,:);
        
        if iscell(genotype.reservoirActivationFunction)
            tempstates_tanh = feval('tanh',((genotype.esnMinor(i).inputWeights*genotype.esnMinor(i).inputScaling)*([genotype.esnMinor(i).inputShift inputSequence(n,:)])')+x{i}(n,:)');
            tempstates_lin = feval('linearNode',((genotype.esnMinor(i).inputWeights*genotype.esnMinor(i).inputScaling)*([genotype.esnMinor(i).inputShift inputSequence(n,:)])')+x{i}(n,:)');
      
            index_tanh = cellfun(@strcmp, activ(i,:), A);
            index_lin = cellfun(@strcmp, activ(i,:), B);
            
            states{i}(n,index_tanh) = tempstates_tanh(index_tanh);
            states{i}(n,index_lin) = tempstates_lin(index_lin);
            
        else
            states{i}(n,:) = feval(genotype.reservoirActivationFunction,((genotype.esnMinor(i).inputWeights*genotype.esnMinor(i).inputScaling)*([genotype.esnMinor(i).inputShift inputSequence(n,:)])')+x{i}(n,:)'); %n-1
        end
    end
    
end

if config.leakOn
    for i= 1:genotype.nInternalUnits
        leakStates = zeros(size(states{i}));
        for n = 2:length(inputSequence(:,1))
            leakStates(n,:) = (1-genotype.esnMinor(i).leakRate)*leakStates(n-1,:)+ genotype.esnMinor(i).leakRate*states{i}(n,:);
        end
        states{i} = leakStates;
    end
end

statesExt = ones(size(states{1},1),1)*genotype.inputShift;
    for i= 1:genotype.nInternalUnits
        statesExt = [statesExt states{i}];
    end
       
    if config.AddInputStates == 1
        statesExt = [statesExt inputSequence];
    end


statesExt = statesExt(config.nForgetPoints+1:end,:); % remove washout