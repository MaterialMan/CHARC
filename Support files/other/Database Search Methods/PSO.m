%% Find best performances based on metrics using PSO
function [final_error, final_metrics,output,video] =  PSO(rngstate,metrics,test_error,metric_focus,task_num,swarm_size,maxStall,maxIter,minValue,multitask, video)

rng(rngstate,'twister') 

if nargin > 10
    record = 1;
    
else
    record = 0;
    video = 0;
end

%call func
nvars = length(metric_focus);

if multitask
    fun = @(x) getMultiError(x);
else
    fun = @(x) getError(x);
end

options = optimoptions('particleswarm','SwarmSize',swarm_size,'MaxStallIterations',...
    maxStall,'MaxIterations',maxIter,'Display','off','InertiaRange',[0.2, 0.2],...
    'SelfAdjustmentWeight',1.49,'SocialAdjustmentWeight',1.49,'PlotFcn',@pswplotswarm,'MinNeighborsFraction',1,'ObjectiveLimit',minValue);%,'OutputFcn',@pswplotranges);
lb = min(metrics(:,metric_focus));
hb =max(metrics(:,metric_focus));
cnt = 1;
[final_metrics,final_error,~,output] = particleswarm(fun,nvars,lb,hb,options);

    function y = getError(x)
        distances = pdist2(metrics(:,metric_focus),x);
        [~,indx] = min(distances);
        y = test_error(indx,task_num);
    end

    function y = getMultiError(x)
        distances = pdist2(metrics(:,metric_focus),x);
        [~,indx] = min(distances);
        y = sum(test_error(indx,:)); %all tasks
    end

    function stop = pswplotswarm(optimValues,state)
        stop = false; % This function does not stop the solver
        s = optimValues.swarm;
        scatter(metrics(:,metric_focus(1)),metrics(:,metric_focus(2)),10,[0.75 0.75 0.75])
        hold on
        scatter(s(:,1),s(:,2),20,log(optimValues.swarmfvals),'filled')
        hold off
        colormap('copper')
        colorbar
        %drawnow
        if record
            F(cnt) = getframe;
            writeVideo(video,F(cnt));
            cnt = cnt+1;
        end
    end
end
