function[statesExt,genotype] = collectDeepStates_IA_v2(genotype,inputSequence,config)

%if single input entry, add previous state
if size(inputSequence,1) == 1
    inputSequence = [zeros(size(inputSequence)); inputSequence];
end

for i= 1:genotype.nInternalUnits
    if size(inputSequence,1) == 2
        states{i} = genotype.last_state{i};
    else
        states{i} = zeros(size(inputSequence,1),genotype.esnMinor(i).nInternalUnits);
    end
    x{i} = zeros(size(inputSequence,1),genotype.esnMinor(i).nInternalUnits);
end


%equation: x(n) = f(Win*u(n) + S)
for n = 2:size(inputSequence,1)
    
    for i= 1:genotype.nInternalUnits
        for k= 1:genotype.nInternalUnits
            x{i}(n,:) = x{i}(n,:) + ((genotype.connectWeights{i,k}*genotype.interResScaling{i,k})*states{k}(n-1,:)')';
        end
        
        if iscell(genotype.reservoirActivationFunction)
            for p = 1:genotype.esnMinor(i).nInternalUnits            
                states{i}(n,p) = feval(genotype.reservoirActivationFunction{p},((genotype.esnMinor(i).inputWeights(p,:)*genotype.esnMinor(i).inputScaling)*([genotype.esnMinor(i).inputShift inputSequence(n,:)])')+ x{i}(n,p)'); 
            end
        else
            states{i}(n,:) = feval(genotype.reservoirActivationFunction,((genotype.esnMinor(i).inputWeights*genotype.esnMinor(i).inputScaling)*([genotype.esnMinor(i).inputShift inputSequence(n,:)])')+ x{i}(n,:)'); 
        end
    end
    
end


if config.leakOn
    for i= 1:genotype.nInternalUnits
        leakStates = zeros(size(states{i}));
        for n = 2:size(inputSequence,1)
            leakStates(n,:) = (1-genotype.esnMinor(i).leakRate)*leakStates(n-1,:)+ genotype.esnMinor(i).leakRate*states{i}(n,:);
        end
        states{i} = leakStates;
    end
end

statesExt = ones(size(states{1},1),1)*genotype.inputShift;
for i= 1:genotype.nInternalUnits
    statesExt = [statesExt states{i}];
%             subplot(1,2,i)
%             plot(states{i})
%             drawnow
    
    %assign last state variable
    genotype.last_state{i} = states{i}(end,:);
end

if config.AddInputStates == 1
    statesExt = [statesExt inputSequence];
end

statesExt = statesExt(config.nForgetPoints+1:end,:); % remove washout