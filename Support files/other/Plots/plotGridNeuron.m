function plotGridNeuron(figure1,individual,best_indv,loser,config)

set(0,'currentFigure',figure1)

for graph_i= 1:size(config.G,2)
    
    subplot(2,size(config.G,2),graph_i)
    
    if iscell(config.G)
        G = config.G{graph_i};
    else
        G = config.G;
    end
    %graph_indx = logical(full(adjacency(G)));
    %individual(best_indv).W{graph_i,graph_i}(~graph_indx) = 0;
    %individual(loser).W{graph_i,graph_i}(~graph_indx) = 0;
    
    %create graphs to plot
    best_G = digraph(individual(best_indv).W{graph_i,graph_i});
    loser_G = digraph(individual(loser).W{graph_i,graph_i});
    
    if config.plot_3d
        p = plot(best_G,'NodeLabel',{},'Layout','force3');
    else
        p = plot(best_G,'NodeLabel',{},'Layout','force');
    end
    p.NodeColor = 'black';
    p.MarkerSize = 1;
    p.EdgeCData = best_G.Edges.Weight;
    colormap(gca,bluewhitered)
    xlabel('Best weights')
    drawnow
    
    %% plot loser
    subplot(2,size(config.G,2),size(config.G,2) + graph_i)
    if config.plot_3d
        p = plot(loser_G,'NodeLabel',{},'Layout','force3');
    else
        p = plot(loser_G,'NodeLabel',{},'Layout','force');
    end
    p.EdgeCData = loser_G.Edges.Weight;
    p.NodeColor = 'black';
    p.MarkerSize = 1;
    colormap(gca,bluewhitered)
    xlabel('Loser weights')
    
    %pause(0.01)
    drawnow
end
