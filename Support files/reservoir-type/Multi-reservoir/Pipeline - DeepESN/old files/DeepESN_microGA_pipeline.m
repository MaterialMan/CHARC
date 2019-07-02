
%% DeepRes_microGA_pipeline
% This alternate vesion of the previous deepmicroGA is to evolve a
% pipeline/"deep" ESN. The states of the first act as inputs to the next
% ESN and so on. This input weight matrix of each ESN handles the states of the previous and the .

% Tips
% - Not quite sure this works well with multi-dimensional datasets yet

% Author: M. Dale
% Date: 21/06/17 - updated 10/12/17

addpath(genpath('\RoR-master\'))

clearvars -except dataSet maxMinorUnits maxMajorUnits resType
rng(10,'twister');

%% Task/rum parameters
numTests = 10;

if strcmp(dataSet,'NonLinerMap&Memory')
    figure3 = figure;
end

%collect and separate datasets
[trainInputSequence,trainOutputSequence,valInputSequence,valOutputSequence,...
    testInputSequence,testOutputSequence,nForgetPoints,errType,queueType] = selectDataset(dataSet, [] ,[]);%deepSelectData(dataSet, [] ,[]); %NonChanEq has extra input

startTime = datestr(now, 'HH:MM:SS');

%Evolutionary parameters
popSize =15;           
numEpoch = 1985;
numMutate = 0.3; 
deme = popSize-1;   
recRate = 0.4; 
rankedFitness = 0;
startFull = 1;
leakOn = 1;
genPrint = 20;
saveError = zeros(numTests,maxMajorUnits+2);

%% RUn MicroGA
for tests = 1:numTests
    
    clearvars -except trainInputSequence trainOutputSequence valInputSequence valOutputSequence...
        testInputSequence testOutputSequence nForgetPoints errType queueType startFull ...
        numTests figure3 tests dataSet storeError saveError storeUnitsOverGens leakOn resType genPrint...
        popSize numEpoch numMutate deme recRate rankedFitness maxMinorUnits maxMajorUnits best_esnMajor best_esnMinor
    
    fprintf('\n Test: %d  ',tests);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    
    rng(tests,'twister');
    
   [esnMajor, esnMinor] =createDeepReservoir_pipeline(trainInputSequence,trainOutputSequence,popSize,maxMinorUnits,maxMajorUnits,startFull);
    
    tic;
    in = zeros(popSize,maxMajorUnits);
    
    %% Evaluate population
    for popEval = 1:popSize
       
        % Collect states for plain ESN
        switch(resType)
            case 'pipeline'
                statesExt = collectDeepStates_pipeline(esnMajor(popEval),esnMinor(popEval,:),trainInputSequence,nForgetPoints,leakOn);
                statesExtval = collectDeepStates_pipeline(esnMajor(popEval),esnMinor(popEval,:),valInputSequence,nForgetPoints,leakOn);
            case 'pipeline_IA'
                statesExt = collectDeepStates_pipeline_IA(esnMajor(popEval),esnMinor(popEval,:),trainInputSequence,nForgetPoints,leakOn);
                statesExtval = collectDeepStates_pipeline_IA(esnMajor(popEval),esnMinor(popEval,:),valInputSequence,nForgetPoints,leakOn);
        end
        
        % Find best reg parameter
        regTrainError = [];
        regValError =[];regWeights=[];
        regParam = [10e-1 10e-3 10e-5 10e-7 10e-9];
        for i = 1:length(regParam)
            
            esnMajor(popEval).regParam = regParam(i);
            %Train: tanspose is inversed compared to equation
            outputWeights = trainOutputSequence(nForgetPoints+1:end,:)'*statesExt*inv(statesExt'*statesExt + esnMajor(popEval).regParam*eye(size(statesExt'*statesExt)));
            
            % Calculate trained output Y
            outputSequence = statesExt*outputWeights';
            regTrainError(i,:)  = calculateError(outputSequence,trainOutputSequence,nForgetPoints,errType);
            
            % Calculate trained output Y
            outputValSequence = statesExtval*outputWeights';
            regValError(i,:)  = calculateError(outputValSequence,valOutputSequence,nForgetPoints,errType);
            regWeights(i,:,:) =outputWeights;
        end

        [~, regIndx]= min(sum(regValError,2));
        trainError(popEval,:) = regTrainError(regIndx,:);
        valError(popEval,:) = regValError(regIndx,:);
        esnMajor(popEval).regParam = regParam(regIndx);
        testWeights =reshape(regWeights(regIndx,:,:),size(regWeights,2),size(regWeights,3));
        
        %% Evaluate on test data
        switch(resType)
            case 'pipeline'
                testStates = collectDeepStates_pipeline(esnMajor(popEval),esnMinor(popEval,:),testInputSequence,nForgetPoints,leakOn);
            case 'pipeline_IA'
                testStates = collectDeepStates_pipeline_IA(esnMajor(popEval),esnMinor(popEval,:),testInputSequence,nForgetPoints,leakOn);
        end
        testSequence = testStates*testWeights';
        testError(popEval,:) = calculateError(testSequence,testOutputSequence,nForgetPoints,errType);
        totalError(popEval,:) = testError(popEval,:);
        
        %% Print all    
        minors = [esnMinor(popEval,:).nInternalUnits]; 
        in(popEval,1:length(minors)) = minors;
        
        %fprintf('Error %.3f %.3f %.3f, majorUnits: %d, total: %d, minors: \n', sum(trainError(popEval,:),2),sum(valError(popEval,:),2),sum(testError(popEval,:),2),esnMajor(popEval).nInternalUnits, sum(minors));
        %disp(minors)
        
    end
    
    %% Calculate pop rank
    if rankedFitness
        rank = [];
        rank_score = 1:popSize;
        [full_Score,full_I] = sort([totalError sum(in,2)]);
        for r = 1:2
            rank(full_I(:,r),r) = rank_score;
        end
        
        storeError(tests,1,:) = sum(rank,2);
    else
        [~,errorIndx] =sort(sum(totalError,2));
        storeError(tests,1,:) =sum(totalError,2);
    end
    
    fprintf('Processing took: %.1f, Starting GA \n',toc)
    
    % Infection Phase and update population
    for eval = 2:numEpoch
        
        rng(eval,'twister');
        cmpError = reshape(storeError(tests,eval-1,:),1,popSize);
        % Tournment selection - pick two individuals
        equal = 1;
        while(equal)
            indv1 = randi([1 popSize]);
            indv2 = indv1+randi([1 deme]);
            if indv2 > popSize
                indv2 = indv2- popSize;
            end
            if indv1 ~= indv2
                equal = 0;
            end
        end
        
        % Assess fitness of both and assign winner/loser - highest score
        % wins
        if cmpError(indv1) < cmpError(indv2)
            winner=indv1; loser = indv2;
        else
            winner=indv2; loser = indv1;
        end
               
        %% Infection phase   
        for i = 1:size(esnMinor,2)
            %recombine
            if rand < recRate
                esnMinor(loser,i) = esnMinor(winner,i);           
            end
            
            %Reorder
            [esnMinor(loser,:), esnMajor(loser).connectWeights, esnMajor(loser).nInternalUnits] = reorderESNMinor_nonRoR(esnMinor(loser,:),esnMajor(loser));
            
            %mutate nodes
%             if round(rand)
%                 for p = randi([1 10])
%                     if rand < numMutate
%                         [esnMinor,esnMajor] = mutateLoser_nodes_pipeline(esnMinor,esnMajor,loser,i,maxMinorUnits);
%                     end
%                 end
%             end
            
            %mutate scales
            if rand < numMutate
                [esnMinor,esnMajor] = mutateLoser_hyper_pipeline(esnMinor,esnMajor,loser,i);
            end
            
            
            %mutate weights
            for j = 1:esnMinor(loser,i).nInternalUnits
                if rand < numMutate
                    [esnMinor,esnMajor] = mutateLoser_weights_pipeline(esnMinor,esnMajor,loser,i);
                end
            end
            
        end
        
        %% Evaluate and update fitness
        storeError(tests,eval,:) = storeError(tests,eval-1,:);
        
        % Collect states for plain ESN
        switch(resType)
            case 'pipeline'
                statesExt = collectDeepStates_pipeline(esnMajor(loser),esnMinor(loser,:),trainInputSequence,nForgetPoints,leakOn);
                statesExtval = collectDeepStates_pipeline(esnMajor(loser),esnMinor(loser,:),valInputSequence,nForgetPoints,leakOn);
            case 'pipeline_IA'
                statesExt = collectDeepStates_pipeline_IA(esnMajor(loser),esnMinor(loser,:),trainInputSequence,nForgetPoints,leakOn);
                statesExtval = collectDeepStates_pipeline_IA(esnMajor(loser),esnMinor(loser,:),valInputSequence,nForgetPoints,leakOn);
        end
        % Find best reg parameter
        regTrainError = [];
        regValError =[];regWeights=[];
        regParam = [10e-1 10e-3 10e-5 10e-7 10e-9];

        for i = 1:length(regParam)
            
            esnMajor(loser).regParam = regParam(i);
            %Train: tanspose is inversed compared to equation
            outputWeights = trainOutputSequence(nForgetPoints+1:end,:)'*statesExt*inv(statesExt'*statesExt + esnMajor(loser).regParam*eye(size(statesExt'*statesExt)));
            
            % Calculate trained output Y
            outputSequence = statesExt*outputWeights';
            regTrainError(i,:)  = calculateError(outputSequence,trainOutputSequence,nForgetPoints,errType);
            
            % Calculate trained output Y
            outputValSequence = statesExtval*outputWeights';
            
            regValError(i,:)  = calculateError(outputValSequence,valOutputSequence,nForgetPoints,errType);
            regWeights(i,:,:) =outputWeights;
        end
        %[~, regIndx]= min(sum(regTrainError+regValError,2));
        [~, regIndx]= min(sum(regValError,2));
        trainError(loser,:) = regTrainError(regIndx,:);
        valError(loser,:) = regValError(regIndx,:);
        esnMajor(loser).regParam = regParam(regIndx);
        testWeights =reshape(regWeights(regIndx,:,:),size(regWeights,2),size(regWeights,3));
        
        %% Evaluate on test data
        switch(resType)
            case 'pipeline'
                testStates = collectDeepStates_pipeline(esnMajor(loser),esnMinor(loser,:),testInputSequence,nForgetPoints,leakOn);
            case 'pipeline_IA'
                testStates = collectDeepStates_pipeline_IA(esnMajor(loser),esnMinor(loser,:),testInputSequence,nForgetPoints,leakOn);               
        end
        testSequence = testStates*testWeights';
        testError(loser,:) = calculateError(testSequence,testOutputSequence,nForgetPoints,errType);
        totalError(loser,:) = testError(loser,:);%trainError(loser,:)+valError(loser,:);
        
        %% Print all
        %fprintf('New Loser Error %.3f %.3f %.3f, majorUnits: %d, minors: \n', sum(trainError(loser,:),2),sum(valError(loser,:),2),sum(testError(loser,:),2),esnMajor(loser).nInternalUnits);
        
        for i=1:size(esnMinor,2)
            if ~isempty(esnMinor(loser,i).nInternalUnits)
                in(loser,i) = esnMinor(loser,i).nInternalUnits;
            else
                in(loser,i) =0;
            end
        end
        %disp(in(loser,:))
        
        %%  Re-Calculate pop rank
        if rankedFitness
            rank = [];
            rank_score = 1:popSize;
            [full_Score,full_I] = sort([totalError sum(in,2)]);
            for r = 1:2
                rank(full_I(:,r),r) = rank_score;
            end
            
            storeError(tests,eval,:) = sum(rank,2);
            finError = reshape(storeError(tests,eval,:),1,popSize);
            [~,errorIndx] = min(finError);
            [M,I]= sort(finError);
        else
            storeError(tests,eval,:) = sum(totalError,2);
            [M,errorIndx]= sort(sum(totalError,2));
        end
        
        if (mod(eval,genPrint) == 0)
            fprintf('Gen %d, time taken: %.4f sec(s)\n Winner is %d, Loser is %d \n',eval,toc/genPrint,winner,loser);
            numUnits = sum(in(errorIndx(1),:));
            storeUnitsOverGens(tests,eval,:) = sum(in,2);
            fprintf('Best %d, Error %.4f %.4f %.4f, max neurons: %d, minors: \n',errorIndx(1),sum(trainError(errorIndx(1),:),2),sum(valError(errorIndx(1),:),2),sum(testError(errorIndx(1),:),2),numUnits);
            disp(in(errorIndx(1),:))
            tic;
        end
    end
    
    % Find lowest fitness
    [best_fit,indxBest] = min(reshape(storeError(tests,numEpoch,:),1,popSize));
    best_esnMajor{tests} = esnMajor(indxBest);
    best_esnMinor{tests,:} = esnMinor(indxBest,:);
    
    details = [best_fit best_esnMajor{tests}.nInternalUnits sum([best_esnMinor{tests,:}.nInternalUnits]) best_esnMinor{tests,:}.nInternalUnits];
    saveError(tests,1:length(details)) = details;
    
    %% ------------------------------ Save data -----------------------------------------------------------------------------------
    save(strcat('DeepRes_',resType,num2str(maxMajorUnits),'x',num2str(maxMinorUnits),'_',dataSet,'_',datestr(now,'dd-mm-yyyy'),'_workspace','.mat'));
    
end

%% Gather metric information

for i = 1:numTests
    [meanLE{i}, kernel_rank(i), gen_rank(i),rank_diff(i)] = DeepRes_KQ_GR_LE(best_esnMajor{i},best_esnMinor{i,:},resType);
    [MC(i),Cm(i)] = DeepResMemoryTest(best_esnMajor{i},best_esnMinor{i,:},resType);
    size(i) = sum([best_esnMinor{i,:}.nInternalUnits]);
end

Metric = [size; kernel_rank; gen_rank; rank_diff;MC;Cm]';

save(strcat('DeepRes_',resType,num2str(maxMajorUnits),'x',num2str(maxMinorUnits),'_',dataSet,'_',datestr(now,'dd-mm-yyyy'),'_workspace','.mat'));
   
% finTime = datestr(now, 'HH:MM:SS');
% fprintf('Finished: %s \n',finTime)
% totTime= finTime-startTime;
% fprintf('Time taken: %d Hrs, %d Mins, %d Secs \n',totTime(1)*10+totTime(2),totTime(4)*10+totTime(5),totTime(7)*10+totTime(8))

