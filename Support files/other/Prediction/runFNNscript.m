
%% Learn the behaviour-performance relationship and test across different reservoirs
clear
rng(1,'twister');

figure1 = figure;

% create dataset to learn from - should hold on reservoirs to be predicted
% and tested on. Replace for desired systems
dataset{1} = load('assessed_dB_forPrediction_25nodes_21990dbSize','pred_dataset');
dataset{2} = load('assessed_dB_forPrediction_50nodes_21990dbSize','pred_dataset');
dataset{3} = load('assessed_dB_forPrediction_100nodes_21990dbSize','pred_dataset');
dataset{4} = load('assessed_dB_forPrediction_200nodes_21990dbSize','pred_dataset');

num_tests = 10;
nn_size = 100;
num_tasks = 4;

%assign threshold for each task
threshold = [0.8 0.8 0.8 0.8];

% dummy output
output_data = [];

% assign number of samples to use for each substrate
samples{1} = 1:21990;
samples{2} = 1:21990;
samples{3} = 1:21990;
samples{4} = 1:21990;

% dataset{5} = dataset{1};
% for i = 2:4
%     dataset{5}.pred_dataset.inputs = [dataset{5}.pred_dataset.inputs; dataset{i}.pred_dataset.inputs];
%     dataset{5}.pred_dataset.outputs = [dataset{5}.pred_dataset.outputs; dataset{i}.pred_dataset.outputs];
% end
% samples{5} = 1:21990*4;

% Predict each task and evaluate on all reservoirs
% num_test_substrates = 0;
% for task = 1:num_tasks 
%     [meanTrainRMSE{task},meanTestRMSE{task}] = learnFNNModel(figure1,dataset,num_tests,nn_size,task,threshold,samples,output_data,0,num_test_substrates);    
% end

%% with materials
dataset{5} = load('assessedHardware_dB_forPrediction_run1_2199dbSize','pred_dataset');
dataset{6} = load('assessed_dB_forPrediction_400nodes_2199dbSize_run1','pred_dataset');

% assign number of samples to use for each substrate
samples{5} = 1:2199;
samples{6} = 1:2199;

% Predict each task and evaluate on all reservoirs
num_test_substrates = 2;
for task = 1:num_tasks 
    [meanMatTrainRMSE{task},meanMatTestRMSE{task},~,output_data,minTestRMSE{task},maxTestRMSE{task}] = learnFNNModel(figure1,dataset,num_tests,nn_size,task,threshold,samples,output_data,1,num_test_substrates);    
end

save('D:\Git\branches\Version_2\Results\ProcRoySocA paper\Delta plots\predict_data_10FNNs_2.mat')

%% plot actual vs predicted - do this manually
figure
d = output_data.T2{4,6};
scatter(d(:,1),d(:,2),10,'k');
line([0 1], [0 1],'Color','r');
xlim([max([min(d(:,1)) 0]) min([max(d(:,1)) 1])])
ylim([max([min(d(:,2)) 0]) min([max(d(:,1)) 1])])
xlabel('Predicted')
ylabel('Actual')

%calculate R^2
Bbar = mean(d(:,1));
SStot = sum((d(:,1) - Bbar).^2);
SSreg = sum((d(:,2) - Bbar).^2);
SSres = sum((d(:,1) - d(:,2)).^2);
R2 = 1 - SSres/SStot;
R = corrcoef(d(:,1),d(:,2));
Rsq = R(1,2).^2;
title(strcat('R=',num2str(Rsq)))

%% plot as bar charts
font_size = 12;
figure
subplot(2,2,1)
bar(meanMatTestRMSE{1,1}-diag(meanMatTestRMSE{1,1}))
ylabel('\Delta')
xticklabels({'25','50','100','200'})
line([0 5], [0.025 0.025],'Color','r');
%legend({'25','50','100','200','CNT','DL','Thres.'},'Location','northeast','NumColumns',1)
title('NARMA-10')
xlabel('ESN Size')
%set(gca,'FontSize',font_size,'FontName','Arial')

subplot(2,2,2)
bar(meanMatTestRMSE{1,2}-diag(meanMatTestRMSE{1,2}))
xticklabels({'25','50','100','200'})
ylabel('\Delta')
line([0 5], [0.025 0.025],'Color','r');
legend({'25','50','100','200','CNT','DL','Thres.'},'Location','northeast','NumColumns',1)
title('NARMA-30')
xlabel('ESN Size')
%set(gca,'FontSize',font_size,'FontName','Arial')

