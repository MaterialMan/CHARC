function plotDatabaseComparison(figureHandle1,database1,database2,database1_name,database2_name,overlap)

set(0,'currentFigure',figureHandle1)
maxGR = max([max(database1(:,2)) max(database2(:,2))]);
maxKR = max([max(database1(:,1)) max(database2(:,1))]);
maxMC = max([max(database1(:,3)) max(database2(:,3))]);
plotSize = 5;

if nargin < 6
    
    subplot(2,3,1)
    scatter(database1(:,1),database1(:,2),plotSize,'r','filled')
    xlabel('KR')
    ylabel('GR')
    set(gca,'FontSize',12,'FontName','Arial')
    xlim([0 maxKR])
    ylim([0 maxGR])
    
    subplot(2,3,2)
    title(database1_name)
    scatter(database1(:,1),database1(:,3),plotSize,'r','filled')
    xlabel('KR')
    ylabel('MC')
    set(gca,'FontSize',12,'FontName','Arial')
    xlim([0 maxKR])
    ylim([0 maxMC])
    
    subplot(2,3,3)
    scatter(database1(:,2),database1(:,3),plotSize,'r','filled')
    xlabel('GR')
    ylabel('MC')
    set(gca,'FontSize',12,'FontName','Arial')
    xlim([0 maxGR])
    ylim([0 maxMC])
    
    subplot(2,3,4)
    scatter(database2(:,1),database2(:,2),plotSize,'k','filled')
    xlabel('KR')
    ylabel('GR')
    set(gca,'FontSize',12,'FontName','Arial')
    xlim([0 maxKR])
    ylim([0 maxGR])
    
    subplot(2,3,5)
    title(database2_name)
    scatter(database2(:,1),database2(:,3),plotSize,'k','filled')
    xlabel('KR')
    ylabel('MC')
    set(gca,'FontSize',12,'FontName','Arial')
    xlim([0 maxKR])
    ylim([0 maxMC])
    
    subplot(2,3,6)
    scatter(database2(:,2),database2(:,3),plotSize,'k','filled')
    xlabel('GR')
    ylabel('MC')
    set(gca,'FontSize',12,'FontName','Arial')
    xlim([0 maxGR])
    ylim([0 maxMC])
    
else
    set(gcf,'Position',[-4 340 1923 489]);
    subplot(1,3,1)
    scatter(database1(:,1),database1(:,2),plotSize,'k','filled')
    hold on
    scatter(database2(:,1),database2(:,2),plotSize,'r','filled')
    hold off
    xlabel('KR')
    ylabel('GR')
    set(gca,'FontSize',12,'FontName','Arial')
    xlim([0 maxKR])
    ylim([0 maxGR])
    
    subplot(1,3,2)
    title(strcat(database1_name,'vs',database2_name))
    scatter(database1(:,1),database1(:,3),plotSize,'k','filled')
    hold on
    scatter(database2(:,1),database2(:,3),plotSize,'r','filled')
    hold off 
    xlabel('KR')
    ylabel('MC')
    set(gca,'FontSize',12,'FontName','Arial')
    xlim([0 maxKR])
    ylim([0 maxMC])
    
    subplot(1,3,3)
    scatter(database1(:,2),database1(:,3),plotSize,'k','filled')
    hold on
    scatter(database2(:,2),database2(:,3),plotSize,'r','filled')
    hold off
    xlabel('GR')
    ylabel('MC')
    set(gca,'FontSize',12,'FontName','Arial')
    xlim([0 maxGR])
    ylim([0 maxMC])
    set(gcf,'PaperOrientation','landscape');
end

set(gcf,'renderer','OpenGL')
drawnow

