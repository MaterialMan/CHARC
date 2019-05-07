function [esn,N] = addNodeMicroGA_Deep(esn)


nInputUnits = size(esn.inputWeights,2)-1;

%esn.connectivity = max([10/esn.nInternalUnits rand]);
addWeights = sprand(esn.nInternalUnits,1,esn.connectivity);%zeros(esn.nInternalUnits,1)+
addWeights(addWeights ~= 0) = ...
            addWeights(addWeights ~= 0)  - 0.5;
add2ndWeights =sprand(1,esn.nInternalUnits+1,esn.connectivity);%= zeros(1,esn.nInternalUnits+1);
add2ndWeights(add2ndWeights ~= 0) = ...
            add2ndWeights(add2ndWeights ~= 0)  - 0.5;
addInputWeights = rand(1,nInputUnits+1)-0.5;%sprand(1,esn.nInternalUnits+1,esn.connectivity);%zeros(1,esn.nInputUnits+1);
%addInputWeights(addInputWeights ~= 0) = ...
            %addInputWeights(addInputWeights ~= 0)  - 0.5;
        
%randomly choose insertion
N = randi([1 esn.nInternalUnits-1]);

%add new zero weights
esn.internalWeights_UnitSR = [esn.internalWeights_UnitSR(:,1:N) addWeights esn.internalWeights_UnitSR(:,N+1:end)];
esn.internalWeights_UnitSR = [esn.internalWeights_UnitSR(1:N,:); add2ndWeights; esn.internalWeights_UnitSR(N+1:end,:)];
esn.internalWeights = [esn.internalWeights(:,1:N) addWeights*esn.spectralRadius esn.internalWeights(:,N+1:end)];
esn.internalWeights = [esn.internalWeights(1:N,:); add2ndWeights*esn.spectralRadius; esn.internalWeights(N+1:end,:)];
  
%re-

%update input weights
esn.inputWeights = [esn.inputWeights(1:N,:); addInputWeights; esn.inputWeights(N+1:end,:)];

%update num units
esn.nInternalUnits  = esn.nInternalUnits +1;

if size(esn.leakRate,1) > 1
    %update leakRate
    esn.leakRate = [esn.leakRate(1:N); rand; esn.leakRate(N+1:end)];
end


