%% MAP-elites
% Notes: Implementation of MAP-elites using reservoir metrics to create behaviour space 

% Author: M. Dale
% Date: 30/04/19
clearvars -except config
close all

%% Setup
config.parallel = 1;                        % use parallel toolbox

%start paralllel pool if empty
if isempty(gcp) && config.parallel
    parpool('local',4,'IdleTimeout', Inf); % create parallel pool
end

%% type of network to evolve
config.res_type = 'RoR';                 % can use different hierarchical reservoirs. RoR_IA is default ESN.
config.num_nodes = [100];                      % num of nodes in subreservoirs, e.g. config.num_nodes = {10,5,15}, would be 3 subreservoirs with n-nodes each
config = selectReservoirType(config);       % get correct functions for type of reservoir

%% Network details
config.metrics = {'KR','linearMC'}; % metrics to use (and order of metrics)

%% Evolutionary parameters
config.num_tests = 1;                        % num of runs
config.initial_population = 50;             % large pop better
config.total_iter = 150;                    % num of gens
config.mut_rate = 0.05;                       % mutation rate
config.rec_rate = 0.5;                       % recombination rate

%% Task parameters
config.discrete = 0;                                                        % binary input for discrete systems
config.nbits = 16;                                                          % if using binary/discrete systems
config.preprocess = 1;                                                      % basic preprocessing, e.g. scaling and mean variance
config.dataset = 'narma_10';                                                  % Task to evolve for

% get any additional params. This might include:
% details on reservoir structure, extra task variables, etc. 
config = getAdditionalParameters(config);

% get dataset information
config = selectDataset(config);

config.error_to_check = 'train&val&test';

%% MAP of elites parameters
config.batch_size = 10;                                                     % how many offspring to create in one iteration
config.local_breeding = 1;                                                  % if interbreeding is local or global
config.k_neighbours = 10;                                                    % select second parent from neighbouring behaviours
config.total_MAP_size = round((config.num_nodes)*config.num_reservoirs + (config.add_input_states*config.task_num_inputs) + 1);  %size depends system used
config.MAP_resolution = flip(recursiveDivision(config.total_MAP_size));     % list to define MAP of elites resolution, i.e., how many cells
config.change_MAP_iter = round(config.total_iter/(length(config.MAP_resolution)-1)); % change the resolution after I iterations
config.start_MAP_resolution = config.MAP_resolution(1);                        % record of first resolution point
config.voxel_size = 10;                                                     % to measure behaviour space

config.figure_array = [figure figure figure];

config.gen_print = 1;
config.save_gen = 20;

