%% Evolve CPPN to construct substrate for a specific task
% This script can be used to evolve any reservoir directly to a task. It
% uses the steady-state Microbial Genetic Algorithm to evolve the best
% solution.

% Author: M. Dale
% Date: 08/11/18
clear
close all

% add all subfolders to the path --> make all functions in subdirectories available
% addpath(genpath(pwd));

warning('off','all')
rng(1,'twister');

%% Setup
config.parallel = 1;                        % use parallel toolbox

%start paralllel pool if empty
if isempty(gcp) && config.parallel
    parpool('local',4,'IdleTimeout', Inf); % create parallel pool
end

%% Evolutionary parameters
config.num_tests = 1;                        % num of runs
config.pop_size = 100;                       % large pop better
config.total_gens = 1000;                    % num of gens
config.mut_rate = 0.1;                       % mutation rate
config.deme_percent = 0.2;                  % speciation percentage
config.deme = round(config.pop_size*config.deme_percent);
config.rec_rate = 0.5;                       % recombination rate

% Network details
config.metrics = {'KR','GR','linearMC'};       % behaviours that will be used; name metrics to use and order of metrics
config.voxel_size = 10;                  % when measuring quality, this will determine the voxel size. Depends on systems being compared. Rule of thumb: around 10 is good

% Novelty search parameters
config.k_neighbours = 10;                   % how many neighbours to check, e.g 10-15 is a good rule-of-thumb
config.p_min_start = 3;%sum(config.num_nodes)/10;                     % novelty threshold. In general start low. Reduce or increase depending on network size.
config.p_min_check = 200;                   % change novelty threshold dynamically after "p_min_check" generations.

% general params
config.gen_print = 10;                       % after 'gen_print' generations display archive and database
config.start_time = datestr(now, 'HH:MM:SS');
config.save_gen = inf;                       % save data at generation = save_gen
config.param_indx = 1;                      % index for recording database quality; start from 1

% prediction parameters
config.get_prediction_data = 0;             % collect task performances after experiment. Variables below are applied if '1'.
config.task_list = {'Laser'}; % tasks to assess
%config.discrete = 0;                        % binary or continious input to system
%config.nbits = 16;                          % set bit conversion if using binary/discrete systems
config.preprocess = 1;                 % save metrics

%% substrate details
config_sub = config;

config_sub.res_type ='Graph';               % currently only works with lattice as CPPN configured substrate
config_sub.num_nodes = [7];                 % num of nodes in subreservoirs, e.g. config.num_nodes = {10,5,15}, would be 3 subreservoirs with n-nodes each

config_sub = selectReservoirType(config_sub);       % get correct functions for type of reservoir

% dummy variables for dataset; not used but still needed for functions to
% work
config_sub.train_input_sequence= [];
config_sub.train_output_sequence =[];
config_sub.dataset = 'blank';

[config_sub] = getAdditionalParameters(config_sub);

%% CPPN details
config.res_type = 'RoR';                      % can use different hierarchical reservoirs. RoR_IA is default ESN.
config.num_nodes = [25];                  % num of nodes in subreservoirs, e.g. config.num_nodes = {10,5,15}, would be 3 subreservoirs with n-nodes each
config = selectReservoirType(config);       % get correct functions for type of reservoir
config.CPPN_inputs = 6;                     % coord of node A(x,y) and node B(x,y)
config.CPPN_outputs = length(config_sub.num_nodes)*2 +1; % Output 1: input layer, 2: hidden layer, 3: outputlayer

config.preprocess = 1;                   % basic preprocessing, e.g. scaling and mean variance
config.dataset = 'CPPN';                 % Task to evolve for

% get any additional params
[config] = getAdditionalParameters(config);
[config] = selectDataset(config);

