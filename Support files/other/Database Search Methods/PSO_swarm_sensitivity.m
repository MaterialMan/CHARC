clear
load('collected_rand_data.mat')

%store stats
stat_results = struct(...
    'A',zeros(1,7),...
    'p',zeros(1,7),...
    'r',zeros(1,7),...
    'A_ks',zeros(1,7),...
    'p_ks',zeros(1,7),...
    'r_ks',zeros(1,7),...
    'pso_error',zeros(7,1),...
    'rand_error',zeros(7,1),...
    'task_pso_error',zeros(20,7),...
    'task_rand_error',zeros(20,7));

pop_list = 5:5:100;
maxStall_list = 1:1:20;
archive_tests =length(pop_list);
stat_results= repmat(stat_results,[1,archive_tests*2]);

multitask = 0;
figure1 = figure;
dataBase =1:14400;
cnt=1;
tmp = zeros(length(pop_list),length(maxStall_list));

for pop_cnt = 1:length(pop_list)%cnt = 1:archive_tests
for maxStall_cnt = 1:length(maxStall_list)
    
pop = pop_list(pop_cnt);
maxStall = maxStall_list(maxStall_cnt);
%maxStall = round(500/pop)-1; 
%maxIter =round(500/pop)-1;
maxIter =maxStall;
pso_error = []; min_rand=[];
metrics = abs(Metrics_all_comb(dataBase,:));
tError = testError_all_comb(dataBase,:);

for task = 1:1 % test every task
    minValue = min(tError(:,task));
    fprintf('\n---- Pop size: %d, task: %d --------\n\n',pop,task)
    for i = 1:20 % get averages of PSO and random
        [pso_error(i,task), pso_metrics(i,:),output] =  PSO(metrics,tError,[3 4],task,pop,maxStall,maxIter,minValue,multitask);
        evals(i,task) = output.funccount;
        distances = pdist2(metrics(:,[3 4]),pso_metrics(i,:));
        [~,indx] = min(distances);
        if multitask
            task_pso_error(i,:) = tError(indx(1),:);
            %get rand errors
            pos = randperm(length(dataBase),evals(i,task));
            [rand_error(i,task),indx] = min(sum(tError(pos,:),2));
            task_rand_error(i,:) = tError(pos(indx),:);
        else
            task_pso_error(i,task) = tError(indx(1),task);
            %get rand errors
            pos = randperm(length(dataBase),evals(i,task));
            [rand_error(i,task),indx] = min(sum(tError(pos,task),2));
            task_rand_error(i,task) = tError(pos(indx),task);
        end
    end
end

h=[]; p = []; A=[]; r =[];
for task = 1:1
    [A(task),p(task),h(task)] =statCheck(pso_error(:,task),rand_error(:,task),0);
    if median(pso_error(:,task)) < median(rand_error(:,task))
        r(task) = h(task)*2;
    end
    if median(pso_error(:,task)) > median(rand_error(:,task))
        r(task) = h(task)*-2;
    end
end

h_ks=[]; p_ks = []; A_ks=[]; r_ks =[];
for task = 1:1
    [A_ks(task),p_ks(task),h_ks(task)] =statCheck(pso_error(:,task),rand_error(:,task),1);
    if median(pso_error(:,task)) < median(rand_error(:,task))
        r_ks(task) = h_ks(task)*2;
    end
    if median(pso_error(:,task)) > median(rand_error(:,task))
        r_ks(task) = h_ks(task)*-2;
    end
end

%record info based on pop size
stat_results(cnt).A = A;
stat_results(cnt).p = p;
stat_results(cnt).r = r;
stat_results(cnt).A_ks = A_ks;
stat_results(cnt).p_ks = p_ks;
stat_results(cnt).r_ks = r_ks;

stat_results(cnt).pso_error = pso_error;
stat_results(cnt).rand_error = rand_error;
stat_results(cnt).task_pso_error = task_pso_error;
stat_results(cnt).task_rand_error = task_rand_error;
stat_results(cnt).evals = evals;


figure(figure1)
% yyaxis left
% boxplot([stat_results(cnt).pso_error stat_results(cnt).rand_error],'notch','on')
% yyaxis right
% plot(repmat(median(evals),1,2),'--');

tmp(pop_cnt,maxStall_cnt)=median(stat_results(cnt).pso_error);
imagesc(flip(tmp))
colormap('hot')
xticklabels(pop_list)
yticklabels(flip(maxStall_list))
ylabel('Swarm Size')
xlabel('Iterations') 
colorbar
cnt=cnt+1;

end
end

%% rand plot
figure
A = reshape(median([stat_results.rand_error]),length(pop_list),length(maxStall_list));
A(A>=max(median([stat_results.pso_error]))) =max(median([stat_results.pso_error])); 
imagesc(flip(A))
contourf(A)
colormap('hot')
xticks(2:2:length(maxStall_list))
xticklabels(2:2:20) %xticklabels(10:10:100)
yticks(1:2:length(pop_list))
yticklabels((10:10:100))
ylabel('Swarm Size')
xlabel('Iterations') 
colorbar
set(gca,'FontSize',18)

%% pso plot
figure
B = reshape(median([stat_results.pso_error]),length(pop_list),length(maxStall_list));
imagesc(flip(B))
contourf(B)
colormap('hot')
xticks(2:2:length(maxStall_list))
xticklabels(2:2:20) %xticklabels(10:10:100)
yticks(1:2:length(pop_list))
yticklabels((10:10:100))
ylabel('Swarm Size')
xlabel('Iterations') 
colorbar
set(gca,'FontSize',18)

%% evals
figure
cnt_1 = 1; cnt_2 = 1; evals = [];
for i = pop_list
    for j = maxStall_list
        evals(cnt_1,cnt_2)= i*j;
        cnt_1 = cnt_1 +1;
    end
    cnt_1 = 1;
    cnt_2 = cnt_2+1;
end
imagesc(flip(evals))
colormap('hot')
xticks(2:2:length(maxStall_list))
xticklabels(2:2:20)
yticks(1:2:length(pop_list))
yticklabels(flip(10:10:100))
ylabel('Swarm Size')
xlabel('Iterations') 
colorbar
set(gca,'FontSize',18)

figure
B = reshape(median([stat_results.evals]),20,20);
imagesc(flip(B))
%contourf(B)
colormap('hot')
xticks(2:2:length(maxStall_list))
xticklabels(2:2:20) %xticklabels(10:10:100)
yticks(1:2:length(pop_list))
yticklabels((10:10:100))
ylabel('Swarm Size')
xlabel('Iterations') 
colorbar
set(gca,'FontSize',18)

% multiBoxplot([stat_results.pso_error stat_results.rand_error],{num2str(pop_list')},2,{'PSO','Random'},1,0,0)
% xlabel('Swarm Size')
% ylabel('Task Error (NMSE)')
% yyaxis right
% plot(median([stat_results.evals]),'--');

% figure
% subplot(2,1,1)
% plot(pop_list,median([stat_results.pso_error]))
% xlabel('Swarm Size')
% ylabel('Task Error (NMSE)')
% subplot(2,1,2)
% 
% plot(median([stat_results.evals]),median([stat_results.pso_error]))
% xlabel('Evals')
% ylabel('Task Error (NMSE)')
% 
% figure
% yyaxis left
% boxplot([stat_results.pso_error],'notch','on','color','b')
% xticklabels(pop_list)
% yyaxis right
% boxplot([stat_results.evals],'notch','on','color','r')
% xticklabels(pop_list)