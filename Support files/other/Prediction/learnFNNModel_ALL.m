function [rmseNN,maeNN,testRMSE,testMAE] = learnFNNModel_ALL(figureHandle,test_thresh,task,tests,test_thresh_name, num_feat)
% task: set what task to train for.
% test_thresh: set what limit should be bound on target data.
% tests: how many models to train.

NNsize = 100;

dataset =[];
for res = [25 50 100 200]
    load(strcat('assessed_dB_forPrediction_',num2str(res),'nodes_21990dbSize.mat'),'pred_dataset')
    dataset = [dataset; pred_dataset];
end

fprintf('Loaded data. Learning models........\n')

%% pre processing
ext_data =[]; x=[]; t=[];
for p = 1:4
    x = [x dataset(p).inputs'];
    t = [t dataset(p).outputs(:,task)'];   
end

indx = isnan(t);
t(indx) = [];
x(:,indx) = [];

indx = t > test_thresh; %0.8
t(indx) = [];
x(:,indx) = [];

ext_data(1:3,:) = x;

if num_feat > 3
    ext_data(4,:) = x(1,:)-x(2,:);
    ext_data(5,:) = sqrt(abs(x(1,:)-x(2,:)));
    ext_data(6,:) = x(1,:).^2 + x(2,:).^2 + x(3,:).^2;
    ext_data(7,:) = abs(x(1,:)-x(2,:));
    ext_data(8,:) = sqrt(abs(x(1,:)-x(2,:)));
    ext_data(9:11,:) = round(x);
    
    ext_data(12,:) = t;
else
    ext_data(4,:) = t;
end
% flip
data = ext_data';

%% individual datasets
for p = 1:4
    ext_data_test =[]; 
    x_test = dataset(p).inputs';
    t_test = dataset(p).outputs(:,task)';
    
    indx = isnan(t_test);
    t_test(indx) = [];
    x_test(:,indx) = [];
    
    indx = t_test > test_thresh; %0.8
    t_test(indx) = [];
    x_test(:,indx) = [];
    
    ext_data_test(1:3,:) = x_test;
    
    if num_feat > 3
        ext_data_test(4,:) = x_test(1,:)-x_test(2,:);
        ext_data_test(5,:) = sqrt(abs(x_test(1,:)-x_test(2,:)));
        ext_data_test(6,:) = x_test(1,:).^2 + x_test(2,:).^2 + x_test(3,:).^2;
        ext_data_test(7,:) = abs(x_test(1,:)-x_test(2,:));
        ext_data_test(8,:) = sqrt(abs(x_test(1,:)-x_test(2,:)));
        ext_data_test(9:11,:) = round(x_test);
        
        ext_data_test(12,:) = t_test;
    else
        ext_data_test(4,:) = t_test;
    end
    
    data_test{p} = ext_data_test';    
end
%%
fprintf('Preprocessed data........\n')

%% train model
parfor test = 1:tests
    [trainedModel{test}, maeNN(test),rmseNN(test)] = trainFNNpredictor(data,NNsize);
    fprintf('Size = %d, test = %d, RMSE = %.4f, MAE = %.4f \n',p,test,rmseNN(test),maeNN(test));
end


fprintf('Testing learnt models........\n')

%% test models on each dataset
for i = 1:4 % test on each res size
    for tst = 1:tests
        tempModel = trainedModel{tst};
        y = tempModel(data_test{i}(:,1:size(data_test{i},2)-1)');
        t = data_test{i}(:,size(data_test{i},2));
        testRMSE(i,tst) = sqrt(mean((t-y').^2));
        testMAE(i,tst) = mae(t-y');
    end
end


%% plot difference in model prediction
set(figureHandle,'Position',[575   514   896   293])
set(0,'currentFigure',figureHandle)
subplot(1,2,1)
imagesc(mean(testRMSE,2)');
title('RMSE')
colormap(gca,bluewhitered)
colorbar
xticks([1,2,3,4])
yticks([1])
xticklabels({'25','50','100','200'})
yticklabels({'All Data'})
xlabel('Test')
ylabel('Trained')
set(gca,'FontSize',12,'FontName','Arial')
setText(mean(testRMSE,2),mean(testRMSE,2))


subplot(1,2,2)
imagesc(mean(testMAE,2)');
title('MAE')
colormap(gca,bluewhitered)
colorbar
xticks([1,2,3,4])
yticks([1])
xticklabels({'25','50','100','200'})
yticklabels({'All Data'})
xlabel('Test')
ylabel('Trained')
set(gca,'FontSize',12,'FontName','Arial')
setText(mean(testMAE,2),mean(testMAE,2))

set(gcf,'renderer','OpenGL')

switch(task)
    case 1
        print(strcat('predictNN_allSizes_N10_thres',test_thresh_name,'_nFeatures_',num2str(num_feat)),'-dpdf','-bestfit')
    case 2
        print(strcat('predictNN_allSizes_N30_thres',test_thresh_name,'_nFeatures_',num2str(num_feat)),'-dpdf','-bestfit')
    case 3
        print(strcat('predictNN_allSizes_Laser_thres',test_thresh_name,'_nFeatures_',num2str(num_feat)),'-dpdf','-bestfit')
    case 4
        print(strcat('predictNN_allSizes_NonChan_thres',test_thresh_name,'_nFeatures_',num2str(num_feat)),'-dpdf','-bestfit')
end


%% overlay text
function setText(mat,mat2)

textStrings = num2str(mat(:), '%0.2f');       % Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  % Remove any space padding
[x1, y1] = meshgrid(1:length(mat),1);  % Create x and y coordinates for the strings
hStrings = text(x1(:), y1(:), textStrings(:), ...  % Plot the strings
    'HorizontalAlignment', 'center');
midValue = mean(get(gca, 'CLim'));  % Get the middle value of the color range
textColors = repmat(abs(mat2(:)) > min(mat(:)), 1, 3);  % Choose white or black for the
%   text color of the strings so
%   they can be easily seen over
%   the background color
set(hStrings, {'Color'}, num2cell(textColors, 2));  % Change the text colors
