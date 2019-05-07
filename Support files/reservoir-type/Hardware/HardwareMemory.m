%% Hardware memory capacity
%geno 2-dimensional
function [MC,outputWeights] = HardwareMemory(read_session,maxInputs,genotype,nInternalUnits,regParam,leakOn)

scurr = rng;
temp_seed = scurr.Seed;
switch_session = [];
rng(1,'twister');

%Remove input sequence and reduce forget points
nForgetPoints = 200;
nOutputUnits = nInternalUnits*2;
nInputUnits = 1;

%% Assign input data and collect target output
dataLength = 6000;
dataSequence = rand(1,dataLength+1++nOutputUnits);% Deep-ESN version: 1.6*rand(1,dataLength+1++nOutputUnits)-0.8;
sequenceLength = 5000;
      
memInputSequence = dataSequence(nOutputUnits+1:dataLength+nOutputUnits)'; 

for i = 1:nOutputUnits
    memOutputSequence(:,i) = dataSequence(nOutputUnits+1-i:dataLength+nOutputUnits-i);
end

trainInputSequence = repmat(memInputSequence(1:sequenceLength,:),1,nInputUnits);%repmat(memInputSequence(1:sequenceLength/2,:),1,maxInputs);
testInputSequence = repmat(memInputSequence(1+sequenceLength:end,:),1,nInputUnits);%repmat(memInputSequence,1,maxInputs);

trainOutputSequence = memOutputSequence(1:sequenceLength,:);%repmat(memInputSequence,1,maxInputs);
testOutputSequence = memOutputSequence(1+sequenceLength:end,:);%repmat(memInputSequence,1,maxInputs);

%% Training
[states,inputLoc,Queue] = collectStatesHardware('train',switch_session, read_session, genotype, ...
    trainInputSequence,nForgetPoints,maxInputs,'simple',...
    [],[],[],leakOn);

%train
outputWeights = trainOutputSequence(nForgetPoints+1:end,:)'*states*inv(states'*states + regParam*eye(size(states'*states)));
Yt = states * outputWeights';

%% Test
test_states = collectStatesHardware('test',switch_session, read_session, genotype, ...
    testInputSequence,nForgetPoints,maxInputs,'simple',...
    [],inputLoc,Queue,leakOn);

Y = test_states * outputWeights';

%% work out MC
MC= 0; Cm = 0;
for i = 1:nOutputUnits   
    coVar = cov(testOutputSequence(nForgetPoints+1:end,i),Y(:,i)).^2;
    outVar = var(Y(:,i));
    targVar = var(testInputSequence(nForgetPoints+1:end,:));
    totVar = (outVar*targVar(1)');
    C = coVar(1,2)/totVar;
    MC = MC + C;   
    R = corrcoef(testOutputSequence(nForgetPoints+1:end,i),Y(:,i));
    Cm = Cm + R(1,2).^2;
end

MC = sum(1-calculateError(Y,testOutputSequence,nForgetPoints,'NMSE_mem'));

if isnan(MC) || MC < 0
    MC = 0;
end

%fprintf('Memory Capacity: %.3f out of %d.... (corrcoeff = %.3f) \n',MC,nOutputUnits,Cm);
release(read_session);
% Go back to old seed
rng(temp_seed,'twister');

