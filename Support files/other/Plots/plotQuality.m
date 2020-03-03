function plotQuality(figureHandle,database,tag,c)

set(0,'currentFigure',figureHandle)

x = 0:10;
hold on

for i = 1:length(database)
    y = mean(database{i});
    L = y - min(database{i});
    U = max(database{i}) - y;
    errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)])%,'lineStyle',tag{i},'color',c{i})
end

hold off
grid on
box on

lb = 0:200:2000;
xticklabels(lb)
xlabel('Generations')
ylabel('Total Coverage (\theta)')
%lg = legend(lg_label,'Location','northwest');

set(gca,'FontSize',12,'FontName','Arial')
%set(lg,'FontSize',12)

set(gcf,'renderer','OpenGL')
drawnow


