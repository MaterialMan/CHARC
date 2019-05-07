%% Find best performances based on metrics using PSO - evaluate on tasks
function [final_error, final_metrics, best_indv, output] =  psoOnDatabase(config,database,genotype)

rng(config.rngState,'twister');
%record video
vid = VideoWriter('psoSearch.avi');
vid.FrameRate = 5;
open(vid);

config.track_pos = [];
config.track_value = [];
        
%call func
nvars = length(config.metrics);%1;%length(config.metrics); 
fun = @(x) getError(x);

options = optimoptions('particleswarm','SwarmSize',config.swarm_size,'HybridFcn',@fmincon,'MaxStallIterations',...
    config.maxStall,'MaxIterations',config.maxIter,'Display','iter','InertiaRange',config.InertiaRange,...
    'SelfAdjustmentWeight',config.SelfAdjustmentWeight,'SocialAdjustmentWeight',config.SocialAdjustmentWeight,'MinNeighborsFraction',config.MinNeigh,'PlotFcn',@pswplotswarm);%,'OutputFcn',@pswplotranges);
lb= min(database);%1;%min(database);
hb= max(database);% length(database);%max(database);
cnt =1; F =[];

%run pso
[metrics_pos,final_error,~,output] = particleswarm(fun,nvars,lb,hb,options);
        
best_indv = round(metrics_pos);
final_metrics = database(round(metrics_pos),:);

    function y = getError(x)
        distances = pdist2(database,round(x));%[round(x(1)) x(2)]);
        [~,indx] = min(distances); 
        %indx = round(x);
        
        %evaluate ESN on task
        task_error = assessDBonTasks(config,genotype(indx),database(indx,:));
        
        y = task_error.outputs; 
        
    end

    function stop = pswplotswarm(optimValues,state)
        set(gcf,'position', [24 349 1632 497]);
        
        stop = false; % This function does not stop the solver
                
        distances = pdist2(database,round(optimValues.swarm));%[round(x(1)) x(2)]);
        [~,s] = min(distances); 

        %s = round(optimValues.swarm);
        
        config.track_pos = [config.track_pos s];
        config.track_value = [config.track_value; optimValues.swarmfvals];
        
        [~,top5_indx] = sort(config.track_value);
        
        v = 1:length(config.metrics);
        C = nchoosek(v,2);
        
        if size(C,1) > 3
            num_plot_x = size(C,1)/2;
            num_plot_y = 2;
        else
            num_plot_x = 1;
            num_plot_y = 3;
        end
        
        for i = 1:size(C,1)
            
            subplot(num_plot_x,num_plot_y,i)
            
            % grey out all reservoirs to highlight database
            scatter(database(:,C(i,1)),database(:,C(i,2)),10,[0.75 0.75 0.75],'filled')
            hold on
             
            % add colour to reservoirs been evaluated
            %scatter(config.track_pos(:,C(i,1)),config.track_pos(:,C(i,2)),10,config.track_value,'filled')
            scatter(database(config.track_pos,C(i,1)),database(config.track_pos,C(i,2)),10,config.track_value,'filled')           
              
            % show swarm as blue
            scatter(database(s,C(i,1)),database(s,C(i,2)),20,[0 0 1],'filled')
            
            % highlight top 5 locations
            %scatter(config.track_pos(top5_indx(1:5),C(i,1)),config.track_pos(top5_indx(1:5),C(i,2)),20,[1 0 0],'filled')
            scatter(database(config.track_pos(top5_indx(1:5)),C(i,1)),database(config.track_pos(top5_indx(1:5)),C(i,2)),20,[1 0 0],'filled')
            
            hold off
            
            if i ==2
                title(strcat('Lowest error found: ',num2str(min(config.track_value),3),', Space searched: ',num2str((optimValues.funccount/length(database))*100,2),'%'))
            end
            
            xlabel(config.metrics(C(i,1)))
            ylabel(config.metrics(C(i,2)))
            legend({'All reservoirs','Evaluated','Swarm','Top 5'})
            colormap('copper')
        end
        
        drawnow
        %make video
        F = getframe(gcf);
        writeVideo(vid,F);
        cnt = cnt +1;
    end

    function stop = pswplotranges(optimValues,state)
        
        stop = false; % This function does not stop the solver
        switch state
            case 'init'
                nplot = size(optimValues.swarm,2); % Number of dimensions
                for i = 1:nplot % Set up axes for plot
                    subplot(nplot,1,i);
                    tag = sprintf('psoplotrange_var_%g',i); % Set a tag for the subplot
                    semilogy(optimValues.iteration,0,'-k','Tag',tag); % Log-scaled plot
                    ylabel(num2str(i))
                end
                xlabel('Iteration','interp','none'); % Iteration number at the bottom
                subplot(nplot,1,1) % Title at the top
                title('Log range of particles by component')
                setappdata(gcf,'t0',tic); % Set up a timer to plot only when needed
            case 'iter'
                nplot = size(optimValues.swarm,2); % Number of dimensions
                for i = 1:nplot
                    subplot(nplot,1,i);
                    % Calculate the range of the particles at dimension i
                    irange = max(optimValues.swarm(:,i)) - min(optimValues.swarm(:,i));
                    tag = sprintf('psoplotrange_var_%g',i);
                    plotHandle = findobj(get(gca,'Children'),'Tag',tag); % Get the subplot
                    xdata = plotHandle.XData; % Get the X data from the plot
                    newX = [xdata optimValues.iteration]; % Add the new iteration
                    plotHandle.XData = newX; % Put the X data into the plot
                    ydata = plotHandle.YData; % Get the Y data from the plot
                    newY = [ydata irange]; % Add the new value
                    plotHandle.YData = newY; % Put the Y data into the plot
                end
                if toc(getappdata(gcf,'t0')) > 1/30 % If 1/30 s has passed
                    drawnow % Show the plot
                    setappdata(gcf,'t0',tic); % Reset the timer
                end
            case 'done'
                % No cleanup necessary
        end
    end

close(vid)

end