subplot(2,2,3)
bar(meanMatTestRMSE{1,3}-diag(meanMatTestRMSE{1,3}))
xticklabels({'25','50','100','200'})
ylabel('\Delta')
line([0 5], [0.025 0.025],'Color','r');
%legend({'25','50','100','200','CNT','DL','\Delta thres.'},'Location','northeast','NumColumns',2)
title('Laser')
xlabel('ESN Size')
%set(gca,'FontSize',font_size,'FontName','Arial')

subplot(2,2,4)
bar(meanMatTestRMSE{1,4}-diag(meanMatTestRMSE{1,4}))
xticklabels({'25','50','100','200'})
ylabel('\Delta')
line([0 5], [0.025 0.025],'Color','r');
%legend({'25','50','100','200','CNT','DL','\Delta thres.'},'Location','northeast','NumColumns',2)
title('Nonlinear Channel Eq.')
xlabel('ESN Size')
%set(gca,'FontSize',font_size,'FontName','Arial')

print('delta_barchart','-dpdf','-bestfit')

%% plot as bar charts -  substrates only
font_size = 14;
figure
subplot(2,2,1)
bar([meanMatTestRMSE{1,1}(:,5)'-diag(meanMatTestRMSE{1,1})'; meanMatTestRMSE{1,1}(:,6)'-diag(meanMatTestRMSE{1,1})'] )
ylabel('\Delta')
xticklabels({'CNT', 'DL'})
%line([0 5], [0.025 0.025],'Color','r');
%legend({'25','50','100','200'},'Location','northwest','NumColumns',1)
title('NARMA-10')
%xlabel('ESN Size')
set(gca,'FontSize',font_size,'FontName','Arial')
ylim([-0.1 0.3])

subplot(2,2,2)
bar([meanMatTestRMSE{1,2}(:,5)'-diag(meanMatTestRMSE{1,2})'; meanMatTestRMSE{1,2}(:,6)'-diag(meanMatTestRMSE{1,2})'] )
ylabel('\Delta')
xticklabels({'CNT', 'DL'})
legend({'25','50','100','200'},'Location','northwest','NumColumns',1)
title('NARMA-30')
%xlabel('ESN Size')
set(gca,'FontSize',font_size,'FontName','Arial')
ylim([-0.1 0.3])

subplot(2,2,3)
bar([meanMatTestRMSE{1,3}(:,5)'-diag(meanMatTestRMSE{1,3})'; meanMatTestRMSE{1,3}(:,6)'-diag(meanMatTestRMSE{1,3})'] )
ylabel('\Delta')
xticklabels({'CNT', 'DL'})
%legend({'25','50','100','200','CNT','DL','\Delta thres.'},'Location','northeast','NumColumns',2)
title('Laser')
%xlabel('ESN Size')
set(gca,'FontSize',font_size,'FontName','Arial')
ylim([-0.1 0.3])

subplot(2,2,4)
bar([meanMatTestRMSE{1,4}(:,5)'-diag(meanMatTestRMSE{1,4})'; meanMatTestRMSE{1,4}(:,6)'-diag(meanMatTestRMSE{1,4})'] )
ylabel('\Delta')
xticklabels({'CNT', 'DL'})
%legend({'25','50','100','200','CNT','DL','\Delta thres.'},'Location','northeast','NumColumns',2)
title('NCE')
ylim([-0.1 0.3])
%xlabel('ESN Size')
set(gca,'FontSize',font_size,'FontName','Arial')

print('delta_barchart_subOnly','-dpdf','-bestfit')

%% plot task clusters
figure1 = figure;
figure2 = figure;
figure3 = figure;
figure4 = figure;
figure5 = figure;

fig_list = [figure2 figure3 figure4 figure5];

% plot all behaviours
for i = 1:length(dataset)
error{i} = dataset{1,i}.pred_dataset.outputs;
data{i} = dataset{1,i}.pred_dataset.inputs;

[a_error{i},ascend_task_indx] = sort(error{i});

range_to_plot = length(error{i});

T1 = data{i}(ascend_task_indx(1:range_to_plot,1),:);
T1_error = a_error{i}(1:range_to_plot,1);
T2 = data{i}(ascend_task_indx(1:range_to_plot,2),:);
T2_error = a_error{i}(1:range_to_plot,2);
T3 = data{i}(ascend_task_indx(1:range_to_plot,3),:);
T3_error = a_error{i}(1:range_to_plot,3);
T4 = data{i}(ascend_task_indx(1:range_to_plot,4),:);
T4_error = a_error{i}(1:range_to_plot,4);

