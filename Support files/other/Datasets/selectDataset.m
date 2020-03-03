
%% Select Data Script: Generate task data sets and split data
function [config] = selectDataset(config)

scurr = rng;
temp_seed = scurr.Seed;

wash_out =50;

rng(1,'twister');

switch config.dataset
    
    %% test data
    case 'test_pulse'
        err_type = 'NMSE';
        wash_out =0;
        sequence_length = 300;
        train_fraction=0.3333;    val_fraction=0.3333;    test_fraction=0.3333;
        
        input_sequence = zeros(sequence_length,1);
        
        for i=1:sequence_length
            if mod(i,25) == 0
                input_sequence(i) = 1;
            end
        end
        
        output_sequence = input_sequence;
        
        %% Chaotic systems
    case 'narma_10' %input error 4 - good task
        err_type = 'NMSE';
        sequence_length = 5000;
        train_fraction=0.6;    val_fraction=0.2;    test_fraction=0.2;
        [input_sequence,output_sequence] = generate_new_NARMA_sequence(sequence_length,10);
        input_sequence = 2*input_sequence-0.5;
        output_sequence = 2*output_sequence-0.5;
        %fprintf('NARMA 10 task: %s \n',datestr(now, 'HH:MM:SS'))
        %config.preprocess = '';
        
    case 'narma_20' %input error 4 - good task
        err_type = 'NMSE';
        sequence_length = 5000;
        train_fraction=0.6;    val_fraction=0.2;    test_fraction=0.2;
        [input_sequence,output_sequence] = generate_new_NARMA_sequence(sequence_length,20);
        input_sequence = 2*input_sequence-0.5;
        output_sequence = 2*output_sequence-0.5;
        %fprintf('NARMA 20 task: %s \n',datestr(now, 'HH:MM:SS'))
        
        
    case 'narma_30' %input error 4 - good task
        err_type = 'NMSE';
        sequence_length = 5000;
        train_fraction=0.6;    val_fraction=0.2;    test_fraction=0.2;
        [input_sequence,output_sequence] = generate_new_NARMA_sequence(sequence_length,30);
        input_sequence = 2*input_sequence-0.5;
        output_sequence = 2*output_sequence-0.5;
        %fprintf('NARMA 30 task: %s \n',datestr(now, 'HH:MM:SS'))
        
    case 'multi_narma'
        err_type = 'NMSE';
        sequence_length = 5000;
        train_fraction=0.6;    val_fraction=0.2;    test_fraction=0.2;
        [input_sequence(:,1),output_sequence(:,1)] = generate_new_NARMA_sequence(sequence_length,5);
        [input_sequence(:,2),output_sequence(:,2)] = generate_new_NARMA_sequence(sequence_length,10);
        [input_sequence(:,3),output_sequence(:,3)] = generate_new_NARMA_sequence(sequence_length,30);
        
        input_sequence = 2*input_sequence-0.5;
        output_sequence = 2*output_sequence-0.5;
        
    case 'narma_10_DLexample' %input error 4 - good task
        err_type = 'NRMSE';
        config.preprocess = 0;       
        sequence_length = 2700;
        train_fraction = 0.3333;    val_fraction=0.3333;    test_fraction=0.3333;
        
        [input_sequence,output_sequence] = generate_new_NARMA_sequence(sequence_length,10);
        
    case 'narma_10_QRC' %input error 4 - good task
        err_type = 'NMSE';
        config.preprocess = 0;
        
        sequence_length = 12000;
        train_fraction = 0.3333;    val_fraction=0.3333;    test_fraction=0.3333;
        
        [input_sequence,output_sequence] = generate_new_NARMA_sequence(sequence_length,10);
        input_sequence = (input_sequence*2)*0.2;
        
    case 'henon_map' % input error > 1 - good task
        
        err_type = 'NMSE';
        sequence_length= 3000;
        stdev = 0.05;
        train_fraction=0.5;    val_fraction=0.2;    test_fraction=0.2;
        [input_sequence,output_sequence] = generateHenonMap(sequence_length,stdev);
        
        %% Time-series
    case 'IPIX_plus5' % good task
        err_type = 'IPIX';
        sequence_length = 2000;
        train_fraction=0.4;    val_fraction=0.25;    test_fraction=0.35;   %val and test are switched later so ratios need to be swapped
        
        % IPIX radar task
        %load hiIPIX.txt
        load loIPIX.txt
        
        ahead = 5;
        data = loIPIX(1:sequence_length+ahead,:);
        input_sequence = data(1:sequence_length,:);
        output_sequence = data(ahead+1:end,:);
        
        %fprintf('Low IPIX task - 5 ahead. \n Started at %s \n',datestr(now, 'HH:MM:SS'))
        
    case 'IPIX_plus1' % good task
        err_type = 'IPIX';
        sequence_length = 2000;
        train_fraction=0.4;    val_fraction=0.25;    test_fraction=0.35;   %val and test are switched later so ratios need to be swapped
        
        % IPIX radar task
        %load hiIPIX.txt
        load loIPIX.txt
        
        ahead = 1;
        data = loIPIX(1:sequence_length+ahead,:);
        input_sequence = data(1:sequence_length,:);
        output_sequence = data(ahead+1:end,:);
        
        %fprintf('Low IPIX task 1 ahead. \n Started at %s \n',datestr(now, 'HH:MM:SS'))
        
        
    case 'laser' % good task
        
        err_type = 'NMSE';
        % Sante Fe Laser generator task
        sequence_length = 1000;
        train_fraction=0.6;    val_fraction=0.2;    test_fraction=0.2;
        
        ahead = 1;
        %data = laser_dataset;  %checkout the list at http://uk.mathworks.com/help/nnet/gs/neural-network-toolbox-sample-data-sets.html
        %data = cell2mat(data(:,1:sequence_length+ahead));
        data = load('laser.txt');
        input_sequence = data(1:sequence_length-ahead);
        output_sequence = data(ahead+1:sequence_length);
        
        %fprintf('Laser task TSP - 64 electrode test: %s \n',datestr(now, 'HH:MM:SS'))
        
    case 'sunspot' % good task but not sure about dataset- problem with dividing set
        
        err_type = 'NMSE';
        % Sunspot task - needs proper dataset separation
        sequence_length = 3100;
        train_fraction= 1600/sequence_length;    val_fraction=500/sequence_length;    test_fraction=1000/sequence_length;
        
        ahead = 1;
        load sunspot.txt %solar_dataset;  %checkout the list at http://uk.mathworks.com/help/nnet/gs/neural-network-toolbox-sample-data-sets.html
        data = sunspot(1:sequence_length+ahead,4);
        input_sequence = data(1:end-ahead);
        output_sequence = data(ahead+1:end);
        
        %fprintf('Sunspot task TSP: %s \n',datestr(now, 'HH:MM:SS'))
        
        %% Pattern Recognition - using PCA to reduce dimensions maybe very useful
        
    case 'autoencoder'
        err_type = 'NMSE';
        train_fraction=0.5;    val_fraction=0.25;    test_fraction=0.25;
        
        % image
        %         t = digitTrainCellArrayData; %28 x 28 image x 5000
        %         for i=1:length(t)
        %             u(:,i) = t{i}(:);
        %         end
        
        % data signal
        t = rand(1000,10);
        u = t';
        
        input_sequence= u';
        output_sequence= u';
        
        
    case 'attractor' %reconstruct lorenz attractor
        err_type = 'NMSE';
        train_fraction=0.5;    val_fraction=0.25;    test_fraction=0.25;
        wash_out =100;
        
        switch(config.attractor_type)
            case 'lorenz'
                data_length = 1e4; T = 100; h = 0.001;
                [x,y, z] = createLorenz(28, 10, 8/3, T, h, data_length);  % roughly 100k datapoints
                attractor_sequence= [x, y, z];
                slice = [1 1 0.5];
            case 'rossler'
                data_length = 4e3; T = 100; h = 0.001;
                [x,y,z] = createRosslerAttractor(0.2,0.2,5.7, T, h ,data_length); % roughly 100k datapoints
                attractor_sequence= [x, y, z];
                slice = [1 1 0.5];
            case 'limit_cycle'
                data_length = 4e3; T = 100; h = 0.001;
                [x, y] = createLimitCycleAttractor(4, T, h, data_length); % roughly 10k datapoints
                attractor_sequence= [x, y];
                slice = [1 1 0.5];
            case 'mackey_glass'
                data_length = 8e3; T = 1e4;
                %[x] = createMackeyGlass(17, 0.1, 0.2, 10, T ,data_length);
                %attractor_sequence= x';
                x = load('Mackey_Glass_t17.txt');
                
                attractor_sequence= x(1:data_length);
                slice = [1 1 0.5];

            case 'duffing_map'
                data_length = 4e3;
                data_struct.delta= 0.3;
                data_struct.alpha= -1;
                data_struct.beta= 1;
                data_struct.gamma= 0.5;
                data_struct.w = 1.2;
                y0 = [1 0];
                T = 1e3;
                [x] =createDuffingOscillator(data_length, data_struct, y0, T);
                attractor_sequence= x';
                slice = [1 1 0.5];
            case 'dynamic' % not finished: still playing with
                
                data_length = 4e3;
                plot = 0;
                num_attractors = 10;
                [x] = attractorSwitch(data_length,num_attractors,plot);
                attractor_sequence= x;
                slice = [1 1 1];
            otherwise
        end
        
        data_length = size(attractor_sequence,1);
        
        % divide data -  add no signal
        
        input_sequence = attractor_sequence;
        input_sequence(floor(data_length*train_fraction*slice(1))+1:floor(data_length*train_fraction),:) = zeros;
        input_sequence(floor(data_length*train_fraction)+floor(data_length*val_fraction*slice(2))+1:floor(data_length*train_fraction)+floor(data_length*val_fraction),:) = zeros;
        input_sequence(floor(data_length*train_fraction)+floor(data_length*val_fraction)+floor(data_length*test_fraction*slice(3))+1:end,:) = zeros;
        
        ahead = 1;%shift by 1. Becomes prediction problem
        input_sequence = input_sequence(1:end-ahead,:);
        output_sequence = attractor_sequence(1+ahead:end,:);
        
    case 'NIST-64' %Paper: Reservoir-based techniques for speech recognition
        err_type = 'OneVsAll_NIST';
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
        
        input_sequence = u_list';
        output_sequence = y_list';
        
        
    case 'non_chan_eq_rodan' % (1:in, 1:out) error 0.999 Good task, requires memory
        err_type = 'NMSE';
        %input alone error = 0.091
        sequence_length = 2000;
        train_fraction=0.25;    val_fraction=0.375;    test_fraction=0.375;
        
        [input_sequence, output_sequence] = NonLinear_ChanEQ_data(sequence_length);
        input_sequence =input_sequence';
        output_sequence =output_sequence';
        
    case 'hand_digits'
        
        err_type = 'softmax';
        train_fraction=0.8;    val_fraction=0.1;    test_fraction=0.1;
        dataset_length = 5000; %manually change dataset length for xval
        
        load('handDigits.mat');
        input_sequence = X;
        output_sequence = [];
        for i = 1:10
            output_sequence(:,i) = y==i;
        end
        
        target=randperm(dataset_length);
        temp_inputSequence = input_sequence(target,:);
        temp_outputSequence = output_sequence(target,:);
        
        input_sequence = temp_inputSequence;
        output_sequence = temp_outputSequence;
        
    case 'japanese_vowels' %(12: IN, 9:OUT - binary ) - input only 83% accuracy!  Train:0.2288  Test:0.1863
        err_type = 'softmax'; %Paper: Optimization and applications of echo state networks with leaky- integrator neurons
        
        % Nine male speakers uttered two Japanese vowels /ae/ successively.
        % For each utterance, with the analysis parameters described below, we applied
        % 12-degree linear prediction analysis to it to obtain a discrete-time series
        % with 12 LPC cepstrum coefficients. This means that one utterance by a speaker
        % forms a time series whose length is in the range 7-29 and each point of a time
        % series is of 12 features (12 coefficients).
        % The number of the time series is 640 in total. We used one set of 270 time series for
        % training and the other set of 370 time series for testing.
        
        [train_input_sequence,trainOutputSequence,testInputSequence,test_output_sequence] = readJapVowels();
        input_sequence = [train_input_sequence; testInputSequence];
        output_sequence = [trainOutputSequence; test_output_sequence];
        train_fraction=size(train_input_sequence,1)/9961;    val_fraction=(size(testInputSequence,1)/9961)*0.1;    test_fraction=(size(testInputSequence,1)/9961)*0.9;
        
        t =  randperm(dataset_length,dataset_length);
        
    case 'signal_classification'
        err_type = 'softmax';
        
        train_fraction=0.25;    val_fraction=0.375;    test_fraction=0.375;
        
        freq = 1000;
        fprintf('Signal Classification: \n',datestr(now, 'HH:MM:SS'))
        fprintf('Freq: %d Hz\n',freq);
        scanFreq = 20000; %per channel
        step = 1/scanFreq;
        t = 0:step:1-step;
        amplitude = 1;
        sequence_length = 3000;
        period = 20;
        
        % sinewave input
        input_sequence(:,1) = amplitude*sin(2*pi*freq*t);
        input_sequence(:,2) = amplitude*square(2*pi*freq*t);
        
        cnt = 1; sinInput =[];squareInput=[];
        for i = 0:period:sequence_length-period
            sinInput(cnt,i+1:i+period) = input_sequence(i+1:i+period,1);
            squareInput(cnt,i+1:i+period) = input_sequence(i+1:i+period,2);
            cnt = cnt +1;
        end
        
        combInput = zeros(sequence_length,1);
        combOutput= ones(sequence_length,2)*0;
        for i = 1:sequence_length/period
            if round(rand)
                combInput = combInput+sinInput(i,:)';
                combOutput((i*period)-period+1:i*period,1) =  ones(period,1);
            else
                combInput = combInput+squareInput(i,:)';
                combOutput((i*period)-period+1:i*period,2) =  ones(period,1);
            end
        end
        
        input_sequence = combInput;
        output_sequence = combOutput;
        
    case 'iris' %iris_dataset; (4:in, 3:out) %input alone 76% - medium task
        err_type = 'softmax';%'IJCNNpaper';%'confusion';
        
       % wash_out = 25;
        
        train_fraction=0.6;    val_fraction=0.2;    test_fraction=0.2;
        dataset_length = 150;
        
        t =  randperm(dataset_length,dataset_length);
        
        load('iris.mat');
        
        %[input_sequence, output_sequence] =  %iris_dataset; %iris_dataset; (4:in, 3:out)
        input_sequence = input_sequence(:,t)';
        output_sequence = output_sequence(:,t)';
        
