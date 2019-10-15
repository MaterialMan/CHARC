%% plot all behaviours in behaviour space
function plotSearch(database, gen,config)

all_behaviours = reshape([database.behaviours],length(config.metrics),length(database))';

set(0,'currentFigure',config.figure_array(1))
title(strcat('Gen:',num2str(gen)))
v = 1:length(config.metrics);
C = nchoosek(v,2);

if size(C,1) > 3
    num_plot_x = 3;
    num_plot_y = ceil(size(C,1)/3);
else
    num_plot_x = 1;
    num_plot_y = 3;
end

for i = 1:size(C,1)
    subplot(num_plot_x,num_plot_y,i)

    scatter(all_behaviours(:,C(i,1)),all_behaviours(:,C(i,2)),20,1:length(all_behaviours),'filled')

    xlabel(config.metrics(C(i,1)))
    ylabel(config.metrics(C(i,2)))
    colormap('copper')
end

drawnow

end