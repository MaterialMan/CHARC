
function plotParameter(figureHandle,search_archive,parameter,pSize,p1,p2)

set(0,'currentFigure',figureHandle);
%set(gcf,'Position',[-4 340 1923 489]);

if size(search_archive,2) < 3
    
    maxGR = max(search_archive(:,2));
    maxKR = max(search_archive(:,1));
    
    scatter(search_archive(:,1),search_archive(:,2),pSize,[parameter],'filled')
    xlim([0 maxKR])
    ylim([0 maxGR])
    map = cubehelix(length(search_archive));
    colormap(map)
    xlabel(p1)
    ylabel(p2)
    colorbar
    set(gca,'FontSize',12,'FontName','Arial')
    
    figure
    scatterhist(search_archive(:,1),search_archive(:,2))
    xlim([0 maxKR])
    ylim([0 maxGR])
    xlabel(p1)
    ylabel(p2)
    set(gca,'FontSize',12,'FontName','Arial')
    
else
    
    maxGR = max(search_archive(:,2));
    maxKR = max(search_archive(:,1));
    maxMC = max(search_archive(:,3));
    
    %pSize= 5;
    
    subplot(1,3,1)
    scatter(search_archive(:,1),search_archive(:,2),pSize,[parameter],'filled')
    xlim([0 maxKR])
    ylim([0 maxGR])
    map = cubehelix(length(search_archive));
    colormap(map)
    xlabel('KR')
    ylabel('GR')
    colorbar
    set(gca,'FontSize',12,'FontName','Arial')
    
    subplot(1,3,2)
    scatter(search_archive(:,1),search_archive(:,3),pSize,[parameter],'filled')
    xlim([0 maxKR])
    ylim([0 maxMC])
    map = cubehelix(length(search_archive));
    colormap(map)
    xlabel('KR')
    ylabel('MC')
    colorbar
    set(gca,'FontSize',12,'FontName','Arial')
    
    subplot(1,3,3)
    scatter(search_archive(:,2),search_archive(:,3),pSize,[parameter],'filled')
    xlim([0 maxGR])
    ylim([0 maxMC])
    map = cubehelix(length(search_archive));
    colormap(map)
    xlabel('GR')
    ylabel('MC')
    colorbar
    set(gca,'FontSize',12,'FontName','Arial')
    
    set(gcf,'renderer','OpenGL')
    set(gcf,'PaperOrientation','landscape');
    
    drawnow
    
end

