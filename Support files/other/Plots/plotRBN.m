function plotRBN(individual,config)

set(0,'currentFigure',config.figure_array(2))

for j = 1:config.num_reservoirs
    source_node = repmat(1:individual.nodes(j),config.k,1);
    source_node = source_node(:);
    G_in = [individual.RBN_node{j}.input];
    G{j} = graph(source_node,G_in);
    subplot(1,config.num_reservoirs,j)
    plot(G{j})    
end

drawnow



