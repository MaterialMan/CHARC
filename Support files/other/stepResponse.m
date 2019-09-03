clear
close all

%set random seed for experiments
rng(1,'twister');

config.figure_array = [figure figure('Position',[10 52 853 893]) ];

% type of network to evolve
config.res_type = 'RoR';                % state type of reservoir to use. E.g. 'RoR' (Reservoir-of-reservoirs/ESNs), 'ELM' (Extreme learning machine), 'Graph' (graph network of neurons), 'DL' (delay line reservoir) etc. Check 'selectReservoirType.m' for more.
config.num_nodes = [25];                  % num of nodes in each sub-reservoir, e.g. if config.num_nodes = {10,5,15}, there would be 3 sub-reservoirs with 10, 5 and 15 nodes each. For one reservoir, sate as a non-cell, e.g. config.num_nodes = 25
config = selectReservoirType(config);   % collect function pointers for the selected reservoir type

% Network details
config.metrics = {'KR','GR','MC'};       % behaviours that will be used; name metrics to use and order of metrics
config.voxel_size = 10;                  % when measuring quality, this will determine the voxel size. Depends on systems being compared. Rule of thumb: around 10 is good


% dummy variables for dataset; not used but still needed for functions to
% work
%config.train_input_sequence= [];
%config.train_output_sequence =[];
config.discrete = 0;               % select '1' for binary input for discrete systems
config.nbits = 16;                 % only applied if config.discrete = 1; if wanting to convert data for binary/discrete systems
config.preprocess = 1;             % basic preprocessing, e.g. scaling and mean variance
config.dataset = 'attractor';

% get any additional params stored in getDataSetInfo.m. This might include:
% details on reservoir structure, extra task variables, etc.
config = getAdditionalParameters(config);

% get dataset information
[config] = selectDataset(config);

config.num_tests = 1;                        % num of tests/runs
config.pop_size = 100;                       % initail population size. Note: this will generally bias the search to elitism (small) or diversity (large)
plot_on = 1;

%% define impulse
config.wash_out = 10;
%input_sequence = 2*rand(50,1)-1;

input_sequence = zeros(100,size(config.train_input_sequence,2));%
input_sequence(21:50,:) = ones(30,size(config.train_input_sequence,2));

%% run tests
for tests = 1:config.num_tests
    % update random seed
    rng(tests,'twister');
    
    % create population of reservoirs
    population = config.createFcn(config);
    
    %% visualise population
    for pop = 1:config.pop_size
        
        individual = population(pop);
        individual.bias_node = 0;
        states = config.assessFcn(individual,input_sequence,config);
        
        if plot_on
            set(0,'currentFigure',config.figure_array(2));
            subplot(2,2,[1 2])
            W = full(individual.W{1,1});
            G = digraph(W);
            p = plot(G,'Layout','force');
            p.MarkerSize = 10;
            
            %set default colormap
            p.EdgeCData = 2*rand(size(G.Edges.Weight))-1;
            colormap(gca,bluewhitered)
            caxis([-1 1])
            colorbar
            
            subplot(2,2,3)
            plot(states(:,1:end-1))
            ylabel('Output Magnitude')
            xlabel('Time/samples')
            h = animatedline([0 0],[-1 1],'Color','r');
            
            subplot(2,2,4)
            imagesc(states)
            colormap(gca,bluewhitered)
            xlabel('Nodes')
            ylabel('Time/samples')
            colorbar
            %plot3(1:length(states)-1,states(1:end-1,1:end-1),states(2:end,1:end-1))
            
            %run through each node after each state            
            for i = 2:size(states,1)
                p.NodeColor = ones(individual.nodes(1),3);
                p.EdgeCData = zeros(1,size(G.Edges.Weight,1));
                for k = 1:individual.nodes(1)
                    if states(i,k) > 0
                        colour = [1 1-states(i,k) 1-states(i,k)];
                    else
                        colour = [1-abs(states(i,k)) 1-abs(states(i,k)) 1];
                    end
                    
                    p.NodeColor(k,:) = colour;
                    
                    if var(states(i-1:i,k)) > 0.01 && sum(states(i,1:end-1)) ~= sum(individual.nodes)
                        p.EdgeCData(G.Edges.EndNodes(:,1) == k) = G.Edges.Weight(G.Edges.EndNodes(:,1) == k).*(states(i-1,k));
                        p.EdgeCData(G.Edges.EndNodes(:,2) == k) = G.Edges.Weight(G.Edges.EndNodes(:,2) == k).*(states(i,k));
                    end
                end
                
                clearpoints(h);
                addpoints(h,[i i],[-1 1]);
                drawnow
            end
        end
        
        % get step response etc.
        S = stepinfo(states(:,1:end-1),1:size(states,1));
        avg_ST(pop) = median([S.SettlingTime]);
        avg_RT(pop) = median([S.RiseTime]);
        avg_OS(pop) = median([S.Overshoot]);
        avg_PK(pop) = median([S.Peak]);
    end
    
    %% get metrics
    fprintf('\n Step response complete. Sweeping metrics... \n');
    parfor pop_indx = 1:config.pop_size
        population(pop_indx).behaviours = getMetrics(population(pop_indx),config);
    end
    fprintf('\n metrics complete. \n');
    
    metrics = reshape([population.behaviours],config.pop_size,3);
    
    % plot correlations
    plotSearch(population, 1,config)
    
    figure
    corrplot([metrics avg_ST' avg_RT' avg_OS' avg_PK'],'varNames',{'KR','GR','MC','ST','RT','OS','PK'},'type','Kendall','testR','on');
    %
    % figure
    % corrplot([metrics avg_ST' avg_RT' avg_OS' avg_PK'],'varNames',{'KR','GR','MC','ST','RT','OS','PK'});
    
    %% reorder by peak
    % [peak,indx] =sort([S.Peak]);
    % rorder_peak_S = S(indx);
    %
    % mean_W_1 = mean(W);
    % mean_W_2 = mean(W,2);
    % add_W = mean_W_1 + mean_W_2';
    % add_W(:,indx)
    
    
    
end