for j = 1:length(fig_list)
figure(fig_list(j))
subplot(1,3,1)
hold on
scatter(T1(:,1),T1(:,2),10,[0.75 0.75 0.75],'filled');
xlabel('KR')
ylabel('GR')
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,2)
hold on
scatter(T1(:,1),T1(:,3),10,[0.75 0.75 0.75],'filled');
xlabel('KR')
ylabel('MC')
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,3)
hold on
scatter(T1(:,2),T1(:,3),10,[0.75 0.75 0.75],'filled');
xlabel('GR')
ylabel('MC')
colorbar
end

end

% plot performances of best
for i = 1:length(dataset)
error{i} = dataset{1,i}.pred_dataset.outputs;
data{i} = dataset{1,i}.pred_dataset.inputs;

[a_error{i},ascend_task_indx] = sort(error{i});


range_to_plot = 250;

T1 = data{i}(ascend_task_indx(1:range_to_plot,1),:);
T1_error = a_error{i}(1:range_to_plot,1);
T2 = data{i}(ascend_task_indx(1:range_to_plot,2),:);
T2_error = a_error{i}(1:range_to_plot,2);
T3 = data{i}(ascend_task_indx(1:range_to_plot,3),:);
T3_error = a_error{i}(1:range_to_plot,3);
T4 = data{i}(ascend_task_indx(1:range_to_plot,4),:);
T4_error = a_error{i}(1:range_to_plot,4);

%figure
figure(figure1)
subplot(1,3,1)
scatter(T1(:,1),T1(:,2),10,[1 0 0],'filled');
hold on
scatter(T2(:,1),T2(:,2),10,[0 1 0],'filled'); % [0.75 0.75 0.75]
scatter(T3(:,1),T3(:,2),10,[0 0 1],'filled'); %[0.5 0.5 0.5]
scatter(T4(:,1),T4(:,2),10,[0 0 0],'filled'); % [0.25 0.25 0.25] [0 0 0]
xlabel('KR')
ylabel('GR')
set(gca,'FontSize',12,'FontName','Arial')
legend({'T1','T2','T3','T4'},'Location','northwest')

subplot(1,3,2)
scatter(T1(:,1),T1(:,3),10,[1 0 0],'filled');
hold on
scatter(T2(:,1),T2(:,3),10,[0 1 0],'filled');
scatter(T3(:,1),T3(:,3),10,[0 0 1],'filled');
scatter(T4(:,1),T4(:,3),10,[0 0 0],'filled');
xlabel('KR')
ylabel('MC')
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,3)
scatter(T1(:,2),T1(:,3),10,[1 0 0],'filled');
hold on
scatter(T2(:,2),T2(:,3),10,[0 1 0],'filled');
scatter(T3(:,2),T3(:,3),10,[0 0 1],'filled');
scatter(T4(:,2),T4(:,3),10,[0 0 0],'filled');
xlabel('GR')
ylabel('MC')

%% task 1
figure(figure2)
subplot(1,3,1)
hold on
scatter(T1(:,1),T1(:,2),10,T1_error,'filled');
xlabel('KR')
ylabel('GR')
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,2)
hold on
scatter(T1(:,1),T1(:,3),10,T1_error,'filled');
xlabel('KR')
ylabel('MC')
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,3)
hold on
scatter(T1(:,2),T1(:,3),10,T1_error,'filled');
xlabel('GR')
ylabel('MC')
colorbar
%% task 2
figure(figure3)
subplot(1,3,1)
hold on
scatter(T2(:,1),T2(:,2),10,T2_error,'filled');
xlabel('KR')
ylabel('GR')
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,2)
hold on
scatter(T2(:,1),T2(:,3),10,T2_error,'filled');
xlabel('KR')
ylabel('MC')
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,3)
hold on
scatter(T2(:,2),T2(:,3),10,T2_error,'filled');
xlabel('GR')
ylabel('MC')
colorbar

%% task 3
figure(figure4)
subplot(1,3,1)
hold on
scatter(T3(:,1),T3(:,2),10,T3_error,'filled');
xlabel('KR')
ylabel('GR')
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,2)
hold on
scatter(T3(:,1),T3(:,3),10,T3_error,'filled');
xlabel('KR')
ylabel('MC')
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,3)
hold on
scatter(T3(:,2),T3(:,3),10,T3_error,'filled');
xlabel('GR')
ylabel('MC')
colorbar

%% task 4
figure(figure5)
subplot(1,3,1)
hold on
scatter(T4(:,1),T4(:,2),10,T4_error,'filled');
xlabel('KR')
ylabel('GR')
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,2)
hold on
scatter(T4(:,1),T4(:,3),10,T4_error,'filled');
xlabel('KR')
ylabel('MC')
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,3)
hold on
scatter(T4(:,2),T4(:,3),10,T4_error,'filled');
xlabel('GR')
ylabel('MC')
colorbar
end



