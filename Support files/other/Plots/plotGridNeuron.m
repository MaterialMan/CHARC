function plotGridNeuron(figure1,individual,store_error,test,best_indv,loser,config)

set(0,'currentFigure',figure1)
subplot(2,2,[1 2])
imagesc(reshape(store_error(test,:,:),size(store_error,2),size(store_error,3)))
set(gca,'YDir','normal')
colormap(bluewhitered)
colorbar
ylabel('Generations')
xlabel('Individual')

if iscell(config.G)
    G = config.G{1};
else
    G = config.G;
end
graph_indx = logical(full(adjacency(G)));
individual(best_indv).W{1,1}(~graph_indx) = 0;
individual(loser).W{1,1}(~graph_indx) = 0;
%create graphs to plot
best_G = digraph(individual(best_indv).W{1,1});
loser_G = digraph(individual(loser).W{1,1});

subplot(2,2,3)
if config.plot_3d
    p = plot(best_G,'NodeLabel',{},'Layout','force3');
else
    p = plot(best_G,'NodeLabel',{},'Layout','force');
end
p.NodeColor = 'black';
p.MarkerSize = 1;
p.EdgeCData = best_G.Edges.Weight;
colormap(bluewhitered)
xlabel('Best weights')

subplot(2,2,4)
if config.plot_3d
    p = plot(loser_G,'NodeLabel',{},'Layout','force3');
else
    p = plot(loser_G,'NodeLabel',{},'Layout','force');
end
p.EdgeCData = loser_G.Edges.Weight;
p.NodeColor = 'black';
p.MarkerSize = 1;
colormap(bluewhitered)
xlabel('Loser weights')

%pause(0.01)
drawnow
end
