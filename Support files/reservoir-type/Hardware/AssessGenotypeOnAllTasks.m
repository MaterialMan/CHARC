
function [testError, metrics] = AssessGenotypeOnAllTasks(genotype,config, read_session, switch_session,taskList,metrics)

rng(1,'twister');

%define tasks
for set = 1:length(taskList)
    config.dataSet = taskList{set};
    [data{set}] = selectDataset(config);
end

if config.useMetrics
     kernel_rank =[];gen_rank=[];MC=[];
end

%asses genotype
for test= 1:size(genotype,1)
    
    release(read_session); release(switch_session);
    testGenotype = reshape(genotype(test,:,:),size(genotype,2),size(genotype,3));
    
    %fprintf('\nIndv %d:\n',test)
    
    if config.useMetrics
        [kernel_rank(test),gen_rank(test),~,MC(test)] =getMetrics(switch_session,read_session,testGenotype...
            ,config.num_electrodes/2,config.num_electrodes,config.reg_param,config.leakOn,config.metrics_used);
        fprintf('Metrics: KR %d, GR %d, MC %.3f\n',kernel_rank(test),gen_rank(test),MC(test))
        
        metrics = [kernel_rank; gen_rank; kernel_rank-gen_rank; abs(kernel_rank-gen_rank); MC];
    else
        metrics = zeros(size(genotype,1),sum(config.metrics_used));
    end
    
    for taskSet = 1:length(taskList)
        
        trainInput= data{taskSet}.trainInputSequence;
        trainOutput= data{taskSet}.trainOutputSequence;
        valInput= data{taskSet}.valInputSequence;
        valOutput = data{taskSet}.valOutputSequence;
        testInput= data{taskSet}.testInputSequence;
        testOutput= data{taskSet}.testOutputSequence;
        
        switch (data{taskSet}.queueType)
            case 'Weighted'
                numInputs = size(trainInput,2);
                inputWeights = (2*rand(config.num_electrodes/2, numInputs)-1)/12;
                weightedTrainSequence = trainInput*inputWeights';
                weightedValSequence = valInput*inputWeights';
                weightedTestSequence = testInput*inputWeights';       
            otherwise
                weightedTrainSequence = [];
                weightedValSequence = [];
                weightedTestSequence = [];
        end
        
        % training data
        [statesExt,inputLoc,queue] = collectStatesHardware('train',switch_session, read_session, testGenotype, ...
            trainInput,data{taskSet}.nForgetPoints,(config.num_electrodes/2),data{taskSet}.queueType,...
            weightedTrainSequence(),[],[],config.leakOn);
        
        % val data
        statesExtval = collectStatesHardware('val',switch_session, read_session, testGenotype, ...
            valInput,data{taskSet}.nForgetPoints,(config.num_electrodes/2),data{taskSet}.queueType,...
            weightedValSequence(),inputLoc,queue,config.leakOn);
        
        % Find best reg parameter
        regTrainError = [];
        regValError =[];regWeights=[];
        regParam = [10e-1 10e-3 10e-5 10e-7 10e-9];
        
        for j = 1:length(regParam)
            
            %Train: tanspose is inversed compared to equation
            outputWeights = trainOutput(data{taskSet}.nForgetPoints+1:end,:)'*statesExt*inv(statesExt'*statesExt + regParam(j)*eye(size(statesExt'*statesExt)));
            
            % Calculate trained output Y
            outputSequence = statesExt*outputWeights';
            regTrainError(j,:)  = calculateError(outputSequence,trainOutput,data{taskSet}.nForgetPoints,data{taskSet}.errType);
            
            % Calculate trained output Y
            outputValSequence = statesExtval*outputWeights';
            regValError(j,:)  = calculateError(outputValSequence,valOutput,data{taskSet}.nForgetPoints,data{taskSet}.errType);
            regWeights(j,:,:) =outputWeights;
        end
        
        [~, regIndx]= min(sum(regValError,2));
        trainError(test,taskSet) = regTrainError(regIndx,:);
        valError(test,taskSet) = regValError(regIndx,:);
        testWeights =reshape(regWeights(regIndx,:,:),size(regWeights,2),size(regWeights,3));
        
        %% Evaluate on test data
        testStates = collectStatesHardware('test',switch_session, read_session, testGenotype, ...
            testInput,data{taskSet}.nForgetPoints,(config.num_electrodes/2),data{taskSet}.queueType,...
            weightedTestSequence,inputLoc,queue,config.leakOn);
        
        testSequence = testStates*testWeights';
        
        if config.showNeuronStates
            
            hold on
            imagesc(testStates)
            colormap('gray')
            hold off
            drawnow
        end
        testError(test,taskSet) = calculateError(testSequence,testOutput,data{taskSet}.nForgetPoints,data{taskSet}.errType);
        
        fprintf('Task: %s,  Child test error = %.4f\n',taskList{taskSet},testError(test,taskSet))
        
    end
%    save(strcat('assessedGenoHardware_',num2str(size(genotype,1)),'_plusMetrics_SN_',config.material,'_run_',num2str(tests),'.mat'),'config','metrics','testError','genotype')
end

%save(strcat('assessedGenoHardware_',num2str(popSize),'.mat'),'Metrics','testError','genotype')

