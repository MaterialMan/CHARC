%% Select Data Script: Generate task data sets and split data
% Notes:
% - All data normalised between [-0.5 0.5]
% - Incomplete, but most datasets should work.

function [trainInputSequence,trainOutputSequence,valInputSequence,valOutputSequence,...
    testInputSequence,testOutputSequence,nForgetPoints,errType,queueType] = selectDataset_Rodan(inputData,hardware)

scurr = rng;
temp_seed = scurr.Seed;

if nargin < 2
    hardware = 0;
end

rng(1,'twister');

switch inputData
    
    %% Chaotic systems
    case 'NARMA10' %input error 4 - good task
        errType = 'NMSE';
        queueType = 'simple';
        nForgetPoints =200;
        sequenceLength = 8000;
        train_fraction=0.25;    val_fraction=0.375;    test_fraction=0.375;
        [inputSequence,outputSequence] = generate_new_NARMA_sequence(sequenceLength,10);
        inputSequence = 2*inputSequence-0.5;
        outputSequence = 2*outputSequence-0.5;
        fprintf('NARMA 10 task: %s \n',datestr(now, 'HH:MM:SS'))
        
    case 'NARMA20' %input error 4 - good task
        errType = 'NMSE';
        queueType = 'simple';
        nForgetPoints =200;
        sequenceLength = 8000;
        train_fraction=0.25;    val_fraction=0.375;    test_fraction=0.375;
        [inputSequence,outputSequence] = generate_new_NARMA_sequence(sequenceLength,20);
        inputSequence = 2*inputSequence-0.5;
        outputSequence = 2*outputSequence-0.5;
        fprintf('NARMA 20 task: %s \n',datestr(now, 'HH:MM:SS'))
        
    case 'NARMA30' %input error 4 - good task
        errType = 'NMSE';
        queueType = 'simple';
        nForgetPoints =200;
        sequenceLength = 8000;
        train_fraction=0.25;    val_fraction=0.375;    test_fraction=0.375;
        [inputSequence,outputSequence] = generate_new_NARMA_sequence(sequenceLength,30);
        inputSequence = 2*inputSequence-0.5;
        outputSequence = 2*outputSequence-0.5;
        fprintf('NARMA 30 task: %s \n',datestr(now, 'HH:MM:SS'))
         
    case 'HenonMap' % input error > 1 - good task
        queueType = 'simple';
        errType = 'NMSE';
        nForgetPoints =200;
        sequenceLength= 8000;
        stdev = 0.05;
        train_fraction=0.25;    val_fraction=0.375;    test_fraction=0.375;
        [inputSequence,outputSequence] = generateHenonMap(sequenceLength,stdev);
        
        %% Time-series
    case 'IPIX_plus5' % good task
        errType = 'IPIX';
        queueType = 'Weighted';
        nForgetPoints =100;
        sequenceLength = 2000;
        train_fraction=0.4;    val_fraction=0.25;    test_fraction=0.35;   %val and test are switched later so ratios need to be swapped
        
        % IPIX radar task
        %load hiIPIX.txt
        load loIPIX.txt
        
        ahead = 5;
        data = loIPIX(1:sequenceLength+ahead,:);
        inputSequence = data(1:sequenceLength,:);
        outputSequence = data(ahead+1:end,:);
        
        fprintf('Low IPIX task - 5 ahead. \n Started at %s \n',datestr(now, 'HH:MM:SS'))
        
    case 'IPIX_plus1' % good task
        errType = 'IPIX';
        queueType = 'Weighted';
        nForgetPoints =100;
        sequenceLength = 2000;
        train_fraction=0.4;    val_fraction=0.25;    test_fraction=0.35;   %val and test are switched later so ratios need to be swapped
        
        % IPIX radar task
        %load hiIPIX.txt
        load loIPIX.txt
        
        ahead = 1;
        data = loIPIX(1:sequenceLength+ahead,:);
        inputSequence = data(1:sequenceLength,:);
        outputSequence = data(ahead+1:end,:);
        
        fprintf('Low IPIX task 1 ahead. \n Started at %s \n',datestr(now, 'HH:MM:SS'))
        
        
    case 'Laser' % good task
        queueType = 'simple';
        errType = 'NMSE';
        % Sante Fe Laser generator task
        nForgetPoints =200;
        sequenceLength = 8000;
        train_fraction=0.25;    val_fraction=0.375;    test_fraction=0.375;
        
        ahead = 1;
        data = laser_dataset;  %checkout the list at http://uk.mathworks.com/help/nnet/gs/neural-network-toolbox-sample-data-sets.html
        data = cell2mat(data(:,1:sequenceLength+ahead));
        inputSequence = data(1:end-ahead)';
        outputSequence = data(ahead+1:end)';
        
        fprintf('Laser task TSP - 64 electrode test: %s \n',datestr(now, 'HH:MM:SS'))
        
        
    case 'Sunspot' % good task but not sure about dataset- problem with dividing set
        queueType = 'simple';
        errType = 'NMSE';
        % Sunspot task - needs proper dataset separation
        nForgetPoints =100;
        sequenceLength = 3100;
        train_fraction= 1600/sequenceLength;    val_fraction=500/sequenceLength;    test_fraction=1000/sequenceLength;
        
        ahead = 1;
        load sunspot.txt %solar_dataset;  %checkout the list at http://uk.mathworks.com/help/nnet/gs/neural-network-toolbox-sample-data-sets.html
        data = sunspot(1:sequenceLength+ahead,4);
        inputSequence = data(1:end-ahead);
        outputSequence = data(ahead+1:end);
        
        fprintf('Sunspot task TSP: %s \n',datestr(now, 'HH:MM:SS'))
        
        %% Pattern Recognition - using PCA to reduce dimensions maybe very useful
    case 'NIST-64' %Paper: Reservoir-based techniques for speech recognition
        errType = 'OneVsAll_NIST';
        queueType = 'Weighted';
        nForgetPoints =150;
        xvalDetails.kfold = 5;
        xvalDetails.kfoldSize = 150;
        xvalDetails.kfoldType = 'standard';
        train_fraction=0.7;    val_fraction=0.15;    test_fraction=0.15; %meaningless
        
        y_list = [];
        u_list = [];
        lens = [];
        
        for i = 1:5
            l = [ 1 2 5 6 7];
            for j = 1:10
                for n = 0:9
                    u_z = zeros(77,xvalDetails.kfoldSize);
                    u = load(strcat('s',num2str(l(i)),'_u',num2str(j),'_d',num2str(n)));
                    u_z(:,1:size(u.spec,2)) = u.spec;
                    
                    y = zeros(10,size(u_z,2))-1;
                    y(n+1,:) = ones(1,size(u_z,2));
                    u_list = [u_list u_z];
                    lens = [lens size(u_z,2)];
                    y_list = [y_list y];
                end
            end
        end
        
        inputSequence = u_list';
        outputSequence = y_list';
        
        
    case 'NonChanEqRodan' % (1:in, 1:out) error 0.999 Good task, requires memory
        errType = 'NMSE';
        queueType = 'simple'; %input alone error = 0.091
        nForgetPoints =200;
        sequenceLength = 8000;
        train_fraction=0.25;    val_fraction=0.375;    test_fraction=0.375;
        
        [inputSequence, outputSequence] = NonLinear_ChanEQ_data(sequenceLength);
        inputSequence =inputSequence';
        outputSequence =outputSequence';
        
    case 'handDigits'
        errType = 'softmax';
        queueType = 'Weighted';
        nForgetPoints =10;
        train_fraction=0.8;    val_fraction=0.1;    test_fraction=0.1;
        datasetLength = 5000; %manually change dataset length for xval
        
        load('handDigits.mat');
        inputSequence = X;
        outputSequence = [];
        for i = 1:10
            outputSequence(:,i) = y==i;
        end
        
        target=randperm(datasetLength);
        temp_inputSequence = inputSequence(target,:);
        temp_outputSequence = outputSequence(target,:);
        
        inputSequence = temp_inputSequence;
        outputSequence = temp_outputSequence;
        
    case 'JapVowels' %(12: IN, 9:OUT - binary ) - input only 83% accuracy!  Train:0.2288  Test:0.1863
        errType = 'softmax'; %Paper: Optimization and applications of echo state networks with leaky- integrator neurons
        queueType = 'Weighted';
        % Nine male speakers uttered two Japanese vowels /ae/ successively.
        % For each utterance, with the analysis parameters described below, we applied
        % 12-degree linear prediction analysis to it to obtain a discrete-time series
        % with 12 LPC cepstrum coefficients. This means that one utterance by a speaker
        % forms a time series whose length is in the range 7-29 and each point of a time
        % series is of 12 features (12 coefficients).
        % The number of the time series is 640 in total. We used one set of 270 time series for
        % training and the other set of 370 time series for testing.
        nForgetPoints =100;
        
        [trainInputSequence,trainOutputSequence,testInputSequence,testOutputSequence] = readJapVowels();
        inputSequence = [trainInputSequence; testInputSequence];
        outputSequence = [trainOutputSequence; testOutputSequence];
        train_fraction=size(trainInputSequence,1)/9961;    val_fraction=(size(testInputSequence,1)/9961)*0.1;    test_fraction=(size(testInputSequence,1)/9961)*0.9;
        
        
    case 'SignalClassification'
        errType = 'softmax';
        queueType = 'simple';
        nForgetPoints =100;
        train_fraction=0.25;    val_fraction=0.375;    test_fraction=0.375;
        
        freq = 1000;
        fprintf('Signal Classification: \n',datestr(now, 'HH:MM:SS'))
        fprintf('Freq: %d Hz\n',freq);
        scanFreq = 20000; %per channel
        step = 1/scanFreq;
        t = 0:step:1-step;
        amplitude = 1;
        sequenceLength = 6000;
        period = 20;
        
        % sinewave input
        inputSequence(:,1) = amplitude*sin(2*pi*freq*t);
        inputSequence(:,2) = amplitude*square(2*pi*freq*t);
        
        cnt = 1; sinInput =[];squareInput=[];
        for i = 0:period:sequenceLength-period
            sinInput(cnt,i+1:i+period) = inputSequence(i+1:i+period,1);
            squareInput(cnt,i+1:i+period) = inputSequence(i+1:i+period,2);
            cnt = cnt +1;
        end
        
        combInput = zeros(sequenceLength,1); 
        combOutput= ones(sequenceLength,2)*-1;
        for i = 1:sequenceLength/period
            if round(rand)
                combInput = combInput+sinInput(i,:)';
                combOutput((i*period)-period+1:i*period,1) =  ones(period,1);
            else
                combInput = combInput+squareInput(i,:)';
                combOutput((i*period)-period+1:i*period,2) =  ones(period,1);
            end
        end
        
        inputSequence = combInput;
        outputSequence = combOutput;
        figure
        subplot(2,1,1)
        plot(inputSequence(1:350))
        subplot(2,1,2)
        plot(outputSequence(1:350,:))
        
    case 'MSO'
        errType = 'NRMSE';
        queueType = 'simple'; %?
        nForgetPoints =100;
        sequenceLength= 2000;
        train_fraction=0.583333;    val_fraction=0.16667;    test_fraction=0.25;
        
        for t = 1:sequenceLength
            u(1,t) = sin(0.2*t)+sin(0.311*t);
            u(2,t) = sin(0.2*t)+sin(0.311*t)+sin(0.42*t);
            u(3,t) = sin(0.2*t)+sin(0.311*t)+sin(0.42*t)+sin(0.51*t);
            u(4,t) = sin(0.2*t)+sin(0.311*t)+sin(0.42*t)+sin(0.51*t)+sin(0.74*t);
            %u(1,t) = sin(0.2*t)+sin(0.311*t)+sin(0.42*t)+sin(0.51*t)+sin(0.63*t)+sin(0.74*t)+sin(0.85*t)+sin(0.97*t);
        end
        %predictor - not sure what predictor value is best
        %ahead = 10;
        %outputSequence = u(:,ahead+1:end)';
        inputSequence = zeros(sequenceLength,size(u,1));%u(:,1:end-ahead)';
        outputSequence = u';
        
    case 'secondOrderTask' %best 3.61e-3
        queueType = 'simple';
        errType = 'NMSE';

        nForgetPoints =50;
        sequenceLength = 700;
        train_fraction= 300/sequenceLength;    val_fraction=100/sequenceLength;    test_fraction=300/sequenceLength;       
        u = rand(sequenceLength,1)/2;
        y = zeros(sequenceLength,1);
        for i = 3:sequenceLength
            y(i) = 0.4*y(i-1)+0.4*y(i-1)*y(i-2)+0.6*(u(i).^2) + 0.1;
        end
        inputSequence = u;
        outputSequence = y;
        
end

%normalise all features
%[inputSequence, mu, sigma] = featureNormalize(inputSequence);

%squash
if hardware
    for i = 1:size(inputSequence,2)
        if max(inputSequence(:,i)) ~= 0
            inputSequence(:,i) = ((inputSequence(:,i)-mean(inputSequence(:,i)))/((max(inputSequence(:,i))-min(inputSequence(:,i)))))-0.5;
        end
    end
end

[trainInputSequence,valInputSequence,testInputSequence] = ...
    split_train_test3way(inputSequence,train_fraction,val_fraction,test_fraction);
[trainOutputSequence,valOutputSequence,testOutputSequence] = ...
    split_train_test3way(outputSequence,train_fraction,val_fraction,test_fraction);

% Go back to old seed
rng(temp_seed,'twister');