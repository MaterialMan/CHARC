function [meanTrainRMSE,meanTestRMSE,output_data,trainedModel] = learnFNNModel2(figureHandle,dataset,tests,NNsize)
% task: set what task to train for.
% test_thresh: set what limit should be bound on target data.
% tests: how many models to train.

samples = 1:size(dataset(1).inputs,1);

%% pre processing
x = dataset.inputs(samples,:)';
t = dataset.outputs(samples,:)';

% % remove outliers
% pos_outliers = isoutlier(t);
% t(pos_outliers) = [];
% x(:,pos_outliers)= [];
    
%assign data
data = [x; t];

% partition data equally between training and test set
[train_set,test_set]= preprocessCHARCdataset(data',70);

fprintf('Preprocessed data........\n')

%% train model
for test = 1:tests
    [trainedModel{test}, ~,trainRMSE(test)] = trainFNNpredictor(train_set,NNsize);
    fprintf('Test = %d, RMSE = %.4f\n',test,trainRMSE(test));
end

meanTrainRMSE = mean(trainRMSE);

fprintf('Testing learnt models........\n')

for test = 1:tests
    tempModel = trainedModel{test};                   % get trained model - predicts performance of substrate given substrate behaviour
    y = tempModel(test_set(:,1:size(test_set,2)-1)');     % output of trained model, given metrics as inputs
    t = test_set(:,size(test_set,2));                     % target error for given metrics
    testRMSE(test) = sqrt(mean((t-y').^2));%/var(t));         % calculate error of model
end

meanTestRMSE = mean(testRMSE);

figure(figureHandle)
scatter(y',t)
line([0 1], [0 1],'Color','r')
xlim([0 max(y)])
ylim([0 max(t)])
xlabel('Predicted')
ylabel('Actual')

output_data = [y' t];

