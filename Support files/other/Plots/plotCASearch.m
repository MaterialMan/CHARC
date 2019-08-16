%% plot all behaviours in behaviour space
function plotCASearch(database, gen,config)

all_behaviours = reshape([database.behaviours],length(config.metrics),length(database))';

set(0,'currentFigure',config.figure_array(1))
title(strcat('Gen:',num2str(gen)))
v = 1:length(config.metrics);
C = nchoosek(v,2);

if size(C,1) > 3
    num_plot_x = size(C,1)/2;
    num_plot_y = 2;
else
    num_plot_x = 3;
    num_plot_y = 1;
end

for i = 1:size(C,1)
    subplot(num_plot_x,num_plot_y,i)

    for p = 1:length(all_behaviours)
        [class(p),symmetry(p)] = getECAclass(bi2de(database(p).rules{1,1}(:,1)'));
    end
    scatter(all_behaviours(:,C(i,1)),all_behaviours(:,C(i,2)),20,1:length(all_behaviours),'filled')

    xlabel(config.metrics(C(i,1)))
    ylabel(config.metrics(C(i,2)))
    colormap('copper')
end

drawnow

% classes and symmetry
figure
for c = 1:4
    subplot(2,2,c)
    scatter(all_behaviours(class == c,1),all_behaviours(class == c,3),20,symmetry(class == c),'filled')
    xlim([0 max(all_behaviours(:,1))])
    ylim([0 max(all_behaviours(:,3))])
    caxis([0 max(symmetry)])
    title(strcat('class','',num2str(c)))
    xlabel('KR')
    ylabel('MC')
    %colorbar
end

% classes and delay
figure
time_period = [database.time_period];
for c = 1:4
    subplot(2,2,c)
    scatter(all_behaviours(class == c,1),all_behaviours(class == c,3),20,time_period(class == c),'filled')
    xlim([0 max(all_behaviours(:,1))])
    ylim([0 max(all_behaviours(:,3))])
    caxis([0 max(time_period)])
    title(strcat('class','',num2str(c)))
    xlabel('KR')
    ylabel('MC')
    %colorbar
end


end