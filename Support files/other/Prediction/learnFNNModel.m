function [meanTrainRMSE,meanTestRMSE,trainedModel,output_data,minTestRMSE,maxTestRMSE] = learnFNNModel(figureHandle,dataset,tests,...
    NNsize,task,threshold,samples,output_data,plus_mat,num_test_substrates)
% task: set what task to train for.
% test_thresh: set what limit should be bound on target data.
% tests: how many models to train.

% samples{1:4} = 1:21990;%size(dataset{1}.pred_dataset.inputs,1);%randi([1 size(dataset(1).inputs,1)],1000,1);
% samples{5:6} = 1:2199;%size(dataset{1}.pred_dataset.inputs,1);%randi([1 size(dataset(1).inputs,1)],1000,1);

num_subs = length(dataset);

for p = 1:num_subs
    
    %% pre processing
    x = dataset{p}.pred_dataset.inputs(samples{p},:)';
    t = dataset{p}.pred_dataset.outputs(samples{p},task)';
       
    % remove bad reservoirs - NaNs and error > 1
    indx = t > threshold(task);
    x(:,indx) = [];
    t(indx) = [];
    
    indx2 = isnan(t);
    x(:,indx2) = [];
    t(indx2) = [];
        
    
    %assign data
    data = [x; t];
    
    % train only on ESNs
    if p <= num_subs-num_test_substrates
        % partition data equally between training and test set
        [train_set{p},test_set{p}]= preprocessCHARCdataset(data',70);
        
        %% train model
        for test = 1:tests
            [trainedModel{p,test},~,trainRMSE(p,test)] = trainFNNpredictor(train_set{p},NNsize);
            fprintf('Test = %d, RMSE = %.4f \n',test,trainRMSE(p,test));
        end
        
          %calculate mean
        meanTrainRMSE = mean(trainRMSE,2);
    else
        %assign data for substrates straight to test set
        test_set{p} = data';
        
         %dummy mean
        meanTrainRMSE = 1;
    end
    fprintf('Preprocessed data........\n')
    
  
end



fprintf('Testing learnt models........\n')

%% test models on each dataset
for pt = 1:num_subs-num_test_substrates % train res (excl. test substrates)
    for i = 1:num_subs % test on each substrate
        for tst = 1:tests
            tempModel = trainedModel{pt,tst};                   % get trained model - predicts performance of substrate given substrate behaviour
            y = tempModel(test_set{i}(:,1:size(test_set{i},2)-1)');     % output of trained model, given metrics as inputs
            t = test_set{i}(:,size(test_set{i},2));                     % target error for given metrics
            testRMSE(tst) = sqrt(mean((t-y').^2));  %(pt,i,tst)       % calculate error of model

            figure(figureHandle)
            scatter(y',t)
            line([0 1], [0 1],'Color','r')
            xlim([0 max(y)])
            ylim([0 max(t)])
            xlabel('Predicted')
            ylabel('Actual')
              
        end
        
        meanTestRMSE(pt,i) = mean(testRMSE);
        minTestRMSE(pt,i) = min(testRMSE);
        maxTestRMSE(pt,i) = max(testRMSE);
        % assign to tasks for later plots
        %output_data = [y' t];
        switch(task)
            case 1
                output_data.T1{pt,i} = [y' t];
            case 2
                output_data.T2{pt,i} = [y' t];
            case 3
                output_data.T3{pt,i} = [y' t];
            case 4
                output_data.T4{pt,i} = [y' t];
        end
    end
end

%meanTestRMSE = mean(testRMSE,3);

%% plot difference in model prediction
% plot without difference
if plus_mat
    x_ticks = 1:num_subs;
    y_ticks = 1:num_subs-num_test_substrates;
    tick_labels = {'25','50','100','200','CNT','DL'};
    y = 1:num_subs;
    x = 1:num_subs-num_test_substrates;
else
    x_ticks = 1:num_subs-num_test_substrates;
    y_ticks = 1:num_subs-num_test_substrates;
    y = 1:num_subs-num_test_substrates;
    x = 1:num_subs-num_test_substrates;
    tick_labels = {'25','50','100','200','All'};
end

% figure2 = figure;
% set(figure2,'Position',[652   134   642   496])
% set(0,'currentFigure',figure2)
% imagesc(meanTestRMSE(x,y)-diag(meanTestRMSE(x,y)));
% %title('\Delta')
% %title('RMSE')
% colormap(gca,bluewhitered)
% h = colorbar; 
% set(get(h,'label'),'string','\Delta');
% xticks(x_ticks)
% yticks(y_ticks)
% xticklabels(tick_labels)
% yticklabels(tick_labels)
% xlabel('Test')
% ylabel('Trained')
% set(gca,'FontSize',14,'FontName','Arial')
% 
% A = meanTestRMSE(x,y)-diag(meanTestRMSE(x,y));
% B = meanTestRMSE(x,y);%A-diag(meanTestRMSE(x,y));
% setText(A,B)



% plot difference
% figure1 = figure;
% set(figure1,'Position',[652   134   642   496])
% set(0,'currentFigure',figure1)
% imagesc(mean(testRMSE,3)-diag(mean(testRMSE,3)));
% title('RMSE')
% colormap(gca,bluewhitered)
% colorbar
% xticks(x_ticks)
% yticks(y_ticks)
% xticklabels(tick_labels)
% yticklabels(tick_labels)
% xlabel('Test')
% ylabel('Trained')
% set(gca,'FontSize',12,'FontName','Arial')
% setText(mean(testRMSE,3),mean(testRMSE,3)-diag(mean(testRMSE,3)))

set(gcf,'renderer','OpenGL')


%% overlay text
function setText(mat,mat2)

textStrings = num2str(mat(:), '%0.2f');       % Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  % Remove any space padding
[x1, y1] = meshgrid(1:size(mat,2),1:size(mat,1));  % Create x and y coordinates for the strings
hStrings = text(x1(:), y1(:), textStrings(:), ...  % Plot the strings
    'HorizontalAlignment', 'center','FontSize',14,'FontName','Arial');
midValue = mean(get(gca, 'CLim'));  % Get the middle value of the color range
textColors = repmat(abs(mat(:)) > mean(mat2(:))*0.3, 1, 3);  % Choose white or black for the
%   text color of the strings so
%   they can be easily seen over
%   the background color
set(hStrings, {'Color'}, num2cell(textColors, 2));  % Change the text colors
