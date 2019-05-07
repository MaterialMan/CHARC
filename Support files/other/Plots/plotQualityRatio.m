function plotQualityRatio(figureHandle,database,resize,type,directed)

set(0,'currentFigure',figureHandle)

x = 0:10;

hold on
for i = 1:length(database)
    
    data = database{i}/resize(i).^3;
    y = mean(data);
    L = y - min(data);
    U = max(data) - y;
    if i == 3
        errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)],'lineStyle','-','color','k')
    else
        if directed
            errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)],'lineStyle','-','color','b')
        else
            errorbar(x,[0 y(1:end)],[0 L(1:end)],[0 U(1:end)],'lineStyle','--','color','r')
        end
    end
    %text(mean(x),mean(y)+mean(y)*0.25,strcat(num2str(resize(i)),' node ',type{i}))
    
end
hold off

lb = 0:200:2000;
xticklabels(lb)
xlabel('Generations')
ylabel('log(r)')
%lg = legend(database1_name,database2_name,'Location','northwest');
set(gca, 'YScale', 'log')
set(gca,'FontSize',12,'FontName','Arial')

set(gcf,'renderer','OpenGL')
drawnow
