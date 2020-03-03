function test_error = assessESNonTask(esnMinor,esnMajor,...
    trainInputSequence,trainOutputSequence,valInputSequence,valOutputSequence,testInputSequence,testOutputSequence,...
    nForgetPoints,leakOn,errType,resType)


if size(trainInputSequence,2) > 1
    scurr = rng;
    temp_seed = scurr.Seed;
    rng(1,'twister');
    %weights
    esnMajor.nInputUnits = size(trainInputSequence,2);
    for i = 1:size(esnMinor,2)
        esnMinor(:,i).inputWeights = 2*rand(esnMinor(:,i).nInternalUnits, size(trainInputSequence,2)+1)-1;
    end
    rng(temp_seed,'twister');
end

% Collect states for plain ESN
switch(resType)
    case 'RoR'
        statesExt = collectDeepStates_nonIA(esnMajor,esnMinor,trainInputSequence,nForgetPoints,leakOn);
        statesExtval = collectDeepStates_nonIA(esnMajor,esnMinor,valInputSequence,nForgetPoints,leakOn);
    case 'RoR_IA'
        statesExt = collectDeepStates_IA(esnMajor,esnMinor,trainInputSequence,nForgetPoints,leakOn);
        statesExtval = collectDeepStates_IA(esnMajor,esnMinor,valInputSequence,nForgetPoints,leakOn);
end
% Find best reg parameter
regTrainError = [];
regValError =[];regWeights=[];
regParam = [10e-1 10e-3 10e-5 10e-7 10e-9];

for i = 1:length(regParam)
    
    esnMajor.regParam = regParam(i);
    %Train: tanspose is inversed compared to equation
    outputWeights = trainOutputSequence(nForgetPoints+1:end,:)'*statesExt*inv(statesExt'*statesExt + esnMajor.regParam*eye(size(statesExt'*statesExt)));
    
    % Calculate trained output Y
    outputSequence = statesExt*outputWeights';
    regTrainError(i,:)  = calculateError(outputSequence,trainOutputSequence,nForgetPoints,errType);
    
    % Calculate trained output Y
    outputValSequence = statesExtval*outputWeights';
    regValError(i,:)  = calculateError(outputValSequence,valOutputSequence,nForgetPoints,errType);
    regWeights(i,:,:) =outputWeights;
end

[~, regIndx]= min(sum(regValError,2));
trainError = regTrainError(regIndx,:);
valError = regValError(regIndx,:);
esnMajor.regParam = regParam(regIndx);
testWeights =reshape(regWeights(regIndx,:,:),size(regWeights,2),size(regWeights,3));

%% Evaluate on test data
switch(resType)
    case 'RoR'
        testStates = collectDeepStates_nonIA(esnMajor,esnMinor,testInputSequence,nForgetPoints,leakOn);
    case 'RoR_IA'
        testStates = collectDeepStates_IA(esnMajor,esnMinor,testInputSequence,nForgetPoints,leakOn);
end
testSequence = testStates*testWeights';
test_error = calculateError(testSequence,testOutputSequence,nForgetPoints,errType);

