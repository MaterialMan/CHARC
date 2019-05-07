%% Over archive size

clear
%random archive 100,000 size
load('Z:\My Upcoming Publications ''Work-iniprogress''\New Journal Paper\git\Random\collected_rand_data.mat')

archive_tests =10;
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

stat_results= repmat(stat_results,[1,archive_tests]);

multitask = 1;
start = 30;
archive_length = start;
figure1 = figure;

for cnt = 1:archive_tests

dataBase = 1:start^2;
archive_length = [archive_length start^2];

pop =50;
maxStall = 5; maxIter =5;
pso_error = []; min_rand=[];
metrics = abs(Metrics_all_comb(dataBase,:));
tError = testError_all_comb(dataBase,:);

task_tests = [1 3 4 7];

for task = task_tests % test every task

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
for task = task_tests
    [A(task),p(task),h(task)] =statCheck(pso_error(:,task),rand_error(:,task),0);
    if median(pso_error(:,task)) < median(rand_error(:,task))
        r(task) = h(task)*2;
    end
    if median(pso_error(:,task)) > median(rand_error(:,task))
        r(task) = h(task)*-2;
    end
end

h_ks=[]; p_ks = []; A_ks=[]; r_ks =[];
for task = task_tests
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

start = start+30;
figure(figure1)
boxplot([pso_error(:,task) rand_error(:,task)],'notch','on')

end

for i = 1:length(stat_results)
  tmplot_pso(:,i) =  stat_results(i).pso_error(:,task);
  tmplot_rand(:,i) = stat_results(i).rand_error(:,task);
end
tmplot = [tmplot_pso tmplot_rand];
multiBoxplot(tmplot,{num2str(archive_length')},2,{'PSO','Random'},1,0,0)
xlabel('Database Size')
ylabel('Task Error (NMSE)')
set(gca,'FontSize',12)