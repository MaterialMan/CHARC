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
        plotAEWeights(best_individual,config)
               
    case 'poleBalance'
        set(0,'currentFigure',config.figure_array(1))
        config.run_sim = 1;
        config.testFcn(best_individual,config);
        config.run_sim = 0;
        
    case 'attractor'

        test_states = config.assessFcn(best_individual,config.test_input_sequence,config);
        test_sequence = test_states*best_individual.output_weights;
        
        set(0,'currentFigure',config.figure_array(3))
        subplot(1,3,1)
        plot(config.test_output_sequence(config.wash_out+1:end,:),'r')
        hold on
        plot(test_sequence,'b')
        hold off
        
        subplot(1,3,2)
        X = config.test_output_sequence(config.wash_out+1:end,:);
        T = test_sequence;
        if size(X,2) > 2
            plot3(X(:,1),X(:,2),X(:,3),'r');
            hold on
            plot3(T(:,1),T(:,2),T(:,3),'b');
            hold off
            xlabel('X'); ylabel('Y'); zlabel('Z');
        else
            plot(X(:,1),X(:,2),'r');
            hold on
            plot(T(:,1),T(:,2),'b');
            hold off
            xlabel('X'); ylabel('Y');
        end
        
        axis equal;
        grid;
        title('Attractor');
        
        subplot(1,3,3)
        plot(test_states)
        
        drawnow
        
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
