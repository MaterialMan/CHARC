

f1 = figure
v = VideoWriter('NS.avi');
database = all_databases{1,10};
open(v);
cnt = 1;
step  = 25;
maxMC = max(database(:,3))+5;
set(f1,'position',[0,492,1657,456])

for i = 1:step:length(database)-step
    hold on
    subplot(1,3,1)
    scatter(database(i:i+step-1,1),database(i:i+step-1,2),20,i:i+step-1,'filled')
    colorbar
    xlabel('Kernel Rank')
    ylabel('Generalisation Rank')
    xlim([0 config.maxMinorUnits])
    ylim([0 config.maxMinorUnits])
    
    hold on
    subplot(1,3,2)
    title(strcat('Generation: ',num2str(i)))
    scatter(database(i:i+step-1,1),database(i:i+step-1,3),20,i:i+step-1,'filled')
    colorbar
    xlabel('Kernel Rank')
    ylabel('Memory Capacity')
    xlim([0 config.maxMinorUnits])
    ylim([0 maxMC])
    
    hold on
    subplot(1,3,3)
    scatter(database(i:i+step-1,2),database(i:i+step-1,3),20,i:i+step-1,'filled')
    colorbar
    xlabel('Generalisation Rank')
    ylabel('Memory Capacity')
    xlim([0 config.maxMinorUnits])
    ylim([0 maxMC])

    drawnow
    %pause(0.001)
    colormap('copper')
    F(cnt) = getframe(f1);
    writeVideo(v,F(cnt));
    cnt = cnt+1;
end
hold off
close(v)