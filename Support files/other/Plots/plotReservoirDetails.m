function F = plotReservoirDetails(population,best_indv,gen,loser,config)

% individual to print - maybe cell if using MAPelites
if iscell(population(best_indv(gen)))
    best_individual = population{best_indv(gen)};
    loser_individual = population{loser};
else
    best_individual = population(best_indv(gen));
    loser_individual = population(loser);
end

desktop     = com.mathworks.mde.desk.MLDesktop.getInstance;
cw          = desktop.getClient('Command Window');
xCmdWndView = cw.getComponent(0).getViewport.getComponent(0);
h_cw        = handle(xCmdWndView,'CallbackProperties');
set(h_cw, 'KeyPressedCallback', @CmdKeyCallback);

CmdKeyCallback('reset');
fprintf('Press any key to skip simulation \n')

% plot task specific details
switch(config.dataset)
    
    case 'autoencoder'
        
        plotAEWeights(best_individual,config)
        
    case 'pole_balance'
        set(0,'currentFigure',config.figure_array(1))
        config.run_sim = 1;
        config.testFcn(best_individual,config);
        config.run_sim = 0;
        
    case 'attractor'
        
        %test_states = config.assessFcn(best_individual,config.test_input_sequence,config,config.test_output_sequence);
        %test_sequence = test_states*best_individual.output_weights;
        test_states = config.assessFcn(loser_individual,config.test_input_sequence,config,config.test_output_sequence);
        test_sequence = test_states*loser_individual.output_weights;
        
        set(0,'currentFigure',config.figure_array(1))
        subplot(1,3,1)
        plot(config.test_output_sequence(config.wash_out+1:end,:),'r')
        hold on
        plot(test_sequence,'b')
        hold off
        
        subplot(1,3,2)
        X = config.test_output_sequence(config.wash_out+1:end,:);
        T = test_sequence;
        switch(size(X,2))
            case 3
            plot3(X(:,1),X(:,2),X(:,3),'r');
            hold on
            plot3(T(:,1),T(:,2),T(:,3),'b');
            hold off
            xlabel('X'); ylabel('Y'); zlabel('Z');
        case 2
            plot(X(:,1),X(:,2),'r');
            hold on
            plot(T(:,1),T(:,2),'b');
            hold off
            xlabel('X'); ylabel('Y');
         case 1
            plot(X(:,1),'r');
            hold on
            plot(T(:,1),'b');
            hold off
            xlabel('X');
        end
        
        %axis equal;
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
        
    case 'franke_fcn'
        set(0,'currentFigure',config.figure_array(1))
        states = config.assessFcn(best_individual,config.test_input_sequence,config);
        output = states*best_individual.output_weights;
        
        subplot(1,2,1)     
        x = config.test_input_sequence(config.wash_out+1:end,1);
        y = config.test_input_sequence(config.wash_out+1:end,2);
        z = config.test_output_sequence(config.wash_out+1:end);
        
        xv = linspace(min(x), max(x), 20);
        yv = linspace(min(y), max(y), 20);
        [X,Y] = meshgrid(xv, yv);
        Z = griddata(x,y,z,X,Y);
        surf(X, Y, Z);
        
        subplot(1,2,2)
        z = output;
        xv = linspace(min(x), max(x), 20);
        yv = linspace(min(y), max(y), 20);
        [X,Y] = meshgrid(xv, yv);
        Z = griddata(x,y,z,X,Y);
        surf(X, Y, Z);
        
        drawnow
               
end

