function[statesExt] = collectDeepStates_nonIA(genotype,inputSequence,config)    

%% Collect states for plain ESN
    for i= 1:genotype.nInternalUnits
        states{i} = zeros(size(inputSequence,1),genotype.esnMinor(i).nInternalUnits);
        x{i} = zeros(size(inputSequence,1),genotype.esnMinor(i).nInternalUnits);
    end
    
    %equation: x(n) = f(Win*u(n) + S)
    for i= 1:genotype.nInternalUnits
        temp_states = [];
        for n = 2:length(inputSequence(:,1))
            for k= 1:genotype.nInternalUnits
                x{i}(n,:) = x{i}(n,:) + (genotype.connectWeights{i,k}*states{k}(n-1,:)')';
            end
            
            if size(genotype.reservoirActivationFunction,1) > 1
                states{i}(n,:) = feval(char(genotype.reservoirActivationFunction{i}),((genotype.esnMinor(i).inputWeights*genotype.esnMinor(i).inputScaling)*([genotype.esnMinor(i).inputShift inputSequence(n,:)])')+x{i}(n,:)');
            else
                if i == 1
                    states{i}(n,:) = feval(genotype.reservoirActivationFunction,((genotype.esnMinor(i).inputWeights*genotype.esnMinor(i).inputScaling)*([genotype.esnMinor(i).inputShift inputSequence(n,:)])')+x{i}(n,:)'); %n-1
                else
                     states{i}(n,:) = feval(genotype.reservoirActivationFunction,x{i}(n,:)'); %n-1
                end
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