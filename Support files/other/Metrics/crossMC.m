function cross_MC = crossMC(individual,config,seed,num_timesteps)

rng(seed,'twister');

n_internal_units = individual.total_units;%sum([genotype.nInternalUnits]);

n_output_units = n_internal_units*2;
n_input_units = individual.n_input_units;

%% Assign input data and collect target output
data_length = num_timesteps;%n_internal_units*4 + config.wash_out*2;%400; 
sequence_length = data_length/2;%200; 
data_sequence = 2*rand(n_input_units,data_length+1+n_output_units)-1;

% rescale for each reservoir
[data_sequence] = featureNormailse(data_sequence,config.preprocess);
            

if config.discrete %strcmp(config.res_type,'elementary_CA') || strcmp(config.res_type,'2d_CA') || strcmp(config.res_type,'RBN')
    data_sequence = floor(heaviside(data_sequence));
end

input_sequence = data_sequence(n_output_units+1:data_length+n_output_units)';

%% cross memory capacity - ????(?)=?(???)?(????)
cross_input_sequence = input_sequence;
cross_output_sequence = [];
for i = 1:n_output_units
    u = data_sequence(n_output_units+1-i:data_length+n_output_units-i)';
    for j = 1:n_output_units
        cross_output_sequence = [cross_output_sequence u.*data_sequence(n_output_units+1-j:data_length+n_output_units-j)'];   
    end
end

cross_train_input_sequence = repmat(cross_input_sequence(1:sequence_length,:),1,n_input_units);
cross_test_input_sequence = repmat(cross_input_sequence(1+sequence_length:end,:),1,n_input_units);

cross_train_output_sequence = cross_output_sequence(1:sequence_length,:);
cross_test_output_sequence = cross_output_sequence(1+sequence_length:end,:);

cross_states = config.assessFcn(individual,cross_train_input_sequence,config);

%train
cross_output_weights = cross_train_output_sequence(config.wash_out+1:end,:)'*cross_states*inv(cross_states'*cross_states + config.reg_param*eye(size(cross_states'*cross_states)));

cross_test_states =  config.assessFcn(individual,cross_test_input_sequence,config);

% calculate output
cross_Y =cross_test_states * cross_output_weights';

% cross_MC = 0;
% for i = 1:n_output_units
%     cross_MC = cross_MC + (1 - mean((cross_test_output_sequence(config.wash_out+1:end,:)-cross_Y).^2)/var(cross_test_output_sequence(config.wash_out+1:end,:)));
% end

cross_MC_k= 0; 
test_in_var = cross_test_input_sequence(config.wash_out+1:end,1);
targVar = 1/(length(test_in_var)-1) * sum((test_in_var-mean(test_in_var)).*(test_in_var-mean(test_in_var)));

for i = 1:n_output_units.^2
       
    coVar = 1/(length(cross_Y(:,i))-1) * sum((cross_test_output_sequence(config.wash_out+1:end,i)-mean(cross_test_output_sequence(config.wash_out+1:end,i)))...
       .*(cross_Y(:,i)-mean(cross_Y(:,i))));    
    outVar = 1/(length(cross_Y(:,i))-1) * sum((cross_Y(:,i)-mean(cross_Y(:,i))).*(cross_Y(:,i)-mean(cross_Y(:,i))));    
    totVar = (outVar*targVar(1));    
    cross_MC_k(i) = (coVar*coVar)/totVar;
    
end

cross_MC_k(isnan(cross_MC_k)) = 0;
cross_MC = sum(cross_MC_k);

end