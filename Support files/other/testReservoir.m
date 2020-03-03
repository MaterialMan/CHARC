function [individual,test_states,test_sequence] = testReservoir(individual,config)

train_states = config.assessFcn(individual,config.train_input_sequence,config,config.train_output_sequence);
val_states = config.assessFcn(individual,config.val_input_sequence,config,config.val_output_sequence);

%if W_out are evolved instead of trained
if config.evolve_output_weights
    output_train_sequence = train_states*individual.output_weights;
    output_val_sequence = val_states*individual.output_weights;
    individual.train_error = calculateError(output_train_sequence,config.train_output_sequence,config);
    individual.val_error = calculateError(output_val_sequence,config.val_output_sequence,config);
else
    
    % Find best reg parameter
    reg_train_error = [];
    reg_val_error =[];reg_weights=[];
    reg_param = [10e-1 10e-3 10e-5 10e-7 10e-9 10e-11];
    
    for i = 1:length(reg_param)
        %Train: tanspose is inversed compared to equation
        output_weights = config.train_output_sequence(config.wash_out+1:end,:)'*train_states*inv(train_states'*train_states + reg_param(i)*eye(size(train_states'*train_states)));
        
        % Calculate trained output Y
        output_train_sequence = train_states*output_weights';
        reg_train_error(i,:)  = calculateError(output_train_sequence,config.train_output_sequence,config);
        
        % Calculate trained output Y
        output_val_sequence = val_states*output_weights';
        reg_val_error(i,:)  = calculateError(output_val_sequence,config.val_output_sequence,config);
        reg_weights(i,:,:) =output_weights';
    end
    
    [~, reg_indx]= min(sum(reg_val_error,2));
    individual.train_error = sum(reg_train_error(reg_indx,:));
    individual.val_error = sum(reg_val_error(reg_indx,:));
    individual.output_weights =reshape(reg_weights(reg_indx,:,:),size(reg_weights,2),size(reg_weights,3));
    
    %remove NaNs
    individual.output_weights(isnan(individual.output_weights)) = 0;
end

%% Evaluate on test data
test_states = config.assessFcn(individual,config.test_input_sequence,config,config.test_output_sequence);
test_sequence = test_states*individual.output_weights;
individual.test_error = sum(calculateError(test_sequence,config.test_output_sequence,config));

end