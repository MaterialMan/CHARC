%% MAP-elites
% Notes: Implementation of MAP-elites using reservoir metrics to create behaviour space 

% Author: M. Dale
% Date: 30/04/19
clear
rng(1,'twister');

%start paralllel pool if empty
if isempty(gcp)
    parpool; % create parallel pool
end

% Setup
%% type of network to evolve
config.resType = 'RoR_IA';                   % can use different hierarchical reservoirs. RoR_IA is default ESN.
config.maxMinorUnits = 20;                   % num of nodes in subreservoirs
config.maxMajorUnits = 1;                   % num of subreservoirs. Default ESN should be 1.
config = selectReservoirType(config);       %get correct functions for type of reservoir

%% Network details
config.startFull = 1;                       % start with max network size
config.alt_node_size = 0;                   % allow different network sizes
config.multiActiv = 0;                      % use different activation funcs
config.leakOn = 1;                          % add leak states
config.rand_connect =1;                     %radnomise networks
config.activList = {'lineraNode','tanh'};   % what activations are in use when multiActiv = 1
config.trainingType = 'Ridge';              %blank is psuedoinverse. Other options: Ridge, Bias,RLS
config.AddInputStates = 1;                  %add input to states
config.regParam = 10e-5;                    %training regulariser
config.metrics = {'KR','MC'}; % metrics to use (and order of metrics)

config.sparseInputWeights = 0;              % use sparse inputs
config.restricedWeight = 0;                 % restrict weights to defined values
config.nsga2 = 0;
config.evolvedOutputStates = 0;             %if evovled outputs are wanted

%% Evolutionary parameters
config.numTests = 1;                        % num of runs
config.initial_population = 200;             % large pop better
config.totalIter = 200;                    % num of gens
config.mutRate = 0.1;                       % mutation rate
config.recRate = 0.5;                       % recombination rate
config.evolveOutputWeights = 0;             % evolve rather than train

config.voxel_size = 10;

%% Task parameters
config.discrete = 0;                                                        % binary input for discrete systems
config.nbits = 16;                                                          % if using binary/discrete systems
config.preprocess = 1;                                                      % basic preprocessing, e.g. scaling and mean variance
config.dataSet = 'poleBalance';                                                  % Task to evolve for

% get dataset
[config] = selectDataset(config);

% get any additional params stored in getDataSetInfo.m
[config,figure3] = getDataSetInfo(config);

%% MAP of elites parameters
config.batch_size = 10;                                                     % how many offspring to create in one iteration
config.local_breeding = 1;                                                  % if interbreeding is local or global
config.k_neighbours = 5;                                                    % select second parent from neighbouring behaviours
config.total_MAP_size = round(config.maxMinorUnits*config.maxMajorUnits + (config.AddInputStates*config.task_num_inputs) + 1);  %size depends system used
config.MAP_resolution = flip(recursiveDivision(config.total_MAP_size/2));     % list to define MAP of elites resolution, i.e., how many cells
config.change_MAP_iter = round(config.totalIter/(length(config.MAP_resolution)-1)); % change the resolution after I iterations
config.start_MAP_resolution = config.MAP_resolution(1);                        % record of first resolution point

figure1 = figure;
figure2 = figure;

