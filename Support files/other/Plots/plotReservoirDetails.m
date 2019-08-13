function plotReservoirDetails(population,store_error,test,best_indv,gen,loser,config)

% individual to print - maybe cell if using MAPelites
if iscell(population(best_indv(gen)))
    best_individual = population{best_indv(gen)};
    loser_individual = population{loser};
else
    best_individual = population(best_indv(gen));
    loser_individual = population(loser);
end

% plot task specific details
switch(config.dataset)
    
    case 'autoencoder'
        plotAEWeights(config.figure_array(3),config.figure_array(3),config.testInputSequence,best_individual,config)
               
    case 'poleBalance'
        set(0,'currentFigure',config.figure_array(1))
        config.run_sim = 1;
        config.testFcn(best_individual,config);
        config.run_sim = 0;
        
    case 'robot'
        set(0,'currentFigure',config.figure_array(1))
        config.run_sim = 1;
        config.testFcn(best_individual,config);
        config.run_sim = 0;
        
    case 'CPPN'
        set(0,'currentFigure',config.figure_array(1))
        subplot(1,2,1)
        G1 = digraph(best_individual.W{1});
        [X_grid,Y_grid] = ndgrid(linspace(-1,1,sqrt(size(G1.Nodes,1))));
        
        p = plot(G1,'XData',X_grid(:),'YData',Y_grid(:));
        p.EdgeCData = G1.Edges.Weight;
        colormap(gca,bluewhitered);
        colorbar
        title('Best')
        
        subplot(1,2,2)
        G2 = digraph(loser_individual.W{1});
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
        plotRoR(config.figure_array(2),best_individual,loser_individual,config);
        
    case {'RBN','elementary_CA'}
        plotRBN(best_individual,config)
        
    case 'Wave'
%         set(0,'currentFigure',config.figure_array(1))
%         config.run_sim = 1;
%         config.testFcn(best_individual,config);
%         config.run_sim = 0;
end

end
