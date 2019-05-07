function [statesExt] = collectDeepStates_ELM(genotype,inputSequence,config)

%% Collect states for plain ESN
for i= 1:genotype.nInternalUnits
    states{i} = zeros(size(inputSequence,1),genotype.esnMinor(i).nInternalUnits);
end

%equation: x(n) = f(W*u(n) + b) -- does not work with multiactiv yet
for i= 1:genotype.nInternalUnits
    for n = 2:length(inputSequence(:,1))
        if i == 1
            states{i}(n,:) = feval(genotype.reservoirActivationFunction,(inputSequence(n,:)*genotype.esnMinor(i).inputScaling)*(genotype.connectWeights{i,i}*genotype.esnMinor(i).spectralRadius) + genotype.esnMinor(i).bias');
        else
            states{i}(n,:) = feval(genotype.reservoirActivationFunction,states{i-1}(n,:)*genotype.connectWeights{i,i} + genotype.esnMinor(i).bias');
        end
    end
    
end


% combine states or only final states
if config.allStates
    statesExt = [];
    for i= 1:genotype.nInternalUnits
        statesExt = [statesExt states{i}];
    end
else
    statesExt = states{genotype.nInternalUnits}; %final states
end


if config.AddInputStates == 1
    statesExt = [statesExt inputSequence];
end

statesExt = statesExt(config.nForgetPoints+1:end,:); % remove washout