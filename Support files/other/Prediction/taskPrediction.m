%% Solve an Input-Output Fitting problem with a Neural Network
% add the database assessed files to the Workspace, then run

clearvars -except pred_dataset config dist %figure1 figure2 figure3

% Used to find the relative distances between each point in the database.
% Can be used to limit the dataset to only diverse solutions
get_data = 0; %%%%%%%%% very important, takes long time %%%%%%%

if ~exist('figure1')
    figure1 = figure;
end

if ~exist('figure2')
    figure2 = figure;
end

if ~exist('figure3')
    figure3 = figure;
end

%% training param
numTests =1;
displayPredict =1;
plotDist = 0;
add_noise =1;
train_nn = 1;

lossfunc = 'mae';
tfunc = 'trainbr';
err_measure= 'NMSE';

nodes = [100]; % fill array to try different sized networks
taskSet = 1:size(pred_dataset.outputs,2);
metrics = 1:size(pred_dataset.inputs,2); %inputs go [KR GR KR-GR abs(KR-GR) MC]

%Pre-process
preprocess = 1; %yes(1)/no(0)
test_thresh  = 0.8; % remove errors above this threshold
met_threshold = 2; % anything below this metric value is removed
remove_metrics = [5 1 2]; %Metrics effected by met_threshold: MC, kR and GR
reducedRegion.y = 20; %nothing greater than MC>20 is in the test error calculation
reducedRegion.xlow = 0; %nothing less than KR<0 is in the test error calculation
reducedRegion.xhigh = 50;%nothing greater than KR>50 is in the test error calculation

%% get best data - try not to repeat anything
if get_data
    f = waitbar(0,'1','Name','Getting Distances...',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(f,'canceling',0);
    dist =[]; T = length(pred_dataset.inputs);
    for i = 1:T%length(esn_data.database)
        if getappdata(f,'canceling')
            break
        end
        dist(i) = findKNN(pred_dataset.inputs,pred_dataset.inputs(i,:),5);
        % Update waitbar and message
        waitbar(i/T,f,i/T)
    end
    delete(f)
    
    % This effectively reduces the size of the dataset to behaviours that are
    % far apart from each other, i.e. ignoring behaviours close together.
    distlength = length(dist)*1; % range [0 1], closer to zero will imply behaviours further apart are only kept
    [DValues,locD]= sort(dist,'descend');
    scatter(pred_dataset.inputs(locD(1:distlength),1),pred_dataset.inputs(locD(1:distlength),5)) %KR vs MC
    data_length = locD(1:distlength);
    
    save('master_script_training_data.mat','-v7.3');
else
    data_length = 1:size(pred_dataset.inputs,1);
    %load('master_script_training_data.mat','dist');
end

%%
for set = 1:length(nodes)
    
    hiddenLayerSize = nodes(set);
    
    for taskNum = 1:length(taskSet)
        %% Task data
        task =taskSet(1,taskNum);%{'NARMA10','NARMA20','NARMA30','Laser','NonChanEqRodan','Sunspot','IPIX_plus5'};
        
        % material tasks - not given
        %mat_task = taskSet(2,taskNum); %{'NARMA10','Laser','NonChanEqRodan','IPIX_plus5','JapVowels'};
        
        x = pred_dataset.inputs(data_length,metrics)';
        % use discrete MC values
        %x = round(x);
        t = pred_dataset.outputs(data_length,task)';
        
        %% preprocess
        %remove NaNs
        indx = isnan(t);
        t(indx) = [];
        x(:,indx) = [];
        
        %remove errorness
        indx = t > test_thresh; %0.8
        t(indx) = [];
        x(:,indx) = [];
        
        %remove low memory
        for i = 1:length(remove_metrics)
            indx = x(remove_metrics(i),:) < met_threshold;
            t(indx) = [];
            x(:,indx) = [];
        end
        
        if preprocess
            t = tanh(t);
        end
        
        %% explore data
        if plotDist
            %figure(figure3)
            corrplot([x' t'])
        end
        
        
        %% Choose a Training Function
        % 'trainlm' is usually fastest.
        % 'trainbr' takes longer but may be better for challenging problems.
        % 'trainscg' uses less memory. Suitable in low memory situations.
        trainFcn = tfunc;  % Levenberg-Marquardt backpropagation.
        
        % Create a Fitting Network
        for test = 1:numTests
            
            net = fitnet(hiddenLayerSize,trainFcn);
            
            % Choose Input and Output Pre/Post-Processing Functions
            % For a list of all processing functions type: help nnprocess
            net.input.processFcns = {'removeconstantrows','mapminmax','mapstd'}; %,'mapstd'
            net.output.processFcns = {'removeconstantrows','mapminmax','mapstd'};
            
            % Setup Division of Data for Training, Validation, Testing
            % For a list of all data division functions type: help nndivide
            net.divideFcn = 'dividerand';  % Divide data randomly
            net.divideMode = 'sample';  % Divide up every sample
            net.divideParam.trainRatio = 70/100;
            net.divideParam.valRatio = 15/100;
            net.divideParam.testRatio = 15/100;
            
            % Choose a Performance Function
            % For a list of all performance functions type: help nnperformance
            net.performFcn = lossfunc;  % Mean Squared Error
            net.trainParam.epochs=1000;
            
            % Choose Plot Functions
            % For a list of all plot functions type: help nnplot
            net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
                'plotregression', 'plotfit'};
            
            % Train the Network
            if train_nn
                rng(test,'twister')
                
                if add_noise
                    [net,tr] = train(net,x + randn(size(x)),t);
                else
                    [net,tr] = train(net,x,t);
                end
                
                net.performFcn = lossfunc;
                
                netList{set,task,test} = net;
            else
                net = netList{set,task,test};
            end
            
            % Test the Network
            if add_noise
                y = net(x+randn(size(x)));
            else
                y = net(x);
            end
            e = gsubtract(t,y);
            performance{set,taskNum}(test) = perform(net,t,y);
            
            % Recalculate Training, Validation and Test Performance
            trainTargets = t .* tr.trainMask{1};
            valTargets = t .* tr.valMask{1};
            testTargets = t .* tr.testMask{1};
            trainPerformance = perform(net,trainTargets,y);
            valPerformance = perform(net,valTargets,y);
            nn_testPerformance{set,taskNum}(test) = calculateError(y',t',0,err_measure);%perform(net,testTargets,y)/length(y);
            
            if displayPredict
                plotData(figure1,nn_testPerformance,x,y,t,set,taskNum,test)
            end
            
            
            % minimise to certain region of behaviour space
            p = x(2,:) < reducedRegion.y;
            xp = x(:,p);
            tp = t(p);
            
            p1 = xp(1,:) > reducedRegion.xlow ;
            p2 = xp(1,:) < reducedRegion.xhigh;
            p3 = p1 + p2;
            p4 = p3 == 2;
            xt = xp(:,p4);
            tt = tp(p4);
            
            rp = randperm(length(tt));
            
            xt = xt(:,rp);
            tt = tt(:,rp);
            
            y_restricted = net(xt);
            nn_testPerf_restricted{set,taskNum}(test) = calculateError(y_restricted',tt',0,err_measure);%perform(net,testTargets,y)/length(y);
            
            %calculate delta
            delta{set,taskNum}(test,1)= nn_testPerformance{set,taskNum}(test);
            delta{set,taskNum}(test,2)= nn_testPerf_restricted{set,taskNum}(test);
            
            display(delta{set,taskNum}(test,:))
            
            figure(figure2)
            %set(gcf,'DefaultAxesFontSize',14,'DefaultAxesFontName','Arial');
            subplot(2,1,1)
            scatter(xt(3,:),xt(5,:),20,tt,'filled')
            title(strcat('Restricted NN MAE=',num2str(nn_testPerf_restricted{set,taskNum}(test))))
            %title('Predicted')
            colorbar
            colormap(cubehelix)
            xlabel('KR-GR')
            ylabel('MC')
            caxis([0 1])
            
            
            subplot(2,1,2)
            scatter(x(3,:),x(5,:),20,t,'filled')
            title(strcat('Original NN MAE=',num2str(nn_testPerformance{set,taskNum}(test))))
            colorbar
            colormap(cubehelix)
            caxis([0 1])
            xlabel('KR-GR')
            ylabel('MC')
            
            
        end
        
        delta_mean(set,taskNum,:) = mean(delta{set,taskNum});
        
        %netList{set,taskNum} = net;
        train_mean(set,taskNum) = mean(performance{set,taskNum});
        train_std(set,taskNum) =std(performance{set,taskNum});
        
        test_mean(set,taskNum) =mean(nn_testPerformance{set,taskNum});
        test_std(set,taskNum) =std(nn_testPerformance{set,taskNum});
        
    end
