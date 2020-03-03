% Separation Metrics and Kernel Quality
function out_metrics = getMetrics_Seeded(individual,config,checks)

scurr = rng;
%temp_seed = scurr.Seed;

% set parameters
%metrics = [];
config.reg_param = 10e-6;
config.wash_out = 25;
metrics_type =  config.metrics;
num_timesteps = round(individual.total_units*1.5) + config.wash_out; % input should be twice the size of network + wash out
n_input_units = individual.n_input_units;

for c = 1:checks
    
    metrics = [];
    
for metric_item = 1:length(config.metrics)
    
    rng(c,'twister')
    
    switch metrics_type{metric_item}
        
        case 'KR'
            
            %define input signal
            ui = 2*rand(num_timesteps,n_input_units)-1;
            
            input_sequence = repmat(ui(:,1),1,n_input_units);
            
            % rescale for each reservoir
            input_sequence =input_sequence.*config.scaler;
            
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
            input_sequence = 0.5 + 0.1*rand(num_timesteps,n_input_units)-0.05;
            
            % rescale for each reservoir
            input_sequence =input_sequence.*config.scaler;
            
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
            seed = 1;
            LE = lyapunovExponent(individual,config,seed);
            metrics = [metrics LE];
            
            %% Entropy measure
        case 'entropy'
            
            data_length = individual.total_units*2 + config.wash_out;%400;
            input_sequence = ones(data_length,n_input_units).*config.scaler;
            
            X = config.assessFcn(individual,input_sequence,config);
            C = X'*X;
            
            X_eig = eig(C);
            
            normX_eig = X_eig./sum(X_eig);
            
            H = -sum(normX_eig.*log2(normX_eig));
            
            entropy = real(H/log2(size(X,2)));
            
            entropy(isnan(entropy)) = 0;
            metrics = [metrics entropy*100];
            
        case 'linearMC'
            
            % measure MC multiple times
            datalength = 500 + config.wash_out*2;
            mc_seed = c;
            temp_MC = testMC(individual,config,mc_seed,datalength);
            
            MC = mean(temp_MC);
            
            metrics = [metrics MC];
            
            
        case 'quadraticMC'
            
            quad_MC = quadraticMC(individual,config,c);
            
            metrics = [metrics quad_MC];
            
        case 'crossMC'
            
            cross_MC = crossMC(individual,config,c);
            
            metrics = [metrics cross_MC];
            
        case 'separation'
            
            data_length = individual.total_units*4 + config.wash_out*2;%400;
            
            u1 = (rand(data_length,n_input_units)-1).*config.scaler;
            u2 = (rand(data_length,n_input_units)).*config.scaler;
            
            D= norm(u1-u2);
            
            X1 = config.assessFcn(individual,u1,config);
            
            X2 = config.assessFcn(individual,u2,config);
            
            sep = norm(X1 - X2)/D;
            
            metrics = [metrics sep];
            %abs(X1-X2)/D(i,config.wash_out+1:end);
            
            
            %             input_sequence = ones(data_length,1);
            %
            %             X = config.assessFcn(individual,input_sequence,config);
            %
            %             centre_of_mass = mean(X);
            %
            %             inter_class_distance =
            %
            %             intra_class_var =
            %
            %             sep = inter_class_distance/(intra_class_var + 1);
            %
            
        case 'mutalInformation'
            
            data_length = individual.total_units*4 + config.wash_out*2;%400;
            
            u = (rand(data_length,n_input_units)-1).*config.scaler;
            
            X = config.assessFcn(individual,u,config);
            
            for i = 1:size(X,1)
                for j = 1:size(X,1)
                    MI(j) = mutualInformation(X(i+1,:), X(i,j));
                end
                meanMI = mean(MI);
            end
            
        case 'transferEntropy'
            TE = transferEntropy(X, Y, W, varargin);
    end
end

out_metrics(c,:) = metrics; 
end
%rng(temp_seed,'twister');