%% Run MicroGA
for tests = 1:config.numTests
    
    clearvars -except config tests figure1 figure2 figure3 store_global_best quality
    
    fprintf('\n Test: %d  ',tests);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    tic
    
    rng((tests-1)*config.totalIter*config.batch_size,'twister');
    
    %reset global best
    global_best = inf;
    
    % create first MAP of elites
    config.res_iter = 1;
    [config, MAP] = changeMAPresolution(config,[]);
    
    %% first batch
    config.popSize = config.initial_population;
    genotype = config.createFcn(config);    
    
    % Evaluate offspring
    for i = 1:config.popSize
        genotype(i).metrics = []; % add metrics to each genotype
    end
    ppm = ParforProgMon('Initial population: ', config.popSize);
    parfor p = 1:config.popSize
        genotype(p).metrics = round(getVirtualMetrics(genotype(p),config))+1;
        genotype(p) = config.testFcn(genotype(p),config);
        ppm.increment();
    end
    
    % find behaviour match
    for i = 1:config.popSize
        %record best error found
        if genotype(i).valError < global_best
            global_best = genotype(i).valError;
        end
            
        discretised_behaviour = floor(genotype(i).metrics/config.MAP_resolution(config.res_iter))*config.MAP_resolution(config.res_iter);
        [~, idx] = ismember(discretised_behaviour, config.combs, 'rows');
        % assign elites
        if isempty(MAP{idx})
            MAP{idx} = genotype(i);
        elseif genotype(i).valError < MAP{idx}.valError
            MAP{idx} = genotype(i);
        end
    end
    
    %% start generational loop
    for iter = 1:config.totalIter-1
        
        % increase MAP resolution
        if mod(iter,config.change_MAP_iter) == 0
            config.res_iter = config.res_iter+1;
            [config, MAP]= changeMAPresolution(config,MAP);
        end
        
        %% evaluate offspirng in batches
        parfor b = 1:config.batch_size
            warning('off','all')
            rng((tests-1)+(iter-1)*config.batch_size+b,'twister');
            
            % find all behaviours and pick one randomly
            occupied_cells = ~cellfun('isempty',MAP);
            idxs = find(occupied_cells);
            p_1 = idxs(randi([1 length(idxs)]));
            
            if config.local_breeding
                % find a second behaviour within some proximity to the first
                list = [MAP{idxs}];
                all_metrics = reshape([list.metrics],length(config.metrics),length([list.metrics])/length(config.metrics));
                
                % pick random neighbour in close proximity
                [knn_indx] = knnsearch(all_metrics',MAP{p_1}.metrics,'K',config.k_neighbours);
                p_2 = idxs(knn_indx(randi([1 length(knn_indx)])));
            else
                p_2 = idxs(randi([1 length(idxs)])); % anywhere in the behaviour space
            end
            
            % decide winner and loser
            if MAP{p_1}.valError < MAP{p_2}.valError
                winner = p_1;
                loser = p_2;
            else
                winner = p_2;
                loser = p_1;
            end
            
            % mix winner and loser first
            offspring(b) = config.recFcn(MAP{winner},MAP{loser},config);
            
            % mutate offspring/loser
            offspring(b) = config.mutFcn(offspring(b),config);
            
            % Evaluate offspring
            offspring(b).metrics = round(getVirtualMetrics(offspring(b),config))+1;
            offspring(b) = config.testFcn(offspring(b),config);
            
        end
        
        %% place batch offspring in MAP of elites
        for i = 1:config.batch_size
            %record offspring errors
            if offspring(i).valError < global_best
                global_best = offspring(i).valError;   
            end
            
            % find behaviour match
            discretised_behaviour = floor(offspring(i).metrics/config.MAP_resolution(config.res_iter))*config.MAP_resolution(config.res_iter);
            [~, idx] = ismember(discretised_behaviour, config.combs, 'rows');
            
            % assign elites
            if isempty(MAP{idx})
                MAP{idx} = offspring(i);
            elseif offspring(i).valError < MAP{idx}.valError
                MAP{idx} = offspring(i);
            end            
        end
        
        %% store and plot best error found
        for i = 1:length(MAP)
            if ~isempty(MAP{i})
                if MAP{i}.valError == global_best
                    best_indv = i;
                end
            end
        end
        
        store_global_best(tests,iter)  = global_best;
        set(0,'currentFigure',figure2)
        plot(store_global_best(tests,:));
        xlabel('Iterations (\times batch size)')
        ylabel('Test Error')
        drawnow;
        
        % plot MAP of elites
        plotSearch(figure1,MAP,iter*config.batch_size,config)
        
        if strcmp(config.resType,'Graph')
            plotGridNeuron(figure3,MAP,best_indv,config)
        end
        
        fprintf('\n iteration: %d, best error: %.4f  ',iter,global_best);
    end
    
    %% measure quality of explored space
    metrics = [];
    for i = 1: length(MAP)
        if ~isempty(MAP{i})
            metrics = [metrics; MAP{i}.metrics];
        end
    end
    
    [quality(tests)] = measureSearchSpace(metrics,config.voxel_size);
    
end

function [config,newMAP] = changeMAPresolution(config,MAP)

[ca, cb] = ndgrid(0:config.MAP_resolution(config.res_iter):config.total_MAP_size,...
    0:config.MAP_resolution(config.res_iter):config.total_MAP_size);%,...
%0:config.MAP_resolution(config.res_iter):config.total_MAP_size); %no. of inputs/outputs to ngrid is no. of metrics

config.combs = [ca(:), cb(:)]; % manually add all combinations together

newMAP = cell(length(config.combs),1);

if ~isempty(MAP)
    
    for i = 1:length(MAP)
        % find behaviour match
        if ~isempty(MAP{i})
            discretised_behaviour = floor(MAP{i}.metrics/config.MAP_resolution(config.res_iter))*config.MAP_resolution(config.res_iter);
            [~, idx] = ismember(discretised_behaviour, config.combs, 'rows');
            
            % assign elites
            if isempty(newMAP{idx})
                newMAP{idx} = MAP{i};
            elseif MAP{i}.valError < newMAP{idx}.valError
                newMAP{idx} = MAP{i};
            end
        end
    end
end

end

function plotSearch(figureHandle,database, gen,config)

set(0,'currentFigure',figureHandle)

v = 1:length(config.metrics);
C = nchoosek(v,2);

if size(C,1) > 3
    num_plot_x = size(C,1)/2;
    num_plot_y = 2;
else
    num_plot_x = 3;
    num_plot_y = 1;
end

X = []; fitness =[];

for i = 1:length(config.combs)
    if ~isempty(database{i}) && database{i}.valError < 1
        X = [X; database{i}.metrics];
        fitness = [fitness; database{i}.valError];
    end
end


for i = 1:size(C,1)
    if size(C,1) > 1
        subplot(num_plot_x,num_plot_y,i)
    end
    scatter(X(:,C(i,1)),X(:,C(i,2)),20, fitness,'filled')
    
    xlabel(config.metrics(C(i,1)))
    ylabel(config.metrics(C(i,2)))
    colormap('copper')
    colorbar
    xticks(0:config.MAP_resolution(config.res_iter):config.total_MAP_size)
    yticks(0:config.MAP_resolution(config.res_iter):config.total_MAP_size)
    grid on
end

title(strcat('Gen:',num2str(gen)))
drawnow

end

function plotGridNeuron(figure1,MAP,best_indv,config)

set(0,'currentFigure',figure1)

if config.plot3d
    p = plot(MAP{best_indv}.G,'NodeLabel',{},'Layout','force3');
else
    p = plot(MAP{best_indv}.G,'NodeLabel',{},'Layout','force');
end
p.NodeColor = 'black';
p.MarkerSize = 1;
if ~config.directedGraph
    p.EdgeCData = MAP{best_indv}.G.Edges.Weight;
end
highlight(p,logical(MAP{best_indv}.input_loc),'NodeColor','g','MarkerSize',3)
colormap(bluewhitered)
xlabel('Best weights')

pause(0.01)
drawnow
end
