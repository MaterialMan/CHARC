function [esnMinor,esnMajor] = mutateLoser_hyper_init(esnMinor,esnMajor,loser,pos)

if ~isempty(esnMinor(loser,pos).nInternalUnits)
    if esnMajor(loser).nInternalUnits > 1
        mutateType = sum(rand >= cumsum([0.25,0.25,0.25,0.25]));
        switch(mutateType)
            case 0
                esnMinor(loser,pos).spectralRadius = esnMinor(loser,pos).spectralRadius+randn*0.1;
                esnMinor(loser,pos).internalWeights = esnMinor(loser,pos).spectralRadius * esnMinor(loser,pos).internalWeights_UnitSR;
            case 1
                esnMinor(loser,pos).inputScaling = esnMinor(loser,pos).inputScaling*randn*0.1;
            case 2
                esnMinor(loser,pos).leakRate = esnMinor(loser,pos).leakRate+randn*0.1;
            case 3
                if esnMajor(loser).nInternalUnits > 1
                    pos2 = randi([1 esnMajor(loser).nInternalUnits]);
                    esnMajor(loser).interResScaling{pos,pos2} = esnMajor(loser).interResScaling{pos,pos2}+randn*0.1;
                end
        end
    else
        mutateType = sum(rand >= cumsum([0.33333,0.33333,0.3333]));
        switch(mutateType)
            case 0
                esnMinor(loser,pos).spectralRadius = esnMinor(loser,pos).spectralRadius+randn*0.1;
                esnMinor(loser,pos).internalWeights = esnMinor(loser,pos).spectralRadius * esnMinor(loser,pos).internalWeights_UnitSR;
            case 1
                esnMinor(loser,pos).inputScaling = esnMinor(loser,pos).inputScaling*randn*0.1;
            case 2
                esnMinor(loser,pos).leakRate = esnMinor(loser,pos).leakRate+randn*0.1;
        end
    end
    
end