function [esnMinor,esnMajor] = mutateLoser_hyper_pipeline(esnMinor,esnMajor,loser,pos)

if ~isempty(esnMinor(loser,pos).nInternalUnits)

mutateType = sum(rand >= cumsum([0.3333,0.3333,0.3333]));  

switch(mutateType)
    case 0
            esnMinor(loser,pos).spectralRadius = 2*rand;
            esnMinor(loser,pos).internalWeights = esnMinor(loser,pos).spectralRadius * esnMinor(loser,pos).internalWeights_UnitSR;
    case 1
            esnMinor(loser,pos).inputScaling = 2*rand-1;
    case 2
            esnMinor(loser,pos).leakRate = rand;

end

end