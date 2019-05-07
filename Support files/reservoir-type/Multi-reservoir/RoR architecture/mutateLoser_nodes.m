function [esnMinor,esnMajor] = mutateLoser_nodes(esnMinor,esnMajor,loser,pos,maxMinorUnits)

%mutateType = sum(rand >= cumsum([0.15,0.15,0.1,0.1,0.1,0.2,0.2]));
if ~isempty(esnMinor(loser,pos).nInternalUnits)

flag = 1;
while(flag)
    mutateType = sum(rand >= cumsum([0.3,0.3,0.4]));
    if mutateType == 2 && (esnMinor(loser,pos).nInternalUnits < 5 || esnMinor(loser,pos).nInternalUnits >= maxMinorUnits)  
        flag = 1;
    else
        flag = 0;
    end
end
    
switch(mutateType)
    case 0 %add new/replace major
        esnMinor(loser,pos).spectralRadius = 2*rand;
        esnMinor(loser,pos).inputScaling = 2*rand-1;
        esnMinor(loser,pos).leakRate = rand;
        esnMinor(loser,pos).inputShift = 2*rand-1;
        
        if ~isempty(esnMinor(loser,pos).nInternalUnits)
            if esnMinor(loser,pos).nInternalUnits+1 > maxMinorUnits
                esnMinor(loser,pos).nInternalUnits = esnMinor(loser,pos).nInternalUnits-1;
            end            
            esnMinor(loser,pos).nInternalUnits = randi([esnMinor(loser,pos).nInternalUnits-1 esnMinor(loser,pos).nInternalUnits+1]);
        else
            esnMinor(loser,pos).nInternalUnits = maxMinorUnits;
        end
        %weights
        esnMinor(loser,pos).inputWeights = (2.0 * rand(esnMinor(loser,pos).nInternalUnits, esnMajor(loser).nInputUnits+1)- 1.0);
        %initialise new reservoir
        esnMinor(loser,pos).connectivity = 10/esnMinor(loser,pos).nInternalUnits;
        esnMinor(loser,pos).internalWeights_UnitSR = generate_internal_weights(esnMinor(loser,pos).nInternalUnits, ...
            esnMinor(loser,pos).connectivity);
        esnMinor(loser,pos).internalWeights = esnMinor(loser,pos).spectralRadius * esnMinor(loser,pos).internalWeights_UnitSR;
        
        %update esnMajor weights
        esnMajor(loser)= changeMajorWeights(esnMajor(loser),pos,esnMinor(loser,:));
        
%         if iscell(esnMajor(loser).reservoirActivationFunction) 
%             ActivList = {'tanh';'linearNode'};
%             activPositions = randi(length(ActivList),1,esnMinor(loser,pos).nInternalUnits);
%             for act = 1:length(activPositions)
%                 esnMajor(loser).reservoirActivationFunction{pos,act} = ActivList{activPositions(act)};
%             end
%         else
%             esnMajor(loser).reservoirActivationFunction = 'tanh';
%         end
        
    case 1 %remove contents of major, i.e. all minor nodes
        %removed = [removed pos];
        if esnMajor(loser).nInternalUnits > 2
            esnMinor(loser,pos) = removeMinorValues_ext(esnMinor(loser,pos));
            esnMajor(loser)= changeMajorWeights(esnMajor(loser),pos,esnMinor(loser,:));
        end
        
%          if iscell(esnMajor(loser).reservoirActivationFunction)
%             esnMajor(loser).reservoirActivationFunction{pos,act} = ActivList{activPositions(act)};
%          end
        
        %Reorder
        [esnMinor(loser,:), esnMajor(loser).connectWeights,esnMajor(loser).interResScaling,esnMajor(loser).nInternalUnits] = reorderESNMinor_ext(esnMinor(loser,:),esnMajor(loser));            

    case 2 %change nodes inside major, i.e. add/remove minor units
        if isempty(esnMinor(loser,pos).nInternalUnits)
        else
            if rand < 0.5 
                [esnMinor(loser,pos),N] = removeNode_deep(esnMinor(loser,pos));
                if N >0
                    esnMajor(loser) = adaptMajorWeights(esnMajor(loser),pos,esnMinor(loser,:),N,0);
                end
            else
                [esnMinor(loser,pos),N] = addNodeMicroGA_Deep(esnMinor(loser,pos));   %addNode
                if N >0
                    esnMajor(loser)= adaptMajorWeights(esnMajor(loser),pos,esnMinor(loser,:),N,1);
                end
            end
        end
        
%         if iscell(esnMajor(loser).reservoirActivationFunction)
%             esnMajor(loser).reservoirActivationFunction{pos,N} = [];
%         end
         
%         %Reorder
%         [esnMinor(loser,:), esnMajor(loser).connectWeights,esnMajor(loser).nInternalUnits] = reorderESNMinor_ext(esnMinor(loser,:),esnMajor(loser));               
%         
end

%make sure both are the same
esnMajor(loser).connectWeights{pos,pos} = esnMinor(loser,pos).internalWeights;
end