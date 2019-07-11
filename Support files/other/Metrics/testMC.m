function MC = testMC(individual,config,seed)

rng(seed,'twister');

n_internal_units = individual.total_units;%sum([genotype.nInternalUnits]);

n_output_units = n_internal_units*2;
n_input_units = individual.n_input_units;

%% Assign input data and collect target output
data_length = 400; %6000
sequence_length = 200; %5000

if strcmp(config.res_type,'basicCA') || strcmp(config.res_type,'2dCA') || strcmp(config.res_type,'RBN')
    data_sequence = sign(rand(1,data_length+1++n_output_units)-0.5);
else
    data_sequence = 1*rand(1,data_length+1+n_output_units)-0.5;
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

if strcmp(config.res_type,'basicCA') || strcmp(config.res_type,'2dCA') || strcmp(config.res_type,'RBN')
    Y = round(test_states * output_weights');
else
    Y = test_states * output_weights';
end

MC= 0; Cm = 0;
for i = 1:n_output_units
    coVar = cov(test_output_sequence(config.wash_out+1:end,i),Y(:,i)).^2;
    outVar = var(Y(:,i));
    targVar = var(test_input_sequence(config.wash_out+1:end,:));
    totVar = (outVar*targVar(1)');
    MC_k(i) = coVar(1,2)/totVar;
    
    %R = corrcoef(test_Output_sequence(config.wash_out+1:end,i),Y(:,i));
    %Cm = Cm + R(1,2).^2;
end

MC = sum(MC_k);

%remove errors
if isnan(MC) || MC < 0
    MC = 0;
end

end