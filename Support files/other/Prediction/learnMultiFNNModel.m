function [rmseNN,maeNN,testRMSE,testMAE] = learnMultiFNNModel(figureHandle,test_thresh,tests,test_thresh_name, num_feat)
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

for p = 1:4
    %% pre processing
    ext_data =[];
    x = dataset(p).inputs';
    t = dataset(p).outputs';
    
    for i = 1:4 % remove bad errors
        indx = isnan(t(i,:));
        t(:,indx) = [];
        x(:,indx) = [];
        
        indx = t(i,:) > test_thresh; %0.8
        t(:,indx) = [];
        x(:,indx) = [];
    end
    
    ext_data(1:3,:) = x;
    if num_feat > 3
        ext_data(4,:) = x(1,:)-x(2,:);
        ext_data(5,:) = sqrt(abs(x(1,:)-x(2,:)));
        ext_data(6,:) = x(1,:).^2 + x(2,:).^2 + x(3,:).^2;
        ext_data(7,:) = abs(x(1,:)-x(2,:));
        ext_data(8,:) = sqrt(abs(x(1,:)-x(2,:)));
        ext_data(9:11,:) = round(x);
        
        ext_data(12:12+size(t,1)-1,:) = t;
    else
        ext_data(4:4+size(t,1)-1,:) = t;
    end
    
    % flip
    data{p} = ext_data';

    fprintf('Preprocessed data........\n')
    
    %% train model
    parfor test = 1:tests
        [trainedModel{p,test}, maeNN(p,test),rmseNN(p,test)] = trainMultiFNNpredictor(data{p},NNsize);
        fprintf('Size = %d, test = %d, RMSE = %.4f, MAE = %.4f \n',p,test,rmseNN(p,test),maeNN(p,test));
    end
    
end
fprintf('Testing learnt models........\n')

%% test models on each dataset
parfor p = 1:4 % different res datasets
    for i = 1:4 % test on each res size
        for test = 1:tests
            tempModel = trainedModel{p,test};
            y = tempModel(data{i}(:,1:size(data{i},2)-4)');
            t = data{i}(:,size(data{i},2)-3:size(data{i},2))'; 
            testRMSE(p,i,test) = sqrt(mean((t(:)-y(:)).^2));
            testMAE(p,i,test) = mae(t(:)-y(:));
        end
    end
end

%% plot difference in model prediction
set(figureHandle,'Position',[575   514   896   293])
set(0,'currentFigure',figureHandle)
subplot(1,2,1)
imagesc(mean(testRMSE,3)-diag(mean(testRMSE,3)));
title('RMSE')
colormap(gca,bluewhitered)
colorbar
xticks([1,2,3,4])
yticks([1,2,3,4])
xticklabels({'25','50','100','200'})
yticklabels({'25','50','100','200'})
xlabel('Test')
ylabel('Trained')
set(gca,'FontSize',12,'FontName','Arial')
setText(mean(testRMSE,3),mean(testRMSE,3)-diag(mean(testRMSE,3)))


subplot(1,2,2)
imagesc(mean(testMAE,3)-diag(mean(testMAE,3)));
title('MAE')
colormap(gca,bluewhitered)
colorbar
xticks([1,2,3,4])
yticks([1,2,3,4])
xticklabels({'25','50','100','200'})
yticklabels({'25','50','100','200'})
xlabel('Test')
ylabel('Trained')
set(gca,'FontSize',12,'FontName','Arial')
setText(mean(testMAE,3),mean(testMAE,3)-diag(mean(testMAE,3)))

set(gcf,'renderer','OpenGL')

print(strcat('predictMultiNN_thres',test_thresh_name,'_nFeatures_',num2str(num_feat)),'-dpdf','-bestfit')
   

%% overlay text
function setText(mat,mat2)
    
textStrings = num2str(mat(:), '%0.2f');       % Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  % Remove any space padding
[x1, y1] = meshgrid(1:length(mat));  % Create x and y coordinates for the strings
hStrings = text(x1(:), y1(:), textStrings(:), ...  % Plot the strings
                'HorizontalAlignment', 'center');
midValue = mean(get(gca, 'CLim'));  % Get the middle value of the color range
textColors = repmat(abs(mat2(:)) > 0.01, 1, 3);  % Choose white or black for the
                                               %   text color of the strings so
                                               %   they can be easily seen over
                                               %   the background color
set(hStrings, {'Color'}, num2cell(textColors, 2));  % Change the text colors