% plot reservoir details
if ~iscell(config.res_type)
switch(config.res_type)
    case 'Graph'
        plotGridNeuron(config.figure_array(2),population,best_indv(gen),loser,config)

        
         set(0,'currentFigure',config.figure_array(1))
        subplot(1,2,1)
        imagesc(states(:,1:end-config.task_num_inputs)')
        colorbar
        subplot(1,2,2)
        imagesc(real(fft(states(:,1:end-config.task_num_inputs)))')
        colorbar
        colormap(bluewhitered)
        
    case {'2D_CA','GOL'}
              colormap('bone')
        
        if config.run_sim
            set(0,'currentFigure',config.figure_array(2))
            set(gcf,'position',[-1005 458 981 335])
            [states,~,extra_states] = config.assessFcn(population(best_indv(gen)),config.test_input_sequence,config);
            for i = 1:size(states,1)
                subplot(1,2,1)
                t_state = states(i,1:end-population(best_indv(gen)).n_input_units);
                imagesc(reshape(t_state,sqrt(size(t_state,2)),sqrt(size(t_state,2))));
                %title(strcat('n = ',num2str(i)))
                subplot(1,2,2)
                t_state = extra_states(i,1:end);
                imagesc(reshape(t_state,sqrt(size(t_state,2)),sqrt(size(t_state,2))));
                
                drawnow
                if config.film
                    F(i) = getframe(gcf);
                else
                    F =[];
                end
                if CmdKeyCallback()
                    i = size(states,1);
                end
                pause(0.05);
            end
        end
        
    case {'Ising'}

        if config.run_sim
            colormap('bone')
            set(0,'currentFigure',config.figure_array(2))
            set(gcf,'position',[-737 236 713 557])
            [states] = config.assessFcn(population(best_indv(gen)),config.test_input_sequence,config);
            for i = 1:size(states,1)
                t_state = states(i,1:end-population(best_indv(gen)).n_input_units);
                imagesc(reshape(t_state,sqrt(size(t_state,2)),sqrt(size(t_state,2))));
                colorbar
                caxis([-1 1])
                drawnow
                if config.film
                    F(i) = getframe(gcf);
                else
                    F =[];
                end
                if CmdKeyCallback()
                    i = size(states,1);
                end
                pause(0.05);
            end
        end
        
    case 'BZ'
        
        plotBZ(config.figure_array(2),population,best_indv(gen),loser,config)
        
        if config.run_sim
            set(0,'currentFigure',config.figure_array(1))
            states = config.assessFcn(population(best_indv(gen)),config.test_input_sequence,config);
            
            for i = 1:size(states,1)
                p = reshape(states(i,1:end-population(best_indv(gen)).n_input_units),sqrt(population(best_indv(gen)).nodes),sqrt(population(best_indv(gen)).nodes),3);
                image(uint8(255*hsv2rgb(p)));
                drawnow;
                if CmdKeyCallback()
                    i = size(states,1);
                end
                if config.film
                    F(i) = getframe;
                else
                    F =[];
                end
            end
        end
        
    case {'RoR','Pipeline','Ensemble'}
        set(0,'currentFigure',config.figure_array(2))
        plotRoR(config.figure_array(2),best_individual,loser_individual,config);
        
        % plot state space
        states = config.assessFcn(best_individual,config.test_input_sequence,config,config.test_output_sequence);
        %         set(0,'currentFigure',config.figure_array(1))
        %         C = nchoosek(1:size(states,2)-1,2);
        %         for i = 1:length(C)
        %             plot(states(:,C(i,1)),states(:,C(i,2)))
        %             hold on
        %         end
        %         hold off
        
        set(0,'currentFigure',config.figure_array(2))
        subplot(1,2,1)
        imagesc(states(:,1:end-config.task_num_inputs)')
        colorbar
        subplot(1,2,2)
        imagesc(real(fft(states(:,1:end-config.task_num_inputs)))')
        colorbar
        colormap(bluewhitered)
           
    case {'RBN','elementary_CA'}
        plotRBN(best_individual,config)
        
    case 'Wave'
        
        config.wave_sim_speed = 1;
        
        set(0,'currentFigure',config.figure_array(2))
        
        %% plot input locations
        subplot(1,2,1)
        indx=1;
        % write input values for each location
        input = best_individual.input_scaling(indx)*(best_individual.input_weights{indx}*[config.test_input_sequence repmat(best_individual.bias_node,size(config.test_input_sequence,1),1)]')';
        
        % change input widths
        node_grid_size = sqrt(best_individual.nodes(indx));
        for n = 1:size(input,1)
            m = reshape(input(n,:),node_grid_size,node_grid_size);
            f_pos = find(m);
            input_matrix_2d = m;
            for p = 1:length(f_pos)
                t = zeros(size(m));
                t(f_pos(p)) = m(f_pos(p));
                [t] = adjustInputShape(t,best_individual.input_widths{indx}(f_pos(p)));
                input_matrix_2d = input_matrix_2d + t;
            end
            input(n,:) = input_matrix_2d(:);
        end
        
        imagesc(reshape(max(abs(input)),node_grid_size,node_grid_size))
        title('Input location')
        colormap(bluewhitered)
        colorbar
        
        %% plot states
        subplot(1,2,2)
        % run wave reservoir on task
        switch(config.dataset)
            case 'robot'
                [~,states] = robot(best_individual,config);
            case 'pole_balance'
                [~,states]= poleBalance(best_individual,config);
            otherwise
                states = config.assessFcn(best_individual,config.test_input_sequence,config);
        end
        
        if config.num_reservoirs
            states = states(:,1:config.num_nodes(1)+best_individual.n_input_units);
        end
        
        set(0,'currentFigure',config.figure_array(1))
        subplot(1,2,1)
        imagesc(states(:,1:end-config.task_num_inputs)')
        colorbar
        subplot(1,2,2)
        imagesc(real(fft(states(:,1:end-config.task_num_inputs)))')
        colorbar
        colormap(bluewhitered)
        
        %plot
        set(0,'currentFigure',config.figure_array(2))
        if config.add_input_states
            h=surf(reshape(states(1,1:end-best_individual.n_input_units),node_grid_size,node_grid_size));
        else
            h=surf(reshape(states(1,1:end),node_grid_size,node_grid_size));
        end

        
        change_scale = 0;
        
        i = 2;
        colormap(gca,'bone'); %
        %set(gca,'visible','off')
        set(gca,'XColor', 'none','YColor','none')
        shading interp
        %lighting phong;
        %material shiny;
        %lightangle(-45,30)
        while(i < size(states,1))
            if mod(i,config.wave_sim_speed) == 0
                if config.add_input_states
                    newH = reshape(states(i,1:end-best_individual.n_input_units),node_grid_size,node_grid_size);
                    set(h,'zdata',newH,'facealpha',0.65);
                    
                    if change_scale
                        set(gca, 'xDir', 'reverse',...
                            'camerapositionmode','manual','cameraposition',[1 1 max((states(i,1:end-best_individual.n_input_units)))]);
                        axis([1 node_grid_size 1 node_grid_size min((states(i,1:end-best_individual.n_input_units))) max((states(i,1:end-best_individual.n_input_units)))]);
                    else
                        set(gca, 'xDir', 'reverse',...
                            'camerapositionmode','manual','cameraposition',[1 1 max(max(states(:,1:end-best_individual.n_input_units)))]);
                        axis([1 node_grid_size 1 node_grid_size min(min(states(:,1:end-best_individual.n_input_units))) max(max(states(:,1:end-best_individual.n_input_units)))]);
                    end
                else
                    newH = reshape(states(i,1:end),node_grid_size,node_grid_size);
                    set(h,'zdata',newH,'facealpha',0.65);
                    if change_scale
                        set(gca, 'xDir', 'reverse',...
                            'camerapositionmode','manual','cameraposition',[1 1 max(states(i,1:end))]);
                        axis([1 node_grid_size 1 node_grid_size min(states(i,1:end)) max(states(i,1:end))]);
                    else
                        set(gca, 'xDir', 'reverse',...
                            'camerapositionmode','manual','cameraposition',[1 1 max(max(states(:,1:end)))]);
                        axis([1 node_grid_size 1 node_grid_size min(min(states(:,1:end))) max(max(states(:,1:end)))]);
                    end
                end
                if config.film
                    F(i) = getframe;
                else
                    F =[];
                end
                drawnow
                pause(0.05)
            end
            
            if CmdKeyCallback()
                i = size(states,1);
            end
            
            i = i +1;
        end
        
    case 'MM'
        
        config.parallel = 0;
        config.plot_states = 1;
        states = config.assessFcn(population(best_indv(gen)),config.test_input_sequence,config);
        states = states(:,1:end-best_individual.n_input_units);
        
        set(0,'currentFigure',config.figure_array(1))
        subplot(1,2,1)
        imagesc(states(:,1:end-config.task_num_inputs)')
        colorbar
        subplot(1,2,2)
        imagesc(real(fft(states(:,1:end-config.task_num_inputs)))')
        colorbar
        colormap(bluewhitered)
               
end


if config.film
    v = VideoWriter('ReservoirPlot_video');%,'MPEG-4');
    v.Quality = 100;
    v.FrameRate = 15;
    open(v);
    writeVideo(v,F);
    close(v);
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