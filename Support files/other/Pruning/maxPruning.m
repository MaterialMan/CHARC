%% Runs a basic pruning algorithm to delete unnecessary weights
% option for parallel deletion
function [individual,old_W_fitness,old_Win_fitness,final_W] = maxPruning(pruneFnc,output_to_check,individual,base_behaviour,bounds,config)

% get seed
scurr = rng;
temp_seed = scurr.Seed;
reverseStr = '';
current_behaviour = base_behaviour;
new_behaviour =[];

% get all positions of weights
for res_i = 1:size(individual.W,1)
    for res_j = 1:size(individual.W,1)
        initial_W_nnz{res_i,res_j} = find(individual.W{res_i,res_j});
        old_W_fitness(res_i,res_j) = nnz(individual.W{res_i,res_j});
        num_to_change_W(res_i,res_j) = 5;
    end
    initial_Win_nnz{res_i} = find(individual.input_weights{res_i});
    old_Win_fitness(res_i) = nnz(individual.input_weights{res_i});
    num_to_change_Win(res_i) = 5;
end
search_list = [];

%initialise lists
W_nnz= initial_W_nnz;
Win_nnz= initial_Win_nnz;

saved_individual = individual;
new_fitness_Win = old_Win_fitness;
new_fitness_W = old_W_fitness;

%cycle through remaining weights
for iter = 1:config.prune_iterations*2
    
    % copy
    new_individual = individual;
    
    % maipulate W
    temp_seed = temp_seed+1;
    rng(temp_seed,'twister')
    %rng(iter,'twister')
    
    if isempty(W_nnz) || isempty(Win_nnz)
        return;
    end
    
    %% delete weights
    for res_i = 1:size(new_individual.W,1) %cycle through all reservoir matrices
        cfp(res_i) = rand < 0.8; % more likely to trim internal weights
        if cfp(res_i)
            for res_j = 1:size(new_individual.W,2) %cycle through all reservoir matrices
                if rand < 0.5 & ~isempty(W_nnz{res_i,res_j})
                    % get random internal weight
                    W_indx{res_i,res_j} = randi([1 length(W_nnz{res_i,res_j})],num_to_change_W(res_i,res_j),1);
                    new_individual.W{res_i,res_j}(W_nnz{res_i,res_j}(W_indx{res_i,res_j})) = 0;
                    new_fitness_W(res_i,res_j) = nnz(new_individual.W{res_i,res_j});
                    % update connectivty ratios
                    new_individual.connectivity(res_i,res_j) = new_fitness_W(res_i,res_j)./(size(new_individual.W{res_i,res_j},1).^2);
                else
                    W_indx{res_i,res_j} = [];
                end
            end
        else
            % get random input weight
            if ~isempty(Win_nnz{res_i})
                Win_indx{res_i} = randi([1 length(Win_nnz{res_i})],num_to_change_Win(res_i),1);
                new_individual.input_weights{res_i}(Win_nnz{res_i}(Win_indx{res_i})) = 0;
                new_fitness_Win(res_i) = nnz(new_individual.input_weights{res_i});
            else
                Win_indx{res_i} = [];
            end
        end
    end
    %search_list = [search_list W_nnz(W_indx)'];
    
    %% assess new network
    if ~strcmp(output_to_check,'behaviours')
        %get fitness/error
        new_individual = pruneFnc(new_individual,config); % e.g. testReservoir
        for f = 1:length(output_to_check)
            new_behaviour(f) = getfield(new_individual,output_to_check{f});           
        end
        
        if  new_behaviour <= base_behaviour
            chng_fitness = 1;%(sum((new_behaviour-base_behaviour) <= bounds)/length(base_behaviour) == 1);
            base_behaviour = new_behaviour;
        else
            chng_fitness = 0;
        end
 
    else
        %get behaviour
        new_behaviour = pruneFnc(new_individual,config); % e.g. getMetrics
        
        chng_fitness = sum(abs(new_behaviour-base_behaviour) <= bounds)/length(base_behaviour) == 1 ;
    end
    
    %% assess fitness
    if chng_fitness
        %delete weights from seletion list
        for res_i = 1:size(new_individual.W,1)
            if cfp(res_i)
                for res_j = 1:size(new_individual.W,2)
                    if ~isempty(W_indx{res_i,res_j})
                        W_nnz{res_i,res_j}(W_indx{res_i,res_j}) = [];
                        old_W_fitness(res_i,res_j) = new_fitness_W(res_i,res_j);
                        num_to_change_W(res_i,res_j) = num_to_change_W(res_i,res_j)+2;
                    end
                end
            else
                Win_nnz{res_i}(Win_indx{res_i}) = [];
                old_Win_fitness(res_i) = new_fitness_Win(res_i);
                num_to_change_Win(res_i) = num_to_change_Win(res_i)+2;
            end
        end
        
        individual = new_individual;
               
        if ~strcmp(output_to_check,'behaviours')
            for f = 1:length(output_to_check)
                individual = setfield(individual,output_to_check{f},new_behaviour(f));
            end    
        end 
        
        msg = sprintf('Iter: %d, New fitness: %.3f (W) %.3f (Win), old behaviour: %.3f %.3f %.3f, \n new behaviour: %.3f %.3f %.3f, (diff): %.3f %.3f %.3f, \n change: %.3f (W) %.3f (Win)\n',iter,mean(mean(old_W_fitness)),mean(old_Win_fitness),...
            base_behaviour,new_behaviour,(new_behaviour-base_behaviour),mean(mean(num_to_change_W)),mean(num_to_change_Win));
        %fprintf([msg]);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        
        current_behaviour = new_behaviour;
        
    else
        for res_i = 1:size(new_individual.W,1)
            if cfp(res_i)
                for res_j = 1:size(new_individual.W,2)
                    if num_to_change_W(res_i,res_j) > 1
                        num_to_change_W(res_i,res_j) = num_to_change_W(res_i,res_j)-1;
                    end
                end
            else
                if num_to_change_Win(res_i) > 1
                    num_to_change_Win(res_i) = num_to_change_Win(res_i)-1;
                end
            end
        end
    end
       
end

%% plot final matrix
final_W = []; initial_W =[];
for res_i = 1:size(individual.W,1)
    col_i =[]; col_f =[];
    for res_j = 1:size(individual.W,1)
        col_i = [col_i; saved_individual.W{res_i,res_j}];
        col_f = [col_f; individual.W{res_i,res_j}];
    end
    initial_W = [initial_W col_i];
    final_W = [final_W col_f];
end

figure
subplot(1,2,1)
imagesc(initial_W)
colormap(gca,bluewhitered)
title(strcat('Old: ',num2str(base_behaviour)))

subplot(1,2,2)
imagesc(final_W)
colormap(gca,bluewhitered)
title(strcat('New: ',num2str(current_behaviour)))
%figure
%histogram(search_list,length(search_list))

schemaball(full(final_W),[],[0,0,1;1 1 1],[],figure);



