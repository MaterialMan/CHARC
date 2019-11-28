%% Pruning test on database
%[val,indx]= sort(reshape([database.behaviours],3,length(database))','descend');
%clearvars -except database config

load('substrate_8_run1_networkSize_RoR_undirected0.mat')
rng(1,'twister')
num_iter = 4;
ppm = ParforProgMon('Database complete: ', num_iter);
parfor indx = 1:num_iter
    warning('off','all')
    individual = database(indx);
    for p = 1:5
        [individual,individual.behaviours,~,error] = pruning(@getMetrics,individual,database(indx).behaviours,[0 0 0.5],1000,0,config);
        fprintf('Node: %d, iter: %d, error: %d \n',indx,p,error)
    end
    
    pruned_database(indx) = individual;
    ppm.increment();
end

%multi_prune = nnz(individual.W{1,1});

% rng(1,'twister')
% individual = database(indx);
% [individual,old_fitness] = pruning(individual,database(indx).behaviours,[0 0 0.5],10000,0,config);
% 
% single_prune = nnz(individual.W{1,1})


% for p = 1:length(database)
%     [individual(p),old_fitness(p)] = pruning(database(p),[0 0 0.5],2500,0,config);
% end
% 
figure1 = figure;
%figure2 = figure;

%for i = 1:1
% M = individual(i).W{1,1};
% if ~isempty(M)
%     [MATreordered{i},MATindices,MATcost] = reorder_matrix(M~=0,'line',0);
% else
%     MATreordered{i} = M;
% end

for plot_indx = 1:length(pruned_database)

M = pruned_database(plot_indx).W{1,1};
[MATreordered_b] = reorder_matrix(M~=0,'line',0);
subplot(1,2,1)
imagesc(M)
colormap(gca,bluewhitered)
title(num2str(pruned_database(plot_indx).behaviours))

[MATreordered_W] = reorder_matrix(abs(M),'line',0);
subplot(1,2,2)
imagesc(MATreordered_W)
colormap(gca,bluewhitered)
title(num2str(nnz(M)))
drawnow
pause(0.1)

end
%title(num2str(individual(i).behaviours))
%end