end

save('journal_master_script_trained_network_25node.mat','-v7.3');


for i = 1:size(nn_testPerformance,1)
    for j = 1:size(nn_testPerformance,2)
        meanESN(i,j)= mean(nn_testPerformance{i,j,:});
        stdESN(i,j) = std(nn_testPerformance{i,j,:});
        %     meanMat(i,j) =
        %     stdMat(i,j) =
        %     meanCleanMat(i,j) =
        %     stdcleanMat(i,j) =
    end
end
meanESN
stdESN

function [avg_dist] = findKNN(metrics,Y,k_neighbours)
[~,D] = knnsearch(metrics,Y,'K',k_neighbours);
avg_dist = mean(D);
end

function plotData(figure1, nn_testPerformance,x,y,t,set,taskNum,test)
figure(figure1)
subplot(2,3,1)
scatter(x(1,:),x(5,:),20,y','filled')
title(strcat('NN MAE=',num2str(nn_testPerformance{set,taskNum}(test))))
colorbar
colormap(cubehelix)
xlabel('KR')
ylabel('MC')
caxis([0 1])

subplot(2,3,2)
scatter(x(1,:),x(2,:),20,y','filled')
title(strcat('NN MAE=',num2str(nn_testPerformance{set,taskNum}(test))))
colorbar
colormap(cubehelix)
xlabel('KR')
ylabel('GR')
caxis([0 1])

subplot(2,3,3)
scatter(x(2,:),x(5,:),20,y','filled')
title(strcat('NN MAE=',num2str(nn_testPerformance{set,taskNum}(test))))
colorbar
colormap(cubehelix)
xlabel('GR')
ylabel('MC')
caxis([0 1])

%
subplot(2,3,4)
scatter(x(1,:),x(5,:),20,t,'filled')
title('Actual Error')
colorbar
colormap(cubehelix)
caxis([0 1])
xlabel('KR')
ylabel('MC')


subplot(2,3,5)
scatter(x(1,:),x(2,:),20,t,'filled')
title('Actual Error')
colorbar
colormap(cubehelix)
caxis([0 1])
xlabel('KR')
ylabel('GR')


subplot(2,3,6)
scatter(x(2,:),x(5,:),20,t,'filled')
title('Actual Error')
colorbar
colormap(cubehelix)
caxis([0 1])
xlabel('GR')
ylabel('MC')
drawnow;
end
%%
% a2 = nn_testPerformance{6,4};
% a1 = nn_testPerformance{5,4};
% a = nn_testPerformance{1,4};
% boxplot([a' a1' a2'])