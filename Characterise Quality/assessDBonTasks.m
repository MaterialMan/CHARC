%% Assess the database on tasks
% import behaviours and assess on tasks, output information as a input-output dataset 
function pred_dataset = assessDBonTasks(config,population,behaviours)

% Define tasks to evaluate
% Example: config.task_list = {'NARMA10','NARMA30','Laser','NonChanEqRodan'};
    
for set = 1:length(config.task_list)
        
    % get datasets
    config.data_set = config.task_list{set};
    [config] = selectDataset(config);

    ppm = ParforProgMon('DB assessed: ', length(population));
    parfor indx = 1:length(population)
        population(indx) = config.testFcn(population(indx),config);
        test_error(indx,set) = population(indx).testError;
        ppm.increment();
    end    
end

% assign behaviours and task performance to struct for prediction
pred_dataset.inputs = behaviours;
pred_dataset.outputs = test_error;

       