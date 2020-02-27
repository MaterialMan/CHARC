%% Assess the database on tasks
% import behaviours and assess on tasks, output information as a input-output dataset
function pred_dataset = assessDBonTasks(config,population,behaviours,results)

% Define tasks to evaluate
% Example: config.task_list = {'NARMA10','NARMA30','Laser','NonChanEqRodan'};
if length(config.res_type)>1
    res_type ='Heterotic';
else
    res_type = config.res_type;
end

% other params
config.figure_array =[];
batch_num = 10;

% error to check - default
config.error_to_check = 'train&val&test';

for set = 1:length(config.task_list)
    
    % get datasets
    config.dataset = config.task_list{set};
    fprintf('\n Task: %s \n',config.dataset);
    
    [config] = selectDataset(config);
    
    ppm = ParforProgMon(strcat('Assessing DB for Task: ', config.dataset), length(population));
    
    if nargin >3
        order = results.pred_best_indx{1,set}(1:length(population));
    else
        order = 1:length(population);
    end
    
    for i= 0:batch_num:length(population)
        
        test_error = [];
        tmp_pop = population(order(i+1:i+batch_num));
        parfor indx = 1:batch_num
            if isfield(tmp_pop(indx),'pop_indx')
                tmp_pop(indx).pop_indx = indx;
            end
            tmp_pop(indx) = config.testFcn(tmp_pop(indx),config);
            
            test_error(indx) = getError(config.error_to_check,tmp_pop(indx));
            fprintf('indv: %d, error: %.4f \n ',indx, test_error(indx));
            ppm.increment();
        end

        population(order(i+1:i+batch_num)) = tmp_pop;
        store_error(i+1:i+batch_num,set) = test_error;
        [best_err(set),best_indx(set)] = min(store_error(i+1:i+batch_num,set));
        fprintf('best indv: %d, best error: %.4f \n ',best_indx(set), best_err(set));
        
        
        save(strcat('assessed_substrate_',res_type,'_',num2str(sum(config.num_reservoirs)),'Nres.mat'),...
           'store_error','best_err','best_indx','config');
    end
    
end
       
% assign behaviours and task performance to struct for prediction
pred_dataset.inputs = behaviours;
pred_dataset.outputs = store_error;

save(strcat('assessed_substrate_',res_type,'_',num2str(sum(config.num_reservoirs)),'Nres.mat'),...
           'store_error','best_err','best_indx','pred_dataset','config');

