
%% Run through every task
% Threshold at 1
% Using 3 features
for i = 1:4
    [rmseNN{i},maeNN{i},testRMSE{i},testMAE{i}] = learnRegressionModel(figure,1,i,10,'1',3);    
end
% Using 11 features
for i = 1:4
    [rmseNN{i},maeNN{i},testRMSE{i},testMAE{i}] = learnRegressionModel(figure,1,i,10,'1',11);    
end

%% Threshold at 0.8 
% Using 3 features
for i = 1:4
    [rmseNN{i},maeNN{i},testRMSE{i},testMAE{i}] = learnRegressionModel(figure,0.8,i,10,'0_8',3);    
end
% Using 11 features
for i = 1:4
    [rmseNN{i},maeNN{i},testRMSE{i},testMAE{i}] = learnRegressionModel(figure,0.8,i,10,'0_8',11);    
end