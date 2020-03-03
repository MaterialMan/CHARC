%% Objective function
function y = fitnessNSGAII(genotype,config)

%Assess each task
y = zeros(1,config.num_objectives);
for j = 1:config.num_objectives
    config.train_input_sequence = config.data{1,j}.train_input_sequence;
    config.train_output_sequence = config.data{1,j}.train_output_sequence;
    
    config.val_input_sequence = config.data{1,j}.val_input_sequence;
    config.val_output_sequence = config.data{1,j}.val_output_sequence;
    
    config.test_input_sequence = config.data{1,j}.test_input_sequence;
    config.test_output_sequence = config.data{1,j}.test_output_sequence;
    
    config.wash_out =  config.data{1,j}.wash_out;
    config.err_type = config.data{1,j}.err_type;
    
    config.task_num_inputs = size(config.train_input_sequence,2);
    config.task_num_outputs = size(config.train_output_sequence,2);
    
    genotype = config.testFcn(genotype,config);
    y(j) = getError(config.error_to_check,genotype);
    %sum(genotype.valError);%sum(genotype.trainError + genotype.valError);
end

end