%% RUn MicroGA
for test = 1:config.num_tests
    
    clearvars -except config config_sub test storeError
    
    fprintf('\n Test: %d  ',test);
    fprintf('Processing genotype......... %s \n',datestr(now, 'HH:MM:SS'))
    tic
    
    % update random seed
    rng(test,'twister');
    
    % Reset database counter
    config.param_indx=1;
    
    % create initial population
    CPPN = config.createFcn(config);
    
    % create initial substrate
    substrate = config_sub.createFcn(config_sub);
    
    %Assess population
    if config.parallel
        ppm = ParforProgMon('Initial population: ', config.pop_size);
        parfor pop_indx = 1:config.pop_size
            warning('off','all')
            % assign weights through CPPN
            [substrate(pop_indx),~,CPPN(pop_indx),~] = assessCPPNonSubstrate(substrate(pop_indx),config_sub,CPPN(pop_indx),config);
            ppm.increment();
            %fprintf('\n i = %d, error = %.4f, took: %.4f\n',popEval,substrate(popEval).valError,toc);
        end
    else
        for pop_indx = 1:config.pop_size
            % assign weights through CPPN
            [substrate(pop_indx),~,CPPN(pop_indx),~] = assessCPPNonSubstrate(substrate(pop_indx),config_sub,CPPN(pop_indx),config);
            fprintf('\n i = %d, behaviours = %.4f %.4f %.4f, took: %.4f\n',pop_indx,[substrate(pop_indx).behaviours],toc);
        end
    end
    
    % establish archive from initial population
    archive = reshape([substrate.behaviours],length(substrate(1).behaviours),config.pop_size)';
    
    % add population to database
    database.substrate = substrate;
    database.CPPN = CPPN;
    
    plotSearch(database.substrate,1,config)
    
   fprintf('Processing took: %.4f sec, Starting GA \n',toc)
    
    % reset variables for novelty threshold
    cnt_no_change = 1;
    config.p_min = config.p_min_start;
    
    %% start GA
    for gen = 2:config.total_gens
        
        % define seed
        rng(gen,'twister');
        
        % Tournment selection - pick two individuals.
        equal = 1;
        while(equal)
            indv1 = randi([1 config.pop_size]);
            indv2 = indv1+randi([1 config.deme]); %Second within in deme range of the first
            if indv2 > config.pop_size
                indv2 = indv2- config.pop_size;
            end
            if indv1 ~= indv2
                equal = 0;
            end
        end
        
        %calculate distances in behaviour space using KNN search
        pop_behaviours = reshape([substrate.behaviours],length(substrate(1).behaviours),config.pop_size)';
        fit_indv1 = findKNN([archive; pop_behaviours],pop_behaviours(indv1,:),config.k_neighbours);
        fit_indv2 = findKNN([archive; pop_behaviours],pop_behaviours(indv2,:),config.k_neighbours);
        
        % Assess fitness of both and assign winner/loser - highest score
        % wins
        if fit_indv1 > fit_indv2
            winner=indv1; loser = indv2;
        else
            winner=indv2; loser = indv1;
        end
               
        %% Infection and mutation phase
        % winner infects loser
        substrate(loser) = config.recFcn(substrate(winner),substrate(loser),config_sub);
        CPPN(loser) = config.recFcn(CPPN(winner),CPPN(loser),config);
        
        % mutate offspring/loser
        substrate(loser) = config.mutFcn(substrate(loser),config_sub);
        CPPN(loser) = config.mutFcn(CPPN(loser),config);
        
        %% Evaluate and update fitness of offspring/loser
        [substrate(loser),~,CPPN(loser),~] = assessCPPNonSubstrate(substrate(loser),config_sub,CPPN(loser),config);
        
        % Store behaviours
        pop_behaviours(loser,:) = substrate(loser).behaviours;
        
        % calculate offsprings neighbours in behaviour space - using
        % population and archive
        fit_offspring = findKNN([archive; pop_behaviours],substrate(loser).behaviours,config.k_neighbours);
        
        % add offspring details to database
        database.substrate(config.pop_size + gen-1) = substrate(loser);
        database.CPPN(config.pop_size + gen-1) = CPPN(loser);
        
        %add offspring to archive under conditions
        if  fit_offspring > config.p_min || rand < 0.001 % random chance of being added to archive
            if length(archive) < 150
                archive(end+1,:) = pop_behaviours(loser,:);
            else
                archive = [archive(2:end,:); pop_behaviours(loser,:)]; % pop & push
            end
            cnt_change(gen) = 1;
            cnt_no_change(gen) = 0;
        else
            cnt_no_change(gen) = 1;
            cnt_change(gen) = 0;
        end
        
        %dynamically adapt p_min -- minimum novelty threshold
        if gen > config.p_min_check+1
            if sum(cnt_no_change(gen-config.p_min_check:gen)) > config.p_min_check-1 % i.e. if not changing enough
                config.p_min = config.p_min - config.p_min*0.05; %minus 5%
                cnt_no_change(gen-config.p_min_check:gen) = zeros; %reset
            end
            if sum(cnt_change(gen-config.p_min_check:gen)) > 10 % i.e. is too frequent
                config.p_min = config.p_min + config.p_min*0.1; %plus 10%
                cnt_change(gen-config.p_min_check:gen) = zeros; %reset
            end
        end
        
        % print info
        if (mod(gen,config.gen_print) == 0)
            fprintf('Gen %d, time taken: %.4f sec(s)\n Winner is %d, Loser is %d \n',gen,toc/config.gen_print,winner,loser);
            fprintf('Length of archive: %d, p_min; %d \n',length(archive), config.p_min);
            tic;
            plotSearch(database.substrate,gen,config)        % plot details
            
            % measure voxel count and quality
            plot_behaviours = reshape([database.substrate.behaviours],length(substrate(1).behaviours),length(database.substrate))';
            [quality(test,config.param_indx),~]= measureSearchSpace(plot_behaviours,config.voxel_size);
            % add database to history of databases
            database_history{test,config.param_indx} = plot_behaviours;
            config.param_indx = config.param_indx+1; % add to saved database counter
            
            plotQuality(quality,config);
        end
        
        % safe details to disk
        if mod(gen,config.save_gen) == 0
            saveData(database_history,database,quality,test,config);
        end
        
    end
    
        % run entire database on set tasks to get performance of behaviours
    if config.get_prediction_data
        all_behaviours = reshape([database.substrate.behaviours],length(substrate(1).behaviours),length(database.substrate))';
        pred_dataset{test} = assessDBonTasks(config,database.substrate,all_behaviours,test);
    end
