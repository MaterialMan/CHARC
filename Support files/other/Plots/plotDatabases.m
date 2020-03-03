function plotDatabases(figureHandle1,database1,database2,database1_name,database2_name,randPlot)

if nargin <= 5
    % take into account first 200 in population for random search
    for i = 1:size(database1,1)
        database1(i,2:end) = database1(i,1:end-1);
        database1(i,1) = database2(i,1);
    end
end

set(0,'currentFigure',figureHandle1)

x = 0:10;
hold on

% take into account first 200 in population for random search
% if randPlot
%     for i = 1:size(database1,1)
%         database1(i,2:end) = database1(i,1:end-1);
%         database1(i,1) = database2(i,1);
%     end
% end

y = mean(database1);
L = y - min(database1);
U = max(database1) - y;
errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)],'lineStyle','-','color',[1 0 0])
text(x(end)+0.15,y(end),database1_name)

y = mean(database2);
L = y - min(database2);
U = max(database2) - y;
errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)],'lineStyle','--','color',[0 0 0])
text(x(end)+0.15,y(end),database2_name)

hold off
grid on
box on

lb = 0:200:2000;
xticklabels(lb)
xlabel('Generations')
ylabel('Total Coverage (\theta)')
lg = legend(database1_name,database2_name,'Location','northwest');

set(gca,'FontSize',12,'FontName','Arial')
set(lg,'FontSize',12)

set(gcf,'renderer','OpenGL')
drawnow