%         input_sequence = [input_sequence(:,t(1:wash_out)) input_sequence(:,t)]';
%         output_sequence = [output_sequence(:,t(1:wash_out)) output_sequence(:,t)]';
        
    case {'MSO1','MSO2','MSO3','MSO4','MSO5','MSO6','MSO7','MSO8','MSO9','MSO10','MSO11','MSO12'}  %MSO'
        
        task = str2num(config.dataset(4:end));
        err_type = 'NRMSE';
        wash_out = 100;
        sequence_length= 1000;
        train_fraction=0.4;    val_fraction=0.3;    test_fraction=0.3;
        
                ahead = 1;
        for t = 1:sequence_length+ahead
            u(t,1) = sin(0.2*t);
            u(t,2) = u(t,1) + sin(0.311*t);
            u(t,3) = u(t,2) + sin(0.42*t);
            u(t,4) = u(t,3) + sin(0.51*t);
            u(t,5) = u(t,4) + sin(0.63*t);
            u(t,6) = u(t,5) + sin(0.74*t);
            u(t,7) = u(t,6) + sin(0.85*t);
            u(t,8) = u(t,7) + sin(0.97*t);
            u(t,9) = u(t,8) + sin(1.08*t);
            u(t,10) = u(t,9) + sin(1.19*t);
            u(t,11) = u(t,10) + sin(1.27*t);
            u(t,12) = u(t,11) + sin(1.32*t);
        end
        
        %predictor 
        input_sequence = u(1:sequence_length,task);
        output_sequence = u(ahead+1:sequence_length+ahead,task);
        
    case 'secondorder_task' %best 3.61e-3
        
        err_type = 'NMSE';
        
        sequence_length = 1500;
        train_fraction=0.5;    val_fraction=0.25;    test_fraction=0.25;
        
        u = rand(sequence_length,1)/2;
        y = zeros(sequence_length,1);
        for i = 3:sequence_length
            y(i) = 0.4*y(i-1)+0.4*y(i-1)*y(i-2)+0.6*(u(i).^2) + 0.1;
        end
        input_sequence = u;
        output_sequence = y;
        
    case 'MNIST'
        err_type = 'softmax';
        
        wash_out = 0;
        train_fraction=0.25;    val_fraction=0.375;    test_fraction=0.375;
        preprocess = 0;
        
        [xTrainImages,tTrain] = digitTrainCellArrayData; %28 x 28 image x 5000
        
        for i=1:length(xTrainImages)
            u(:,i) = xTrainImages{i}(:);
        end
        
        target=randperm(length(xTrainImages));
        temp_inputSequence = u(:,target);
        temp_outputSequence = tTrain(:,target);
        
        input_sequence = temp_inputSequence';
        output_sequence = temp_outputSequence';
        
        
    case 'pole_balance'
        err_type = 'empty';
        train_fraction=0.1;    val_fraction=0.1;    test_fraction=0.1;
        wash_out = 1;
        input_sequence= zeros(100,6);
        output_sequence= zeros(100,1);
        
        
    case 'robot'
        err_type = 'empty';
        train_fraction=0.1;    val_fraction=0.1;    test_fraction=0.1;
        wash_out = 1;
        config.num_sensors = 8;
        input_sequence= zeros(100,config.num_sensors+1);
        output_sequence= zeros(100,4);
        
    case 'CPPN'
        err_type = 'empty';
        train_fraction=0.1;    val_fraction=0.1;    test_fraction=0.1;
        wash_out = 1;
        input_sequence= zeros(100,config.CPPN_inputs);
        output_sequence= zeros(100,config.CPPN_outputs);
        
    case 'binary_nbit_adder'
        
        err_type = 'hamming';
        type = 'nbit_adder';
        bit = 3;
        datalength = 5000;
        train_fraction=0.5;    val_fraction=0.25;    test_fraction=0.25;
        config.preprocess =0;
        
        A_in = randi([0 (2^bit)-1],datalength,1);
        B_in = randi([0 (2^bit)-1],datalength,1);
        
        input = [de2bi(A_in,bit) de2bi(B_in,bit)];
        output=[];
        for i = 1:datalength
            output(i,:) = getAdderTruthTable(type,[bit,A_in(i),B_in(i)]);
        end
        
        in  = [bi2de(input(:,1:bit)) bi2de(input(:,bit+1:end))];
        out = bi2de(output);
        hist(out)
        
        % get uniform distribution
        [N,edges,bin] = histcounts(out,2^bit*2);
        cnt = 1;bin_in=[];bin_out=[];
        for i = min(bin):max(bin)
            bin_in{cnt} = input(bin == i,:);
            bin_out{cnt} = output(bin == i,:);
            cnt = cnt +1;
        end
        
        for i = 1:datalength
            ex = 1;
            while(ex)
                pos = randi([min(bin) max(bin)]);
                if ~isempty(bin_in{pos})
                    ex = 0;
                end
            end
            pos2 = randi([1 length(bin_in{pos})]);
            input_sequence(i,:) = bin_in{pos}(pos2,:);
            output_sequence(i,:) = bin_out{pos}(pos2,:);
        end
        
        in  = [bi2de(input_sequence(:,1:bit)) bi2de(input_sequence(:,bit+1:end))];
        out = bi2de(output_sequence);
        hist(out)
        %hist(in(:,2))
        %hist(in(:,1))
        
    case 'image_gaussian' % Gaussian noise task
        err_type = 'NMSE';
        wash_out = 0;
        train_fraction= 0.5;    val_fraction=0.25;    test_fraction=0.25;
        image_size = 32;
        grey = 1;
        
        % load('airplanes_800x25x25.mat');
        input_sequence = []; output_sequence =[];
        for i = 1:800
            if i > 9 && i < 100
                file_dir = strcat('airplanes\image_00',num2str(i),'.jpg');
            elseif i > 99
                file_dir = strcat('airplanes\image_0',num2str(i),'.jpg');
            else
                file_dir = strcat('airplanes\image_000',num2str(i),'.jpg');
            end
            [img1_input,img1_output] = getImage(file_dir, image_size, 'gaussian',grey);
            
            input_sequence = [input_sequence; img1_input(:)'];
            output_sequence = [output_sequence; img1_output(:)'];
        end
        
    case 'test_plot' % NARMA-5
        err_type = 'NMSE';
        wash_out =10;
        sequence_length = 300;
        train_fraction=0.25;    val_fraction=0.375;    test_fraction=0.375;
        [input_sequence,output_sequence] = generate_new_NARMA_sequence(sequence_length,5);
        input_sequence = 2*input_sequence-0.5;
        output_sequence = 2*output_sequence-0.5;
        
    case 'franke_fcn'
        err_type = 'NMSE';
        sequence_length = 1024;
        train_fraction=0.6;    val_fraction=0.2;    test_fraction=0.2;
        
        data = linspace(0,1,sqrt(sequence_length));
        [X,Y] = meshgrid(data);
        input_sequence = [X(:),Y(:)];


        for i = 1:sequence_length
            output_sequence(i) = franke2d(input_sequence(i,1),input_sequence(i,2));
        end

        t =  randperm(sequence_length);
        input_sequence = input_sequence(t,:);
        output_sequence = output_sequence(t)';
        
        scatter3(input_sequence(:,1),input_sequence(:,2),output_sequence)
end


%% preprocessing
if config.evolve_feedback_weights
   % input_sequence(input_sequence ~= 0) = (1--1)*(input_sequence(input_sequence ~= 0)-min(input_sequence(output_sequence ~= 0)))/(max(input_sequence(input_sequence ~= 0))- min(input_sequence(input_sequence ~= 0)))-1;
  %  output_sequence(output_sequence ~= 0) = (1--1)*(output_sequence(output_sequence ~= 0)-min(output_sequence(output_sequence ~= 0)))/(max(output_sequence(output_sequence ~= 0))- min(output_sequence(output_sequence ~= 0)))-1;
end

% rescale training data
[input_sequence] = featureNormailse(input_sequence,config.preprocess);

% split datasets
[train_input_sequence,val_input_sequence,test_input_sequence] = ...
    split_train_test3way(input_sequence,train_fraction,val_fraction,test_fraction);

[train_output_sequence,val_output_sequence,test_output_sequence] = ...
    split_train_test3way(output_sequence,train_fraction,val_fraction,test_fraction);

% Add extra for washout
train_input_sequence= [train_input_sequence(1:wash_out,:); train_input_sequence];
train_output_sequence= [train_output_sequence(1:wash_out,:); train_output_sequence];

if size(val_input_sequence,1) < wash_out
    wash_input_sequence = [];
    wash_output_sequence = [];
    while(size(wash_input_sequence,1) < size(val_input_sequence,1) + wash_out)
        wash_input_sequence = [val_input_sequence; wash_input_sequence];
        wash_output_sequence = [val_output_sequence; wash_output_sequence];
    end
        val_input_sequence = wash_input_sequence;
        val_output_sequence = wash_output_sequence;
else
    val_input_sequence= [val_input_sequence(1:wash_out,:); val_input_sequence];
    val_output_sequence= [val_output_sequence(1:wash_out,:); val_output_sequence];
end

if size(test_input_sequence,1)< wash_out
    wash_input_sequence = [];
    wash_output_sequence = [];
    while(size(wash_input_sequence,1) < size(test_input_sequence,1) + wash_out)
        wash_input_sequence = [test_input_sequence; wash_input_sequence];
        wash_output_sequence = [test_output_sequence; wash_output_sequence];
    end
        test_input_sequence = wash_input_sequence;
        test_output_sequence = wash_output_sequence;
else
    test_input_sequence= [test_input_sequence(1:wash_out,:); test_input_sequence];
    test_output_sequence= [test_output_sequence(1:wash_out,:); test_output_sequence];
end

% squash into structure
config.train_input_sequence = train_input_sequence;
config.train_output_sequence = train_output_sequence;
config.val_input_sequence = val_input_sequence;
config.val_output_sequence = val_output_sequence;
config.test_input_sequence = test_input_sequence;
config.test_output_sequence = test_output_sequence;

config.wash_out = wash_out;
config.err_type = err_type;

% % if multi-objective, update input/output units
if ~isfield(config,'nsga2')
    config.task_num_inputs = size(config.train_input_sequence,2);
    config.task_num_outputs = size(config.train_output_sequence,2);
end

% Go back to old seed
rng(temp_seed,'twister');
