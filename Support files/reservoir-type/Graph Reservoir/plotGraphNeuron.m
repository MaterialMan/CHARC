function plotGraphNeuron(figure1,individual,best_indv)

set(0,'currentFigure',figure1)

for graph_indx = 1:size(individual.G,1)
    
    subplot(2,size(individual.G,1),graph_indx)
    if config.plot3d
        p = plot(individual(best_indv).G{graph_indx},'NodeLabel',{},'Layout','force3');
    else
        p = plot(individual(best_indv).G{graph_indx},'NodeLabel',{},'Layout','force');
    end
    p.NodeColor = 'black';
    p.MarkerSize = 1;
    if ~config.directedGraph
        p.EdgeCData = individual(best_indv).G{graph_indx}.Edges.Weight;
    end
    highlight(p,logical(individual(best_indv).input_loc),'NodeColor','g','MarkerSize',3)
    colormap(bluewhitered)
    xlabel('Best weights')
    
    % plot loser
    subplot(2,size(individual.G,1),size(individual.G,1)+graph_indx)
    if config.plot3d
        p = plot(individual(loser).G,'NodeLabel',{},'Layout','force3');
    else
        p = plot(individual(loser).G,'NodeLabel',{},'Layout','force');
    end
    if ~config.directedGraph
        p.EdgeCData = individual(loser).G.Edges.Weight;
    end
    p.NodeColor = 'black';
    p.MarkerSize = 1;
    highlight(p,logical(individual(loser).input_loc),'NodeColor','g','MarkerSize',3)
    colormap(bluewhitered)
    xlabel('Loser weights')
    
    pause(0.01)
    drawnow
end