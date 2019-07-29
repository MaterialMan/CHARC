function plotReservoirDetails(population,store_error,test,best_indv,gen,loser,config)

% plot task specific details
switch(config.dataset)
    
    case 'autoencoder'
        plotAEWeights(config.figure_array(3),config.figure_array(3),config.testInputSequence,population(best_indv(gen)),config)
               
    case 'poleBalance'
        set(0,'currentFigure',config.figure_array(1))
        config.run_sim = 1;
        config.testFcn(population(best_indv(gen)),config);
        config.run_sim = 0;
        
    case 'robot'
        set(0,'currentFigure',config.figure_array(1))
        config.run_sim = 1;
        config.testFcn(population(best_indv(gen)),config);
        config.run_sim = 0;
        
    case 'CPPN'
        set(0,'currentFigure',config.figure_array(1))
        subplot(1,2,1)
        G1 = digraph(population(best_indv(gen)).W{1});
        [X_grid,Y_grid] = ndgrid(linspace(-1,1,sqrt(size(G1.Nodes,1))));
        
        p = plot(G1,'XData',X_grid(:),'YData',Y_grid(:));
        p.EdgeCData = G1.Edges.Weight;
        colormap(gca,bluewhitered);
        colorbar
        title('Best')
        
        subplot(1,2,2)
        G2 = digraph(population(loser).W{1});
        [X_grid,Y_grid] = ndgrid(linspace(-1,1,sqrt(size(G2.Nodes,1))));
        
        p = plot(G2,'XData',X_grid(:),'YData',Y_grid(:));
        p.EdgeCData = G2.Edges.Weight;
        colormap(gca,bluewhitered);
        colorbar
        title('loser')
        %drawnow
        return;
end

% plot reservoir details
switch(config.res_type)
    case 'Graph'
        plotGridNeuron(config.figure_array(2),population,store_error,test,best_indv(gen),loser,config)
        
    case '2dCA'
        plotGridNeuron(config.figure_array(2),population,store_error,test,best_indv(gen),loser,config)
        
    case 'basicCA'
%         figure(figure1)
%         imagesc(loserStates');

    case 'BZ'
        plotBZ(config.figure_array(2),population,best_indv(gen),loser,config)
        
    case {'RoR','Pipeline','Ensemble'}
        plotRoR(config.figure_array(2),population,best_indv(gen),loser,config);
        
    case {'RBN','elementary_CA'}
        plotRBN(population(best_indv(gen)),config)
end

end
