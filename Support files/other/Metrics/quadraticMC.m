function quad_MC = quadraticMC(individual,config,seed,num_timesteps)

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

%% quadratic memory capacity - ??(?)=3?2(???)?1 
quad_input_sequence = input_sequence;
for i = 1:n_output_units
     u = data_sequence(n_output_units+1-i:data_length+n_output_units-i);
    quad_output_sequence(:,i) = (3.*(u.^2)) - 1;    
end

quad_train_input_sequence = repmat(quad_input_sequence(1:sequence_length,:),1,n_input_units);
quad_test_input_sequence = repmat(quad_input_sequence(1+sequence_length:end,:),1,n_input_units);

quad_train_output_sequence = quad_output_sequence(1:sequence_length,:);
quad_test_output_sequence = quad_output_sequence(1+sequence_length:end,:);

quad_states = config.assessFcn(individual,quad_train_input_sequence,config);

%train
quad_output_weights = quad_train_output_sequence(config.wash_out+1:end,:)'*quad_states*inv(quad_states'*quad_states + config.reg_param*eye(size(quad_states'*quad_states)));

quad_test_states =  config.assessFcn(individual,quad_test_input_sequence,config);

% calculate output
quad_Y = quad_test_states * quad_output_weights';

% quad_MC = 0;
% for i = 1:n_output_units
%     mse(i) = mean((quad_test_output_sequence(config.wash_out+1:end,i)-quad_Y(:,i)).^2);
%     %deno(i) = mean(quad_test_output_sequence(config.wash_out+1:end,i).^2);    
%     quad_MC(i) = 1-mse(i);%/deno(i));
% end
% sum(quad_MC)
quad_MC_k= 0; 
test_in_var = quad_test_input_sequence(config.wash_out+1:end,1);
targVar = 1/(length(test_in_var)-1) * sum((test_in_var-mean(test_in_var)).*(test_in_var-mean(test_in_var)));

for i = 1:n_output_units
       
    coVar = 1/(length(quad_Y(:,i))-1) * sum((quad_test_output_sequence(config.wash_out+1:end,i)-mean(quad_test_output_sequence(config.wash_out+1:end,i)))...
       .*(quad_Y(:,i)-mean(quad_Y(:,i))));    
    outVar = 1/(length(quad_Y(:,i))-1) * sum((quad_Y(:,i)-mean(quad_Y(:,i))).*(quad_Y(:,i)-mean(quad_Y(:,i))));    
    totVar = (outVar*targVar(1));    
    quad_MC_k(i) = (coVar*coVar)/totVar;
    
end

quad_MC_k(isnan(quad_MC_k)) = 0;
quad_MC = sum(quad_MC_k);

end