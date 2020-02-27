function F = plot_front(population, ref_individual, fronts, objs, clear_points,generation,F,config)

persistent pareto_plot;

cmap = hsv(length(fronts)+1);

if ishandle(pareto_plot) == 1
    ax = pareto_plot.CurrentAxes;
else
    pareto_plot = figure('Name', 'Pareto Plot');
    ax = gca;
    grid(ax, 'on');
    switch(objs)
        case 2
            xlabel(ax, config.dataset_list{1});
            ylabel(ax, config.dataset_list{2});
        case 3
            xlabel(ax, config.dataset_list{1});
            ylabel(ax, config.dataset_list{2});
            zlabel(ax, config.dataset_list{3});
    end
    hold(ax, 'on');  
end

title(strcat('Generation: ',num2str(generation)));

if(clear_points)
    delete(ax.Children);
end

old_limits = [ax.XLim, ax.YLim];

% Plot the reference individual
if ~isempty(ref_individual)
    objectives = ref_individual.objectives;
    switch(objs)
        case 2
            scatter(ax, objectives(:,1), objectives(:,2), 36, cmap(1,:), 'd');
        case 3
            scatter3(ax, objectives(:,1), objectives(:,2),objectives(:,3), 36, cmap(1,:), 'd');
    end
end

for i = 1:length(fronts)
    
    individuals = get_front(population, fronts(i));
    objectives = vertcat(population(individuals).objectives);
    switch(objs)
        case 2
            scatter(ax, objectives(:,1), objectives(:,2), 36,cmap(i+1,:));
        case 3
            scatter3(ax, objectives(:,1), objectives(:,2), objectives(:,3), 36,cmap(i+1,:));
    end
%     new_limits = [[0 max(objectives(:,obj1_idx))],[0 max(max(objectives(:,obj2_idx)))]];%[ax.XLim, ax.YLim];
%   
%     if old_limits(1) < new_limits(1)
%         new_limits(1) =  old_limits(1);
%     end
%     if old_limits(2) < new_limits(2)
%         new_limits(2) =  old_limits(2);
%     end
%     if old_limits(3) < new_limits(3)
%         new_limits(3) =  old_limits(3);
%     end
%     if old_limits(4) < new_limits(4)
%         new_limits(4) =  old_limits(4);
%     end
%     
%     old_limits = new_limits;
end

  
%axis(ax, new_limits);
drawnow;

%drawnow
F(generation) = getframe(pareto_plot);
end
