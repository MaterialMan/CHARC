function [esnMinor,esnMajor] = mutateLoser_plusMutateActivation(esnMinor,esnMajor,loser,pos,maxMinorUnits)

mutateType = sum(rand >= cumsum([0.15,0.15,0.1,0.1,0.1,0.2,0.2]));
%mutateType = sum(rand >= cumsum([0,0,0,1,1,0,0]));

switch(mutateType)
    case 0
        if isempty(esnMinor(loser,pos).nInternalUnits)
        else
            esnMinor(loser,pos).spectralRadius = 2*rand;
            esnMinor(loser,pos).internalWeights = esnMinor(loser,pos).spectralRadius * esnMinor(loser,pos).rho;
        end
    case 1
        if isempty(esnMinor(loser,pos).nInternalUnits)
        else
            esnMinor(loser,pos).inputScaling = 2*rand-1;
        end
    case 2
        if isempty(esnMinor(loser,pos).nInternalUnits)
        else
            esnMinor(loser,pos).leakRate = rand;
        end
    case 3 %add new/replace major
        esnMinor(loser,pos).spectralRadius = 2*rand;
        esnMinor(loser,pos).inputScaling = 2*rand-1;
        esnMinor(loser,pos).leakRate = rand;
        esnMinor(loser,pos).inputShift = 1;
        
        esnMinor(loser,pos).nInternalUnits = randi([2 maxMinorUnits]);
        %weights
        esnMinor(loser,pos).inputWeights = (2.0 * rand(esnMinor(loser,pos).nInternalUnits, esnMajor(loser).nInputUnits+1)- 1.0);%*esn.inputScaling;
        %initialise new reservoir
        esnMinor(loser,pos).connectivity = min([10/esnMinor(loser,pos).nInternalUnits 1]);
        esnMinor(loser,pos).internalWeights_UnitSR = generate_internal_weights(esnMinor(loser,pos).nInternalUnits, ...
            esnMinor(loser,pos).connectivity);
        esnMinor(loser,pos).rho = esnMinor(loser,pos).internalWeights_UnitSR;%/max(abs(eigs(esnMinor(loser,pos).internalWeights_UnitSR)));
        esnMinor(loser,pos).internalWeights = esnMinor(loser,pos).spectralRadius * esnMinor(loser,pos).rho;
        
        %update esnMajor weights
        esnMajor(loser)= changeMajorWeights(esnMajor(loser),pos,esnMinor(loser,:));
        
    case 4 %remove contents of major, i.e. all minor nodes
        %removed = [removed pos];
        if esnMajor(loser).nInternalUnits > 2
            esnMinor(loser,pos) = removeMinorValues_ext(esnMinor(loser,pos));
            esnMajor(loser)= changeMajorWeights(esnMajor(loser),pos,esnMinor(loser,:));
        end
        %esnMajor(loser) = recountMajorInternalUnits(esnMinor(pos));
        
    case 5 %add, or remove weight in contents of major (between minor units)
        if isempty(esnMinor(loser,pos).nInternalUnits)
        else
            if rand < 0.5
                if rand < 0.5
                    esnMinor(loser,pos) = removeWeight(esnMinor(loser,pos),'input');
                else
                    esnMinor(loser,pos) = addWeight(esnMinor(loser,pos),'input');
                end
            else
                if rand < 0.5
                    esnMinor(loser,pos) = removeWeight(esnMinor(loser,pos),'internal');
                else
                    esnMinor(loser,pos) = addWeight(esnMinor(loser,pos),'internal');
                end
            end
            esnMinor(loser,pos).rho = esnMinor(loser,pos).internalWeights_UnitSR;%/max(abs(eigs(esnMinor(loser,pos).internalWeights_UnitSR)));
            esnMinor(loser,pos).internalWeights = esnMinor(loser,pos).spectralRadius * esnMinor(loser,pos).internalWeights_UnitSR;
            %make sure both are the same
            esnMajor(loser).connectWeights{pos,pos} = esnMinor(loser,pos).internalWeights;
        end
    case 6 %change nodes inside major, i.e. add/remove minor units
        if isempty(esnMinor(loser,pos).nInternalUnits)
        else
            if rand < 0.5
                [esnMinor(loser,pos),N] = removeNode(esnMinor(loser,pos));
                if N >0
                    esnMajor(loser) = adaptMajorWeights(esnMajor(loser),pos,esnMinor(loser,:),N,0);
                end
            else
                 [esnMinor(loser,pos),N] = addNodeMicroGA_Deep(esnMinor(loser,pos));   %addNode
                 if N >0
                    esnMajor(loser)= adaptMajorWeights(esnMajor(loser),pos,esnMinor(loser,:),N,1);
                 end
             end
            esnMinor(loser,pos).rho = esnMinor(loser,pos).internalWeights_UnitSR;%/max(abs(eigs(esnMinor(loser,pos).internalWeights_UnitSR)));
            esnMinor(loser,pos).internalWeights = esnMinor(loser,pos).spectralRadius * esnMinor(loser,pos).internalWeights_UnitSR;
            %make sure both are the same
            esnMajor(loser).connectWeights{pos,pos} = esnMinor(loser,pos).internalWeights;
        end
        
    case 7
        true = 1;
        while(true)
            activList = {'ReLU';'tanh';'softplus';'logistic'};%;'linearNode'
            tempActiv = char(activList(randi([1 length(activList)])));
            if ~strcmp(esnMajor(loser).reservoirActivationFunction, tempActiv)
                esnMajor(loser).reservoirActivationFunction = tempActiv;
                true = 0;
            end
        end
end