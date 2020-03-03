%% plot all behaviours in behaviour space
function plotSearchwithTask(database, gen, task_error ,config)

%task_error(task_error > 0.5) = 0.5;
set(gcf,'position',[0,492,1657,456])

for order = 1:1
    
switch(order)
    case 1
        database_plot = database;
        task_error_plot = task_error;  
        %title_label = 'added to database';
    case 2
        [v,I] = sort(task_error,'descend');
        database_plot = database(I);
        task_error_plot = v;
        title_label = 'descend';
    case 3
        [v,I] = sort(task_error,'ascend');
        database_plot = database(I);
        task_error_plot = v;
        title_label = 'ascend';
end


all_behaviours = reshape([database_plot.behaviours],length(config.metrics),length(database_plot))';

set(0,'currentFigure',config.figure_array(1))

v = 1:length(config.metrics);
C = nchoosek(v,2);
% 
% if size(C,1) > 3
%     num_plot_x = ceil(size(C,1)/3);
%     num_plot_y = 3;
% else
%     num_plot_x = 3;
%     num_plot_y = order;
% end

for i = 1:size(C,1)
    subplot(1,3,i + (order-1)*3)

    scatter(all_behaviours(:,C(i,1)),all_behaviours(:,C(i,2)),5,task_error_plot,'filled')

    xlabel(config.metrics(C(i,1)))
    ylabel(config.metrics(C(i,2)))
    colormap(jet)
end

%title(title_label)

colorbar;
drawnow

end