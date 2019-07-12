% Separation Metrics and Kernel Quality
function metrics = getVirtualMetrics(individual,config)

scurr = rng;
temp_seed = scurr.Seed;

% set parameters
metrics = [];
config.reg_param = 10e-6;
config.wash_out = 100;
metrics_type =  config.metrics;
num_timesteps = individual.total_units*2 + config.wash_out; % input should be twice the size of network + wash out
N = individual.n_input_units;

for metric_item = 1:length(config.metrics)
    
    rng(1,'twister');
    
    switch metrics_type{metric_item}
        
        case 'KR'            
            
            %define input signal
            ui = 2*rand(num_timesteps,N)-1;
            
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
            % define input signal
            input_sequence = 1 + 0.1*rand(num_timesteps,N)-0.05;

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
            
            meanLE = LEmetrics_DeepESN(individual,config);
            metrics = [metrics meanLE];
            
            %% Entropy measure
        case 'Entropy'
            
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

            % measure MC multiple times
            %for 
            temp_MC = testMC(individual,config,1);
            %end
           
            MC = mean(temp_MC);
    
            metrics = [metrics MC];
    end
end

rng(temp_seed,'twister');