%% Hardware memory capacity
% comparison to "Deep reservoir computing: A critical experimental
% analysis" -- http://www.sciencedirect.com/science/article/pii/S0925231217307567
% Change: Training length: 5000, test length: 1000

function [MC,Cm] = metricMemory(genotype, config)
tic
scurr = rng;
temp_seed = scurr.Seed;

rng(1,'twister');

%Remove input sequence and reduce forget points
config.nForgetPoints = 200;

nInternalUnits = genotype.nTotalUnits;%sum([genotype.nInternalUnits]);

nOutputUnits = nInternalUnits*2;
nInputUnits = genotype.nInputUnits;

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

states = config.assessFcn(genotype,trainInputSequence,config);

%train
outputWeights = trainOutputSequence(config.nForgetPoints+1:end,:)'*states*inv(states'*states + config.regParam*eye(size(states'*states)));
Yt = states * outputWeights';

%test
testStates =  config.assessFcn(genotype,testInputSequence,config);

Y = testStates * outputWeights';

MC= 0; Cm = 0;
for i = 1:nOutputUnits   
    coVar = cov(testOutputSequence(config.nForgetPoints+1:end,i),Y(:,i)).^2;
    outVar = var(Y(:,i));
    targVar = var(testInputSequence(config.nForgetPoints+1:end,:));
    totVar = (outVar*targVar(1)');
    C = coVar(1,2)/totVar;
    MC = MC + C;   
    R = corrcoef(testOutputSequence(config.nForgetPoints+1:end,i),Y(:,i));
    Cm = Cm + R(1,2).^2;
end



if isnan(MC) || MC < 0
    MC = 0;
end

%fprintf('Memory Capacity: %.3f / %.3f out of %d.... \n',MC,Cm,nOutputUnits);
% Go back to old seed
rng(temp_seed,'twister');


%[TE,AIS] = getAISandTE(testStates, Y);