end
config.finish_time = datestr(now, 'HH:MM:SS');


%% fitness function for novelty search
function [avg_dist] = findKNN(behaviours,Y,k_neighbours)
[~,D] = knnsearch(behaviours,Y,'K',k_neighbours);
avg_dist = mean(D);
end

%% plot the behaviour space
function plotSearch(database, gen,config)

all_behaviours = reshape([database.behaviours],length(database(1).behaviours),length(database))';

% Add specific parameter to observe here
% Example: plot a particular parameter:
% lr = [database.leak_rate]';

set(0,'currentFigure',config.figure_array(1))
title(strcat('Gen:',num2str(gen)))
v = 1:length(config.metrics);
C = nchoosek(v,2);

if size(C,1) > 3
    num_plot_x = ceil(size(C,1)/2);
    num_plot_y = 2;
else
    num_plot_x = 3;
    num_plot_y = 1;
end

for i = 1:size(C,1)
    subplot(num_plot_x,num_plot_y,i)
    scatter(all_behaviours(:,C(i,1)),all_behaviours(:,C(i,2)),20,1:length(all_behaviours),'filled')
    
    % Replace with desired parameter:
    % scatter(all_behaviours(:,C(i,1)),all_behaviours(:,C(i,2)),20,lr,'filled')
    
    xlabel(config.metrics(C(i,1)))
    ylabel(config.metrics(C(i,2)))
    colormap(copper)
end

drawnow
end

%% plot quality
function plotQuality(quality,config)

set(0,'currentFigure',config.figure_array(2))
plot(1:length(quality),quality)
xticks(1:2:length(quality))
xl = xticklabels;
for i = 1:length(xl)
    xticklab(i) = str2num(xl{i});
end
xticklabels(xticklab*config.gen_print)
xlabel('Generation')
ylabel('Quality')

end

function saveData(database_history,database,quality,test,config)
config.figure_array =[];
save(strcat('Framework_substrate_',config.res_type,'_run',num2str(test),'_gens',num2str(config.total_gens),'_',num2str(config.num_reservoirs),'Nres_'),...
    'database_history','database','config','quality','-v7.3');

end