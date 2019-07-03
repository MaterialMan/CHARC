% import database - by hand
clearvars -except all_databases database_genotype config read_session switch_session

% define tasks
test_error = AssessGenotypeOnAllTasks(database_genotype,config, read_session, switch_session,config.task_list);
    
pred_dataset.inputs = all_databases{1,10};
pred_dataset.outputs = test_error;

%save output
 save(strcat('assessedHardware_dB_forPrediction_',num2str(length(database_ext)),'dbSize.mat'),...
                'pred_dataset','config','test_error','taskList','-v7.3');
       