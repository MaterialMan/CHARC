function states = assessGraphReservoir(genotype,inputSequence,config)

if config.globalParams
    x1 = (genotype.w_in*genotype.inputScaling.*genotype.input_loc*inputSequence')';
    x = x1;
    
    if config.inputEval
        for t= 2:size(inputSequence,1)
            x(t,:) = feval(config.actvFunc,genotype.w_in*genotype.inputScaling*inputSequence(t,:) + (genotype.w*genotype.Wscaling*x(t-1,:)'));
        end
    else
        for t= 2:size(inputSequence,1)
            x(t,:) = feval(config.actvFunc,(genotype.w*genotype.Wscaling*x(t-1,:)').*~genotype.input_loc);
            x(t,:) = x(t,:) + x1(t,:);
        end
    end
    
    if config.leakOn
        for i= 1:genotype.nTotalUnits
            leakStates = zeros(size(x));
            for n = 2:size(inputSequence,1)
                leakStates(n,:) = (1-genotype.leakRate)*leakStates(n-1,:)+ genotype.leakRate*x(n,:);
            end
            x = leakStates;
        end
    end

    if config.AddInputStates
        states = [ones(size(inputSequence(config.nForgetPoints+1:end,:))) inputSequence(config.nForgetPoints+1:end,:) x(config.nForgetPoints+1:end,:)];
    else
        %states = [ones(size(inputSequence(config.nForgetPoints+1:end,:))) x(config.nForgetPoints+1:end,:)];
        states =  x(config.nForgetPoints+1:end,:);
    end
    
else % no global params
    x1 = (genotype.w_in.*genotype.input_loc*inputSequence')';
    x = x1;
    
    if config.inputEval
        for t= 2:size(inputSequence,1)
            x(t,:) = feval(config.actvFunc,genotype.w_in*inputSequence(t,:) + (genotype.w*x(t-1,:)'));
        end
    else
        for t= 2:size(inputSequence,1)
            x(t,:) = feval(config.actvFunc,(genotype.w*x(t-1,:)').*~genotype.input_loc);
            x(t,:) = x(t,:) + x1(t,:);
        end
    end
    
    if config.AddInputStates
        states = [ones(size(inputSequence(config.nForgetPoints+1:end,:),1)) inputSequence(config.nForgetPoints+1:end,:) x(config.nForgetPoints+1:end,:)];
    else
        states = [ones(size(inputSequence(config.nForgetPoints+1:end,:),1)) x(config.nForgetPoints+1:end,:)];
    end
    
end

if config.plotStates
    for i = 1:size(states)
        subplot(2,1,1)
        if i > 25
            plot(states(i-25:i,:))
            xticks(1:2:25)
            xticklabels(i-25:2:i)
        else
            plot(states(1:i,:))
        end
        subplot(2,1,2)
        p = plot(genotype.G,'NodeLabel',{});
        p.NodeCData = states(i,:);
        p.EdgeCData = genotype.G.Edges.Weight;
        colormap(bluewhitered)
        drawnow
        pause(0.01)
    end
end

end
