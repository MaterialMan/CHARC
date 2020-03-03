%% Find best performances based on metrics using PSO - evaluate on tasks
function [final_error, final_metrics,output,miniErrorDatabase] =  PSO_evaluateTasks(rngState,metrics,esnMinor,esnMajor,metric_focus,data,...
    swarm_size,maxStall,maxIter,miniErrorDatabase,InertiaRange,SelfAdjustmentWeight,SocialAdjustmentWeight,MinNeigh)

rng(rngState,'twister');

if nargin < 11
    InertiaRange= [0.2, 0.2];%[0.2, 0.2];
    SelfAdjustmentWeight=1.49;
    SocialAdjustmentWeight=1.49;
    MinNeigh=1;%1
end
%get task data
% taskList = {'NARMA10','NARMA20','NARMA30','Laser','NonChanEqRodan','Sunspot','IPIX_plus5','JapVowels','NARMA30','handDigits','HenonMap'};

% saved errors
%miniErrorDatabase = zeros(length(metrics),length(task));

% for task_num = 1:length(task)
%     [trainInputSequence{task_num},trainOutputSequence{task_num},valInputSequence{task_num},valOutputSequence{task_num},...
%         testInputSequence{task_num},testOutputSequence{task_num},nForgetPoints{task_num},errType{task_num}] = selectDataset_Rodan(taskList{task(task_num)});
% end
% leakOn =1;

%call func
nvars = length(metric_focus); 
fun = @(x) getError(x);
options = optimoptions('particleswarm','SwarmSize',swarm_size,'MaxStallIterations',...
    maxStall,'MaxIterations',maxIter,'Display','iter','InertiaRange',InertiaRange,...
    'SelfAdjustmentWeight',SelfAdjustmentWeight,'SocialAdjustmentWeight',SocialAdjustmentWeight,'MinNeighborsFraction',MinNeigh,'PlotFcn',@pswplotswarm);%,'OutputFcn',@pswplotranges);
lb=min(metrics(:,metric_focus));
hb=max(metrics(:,metric_focus));
[final_metrics,final_error,~,output] = particleswarm(fun,nvars,lb,hb,options);

    function y = getError(x)
        distances = pdist2(metrics(:,metric_focus),x);%[round(x(1)) x(2)]);
        [~,indx] = min(distances); 
        
        %evaluate ESN on task
        y_temp = zeros(length(data.tasks),1);
        for i = 1:length(data.trainInputSequence)
            if miniErrorDatabase(indx,data.tasks(i)) == 0
                y_temp(i) = assessESNonTask(esnMinor(indx,:),esnMajor(indx),...
                    data.trainInputSequence{i},data.trainOutputSequence{i},data.valInputSequence{i},data.valOutputSequence{i},data.testInputSequence{i},data.testOutputSequence{i},...
                    data.nForgetPoints{i},data.leakOn,data.errType{i},data.resType);
                
                miniErrorDatabase(indx,data.tasks(i)) = y_temp(i);
            else
                y_temp(i) = miniErrorDatabase(indx,data.tasks(i));%data.tasks(i));
            end
        end
        y = sum(y_temp); 
    end

    function stop = pswplotswarm(optimValues,state)
        stop = false; % This function does not stop the solver
        s = round(optimValues.swarm);
        scatter(metrics(:,metric_focus(1)),metrics(:,metric_focus(2)),10,[0.75 0.75 0.75])
        hold on
        scatter(s(:,1),s(:,2),20,log(optimValues.swarmfvals),'filled')
        % scatter(metrics(s,metric_focus(1)),metrics(s,metric_focus(2)),20,log(optimValues.swarmfvals),'filled')
        hold off
        colormap('copper')
        colorbar
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

end
