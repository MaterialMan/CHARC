%% K-fold xValidation with variable window gap
% Type 1 = typical Xvalidation, making K training and test sets
% Type 0 = Randomise data in windowSize groups

function [trainInputSequence,trainOutputSequence,valInputSequence,valOutputSequence,...
    testInputSequence,testOutputSequence]= KFoldXValidation(inputSequence,outputSequence,kfolds,windowSize,type,train_fraction,val_fraction,test_fraction,xvalType)

%set default distribution
if (nargin<7)
    train_fraction = 0.33333334;
    val_fraction = 0.33333334;
    test_fraction = 0.3333333;
    xvalType = 'Kfold';
else
    %val and test are switched later so ratios need to be swapped   
%     tmpFrac = val_fraction;
%     val_fraction = test_fraction;
%     test_fraction = tmpFrac;
end

switch(type)
    
    case 'standard'       
        %Divide into different partitions
        [trainInputSequence,valInputSequence,testInputSequence] = ...
            split_train_test3way(inputSequence,train_fraction,val_fraction,test_fraction);
        [trainOutputSequence,valOutputSequence,testOutputSequence] = ...
            split_train_test3way(outputSequence,train_fraction,val_fraction,test_fraction);
        
    case 'WindowedKfold'
        testInputSequence = inputSequence(end-windowSize+1:end,:);
        testOutputSequence = outputSequence(end-windowSize+1:end,:);
        inputSequence = inputSequence(1:end-windowSize,:);
        outputSequence = outputSequence(1:end-windowSize,:);
        
        for n = 1:kfolds-1
            tempInputSequence = inputSequence;
            tempOutputSequence = outputSequence;
            
            tempInputSequence((n-1)*windowSize+1:n*windowSize,:) = [];
            tempOutputSequence((n-1)*windowSize+1:n*windowSize,:) = [];
            
            trainInputSequence(n,:,:)= tempInputSequence;
            trainOutputSequence(n,:,:)= tempOutputSequence;
            
            valInputSequence(n,:,:) = inputSequence((n-1)*windowSize+1:n*windowSize,:);
            valOutputSequence(n,:,:) = outputSequence((n-1)*windowSize+1:n*windowSize,:);
            
        end
        
    case 'xvalMatlab' %not finished
        
        %get indices
        if strcmp(xvalType, 'Kfold')
            indices = crossvalind(xvalType,inputSequence(:,1),kfolds);
            
            [len,wid]=size(inputSequence);
             inputSequence_temp = zeros(kfolds,len,wid);
             [n, ~] = histcounts(indices);
             
            % for p = 1:kfolds
             %for i = 1:n(p)
            for j = 1:length(indices)
                %for i = 1:kfolds
                inputSequence_temp(indices(j),j,:) = inputSequence(j,:);
                
                %outputSequence_temp(train(j),:,:) = [outputSequence(j,:)];
                %end
            end
            inputSequence_temp(1,~any(inputSequence_temp,3),:) =[];
            inputSequence( ~any(inputSequence,2),:)=[];
             %end
             %end
            
            
        else
            [train, test] = crossvalind(xvalType,inputSequence(:,1),kfolds);
        end

    case 'NISTXval'
        
        %kfolds =5;
        for i = 1:size(inputSequence,1)/windowSize           
              splitInput(i,:,:) = inputSequence((windowSize*(i-1))+1:windowSize*i,:);
              splitOutput(i,:,:) = outputSequence((windowSize*(i-1))+1:windowSize*i,:);              
        end
        
        indx = crossvalind('Kfold',size(splitInput,1),kfolds);
        
        tempInputSequence = zeros(kfolds,size(splitInput,1)/kfolds*windowSize,77);
        tempOutputSequence = zeros(kfolds,size(splitInput,1)/kfolds*windowSize,10);

        %[~,G]= sort(indx);
        
        cnt1=0;cnt2 =0; cnt3=0;cnt4 =0; cnt5=0;
        for i = 1:length(indx)
            %st = count+1;
            %ed = count+windowSize;
            %indx(G(i))
            switch(indx(i))
                case 1
                    st = cnt1+1;
                    cnt1 = cnt1+windowSize;                    
                    ed = cnt1;
                case 2
                    st = cnt2+1;
                    cnt2 = cnt2+windowSize;
                    ed = cnt2;
                case 3
                    st = cnt3+1;
                    cnt3 = cnt3+windowSize;
                    ed = cnt3;
                case 4
                    st = cnt4+1;
                    cnt4 = cnt4+windowSize;
                    ed = cnt4;
                case 5
                    st = cnt5+1;
                    cnt5 = cnt5+windowSize;
                    ed = cnt5;
            end
            
            tempInputSequence(indx(i),st:ed,:)= reshape(splitInput(i,:,:),windowSize,77);
            tempOutputSequence(indx(i),st:ed,:)= reshape(splitOutput(i,:,:),windowSize,10);
                       
        end
        
        C = combnk(1:5,4);
        V = [5 4 3 2 1];
        
        %split into sets
        for n = 1:kfolds
            trainInputSequence(n,:,:) = reshape(tempInputSequence(C(n,:),:,:),size(tempInputSequence,2)*(kfolds-1),77);
            trainOutputSequence(n,:,:) = reshape(tempOutputSequence(C(n,:),:,:),size(tempInputSequence,2)*(kfolds-1),10);
            valInputSequence(n,:,:) = tempInputSequence(V(n),:,:);
            valOutputSequence(n,:,:) = tempOutputSequence(V(n),:,:);
            testInputSequence(n,:,:) = tempInputSequence(V(n),:,:);
            testOutputSequence(n,:,:) = tempOutputSequence(V(n),:,:);
        end
        
    case 'MNIST'
        seqLength = 60000;
        trainInputSequence = inputSequence(1:seqLength,:);
        trainOutputSequence = outputSequence(1:seqLength,:);
        valInputSequence = inputSequence(seqLength+1:end,:);
        valOutputSequence = outputSequence(seqLength+1:end,:);
        testInputSequence = inputSequence(seqLength+1:end,:);
        testOutputSequence = outputSequence(seqLength+1:end,:);
        
    case 'Randperm' 
        target=randperm(kfolds);
        temp_inputSequence = inputSequence(target,:);
        temp_outputSequence = outputSequence(target,:);
        
        inputSequence = temp_inputSequence;
        outputSequence = temp_outputSequence;
        
        %Divide into different partitions
        [trainInputSequence,valInputSequence,testInputSequence] = ...
            split_train_test3way(inputSequence,train_fraction,val_fraction,test_fraction);
        [trainOutputSequence,valOutputSequence,testOutputSequence] = ...
            split_train_test3way(outputSequence,train_fraction,val_fraction,test_fraction);
        
    case 'xval'
        
        seqLength = floor(size(inputSequence,1)/kfolds);
              
        for i = 1:kfolds
            temp_inputSequence(i,:,:) = inputSequence((seqLength*(i-1))+1:seqLength*i,:);
            temp_outputSequence(i,:,:) = outputSequence((seqLength*(i-1))+1:seqLength*i,:);
        end
        
        for i = 1:kfolds
            set = 1:kfolds;
        end
        testSet = randi([1 kfolds]);
        
        set(testSet) = [];
        testInputSequence = reshape(temp_inputSequence(testSet,:,:),size(temp_inputSequence,2),size(temp_inputSequence,3));
        testOutputSequence = reshape(temp_outputSequence(testSet,:,:),size(temp_outputSequence,2),size(temp_outputSequence,3));
        valInputSequence = testInputSequence;
        valOutputSequence = testOutputSequence;
        
        trainInputSequence = temp_inputSequence(set,:,:);
        trainOutputSequence = temp_outputSequence(set,:,:);
        
    otherwise
        
        target=randperm(kfolds);
        [~, widIn] = size(inputSequence);
        [~, widOut] = size(outputSequence);
        
        %break into window sizes
        newInput = zeros(kfolds,windowSize,widIn);
        newOutput = zeros(kfolds,windowSize,widOut);
        for i = 1:kfolds
            newInput(i,:,:) =inputSequence((i-1)*windowSize+1:i*windowSize,:);
            newOutput(i,:,:) =outputSequence((i-1)*windowSize+1:i*windowSize,:);
        end
        
        %merge back to normal dataset length in random order
        
        newInputSequence = reshape(newInput(target(1),:,:),windowSize,widIn);
        newOutputSequence = reshape(newOutput(target(1),:,:),windowSize,widOut);
        for n = 2:kfolds
            newInputSequence = [newInputSequence; reshape(newInput(target(n),:,:),windowSize,widIn)];
            newOutputSequence = [newOutputSequence; reshape(newOutput(target(n),:,:),windowSize,widOut)];
        end
        
        
        %Divide into different partitions
        [trainInputSequence,valInputSequence,testInputSequence ] = ...
            split_train_test3way(newInputSequence,train_fraction,val_fraction,test_fraction);
        [trainOutputSequence,valOutputSequence,testOutputSequence ] = ...
            split_train_test3way(newOutputSequence,train_fraction,val_fraction,test_fraction);
        
        %     trainInputSequence = [NewInputSequence(target(1),:) NewInputSequence(target(2),:) NewInputSequence(target(3),:)]';
        %     trainOutputSequence = [NewOutputSequence(target(1),:) NewOutputSequence(target(2),:) NewOutputSequence(target(3),:)]';
        %
        %     valInputSequence = [NewInputSequence(target(4),:) NewInputSequence(target(5),:)]';
        %     valOutputSequence = [NewOutputSequence(target(4),:) NewOutputSequence(target(5),:)]';
        %
        %     testInputSequence = inputSequence(end-windowSize+1:end)';
        %     testOutputSequence = outputSequence(end-windowSize+1:end)';
end

%re-order to break time dependencies
% tmpIn = valInputSequence;
% tmpOut = valOutputSequence;
% valInputSequence = testInputSequence;
% valOutputSequence = testOutputSequence;
% testInputSequence = tmpIn;
% testOutputSequence = tmpOut;
