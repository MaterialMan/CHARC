function [esnMinor,esnMajor] = mutateLoser_nodes_pipeline(esnMinor,esnMajor,loser,pos,maxMinorUnits)

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
        esnMinor(loser,pos).inputShift = 1;
        
        if ~isempty(esnMinor(loser,pos).nInternalUnits)
            if esnMinor(loser,pos).nInternalUnits+1 > maxMinorUnits
                esnMinor(loser,pos).nInternalUnits = esnMinor(loser,pos).nInternalUnits-1;
            end            
            esnMinor(loser,pos).nInternalUnits = randi([esnMinor(loser,pos).nInternalUnits-1 esnMinor(loser,pos).nInternalUnits+1]);%randi([2 maxMinorUnits]);
        else
            esnMinor(loser,pos).nInternalUnits = maxMinorUnits;
        end
        
        %inputweights
        if pos ==1
            esnMinor(loser,pos).inputWeights = (2.0 * rand(esnMinor(loser,pos).nInternalUnits, esnMajor(loser).nInputUnits+1)- 1.0);%*esn.inputScaling;
            
            inputWeights = sprand(esnMinor(loser,pos+1).nInternalUnits, esnMinor(loser,pos).nInternalUnits+1, esnMajor(loser).InnerConnectivity);
            inputWeights(inputWeights ~= 0) = ...
                inputWeights(inputWeights ~= 0)  - 0.5;
            esnMinor(loser,pos+1).inputWeights = inputWeights;%*esn.inputScaling;
        else
            inputWeights = sprand(esnMinor(loser,pos).nInternalUnits, esnMinor(loser,pos-1).nInternalUnits+1, esnMajor(loser).InnerConnectivity);
            inputWeights(inputWeights ~= 0) = ...
                inputWeights(inputWeights ~= 0)  - 0.5;
            esnMinor(loser,pos).inputWeights = inputWeights;%*esn.inputScaling;
            
            inputWeights = sprand(esnMinor(loser,pos+1).nInternalUnits, esnMinor(loser,pos).nInternalUnits+1, esnMajor(loser).InnerConnectivity);
            inputWeights(inputWeights ~= 0) = ...
                inputWeights(inputWeights ~= 0)  - 0.5;
            esnMinor(loser,pos+1).inputWeights = inputWeights;%*esn.inputScaling;
        end
        
        %initialise new reservoir
        esnMinor(loser,pos).connectivity = max([10/esnMinor(loser,pos).nInternalUnits rand]);
        esnMinor(loser,pos).internalWeights_UnitSR = generate_internal_weights(esnMinor(loser,pos).nInternalUnits, ...
            esnMinor(loser,pos).connectivity);
        esnMinor(loser,pos).internalWeights = esnMinor(loser,pos).spectralRadius * esnMinor(loser,pos).internalWeights_UnitSR;
        

    case 1 %remove contents of major, i.e. all minor nodes
        %removed = [removed pos];
        if esnMajor(loser).nInternalUnits > 2
            esnMinor(loser,pos) = removeMinorValues_ext(esnMinor(loser,pos));
        end
        
        %Reorder
        [esnMinor(loser,:), esnMajor(loser).connectWeights,esnMajor(loser).nInternalUnits] = reorderESNMinor_nonRoR(esnMinor(loser,:),esnMajor(loser));            

    case 2 %change nodes inside major, i.e. add/remove minor units
        if isempty(esnMinor(loser,pos).nInternalUnits)
        else
            if rand < 0.5 
                [esnMinor(loser,pos),N] = removeNode_pipeline(esnMinor(loser,pos));
                 esnMinor(loser,pos+1).inputWeights(:,N) =[];
            else
                [esnMinor(loser,pos),esnMinor(loser,pos+1)] = addNodeMicroGA_pipeline(esnMinor(loser,pos),esnMinor(loser,pos+1));   %addNode
                
            end
        end
               
end

%make sure both are the same
esnMajor(loser).connectWeights{pos,pos} = esnMinor(loser,pos).internalWeights;
end