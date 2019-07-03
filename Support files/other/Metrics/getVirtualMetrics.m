% Separation Metrics and Kernel Quality
function metrics = getVirtualMetrics(individual,config)

scurr = rng;
temp_seed = scurr.Seed;
metrics = [];
% training reguliser
config.reg_param = 10e-6;

for metric_item = 1:length(config.metrics)
    switch config.metrics{metric_item}
        case 'KR'
            rng(1,'twister');
            num_timesteps = 3300;
            
            %Remove input sequence and reduce forget points
            config.wash_out = 100;
            
            % Expanded version - more reliable, Norton & Ventura: "Improving liquid state machines......"
            N = individual.n_input_units;
            
            bestDist =0;
            for i = 1:1000 %search for biggest separation
                ui = round(20*rand(num_timesteps,N)-10)/10;
                %dist = sum(sum(abs(ui-repmat((sum(ui,2)/N),1,N))));
                dist = std(ui);
                if dist > bestDist
                    bestDist = dist;
                    bestUi = ui;
                end
            end
            
            ui = bestUi;
            
            input_sequence = repmat(ui(:,1),1,N);
            
            %kernel matrix - pick 'to' at halfway point
            M = config.assessFcn(individual,input_sequence,config);
            
            %catch errors
            M(isnan(M)) = 0;
            M(isinf(M)) = 0;
            
            %% Kernal Quality
            s = svd(M);
            
            tmp_rank_sum = 0;
            full_rank_sum = 0;
            e_rank = 1;
            for i = 1:length(s)
                full_rank_sum = full_rank_sum + s(i);
                while (tmp_rank_sum < full_rank_sum * 0.99)
                    tmp_rank_sum = tmp_rank_sum + s(e_rank);
                    e_rank= e_rank+1;
                end
            end
            kernel_rank = e_rank-1;
               
            metrics = [metrics kernel_rank];
            
            %% Genralization Rank
        case 'GR'
            rng(1,'twister');
            ui_1 = round(10*rand)/10;
            ui = repmat(ui_1,1,num_timesteps)'+(1*rand(num_timesteps,1)-0.5)/10;
            ui(1) = ui_1;
            %inputSequence = ui;
            input_sequence =repmat(ui,1,N);
            
            %collect states
            G = config.assessFcn(individual,input_sequence,config);
            
            %catch errors
            G(isnan(G)) = 0;
            G(isinf(G)) = 0;
            
            % get rank of matrix
            s = svd(G);
            
            %claculate effective rank
            tmp_rank_sum = 0;
            full_rank_sum = 0;
            e_rank = 1;
            for i = 1:length(s)
                full_rank_sum = full_rank_sum +s(i);
                while (tmp_rank_sum < full_rank_sum * 0.99)
                    tmp_rank_sum = tmp_rank_sum + s(e_rank);
                    e_rank= e_rank+1;
                end
            end
            gen_rank = e_rank-1;
                       
            metrics = [metrics gen_rank];
                
            %% LE measure
        case 'LE'
            rng(1,'twister');
            meanLE = LEmetrics_DeepESN(individual,config);
            metrics = [metrics meanLE];
            
            %% Entropy measure
        case 'Entropy'
            rng(1,'twister');
            input_sequence = ones(1000,1);
            
            X = config.assessFcn(individual,input_sequence,config);
            C = X'*X;
            
            X_eig = eig(C);
            
            normX_eig = X_eig./sum(X_eig);
            
            H = -sum(normX_eig.*log2(normX_eig));
            
            entropy = real(H/log2(size(X,2)));
            
            entropy(isnan(entropy)) = 0;
            metrics = [metrics entropy*100];
            
        case 'MC'
            %Remove input sequence and reduce forget points
            config.wash_out = 200;
            
            n_internal_units = individual.total_units;%sum([genotype.nInternalUnits]);
            
            n_output_units = n_internal_units*2;
            n_input_units = individual.n_input_units;
            
            %% Assign input data and collect target output
            data_length = 6000;
            if strcmp(config.res_type,'basicCA') || strcmp(config.res_type,'2dCA') || strcmp(config.res_type,'RBN')
                data_sequence = round(rand(1,data_length+1++n_output_units));% Deep-ESN version: 1.6*rand(1,dataLength+1++nOutputUnits)-0.8;
            else
                data_sequence = rand(1,data_length+1+n_output_units);% Deep-ESN version: 1.6*rand(1,dataLength+1++nOutputUnits)-0.8;
            end
            sequence_length = 5000;
            
            mem_input_sequence = data_sequence(n_output_units+1:data_length+n_output_units)';
            
            for i = 1:n_output_units
                mem_output_sequence(:,i) = data_sequence(n_output_units+1-i:data_length+n_output_units-i);
            end
            
            train_input_sequence = repmat(mem_input_sequence(1:sequence_length,:),1,n_input_units);%repmat(memInputSequence(1:sequenceLength/2,:),1,maxInputs);
            test_input_sequence = repmat(mem_input_sequence(1+sequence_length:end,:),1,n_input_units);%repmat(memInputSequence,1,maxInputs);
            
            train_output_sequence = mem_output_sequence(1:sequence_length,:);%repmat(memInputSequence,1,maxInputs);
            test_Output_sequence = mem_output_sequence(1+sequence_length:end,:);%repmat(memInputSequence,1,maxInputs);
            
            states = config.assessFcn(individual,train_input_sequence,config);
            
            %train
            output_weights = train_output_sequence(config.wash_out+1:end,:)'*states*inv(states'*states + config.reg_param*eye(size(states'*states)));
            Yt = round(states * output_weights');
            
            %test
            test_states =  config.assessFcn(individual,test_input_sequence,config);
            
            Y = round(test_states * output_weights');
            
            MC= 0; Cm = 0;
            for i = 1:n_output_units
                coVar = cov(test_Output_sequence(config.wash_out+1:end,i),Y(:,i)).^2;
                outVar = var(Y(:,i));
                targVar = var(test_input_sequence(config.wash_out+1:end,:));
                totVar = (outVar*targVar(1)');
                C = coVar(1,2)/totVar;
                MC = MC + C;
                R = corrcoef(test_Output_sequence(config.wash_out+1:end,i),Y(:,i));
                Cm = Cm + R(1,2).^2;
            end
            
            %remove errors
            if isnan(MC) || MC < 0
                MC = 0;
            end
            
            metrics = [metrics MC];
    end
end

rng(temp_seed,'twister');