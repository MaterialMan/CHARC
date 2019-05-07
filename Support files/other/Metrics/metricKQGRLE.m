% Separation Metrics and Kernel Quality
function [meanLE, kernel_rank, gen_rank,rank_diff] = metricKQGRLE(genotype,config)

if config.use_metric(1)
    
    scurr = rng;
    temp_seed = scurr.Seed;
    rng(1,'twister');
    numTimesteps = 3300;
    
    %Remove input sequence and reduce forget points
    config.nForgetPoints = 100;
    
    % Expanded version - more reliable, Norton & Ventura: "Improving liquid state machines......"
    N = genotype.nInputUnits;
    
    bestDist =0;
    for i = 1:1000 %search for biggest separation
        ui = round(20*rand(numTimesteps,N)-10)/10;
        %dist = sum(sum(abs(ui-repmat((sum(ui,2)/N),1,N))));
        dist = std(ui);
        if dist > bestDist
            bestDist = dist;
            bestUi = ui;
        end
    end
    
    ui = bestUi;
    
    inputSequence = repmat(ui(:,1),1,N);
    
    %kernel matrix - pick 'to' at halfway point
    M = config.assessFcn(genotype,inputSequence,config);
        
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
    
    kernel_rank = kernel_rank/size(M,2);
else
    kernel_rank =[];
end

%% LE measure
%[meanLE] = LEmetrics(esn);
if config.use_metric(3)
   % meanLE = LEmetrics_DeepESN(genotype,config);
   inputSequence = ones(1000,1);
   
   X = config.assessFcn(genotype,inputSequence,config);
   C = X'*X;
   
   X_eig = eig(C);
   
   normX_eig = X_eig./sum(X_eig);
   
   H = -sum(normX_eig.*log2(normX_eig));
   
   meanLE = real(H/log2(size(X,2)));
   
   meanLE(isnan(meanLE)) = 0;
else
    meanLE = [];
end

%% Genralization Rank
%rng(1,'twister');
if config.use_metric(2)
    ui_1 = round(10*rand)/10;
    ui = repmat(ui_1,1,numTimesteps)'+(1*rand(numTimesteps,1)-0.5)/10;
    ui(1) = ui_1;
    %inputSequence = ui;
    inputSequence =repmat(ui,1,N);
    
    %collect states
    G = config.assessFcn(genotype,inputSequence,config);
    
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
    
    gen_rank = gen_rank/size(M,2);
    
else
    gen_rank  =[];
end



%calculate difference
if config.use_metric(1) && config.use_metric(2)
    rank_diff = kernel_rank-gen_rank; %abs(kernel_rank-gen_rank)]; %KQ should be high and GR low for a good classifier
else
    rank_diff = [];
end
% ----------------------------------------------------------------------------------------
%fprintf('KQ: %.3f, GR: %.3f, KQ/GR diff: %.3f, LE1: %.3f, LE2: %.3f\n',kernel_rank,gen_rank,rank_diff(1), meanLE(1), meanLE(2));
%fprintf('KQ: %.3f, GR: %.3f, KQ/GR diff: %.3f, LE: \n',kernel_rank,gen_rank,rank_diff);
%disp(meanLE)

rng(temp_seed,'twister');