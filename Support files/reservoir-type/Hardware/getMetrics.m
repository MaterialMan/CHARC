%Genotype comes in as 2-dimensional
% Outputs: kernel_rank, gen_rank, rank_diff, MC,mapping
% Inputs: switch_session,read_session,genotype,maxInputs,nInternalUnits,regParam,leakOn,metric
function [kernel_rank, gen_rank, rank_diff, MC,mapping] =getMetrics(switch_session,read_session,genotype,maxInputs,nInternalUnits,regParam,leakOn,metric)

queueType = 'simple';
    
temp_config = zeros(64,1);
for i = 1:32
    if genotype(i,2) == 1
        temp_config(genotype(i,1),1) = 1;
    end
end

setUp64Switch_RevoMatMk2(switch_session,temp_config(:,1));
release(switch_session);

[~, kernel_rank, gen_rank,rank_diff] = HardwareMetrics(read_session,maxInputs,genotype,leakOn,metric);

[MC,outputWeights] = HardwareMemory(read_session,maxInputs,genotype,nInternalUnits,regParam,leakOn);

%num input controls and weights
numIns = sum(genotype(:,2)); %find no. of inputs
numOutputsUsed = sum(outputWeights(1,:) ~=0);
weightToControl = genotype(:,2)-genotype(:,3); %separate control inputs
numControlIns = sum(weightToControl == 1); %calculate how many
numWeightIns = numIns-numControlIns; %therefore the rest must be weighted ins
mapping = [numOutputsUsed numControlIns numWeightIns];
