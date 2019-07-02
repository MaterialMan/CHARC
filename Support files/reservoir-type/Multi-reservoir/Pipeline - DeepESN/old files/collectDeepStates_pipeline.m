function [statesExt] = collectDeepStates_pipeline(genotype,inputSequence,config)    

%% Collect states for plain ESN
    for i= 1:genotype.nInternalUnits
        states{i} = zeros(size(inputSequence,1),genotype.esnMinor(i).nInternalUnits);
    end
    
    %equation: x(n) = f(Win*u(n) + S)
    for i= 1:genotype.nInternalUnits
        for n = 2:length(inputSequence(:,1))          
            if i == 1
                states{i}(n,:) = feval(genotype.reservoirActivationFunction,((genotype.esnMinor(i).inputWeights*genotype.esnMinor(i).inputScaling)*([genotype.esnMinor(i).inputShift inputSequence(n,:)])')+ genotype.connectWeights{i,i}*states{i}(n-1,:)'); %n-1
            else
                 states{i}(n,:) = feval(genotype.reservoirActivationFunction,((genotype.esnMinor(i).inputWeights*genotype.esnMinor(i).inputScaling)*([genotype.esnMinor(i).inputShift states{i-1}(n,:)])')+ genotype.connectWeights{i,i}*states{i}(n-1,:)'); %n-1
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