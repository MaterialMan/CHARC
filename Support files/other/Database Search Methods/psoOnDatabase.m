%% Find best performances based on metrics using PSO - evaluate on tasks
function [final_error, final_metrics, best_indv, output] =  psoOnDatabase(config,metrics,database)

rng(config.rngState,'twister');
%record video
vid = VideoWriter('psoSearch.avi');
vid.FrameRate = 5;
open(vid);

config.track_pos = [];
config.track_value = [];

%call func
nvars = length(config.metrics);%1;%length(config.metrics);

p_cnt = 1;
fun = @(x) getPSOError(x);

options = optimoptions('particleswarm','SwarmSize',config.swarm_size,'HybridFcn',@fmincon,'MaxStallIterations',...
    config.maxStall,'MaxIterations',config.maxIter,'Display','iter','InertiaRange',config.InertiaRange,...
    'SelfAdjustmentWeight',config.SelfAdjustmentWeight,'SocialAdjustmentWeight',config.SocialAdjustmentWeight,'MinNeighborsFraction',config.MinNeigh,'PlotFcn',@pswplotswarm,'UseParallel',true);%,'OutputFcn',@pswplotranges);
lb= min(metrics);%1;%min(database);
hb= max(metrics);% length(database);%max(database);
cnt =1; F =[];

% get datasets
for d = 1:length(config.task_list)
    config.dataset = config.task_list{d};
    [dataset{d}] = selectDataset(config);
end

if isfield(database,'pop_indx')
    for indv = 1:length(database)
        %database(indv).pop_indx = mod(indv,10) + 1; %max([database.pop_indx])
        database(indv).pop_indx = indv;
    end
end

%run pso
[metrics_pos,final_error,~,output] = particleswarm(fun,nvars,lb,hb,options);

final_metrics = round(metrics_pos);
best_dist = pdist2(metrics,round(final_metrics));%[round(x(1)) x(2)]);
[~,best_indv] = min(best_dist);
        
%final_metrics = metrics(round(metrics_pos),:);

    function y = getPSOError(x)
        distances = pdist2(metrics,round(x));%[round(x(1)) x(2)]);
        [~,indx] = min(distances);
        %indx = round(x);
        
        %evaluate ESN on task
        for n = 1:length(config.task_list)
            database(indx) = config.testFcn(database(indx),dataset{n});
            error(n) = getError(config.error_to_check,database(indx));
        end
        
        y = sum(error);
        
    end

    function stop = pswplotswarm(optimValues,state)
        set(gcf,'position', [24 349 1632 497]);
        
        stop = false; % This function does not stop the solver
        
        distances = pdist2(metrics,round(optimValues.swarm));%[round(x(1)) x(2)]);
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
            scatter(metrics(:,C(i,1)),metrics(:,C(i,2)),10,[0.75 0.75 0.75],'filled')
            hold on
            
            % add colour to reservoirs been evaluated
            %scatter(config.track_pos(:,C(i,1)),config.track_pos(:,C(i,2)),10,config.track_value,'filled')
            scatter(metrics(config.track_pos,C(i,1)),metrics(config.track_pos,C(i,2)),10,config.track_value,'filled')
            
            % show swarm as blue
            scatter(metrics(s,C(i,1)),metrics(s,C(i,2)),20,[0 0 1],'filled')
            
            % highlight top 5 locations
            %scatter(config.track_pos(top5_indx(1:5),C(i,1)),config.track_pos(top5_indx(1:5),C(i,2)),20,[1 0 0],'filled')
            scatter(metrics(config.track_pos(top5_indx(1:5)),C(i,1)),metrics(config.track_pos(top5_indx(1:5)),C(i,2)),20,[1 0 0],'filled')
            
            hold off
            
            if i ==2
                title(strcat('Lowest error found: ',num2str(min(config.track_value),3),', Space searched: ',num2str((optimValues.funccount/length(metrics))*100,2),'%'))
            end
            
            xlabel(config.metrics(C(i,1)))
            ylabel(config.metrics(C(i,2)))
            legend({'All reservoirs','Evaluated','Swarm','Top 5'})
            colormap('copper')
        end
        
        drawnow
        
        %make video
        %         F = getframe(gcf);
        %         writeVideo(vid,F);
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
