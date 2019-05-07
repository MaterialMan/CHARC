function [err] = calculateError(systemOutput,desiredOutput,config)

if size(systemOutput,1) == size(desiredOutput,1)
    config.nForgetPoints = 0;
elseif size(systemOutput,1) > size(desiredOutput,1)
    systemOutput = systemOutput(config.nForgetPoints+1:end,:);
else
    desiredOutput = desiredOutput(config.nForgetPoints+1:end,:);
end

if config.discrete
    desiredOutput = binaryVector2doubleOutput(desiredOutput,config.q,config.nbits);
    systemOutput = binaryVector2doubleOutput(round((1+systemOutput)/2),config.q,config.nbits);
end

%round((1+systemOutput)/2)

% final measured error type
switch(config.errType)
    
    case 'mae'
        err = desiredOutput-systemOutput;
        
        % Then take the "absolute" value of the "error".
        absoluteErr = abs(err);
        
        % Finally take the "mean" of the "absoluteErr".
        err = mean(absoluteErr);
        
    case 'mase'
        err = (desiredOutput-systemOutput);
        
        % Then take the "absolute" value of the "error".
        absoluteErr = abs(err).*abs(desiredOutput);
        
        % Finally take the "mean" of the "absoluteErr".
        err = mean(absoluteErr);
        
        
    case 'rmse'
        err = sqrt(mean((desiredOutput-systemOutput).^2));
        
    case 'crossEntropy'
        [~,p] = max(systemOutput,[],2);
        tp = zeros(size(systemOutput));
        for i = 1:length(tp)
            tp(i,p(i)) =1;
        end
        %err = -(sum(desiredOutput*log(systemOutput)'+(1-desiredOutput)*log(1-systemOutput)')/size(desiredOutput,1));
        err = (sum(diag(-desiredOutput'*log(systemOutput))-diag((1-desiredOutput')*log(1-systemOutput)))/size(desiredOutput,1));
    
    case 'NRMSE'
        err= sqrt((sum((desiredOutput-systemOutput).^2)/(var(desiredOutput)))*(1/length(desiredOutput)));
        %err = compute_NRMSE(systemOutput,desiredOutput);
        %err = goodnessOfFit(systemOutput,desiredOutput,type);
    case 'NRMSE_henon'
        err = sqrt(mean((systemOutput-desiredOutput).^2))/(max(max(desiredOutput))-min(min(desiredOutput))); %Rodan paper
        
    case 'NMSE'
        err= mean((desiredOutput-systemOutput).^2)/var(desiredOutput);
        
    case 'NMSE_mem'
        err = compute_NRMSE(systemOutput,desiredOutput).^2;
        %err = mean((systemOutput-desiredOutput(nForgetPoints+1:end,:)).^2/var(systemOutput));
        %err =((systemOutput-desiredOutput(nForgetPoints+1:end,:)).^2)'/var(systemOutput')/size(systemOutput,2);
    case 'MSE'
        %err = immse(systemOutput,desiredOutput);
        err = mean((desiredOutput-systemOutput).^2);
        
    case 'SER'
        preDefined = [-3 -1 1 3];
        for i=1:length(systemOutput)
            [Y,I] = min(abs(systemOutput(i)-preDefined));
            new_systemOutput(i,1) =preDefined(I);
        end
        [~,err] = symerr(new_systemOutput,desiredOutput);
        
    case 'confusion'
        for i = 1:length(systemOutput)
            [~,I] = max(systemOutput(i,:));
            systemOutput(i,:) =zeros;
            systemOutput(i,I) =1;
        end
        [err,cm,ind,per] = confusion(systemOutput',desiredOutput');
        
        
        %figure
        %plotconfusion(desiredOutput',systemOutput')
        
    case 'MNISTshort'
        fin = 0;
        start = 0;
        for i=1:1000
            start = fin +1;
            fin = start-1+28;
            if fin > length(systemOutput)
            else
                systemOutput(start:fin,:)= repmat(median(systemOutput(start+10:fin-10,:))',[1 28])';
            end
        end
        
        % Winner-takes-all, but show confidence in other values
        temp_systemOutput =zeros(length(systemOutput),10);
        for i = 1:length(systemOutput)
            [~,I] = max(systemOutput(i,:));
            %temp_systemOutput(i,:) =zeros;
            temp_systemOutput(i,I) =1;
        end
        desiredOutput =desiredOutput(nForgetPoints+1:end,:);
        [err,cm,ind,per] = confusion(temp_systemOutput',desiredOutput');
        
    case 'MultiObjective'
        
    case 'OneVsAll__medianValue'
        
        [~,p] = max(systemOutput,[],2);
        
        for i = 1:size(desiredOutput,1)
            temp_Output(i,:) = find(desiredOutput(i,:));
        end
        
        %find where the sequence finishes then avg everything before
        temp_p =zeros(length(temp_Output),1);
        cnt = 2;
        changeList(1) =1;
        for chn = 2:length(temp_Output)
            if temp_Output(chn) ~= temp_Output(chn-1)
                changeList(cnt) = chn;
                temp_p(changeList(cnt-1):changeList(cnt),1) = mode(p(changeList(cnt-1):changeList(cnt)));
                cnt = cnt +1;
            end
            if chn == length(temp_Output)
                temp_p(changeList(cnt-1):end,1) = mode(p(changeList(cnt-1):end));
            end
        end
        err = 1 - mean(double(mod(temp_p, 10) == mod(temp_Output, 10)));
        %err = 1 - mean(double(mod(p, 10) == mod(temp_Output, 10)));
        
    case 'OneVsAll'
        
        [~,p] = max(systemOutput,[],2);
        
        for i = 1:size(desiredOutput,1)
            temp_Output(i,:) = find(desiredOutput(i,:));
        end
        
        err = 1 - mean(double(mod(p, 10) == mod(temp_Output, 10)));
        
        %err = confusion(mod(p, 10),mod(temp_Output, 10))
        
    case 'OneVsAll_jap' %abandoned
        
        if length(systemOutput) > 4200 %test set
            blocks = [30,30,30,30,30,30,30,30,30];
            blocks = [31,35,88,44,29,24,40,50,29];
        else %train set
            
        end
        
        [~,p] = max(systemOutput,[],2);
        
        for i = 1:size(desiredOutput,1)
            temp_Output(i,:) = find(desiredOutput(i,:));
        end
        
        err = 1 - mean(double(mod(p, 10) == mod(temp_Output, 10)));
        
        
    case 'OneVsAll_NIST'
        
        setSize = 150;
        temp_Output = zeros(size(desiredOutput,1),1);
        
        [~,p] = max(systemOutput,[],2);
        q=p;
        
        
        for i = 1:size(p,1)/setSize
            q(((i-1)*setSize)+1:i*setSize) = mode(p(((i-1)*setSize)+1:i*setSize));
        end
        
        for i = 1:size(desiredOutput,1)
            temp_Output(i,:) = find(desiredOutput(i,:)==1);
        end
        %temp_Output = temp_Output(setSize+1:end,:);
        
        err = 1 - mean(double(mod(q, 10) == mod(temp_Output, 10)));
        
    case 'simplClass'
        mod(pred, 10)
        
        fprintf('\nNeural Network Prediction: %d (digit %d)\n', systemOutput, mod(systemOutput, 10));
    case 'WER'
        % seq = [49,42,49,59,57,64,71,59,50,62,58,41,40,55,51,56,79,83,64,87,77,54,55,74,64,82,93,84,70,83,67,52,45,68,78,79,80,95,72,81,63,56,52,72,71,67,86,83,82,85];
        
        % Winner-takes-all, but show confidence in other values
        %         temp_systemOutput =zeros(length(systemOutput),10)-1;
        temp2_systemOutput =zeros(size(systemOutput,1),10)-1;
        %         for i = 1:length(systemOutput)
        %             [~,I] = max(systemOutput(i,:));
        %             %temp_systemOutput(i,:) =zeros;
        %             temp_systemOutput(i,I) =1;
        %         end
        
        tp = desiredOutput(nForgetPoints+1:end,:);
        M = (size(systemOutput,1))/100;
        numEnd = 0;
        for i = 1:M
            %for j = 1:seq(i)
            numst = numEnd+1;
            numEnd = i*100;
            m(i,:)  = mean(systemOutput(numst:numEnd,:));
            [~,I] = max(m(i,:));
            temp2_systemOutput(numst:numEnd,I) = 1;
            %temp2_systemOutput
            n(i,:)  = mean(tp(numst:numEnd,:));
            [~,P] = max(n(i,:));
            list(i,:) = [I P];
            %end
        end
        
        [~,err] =  symerr(list(:,1),list(:,2));%symerr(temp2_systemOutput,desiredOutput(nForgetPoints+1:end,:));
        
    case 'IPIX'
        err = [];
        %err = mean((desiredOutput-systemOutput).^2)/var(desiredOutput);
        cnt = 0;
        for i=1:size(desiredOutput,2)/2
            err(i) = mean((desiredOutput(:,i+cnt:i+cnt+1)-systemOutput(:,i+cnt:i+cnt+1)).^2)/var(desiredOutput(:,i+cnt:i+cnt+1));
            cnt = cnt +1;
            %temp_err(i) =
            %mean(norm(systemOutput(:,i)-desiredOutput(:,i)).^2)/(mean(norm(desiredOutput(:,i)-mean(desiredOutput(:,i))).^2));
            %%rodan version
        end
        %temp_err = compute_NRMSE(systemOutput,desiredOutput).^2;% sum((systemOutput-desiredOutput).^2)/length(systemOutput);
        %         if length(temp_err) == 1
        %             err = ones(1,10);
        %         else
        
        
        %         if length(temp_err) > 2
        %             cnt = 0;
        %             for j = 1:10
        %                 %err(j) = (temp_err(j+cnt) + temp_err(j+cnt+1));
        %                 err(j) = mean([temp_err(j+cnt) temp_err(j+cnt+1)]);
        %                 cnt = cnt +1;
        %             end
        %         else
        %             %err=sum(temp_err);
        %             err=mean(temp_err);
        %         end
        
    case 'hamming'
        
        systemOutput = round(systemOutput);
        D = pdist2(systemOutput,desiredOutput,'hamming');
        err = sum(diag(D))/length(systemOutput);
        
    case 'softmax'
        
        a = [];
        for i = 1:length(systemOutput)
            a(i,:) = exp(systemOutput(i,:))/sum(exp(systemOutput(i,:)));
        end
        [~,predict] = max(a,[],2);
        
        [~,targ] = max(desiredOutput,[],2);
        
        err = 1- F1Score(targ,predict);
        
    case 'IJCNNpaper'
        
        for p = 1:20
            temp_pred = [];
            
            threshold(p) = 1/20*p;
            for j = 1:length(systemOutput)
                for k = 1:size(systemOutput,2)
                    if systemOutput(j,k) > threshold(p)
                        temp_pred(j,k) = 1;
                    else
                        temp_pred(j,k) = 0;
                    end
                end
            end
            
            % %%%%%%% measure wrongly classified %%%%%%%%%%%%%%
            FP= 0; FN= 0; TP= 0; TN= 0;
            num_wrong = 0;
            class_wrong = 0;
            for j = 1:length(systemOutput) %offset initial transient
                cnt=0;
                for k = 1:size(systemOutput,2)
                    if temp_pred(j,k) ~= sign(desiredOutput(j,k))
                        if temp_pred(j,k) ~= 1
                            FN = FN+1;
                        else
                            FP = FP+1;
                        end
                        num_wrong = num_wrong + 1;
                        cnt = cnt+1;
                    else
                        if temp_pred(j,k) ~= 1
                            TN = TN+1;
                        else
                            TP = TP+1;
                        end
                    end
                end
                
                if cnt>0
                    class_wrong = class_wrong+1;
                end
            end
            
            err(p) = 1 - ((TP*TN)/((TP+FP)*(TN+FN)));            
                
        end
        
        err = min(err);
        
        
    otherwise
        err = compute_NRMSE(systemOutput,desiredOutput);
end