%% Run MicroGA
for tests = 1:config.num_tests
    
    clearvars -except config tests store_global_best quality
    
    fprintf('\n Test: %d  ',tests);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    tic
    
    rng((tests-1)*config.total_iter*config.batch_size,'twister');
    
    %reset global best
    global_best = inf;
    
    % create first MAP of elites
    config.res_iter = 1;
    [config, MAP] = changeMAPresolution(config,[]);
    
    %% first batch
    config.pop_size = config.initial_population;
    population = config.createFcn(config);    
    
    % Evaluate offspring  
    if config.parallel % use parallel toolbox - faster
        parfor pop_indx = 1:config.pop_size
            population(pop_indx).behaviours = round(getMetrics(population(pop_indx),config))+1;
            population(pop_indx) = config.testFcn(population(pop_indx),config);
            fprintf('\n pop: %d, error: %.4f',pop_indx, getError(config.error_to_check,population(pop_indx)));
        end
    else
        for pop_indx = 1:config.pop_size
            population(pop_indx).behaviours = round(getMetrics(population(pop_indx),config))+1;
            population(pop_indx) = config.testFcn(population(pop_indx),config);
        end
    end
    
    % find behaviour match
    for i = 1:config.pop_size
        %record best error found
        if getError(config.error_to_check,population(i)) < global_best
            global_best = getError(config.error_to_check,population(i));%population(i).val_error;
            best_indv = i;
        end
            
        discretised_behaviour = floor(population(i).behaviours/config.MAP_resolution(config.res_iter))*config.MAP_resolution(config.res_iter);
        [~, idx] = ismember(discretised_behaviour, config.combs, 'rows');
        % assign elites
        if isempty(MAP{idx})
            MAP{idx} = population(i);
        elseif getError(config.error_to_check,population(i)) < getError(config.error_to_check,MAP{idx})%MAP{idx}.val_error
            MAP{idx} = population(i);
        end
    end
    
    fprintf('\n iteration: %d, best error: %.4f  ',0,global_best);
    
    %% start generational loop
    for iter = 1:config.total_iter-1
        
        % increase MAP resolution
        if mod(iter,config.change_MAP_iter) == 0
            config.res_iter = config.res_iter+1;
            [config, MAP]= changeMAPresolution(config,MAP);
        end
        
        %% evaluate offspirng in batches
        for b = 1:config.batch_size
            warning('off','all')
            rng((tests-1)+(iter-1)*config.batch_size+b,'twister');
            
            % find all behaviours and pick one randomly
            occupied_cells = ~cellfun('isempty',MAP);
            idxs = find(occupied_cells);
            p_1 = idxs(randi([1 length(idxs)]));
            
            if config.local_breeding
                % find a second behaviour within some proximity to the first
                list = [MAP{idxs}];
                all_metrics = reshape([list.behaviours],length(config.metrics),length([list.behaviours])/length(config.metrics));
                
                % pick random neighbour in close proximity
                [knn_indx] = knnsearch(all_metrics',MAP{p_1}.behaviours,'K',config.k_neighbours);
                p_2 = idxs(knn_indx(randi([1 length(knn_indx)])));
            else
                p_2 = idxs(randi([1 length(idxs)])); % anywhere in the behaviour space
            end
            
            % decide winner and loser
            if getError(config.error_to_check,MAP{p_1}) < getError(config.error_to_check,MAP{p_2})% before MAP{p_1}.val_error < MAP{p_2}.val_error
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
        end
        
        parfor b = 1:config.batch_size
            % Evaluate offspring
            offspring(b).pop_indx = b;
            
            offspring(b).behaviours = round(getMetrics(offspring(b),config))+1;
            
            offspring(b) = config.testFcn(offspring(b),config);
        end
       % end
        
        %% place batch offspring in MAP of elites
        for i = 1:config.batch_size
            %record offspring errors
            if getError(config.error_to_check,offspring(i)) < global_best% before offspring(i).val_error < global_best
                global_best = getError(config.error_to_check,offspring(i)); %offspring(i).val_error;  
                global_best_indv = offspring(i);
            end
            
            % find behaviour match
            discretised_behaviour = floor(offspring(i).behaviours/config.MAP_resolution(config.res_iter))*config.MAP_resolution(config.res_iter);
            [~, idx] = ismember(discretised_behaviour, config.combs, 'rows');
            
            % assign elites
            if isempty(MAP{idx})
                MAP{idx} = offspring(i);
            elseif getError(config.error_to_check,offspring(i)) < getError(config.error_to_check,MAP{idx})% before offspring(i).val_error < MAP{idx}.val_error
                MAP{idx} = offspring(i);
            end            
        end
        
        %% store and plot best error found
        for i = 1:length(MAP)
            if ~isempty(MAP{i})
                if getError(config.error_to_check,MAP{i}) == global_best%MAP{i}.val_error == global_best
                    prev_best = best_indv;
                    best_indv = i;
                end
                
            end
        end
        
        store_global_best(tests,iter)  = global_best;
        %set(0,'currentFigure',config.figure_array(1))
        %plot(store_global_best(tests,:));
        %xlabel('Iterations (\times batch size)')
        %ylabel('Test Error')
        %drawnow;
        
        % plot MAP of elites
        %plotSearch(MAP,iter*config.batch_size,config)
        
        if (mod(iter,config.gen_print) == 0)
            %plotReservoirDetails(MAP,store_global_best,tests,best_indv,1,prev_best,config)       
            %plotReservoirDetails(MAP,best_indv,1,prev_best,config)
        end

 	if (mod(iter,config.save_gen) == 0)
		saveData(MAP,tests,config)        
	end

        fprintf('\n iteration: %d, best error: %.4f  ',iter,global_best);
    end
    
    %% measure quality of explored space
    behaviours = [];
    for i = 1: length(MAP)
        if ~isempty(MAP{i})
            behaviours = [behaviours; MAP{i}.behaviours];
        end
    end
    
    [quality(tests)] = measureSearchSpace(behaviours,config.voxel_size);
    
end

function [config,newMAP] = changeMAPresolution(config,MAP)
% currently 2-D space/MAP
[ca, cb] = ndgrid(0:config.MAP_resolution(config.res_iter):config.total_MAP_size,...
    0:config.MAP_resolution(config.res_iter):config.total_MAP_size);%,...
%0:config.MAP_resolution(config.res_iter):config.total_MAP_size); %no. of inputs/outputs to ngrid is no. of behaviours

config.combs = [ca(:), cb(:)]; % manually add all combinations together

newMAP = cell(length(config.combs),1);

if ~isempty(MAP)
    
    for i = 1:length(MAP)
        % find behaviour match
        if ~isempty(MAP{i})
            discretised_behaviour = floor(MAP{i}.behaviours/config.MAP_resolution(config.res_iter))*config.MAP_resolution(config.res_iter);
            [~, idx] = ismember(discretised_behaviour, config.combs, 'rows');
            
            % assign elites
            if isempty(newMAP{idx})
                newMAP{idx} = MAP{i};
            elseif MAP{i}.val_error < newMAP{idx}.val_error
                newMAP{idx} = MAP{i};
            end
        end
    end
end

end

function plotSearch(database, gen,config)

set(0,'currentFigure',config.figure_array(2))

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
    if ~isempty(database{i}) && database{i}.val_error < 1
        X = [X; database{i}.behaviours];
        fitness = [fitness; database{i}.val_error];
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

function saveData(MAP,tests,config)
config.figure_array =[];
save(strcat('MapElite_',config.dataset,'_substrate_',config.res_type,'_run',num2str(tests),'_gens',num2str(config.total_iter),'_',num2str(sum(config.num_reservoirs)),'Nres.mat'),...
    'MAP','config','-v7.3');
end
