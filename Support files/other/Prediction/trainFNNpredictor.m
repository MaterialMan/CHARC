function [net,maeNN,rmseNN] = trainFNNpredictor(data,NNsize)

x = data(:,1:size(data,2)-1)'; 
t = data(:,size(data,2))';
 
% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

% Create a Fitting Network
hiddenLayerSize = NNsize;
net = fitnet(hiddenLayerSize,trainFcn);

% Choose Input and Output Pre/Post-Processing Functions
% For a list of all processing functions type: help nnprocess
net.input.processFcns = {'removeconstantrows','mapstd'}; %'mapminmax',;
net.output.processFcns = {'removeconstantrows','mapstd'}; %'mapminmax',;

% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivision
net.divideFcn = 'dividerand';  % Divide data randomly
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio = 80/100;
net.divideParam.valRatio = 10/100;
net.divideParam.testRatio = 10/100;

% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
net.performFcn = 'mae';  % Mean Squared Error

% Train the Network
[net,tr] = train(net,x,t);

% Test the Network
y = net(x);
% e = gsubtract(t,y);
% performance = perform(net,t,y);

% Recalculate Training, Validation and Test Performance
% trainTargets = t .* tr.trainMask{1};
% valTargets = t .* tr.valMask{1};
% testTargets = t .* tr.testMask{1};
% trainPerformance = perform(net,trainTargets,y);
% valPerformance = perform(net,valTargets,y);
% testPerformance = perform(net,testTargets,y);

maeNN = mae(t,y);
rmseNN = sqrt(mean((t-y).^2));
%rmseNN = mean(abs(y./t)); % MAPE


