function plotGridNeuron(figure1,genotype,storeError,test,best_indv)

set(0,'currentFigure',figure1)
subplot(2,2,[1 2])
imagesc(reshape(storeError(test,:,:),size(storeError,2),size(storeError,3)))
colormap(bluewhitered)
colorbar
ylabel('Generations')
xlabel('Individual')


subplot(2,2,3)
if config.plot3d
    p = plot(genotype(best_indv).G,'NodeLabel',{},'Layout','force3');
else
    p = plot(genotype(best_indv).G,'NodeLabel',{},'Layout','force');
end
p.NodeColor = 'black';
p.MarkerSize = 1;
if ~config.directedGraph
    p.EdgeCData = genotype(best_indv).G.Edges.Weight;
end
highlight(p,logical(genotype(best_indv).input_loc),'NodeColor','g','MarkerSize',3)
colormap(bluewhitered)
xlabel('Best weights')

subplot(2,2,4)
if config.plot3d
    p = plot(genotype(loser).G,'NodeLabel',{},'Layout','force3');
else
    p = plot(genotype(loser).G,'NodeLabel',{},'Layout','force');
end
if ~config.directedGraph
    p.EdgeCData = genotype(loser).G.Edges.Weight;
end
p.NodeColor = 'black';
p.MarkerSize = 1;
highlight(p,logical(genotype(loser).input_loc),'NodeColor','g','MarkerSize',3)
colormap(bluewhitered)
xlabel('Loser weights')

pause(0.01)
drawnow
end