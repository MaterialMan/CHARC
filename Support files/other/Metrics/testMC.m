function MC = testMC(individual,config,seed,data_length)

rng(seed,'twister');

n_internal_units = individual.total_units;%sum([genotype.nInternalUnits]);

n_output_units = n_internal_units;
n_input_units = individual.n_input_units;

%% Assign input data and collect target output
%data_length = data_length;%500 + config.wash_out*2;%400; 
sequence_length = data_length/2;%200; 
data_sequence = 2*rand(n_input_units,data_length+1+n_output_units)-1;

% rescale for each reservoir
data_sequence = data_sequence.*config.scaler;

if config.discrete %strcmp(config.res_type,'elementary_CA') || strcmp(config.res_type,'2d_CA') || strcmp(config.res_type,'RBN')
    data_sequence = floor(heaviside(data_sequence));
end

mem_input_sequence = data_sequence(n_output_units+1:data_length+n_output_units)';

for i = 1:n_output_units
    mem_output_sequence(:,i) = data_sequence(n_output_units+1-i:data_length+n_output_units-i);
end

train_input_sequence = repmat(mem_input_sequence(1:sequence_length,:),1,n_input_units);
test_input_sequence = repmat(mem_input_sequence(1+sequence_length:end,:),1,n_input_units);

train_output_sequence = mem_output_sequence(1:sequence_length,:);
test_output_sequence = mem_output_sequence(1+sequence_length:end,:);

states = config.assessFcn(individual,train_input_sequence,config);

%train
output_weights = train_output_sequence(config.wash_out+1:end,:)'*states*inv(states'*states + config.reg_param*eye(size(states'*states)));

test_states =  config.assessFcn(individual,test_input_sequence,config);

%Y = test_states * output_weights';

if config.discrete
    Y = double((test_states * output_weights') > 0);
else
    Y = test_states * output_weights';
end

MC_k= 0; Cm = 0; 
test_in_var = test_input_sequence(config.wash_out+1:end,1);
targVar = 1/(length(test_in_var)-1) * sum((test_in_var-mean(test_in_var)).*(test_in_var-mean(test_in_var)));

for i = 1:n_output_units
       
    coVar = 1/(length(Y(:,i))-1) * sum((test_output_sequence(config.wash_out+1:end,i)-mean(test_output_sequence(config.wash_out+1:end,i)))...
       .*(Y(:,i)-mean(Y(:,i))));    
    outVar = 1/(length(Y(:,i))-1) * sum((Y(:,i)-mean(Y(:,i))).*(Y(:,i)-mean(Y(:,i))));    
    totVar = (outVar*targVar(1));    
    MC_k(i) = (coVar*coVar)/totVar;
    
    % remove low values from measure
    if MC_k(i) <= 0.1
        MC_k(i) = 0;
    end
end

MC_k(isnan(MC_k)) = 0;
MC = sum(MC_k);

end