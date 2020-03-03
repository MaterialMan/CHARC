
function results = predictTaskError(train_dataset, test_database, config)

rng(1,'twister');

%% process input data
results.test_dataset = reshape([test_database.behaviours],length(test_database(1).behaviours),length(test_database))';

if ~isfield(train_dataset,'inputs') % get task errors if not given
    all_behaviours = reshape([train_dataset.behaviours],length(train_dataset(1).behaviours),length(train_dataset))';
    train_dataset = assessDBonTasks(config,train_dataset,all_behaviours);
else
    if iscell(train_dataset)
        train_dataset = train_dataset{1};
    end
end
% assign variables
num_tasks = length(config.task_list);

num_tests= 10;
nn_size= [100];

threshold= repmat(2,1,num_tasks);

% increase threshold on hard narma 30 task
threshold(strcmp(config.task_list,'narma_30')) = 2;

samples = 1:length(train_dataset.inputs);

preprocess = 'scaling';

%% create docked window

desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
pred_task = desktop.addGroup('pred_task');
desktop.setGroupDocked('pred_task', 0);
myDim   = java.awt.Dimension(ceil(num_tasks)/2, 2);   % 4 columns, 2 rows
% 1: Maximized, 2: Tiled, 3: Floating
desktop.setDocumentArrangement('pred_task', 1, myDim)

figH    = gobjects(1, num_tasks);
bakWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

% config.figure_array = figure;
% for i = 2:num_tasks
%     config.figure_array = [config.figure_array figure];
% end


%% train predictor
for task = 1:num_tasks
    
fprintf('Task: %s \n',config.task_list{task})

%% pre processing
x = train_dataset.inputs(samples,:)';
t = train_dataset.outputs(samples,task)';

% remove bad reservoirs - NaNs and error > 1
indx = t > threshold(task);
x(:,indx) = [];
t(indx) = [];

indx2 = isnan(t);
x(:,indx2) = [];
t(indx2) = [];

%assign data
data = [x; t];

% rescale training data
norm_input_data = featureNormailse(data(1:end-1,:)',preprocess); 

data(1:end-1,:) = norm_input_data';

% split datasets
train_fraction = 0.7;
[train_set{task},~,test_set{task}] = ...
    split_train_test3way(data',train_fraction);

fprintf('Preprocessed data........\n')

%% train model
for test = 1:num_tests
    [results.trained_model{task,test},~,train_RMSE(task,test)] = trainFNNpredictor(train_set{task},nn_size);
    fprintf('Test = %d, RMSE = %.4f \n',test,train_RMSE(task,test));
end

%calculate mean
results.mean_train_RMSE = mean(train_RMSE,2);

fprintf('Train error %.f, Testing data........\n',results.mean_train_RMSE)

%% Test models
figH(task) = figure('WindowStyle', 'docked', ...
      'Name', sprintf('Figure %d', task), 'NumberTitle', 'off');

set(0,'currentFigure',figH(task))
for test = 1:num_tests
    tempModel = results.trained_model{task,test};                   % get trained model - predicts performance of substrate given substrate behaviour
    y = tempModel(test_set{task}(:,1:size(test_set{task},2)-1)');     % output of trained model, given metrics as inputs
    t = test_set{task}(:,size(test_set{task},2));                     % target error for given metrics
    test_RMSE(test) = sqrt(mean((t-y').^2));  %(pt,i,tst)       % calculate error of model
    
    scatter(y',t)
    line([0 1], [0 1],'Color','r')
    xlim([0 max(y)])
    ylim([0 max(t)])
    xlabel('Predicted')
    ylabel('Actual')    
end
drawnow

%% test on test_dataset
% pre processing
test_data = results.test_dataset';

% remove bad reservoirs - NaNs and error > 1
indx = t > threshold(task);
test_data(:,indx) = [];

indx2 = isnan(t);
test_data(:,indx2) = [];

% rescale training data
norm_test_data = featureNormailse(test_data',preprocess); 

for test = 1:num_tests
    test_model = results.trained_model{task,test};                   % get trained model - predicts performance of substrate given substrate behaviour
    test_prediction(test,:) = test_model(norm_test_data');     % output of trained model, given metrics as inputs    
end

results.mean_test_prediction(:,task) = mean(test_prediction);
 
%% plot predicted performance

set(0,'currentFigure',figH(task))

test_data = test_data';
%errors = log10(1./(results.mean_test_prediction(:,task)));
errors = results.mean_test_prediction(:,task);

v = 1:length(config.metrics);
C = nchoosek(v,2);

if size(C,1) > 3
    num_plot_x = ceil(size(C,1)/3);
    num_plot_y = 3;
else
    num_plot_x = 3;
    num_plot_y = 1;
end

for i = 1:size(C,1)
    subplot(num_plot_x,num_plot_y,i)
    scatter(test_data(:,C(i,1)),test_data(:,C(i,2)),20,errors,'filled')
    
    xlabel(config.metrics(C(i,1)))
    ylabel(config.metrics(C(i,2)))
    colormap('jet')
end
colorbar
subplot(num_plot_x,num_plot_y,1)
title(config.task_list{task})
drawnow

set(get(handle(figH(task)), 'javaframe'), 'GroupName', 'pred_task');
 
fprintf('Preprocessed data........\n')

[results.pred_task_errors{task},results.pred_best_indx{task}] = sort(results.mean_test_prediction(:,task));

% anything less than zero will be considered as good performance, thus
% taking the lowest error above zero
temp_pred_error = results.pred_task_errors{task};
temp_pred_error(temp_pred_error < 0) = [];
results.pred_task_errors{task}(results.pred_task_errors{task} < 0) = temp_pred_error(1);

fprintf('Task %d complete. Avg of Top 5 found: %.4f \n',task,median(temp_pred_error(1:5)))

% get best multi-task indv
sum_task_errors = sum(results.mean_test_prediction,2);
[results.multi_error, results.multi_indx] = sort(sum_task_errors);

% add left over details
results.train_dataset = train_dataset;

end

warning(bakWarn);