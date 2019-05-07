clear
%load('Z:\My Upcoming Publications ''Work-iniprogress''\New Journal Paper\git\Random\collected_rand_data.mat')

load('NS_allResults.mat')

rng(1,'twister')
archive_tests =1;
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
    'task_pso_error',zeros(10,7),...
    'task_rand_error',zeros(10,7));

stat_results= repmat(stat_results,[1,archive_tests]);
task_list{1} = 1:2;
task_list{2} = 1:4;%2:5;%[3 7];
task_list{3} = 1:6;%[1 3:7];%[4 5 6];

for p = 1:length(task_list)
    multitask = 1; tasks = task_list{p}; %1 3 6 7
    %figure1 = figure;
    pso_metrics=[]; rand_error=[];
    task_pso_error =[];task_rand_error=[];
    
    pop =50;
    maxStall = 10; maxIter =10;
    pso_error = []; min_rand=[];
    metrics = database;
    tError = miniErrorDatabase(:,tasks);
    
    
    [minValue,minloc] = min(sum(tError,2));
    fprintf('\n---- Pop size: %d --------\n\n',pop)
    
    for i = 1:10 % get averages of PSO and random
        [pso_error(i,:), pso_metrics(i,:),output] =  PSO(i,metrics,tError,[1 2],[],pop,maxStall,maxIter-1,minValue-1,min(sum(tError(:,tasks),2)),multitask);
        evals(i,:) = output.funccount;
%         distances = pdist2(metrics(:,[1 2]),pso_metrics(i,:));
%         [~,indx] = min(distances);
%         
%         task_pso_error(i,:) = tError(indx(1),:);
%         %get rand errors
%         pos = randperm(length(tError),evals(i,:));
%         [rand_error(i,:),indx] = min(sum(tError(pos,:),2));
%         task_rand_error(i,:) = tError(pos(indx),:);
        
    end
    
    evals_mRes(:,p) = evals;
    pso_mRes(:,p) = sum(task_pso_error,2);
    pso_mRes_metrics{p} = pso_metrics;
    rand_mRes(:,p) = sum(task_rand_error,2);
    lowest_mRes(:,p) = min(sum(tError,2));
end

h = multiBoxplot([pso_mRes rand_mRes],{'2-Tasks','4-Tasks','6-Tasks'},2,{'PSO','Random'},1,0,0);
hold on
h(2) = scatter(1.25:1:3.25,lowest_mRes,'filled','DisplayName','Lowest Combined Error');
hold off
ylabel('NMSE')
set(gca,'FontSize',16)


figure
scatter(metrics(:,3),metrics(:,4),10,'k','+')
hold on
scatter(pso_mRes_metrics{1}(:,1),pso_mRes_metrics{1}(:,2),35,'r','filled')
scatter(pso_mRes_metrics{2}(:,1),pso_mRes_metrics{2}(:,2),35,'b','filled')
scatter(pso_mRes_metrics{3}(:,1),pso_mRes_metrics{3}(:,2),35,'g','filled')
legend('Archive','2-Tasks', '4-Tasks','6-Tasks')
xlabel('KR-GR')
ylabel('MC')
set(gca,'FontSize',16)
hold off

% multiBoxplot([sum(task_pso_error,2) sum(task_rand_error,2)],{'Combined Tasks'},2,{'PSO','Random'},1,0,0)
% hold on
% scatter(1.25,min(sum(tError,2)),'filled','DisplayName','Lowest Combined Error')
% hold off
% 
% multiBoxplot([task_pso_error task_rand_error],{'N-10','Laser','IPIX','Vowels'},2,{'PSO','Random'},1,0,0)
% hold on
% scatter(1.25:1:length(tasks)+0.25,min(tError),'filled','DisplayName','Lowest Individual Task Errors')
% scatter(1.25:1:length(tasks)+0.25,tError(minloc,:),'filled','DisplayName','Best Multi-Task Res. in Archive ')
% hold off
% ylabel('NMSE')
% set(gca,'FontSize',14)


