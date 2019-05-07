% Separation Metrics and Kernel Quality
%geno is 2-dimensional
function [totalDrift, kernel_rank, gen_rank, rank_diff] = HardwareMetrics(read_session,maxInputs,genotype,leakOn,metric)

scurr = rng;
switch_session = [];
temp_seed = scurr.Seed;
rng(1,'twister');
numTimesteps = 3300;

%Remove input sequence and reduce forget points
nForgetPoints = 100;
totalDrift = 0;

% Expanded version - more reliable, Norton & Ventura: "Improving liquid state machines......"
ui = [];
N = 1;

if metric(1)
    %numTimeSteps = 3300; %was 250
    %measure details of input
    bestDist =0;
    for i = 1:1000 %search for biggest separation
        ui = round(20*rand(numTimesteps,N)-10)/10;
        dist = std(ui);
        if dist > bestDist
            bestDist = dist;
            bestUi = ui;
        end
    end
    ui = bestUi;
    
    
    %for test = 1:5
    % Create output queue for DAQ OUT
    inputSequence =repmat(ui(:,1),1,N);
    
    %% Collect average output response from repeat stimulus
    M = collectStatesHardware('train',switch_session, read_session, genotype, ...
        inputSequence,nForgetPoints,maxInputs,'simple',...
        [],[],[],leakOn);
    
    %kernel matrix - pick 'to' at halfway point
    
    M(isnan(M)) = 0;
    M(isinf(M)) = 0;
    
    %% Kernal Quality
    s = svd(M);
    
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
    kernel_rank(1) = e_rank-1;
else
    kernel_rank =[];
end

%% Gen_rank
if metric(2)
    ui_1 = round(10*rand)/10;
    ui = repmat(ui_1,1,numTimesteps)'+(1*rand(numTimesteps,1)-0.5)/10;
    ui(1) = ui_1;
    %inputSequence = ui;
    inputSequence =repmat(ui,1,N);
    
    %% get states
    G = collectStatesHardware('train',switch_session, read_session, genotype, ...
        inputSequence,nForgetPoints,maxInputs,'simple',...
        [],[],[],leakOn);
    
    %catch errors
    G(isnan(G)) = 0;
    G(isinf(G)) = 0;
    
    %% get rank of matrix
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
else
    gen_rank = [];
end

if metric(3)
    rank_diff = kernel_rank-gen_rank;
else
    rank_diff =[];
end
% ----------------------------------------------------------------------------------------
%fprintf('KQ: %.3f, Drfit: %.3f\n',kernel_rank,totalDrift);

release(read_session);
rng(temp_seed,'twister');

