function [esnMinor,esnMajor] = mutateLoser_weights(esnMinor,esnMajor,loser,pos)


if ~isempty(esnMinor(loser,pos).nInternalUnits)
    if esnMajor(loser).nInternalUnits > 1
        mutateType = sum(rand >= cumsum([0.5,0.5])); %0.6,0.4
        switch(mutateType)
            case 0%add, or remove single internal or input weight in minor
                if rand < 0.5
                    if rand < 0.5
                        esnMinor(loser,pos) = removeWeight_deep(esnMinor(loser,pos),'input');
                    else
                        esnMinor(loser,pos) = addWeight(esnMinor(loser,pos),'input');
                    end
                else
                    if rand < 0.5
                        esnMinor(loser,pos) = removeWeight_deep(esnMinor(loser,pos),'internal');
                    else
                        esnMinor(loser,pos) = addWeight(esnMinor(loser,pos),'internal');
                    end
                end
                %make sure both are the same
                esnMajor(loser).connectWeights{pos,pos} = esnMinor(loser,pos).internalWeights;
                
            case 1
                %random select inter reservoir weight matrix to change
                [A,B] = size(esnMajor(loser).connectWeights);
                if A+B ~= 2
                    equal = 0;
                    while(~equal)
                        pos1 = randi([1 A]);
                        pos2 = randi([1 B]);
                        if (pos1 ~= pos2) && (~isempty(esnMajor(loser).connectWeights{pos1,pos2}))
                            equal = 1;
                        end
                    end
                    
                    if rand < 0.5
                        esnMajor(loser).connectWeights{pos1,pos2} = removeWeight_deep(esnMajor(loser).connectWeights{pos1,pos2},'interConnect');
                    else
                        esnMajor(loser).connectWeights{pos1,pos2} = addWeight(esnMajor(loser).connectWeights{pos1,pos2},'interConnect') * esnMajor(loser).interResScaling{pos1,pos2};
                    end
                end
        end
    else
        
        if rand < 0.5
            if rand < 0.5
                esnMinor(loser,pos) = removeWeight_deep(esnMinor(loser,pos),'input');
            else
                esnMinor(loser,pos) = addWeight(esnMinor(loser,pos),'input');
            end
        else
            if rand < 0.5
                esnMinor(loser,pos) = removeWeight_deep(esnMinor(loser,pos),'internal');
            else
                esnMinor(loser,pos) = addWeight(esnMinor(loser,pos),'internal');
            end
        end
        %make sure both are the same
        esnMajor(loser).connectWeights{pos,pos} = esnMinor(loser,pos).internalWeights;
    end
end