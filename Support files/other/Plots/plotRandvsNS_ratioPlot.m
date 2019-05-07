function plotRandvsNS_ratioPlot(resize)

g = 200:200:2000;

for p = 1:length(resize)
    if resize(p) == 25
        %% plot 25
        database1 = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\25 nodes\noveltySearch3D_size25_run10_gens2000.mat', 'all_databases');
        database1_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\25 nodes\noveltySearch3D_size25_run10_gens2000.mat', 'total_space_covered');
        database2= load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_25.mat', 'all_databases');
        database2_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_25.mat', 'total_space_covered');
        database1_name = '25 node(NS)';
        database2_name = '25 node(Rand)';
        
        databases{p,1} = database1_ts.total_space_covered/resize(p).^3;
        databases{p,2} =database2_ts.total_space_covered/resize(p).^3;
        
        databases2{p,1} = database1_ts.total_space_covered;%resize(end).^3;
        databases2{p,2} =database2_ts.total_space_covered;%resize(end).^3;
        
        %plotDatabases(figure,database1_ts.total_space_covered/resize(p).^3,database2_ts.total_space_covered/resize(p).^3,database1_name,database2_name)
        %print('25node_coverage_ratio','-dpdf','-bestfit')
        
        
    end
    %% plot 50
    if resize(p) == 50
        database1 = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\50 nodes\noveltySearch3D_size50_run10_gens2000.mat', 'all_databases');
        database1_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\50 nodes\noveltySearch3D_size50_run10_gens2000.mat', 'total_space_covered');
        database2= load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_50.mat', 'all_databases');
        database2_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_50.mat', 'total_space_covered');
        database1_name = '50 node(NS)';
        database2_name = '50 node(Rand)';
        
        databases{p,1} = database1_ts.total_space_covered/resize(p).^3;
        databases{p,2} =database2_ts.total_space_covered/resize(p).^3;
        
        databases2{p,1} = database1_ts.total_space_covered;%resize(end).^3;
        databases2{p,2} =database2_ts.total_space_covered;%resize(end).^3;
        
        %plotDatabases(figure,database1_ts.total_space_covered/resize(p).^3,database2_ts.total_space_covered/resize(p).^3,database1_name,database2_name)
        %print('50node_coverage_ratio','-dpdf','-bestfit')
        
    end
    %% plot 100
    if resize(p) == 100
        database1 = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\100 nodes\noveltySearch3D_size100_run10_gens2000.mat', 'all_databases');
        database1_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\100 nodes\noveltySearch3D_size100_run10_gens2000.mat', 'total_space_covered');
        database2= load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_100.mat', 'all_databases');
        database2_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_100.mat', 'total_space_covered');
        database1_name = '100 node(NS)';
        database2_name = '100 node(Rand)';
        
        databases{p,1} = database1_ts.total_space_covered/resize(p).^3;
        databases{p,2} =database2_ts.total_space_covered/resize(p).^3;
        
        databases2{p,1} = database1_ts.total_space_covered;%resize(end).^3;
        databases2{p,2} =database2_ts.total_space_covered;%resize(end).^3;
        
        %plotDatabases(figure,database1_ts.total_space_covered/resize(p).^3,database2_ts.total_space_covered/resize(p).^3,database1_name,database2_name)
        %print('100node_coverage_ratio','-dpdf','-bestfit')
        
    end
    
    %% plot 200
    if resize(p) == 200
        database1 = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\200 nodes\noveltySearch3D_size200_run10_gens2000.mat', 'all_databases');
        database1_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\200 nodes\noveltySearch3D_size200_run10_gens2000.mat', 'total_space_covered');
        database2= load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_200.mat', 'all_databases');
        database2_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_200.mat', 'total_space_covered');
        database1_name = '200 node(NS)';
        database2_name = '200 node(Rand)';
        
        databases{p,1} = database1_ts.total_space_covered/resize(p).^3;
        databases{p,2} =database2_ts.total_space_covered/resize(p).^3;
        
        
        databases2{p,1} = database1_ts.total_space_covered;%resize(end).^3;
        databases2{p,2} =database2_ts.total_space_covered;%resize(end).^3;
        
        %plotDatabases(figure,database1_ts.total_space_covered/resize(p).^3,database2_ts.total_space_covered/resize(p).^3,database1_name,database2_name)
        %print('200node_coverage_ratio','-dpdf','-bestfit')
        
    end
end

plotJoinedDatabases(figure,databases,resize)
print('ratioOfIndividualSpace','-dpdf','-bestfit')

plotJoinedDatabases2(figure,databases2,resize)
print('ratioOfSameSpace','-dpdf','-bestfit')

function plotJoinedDatabases(figureHandle1,databases,resize)

set(0,'currentFigure',figureHandle1)
x = 0:10;

hold on
for d = 1:length(databases)
    
    database1 = databases{d,1};
    database2 = databases{d,2};
    
    % take into account first 200 in population for random search
    %if randPlot
    for i = 1:10
        database1(i,2:end) = database1(i,1:end-1);
        database1(i,1) = database2(i,1);
    end
    %end
    
    y = mean(database1);
    L = y - min(database1);
    U = max(database1) - y;
    errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)],'lineStyle','-','color',[1 0 0])
    text(mean(x),mean(y)+mean(y)*0.25,strcat(num2str(resize(d)),' node(NS)'))
    
    
    y = mean(database2);
    L = y - min(database2);
    U = max(database2) - y;
    errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)],'lineStyle','--','color',[0 0 0])
    text(mean(x),mean(y)-mean(y)*0.25,strcat(num2str(resize(d)),' node(Rand)'))
end
hold off

lb = 0:200:2000;
xticklabels(lb)
xlabel('Generations')
ylabel('log(r)')
%lg = legend(database1_name,database2_name,'Location','northwest');
set(gca, 'YScale', 'log')
set(gca,'FontSize',12,'FontName','Arial')
%set(lg,'FontSize',12)

set(gcf,'renderer','OpenGL')
drawnow

function plotJoinedDatabases2(figureHandle1,databases,resize)

set(0,'currentFigure',figureHandle1)
x = 0:10;
labels = {'-','-','-','-'};%{'-','--',':','-.'};
for d = 1:length(databases)
    
    database1 = databases{d,1};
    database2 = databases{d,2};
    
    % take into account first 200 in population for random search
    for i = 1:10
        database1(i,2:end) = database1(i,1:end-1);
        database1(i,1) = database2(i,1);
    end
    
    database1 = database1./[200:200:2000];
    database2 = database2./[200:200:2000];
    
    y = mean(database1);
    L = y - min(database1);
    U = max(database1) - y;
    errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)],'lineStyle','-','color',[1 0 0])
    text(x(end)+0.15,y(end),strcat(num2str(resize(d)),' node(NS)'))
    
     hold on
    
    y = mean(database2);
    L = y - min(database2);
    U = max(database2) - y;
    errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)],'lineStyle','--','color',[0 0 0])
    text(x(end)+0.15,y(end),strcat(num2str(resize(d)),' node(Rand)'))
    
   
end
hold off

lb = 0:200:2000;
xticklabels(lb)
xlim([1 10])
%ylim([0 0.00025])
grid on
xlabel('Generations')
ylabel('r')
%lg = legend(database1_name,database2_name,'Location','northwest');
%set(gca, 'YScale', 'log')
set(gca,'FontSize',12,'FontName','Arial')
%set(lg,'FontSize',12)

set(gcf,'renderer','OpenGL')
drawnow