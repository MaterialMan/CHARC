function [esnMinor,esnMajor] = mutateLoser_weights_pipeline(esnMinor,esnMajor,loser,pos)

if ~isempty(esnMinor(loser,pos).nInternalUnits)
    if rand < 0.5
        if rand < 0.5
            esnMinor(loser,pos) = removeWeight_pipeline(esnMinor(loser,pos),'input');
        else
            esnMinor(loser,pos) = addWeight_pipeline(esnMinor(loser,pos),'input');
        end
    else
        if rand < 0.5
            esnMinor(loser,pos) = removeWeight_pipeline(esnMinor(loser,pos),'internal');
        else
            esnMinor(loser,pos) = addWeight_pipeline(esnMinor(loser,pos),'internal');
        end
    end
    %make sure both are the same
    esnMajor(loser).connectWeights{pos,pos} = esnMinor(loser,pos).internalWeights;   
end