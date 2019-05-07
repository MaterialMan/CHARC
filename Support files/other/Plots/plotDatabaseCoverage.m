function plotDatabaseCoverage(figureHandle1,reservoir,resName,plot_rand)


set(0,'currentFigure',figureHandle1)

% old measure
subplot(1,2,1)
hold on
% plot error bars for evolved runs
x = 0:10;
for i = 1:size(reservoir.D.all_databases,1)
    for j = 1:size(reservoir.D.all_databases,2)
        voxel = measureSearchSpace(reservoir.D.all_databases{i,j});
        old_ts_evo(i,j) = voxel;
    end
end

y = mean(old_ts_evo);
L = y - min(old_ts_evo);
U = max(old_ts_evo) - y;
errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)],'lineStyle','-','color',[0 0 0])
text(x(end)+0.15,y(end),strcat(resName,'evo (old)'))

% plot for random runs
if plot_rand
    for i = 1:size(reservoir.D_rand.all_databases,1)
        for j = 1:size(reservoir.D_rand.all_databases,2)
            voxel = measureSearchSpace(reservoir.D_rand.all_databases{i,j});
            old_ts_rand(i,j) = voxel;
        end
    end
    y = mean(old_ts_rand);
    L = y - min(old_ts_rand);
    U = max(old_ts_rand) - y;
    errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)],'lineStyle','-','color',[1 0 0])
    text(x(end)+0.15,y(end),strcat(resName,'rand (old)'))
end
hold off

xticks(1:2:10)
lb = 200:400:2000;
xticklabels(lb)
xlim([1 10])
%ylim([0 0.00025])
grid on
xlabel('Generations')
ylabel('Coverage')
%set(gca, 'YScale', 'log')
set(gca,'FontSize',12,'FontName','Arial')

% new measure
subplot(1,2,2)
hold on
% on evolved
for i = 1:size(reservoir.D.all_databases,1)
    for j = 1:size(reservoir.D.all_databases,2)
        voxel = measureSearchSpace(reservoir.D.all_databases{i,j});
        new_ts_evo(i,j) = voxel*sum(mad(reservoir.D.all_databases{i,j}));
    end
end

y = mean(new_ts_evo);
L = y - min(new_ts_evo);
U = max(new_ts_evo) - y;
errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)],'lineStyle','-','color',[0 0 0])
text(x(end)+0.15,y(end),strcat(resName,'rand (new)'))

% on rand
if plot_rand
    for i = 1:size(reservoir.D_rand.all_databases,1)
        for j = 1:size(reservoir.D_rand.all_databases,2)
            voxel = measureSearchSpace(reservoir.D_rand.all_databases{i,j});
            new_ts_rand(i,j) = voxel*sum(mad(reservoir.D_rand.all_databases{i,j}));
        end
    end
    
    y = mean(new_ts_rand);
    L = y - min(new_ts_rand);
    U = max(new_ts_rand) - y;
    errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)],'lineStyle','-','color',[1 0 0])
    text(x(end)+0.15,y(end),strcat(resName,'rand (new)'))
end
hold off

%% finsih plot
xticks(1:2:10)
lb = 200:400:2000;
xticklabels(lb)
xlim([1 10])
grid on
xlabel('Generations')
ylabel('Coverage')
set(gca,'FontSize',12,'FontName','Arial')
%set(gca, 'YScale', 'log')
set(gcf,'renderer','OpenGL')
