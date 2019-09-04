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
        
        %plotAEWeights(best_individual,config)
        
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
        
    case 'image_gaussian'
        states = config.assessFcn(best_individual,config.test_input_sequence,config);
        output = states*best_individual.output_weights;
        
        set(0,'currentFigure',config.figure_array(1))
        for image_indx = 1:3
            subplot(3,2,(image_indx*2)-1)
            imagesc(reshape(output(image_indx,:),sqrt(size(output,2)),sqrt(size(output,2))));
            xlabel('Reservoir Output')
            subplot(3,2,image_indx*2)
            imagesc(reshape(config.test_output_sequence(image_indx,:),sqrt(size(output,2)),sqrt(size(output,2))));
            xlabel('Target Output')
        end
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
        
        % plot state space
%         states = config.assessFcn(best_individual,config.test_input_sequence,config);
%         set(0,'currentFigure',config.figure_array(1))
%         C = nchoosek(1:size(states,2)-1,2);
%         for i = 1:length(C)
%             plot(states(:,C(i,1)),states(:,C(i,2)))
%             hold on
%         end
%         hold off
        
    case {'RBN','elementary_CA'}
        plotRBN(best_individual,config)
        
    case 'Wave'
        
        if config.run_sim
            desktop     = com.mathworks.mde.desk.MLDesktop.getInstance;
            cw          = desktop.getClient('Command Window');
            xCmdWndView = cw.getComponent(0).getViewport.getComponent(0);
            h_cw        = handle(xCmdWndView,'CallbackProperties');
            set(h_cw, 'KeyPressedCallback', @CmdKeyCallback);
            
            CmdKeyCallback('reset');
            fprintf('Press any key to skip simulation \n')
            
            set(0,'currentFigure',config.figure_array(1))
            
            node_grid_size = sqrt(best_individual.nodes);
            states = config.assessFcn(best_individual,config.test_input_sequence,config);
            h=surf(reshape(states(1,1:end),node_grid_size,node_grid_size));
            
            i = 1;
            while(i < size(states,1))
                if mod(i,config.sim_speed) == 0
                    newH = reshape(states(i,1:end),node_grid_size,node_grid_size);
                    set(h,'zdata',newH,'facealpha',0.65);
                    set(gca, 'xDir', 'reverse',...
                        'camerapositionmode','manual','cameraposition',[0.5 0.5 2]);
                    axis([1 node_grid_size 1 node_grid_size -2 2]);
                    drawnow
                    %pause(config.sim_speed);
                end
                
                if CmdKeyCallback()
                    i = size(states,1);
                end
                i = i +1;
            end
        end
end

end

function Value = CmdKeyCallback(ObjectH, EventData)

persistent KeyPressed

switch nargin
    case 0
        Value = ~isempty(KeyPressed);
    case 1
        KeyPressed = [];
    case 2
        KeyPressed = true;
    otherwise
        error('Programming error');
end
end