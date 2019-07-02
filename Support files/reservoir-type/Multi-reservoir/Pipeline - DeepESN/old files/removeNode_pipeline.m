function [esn,N] = removeNode_pipeline(esn,num)

if esn.nInternalUnits > 2
    %randomly choose insertion
    N = randi([1 esn.nInternalUnits]);
    
    %add new zero weights
    esn.internalWeights_UnitSR(:,N) =[];
    esn.internalWeights_UnitSR(N,:) =[];
    esn.internalWeights(:,N) =[];
    esn.internalWeights(N,:) =[];
    
    
    %update input weights
    if num ==1
        esn.inputWeights(N,:) =[];
    else
        esn.inputWeights(N,:) =[];
        esn.inputWeights(:,N) =[];
    end
    
    %catch possible error
    if N == esn.nInternalUnits
        N = N-1;
    end
    
    %update num units
    esn.nInternalUnits  = esn.nInternalUnits -1;
    
    if size(esn.leakRate,1) > 1
        %update leakrate
        %esn.leakRate = [esn.leakRate(1:N) rand esn.leakRate(N+1:end)];
        esn.leakRate(N) =[];
    end
    
else
    N =0;
end