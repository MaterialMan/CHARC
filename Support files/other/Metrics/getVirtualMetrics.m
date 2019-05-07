% Separation Metrics and Kernel Quality
function metrics = getVirtualMetrics(genotype,config)

scurr = rng;
temp_seed = scurr.Seed;
metrics = [];

for metric_item = 1:length(config.metrics)
    switch config.metrics{metric_item}
        case 'KR'
            rng(1,'twister');
            numTimesteps = 3300;
            
            %Remove input sequence and reduce forget points
            config.nForgetPoints = 100;
            
            % Expanded version - more reliable, Norton & Ventura: "Improving liquid state machines......"
            N = genotype.nInputUnits;
            
            bestDist =0;
            for i = 1:1000 %search for biggest separation
                ui = round(20*rand(numTimesteps,N)-10)/10;
                %dist = sum(sum(abs(ui-repmat((sum(ui,2)/N),1,N))));
                dist = std(ui);
                if dist > bestDist
                    bestDist = dist;
                    bestUi = ui;
                end
            end
            
            ui = bestUi;
            
            inputSequence = repmat(ui(:,1),1,N);
            
            %kernel matrix - pick 'to' at halfway point
            M = config.assessFcn(genotype,inputSequence,config);
            
            %catch errors
            M(isnan(M)) = 0;
            M(isinf(M)) = 0;
            
            %% Kernal Quality
            s = svd(M);
            
            tmp_rank_sum = 0;
            full_rank_sum = 0;
            e_rank = 1;
            for i = 1:length(s)
                full_rank_sum = full_rank_sum + s(i);
                while (tmp_rank_sum < full_rank_sum * 0.99)
                    tmp_rank_sum = tmp_rank_sum + s(e_rank);
                    e_rank= e_rank+1;
                end
            end
            kernel_rank = e_rank-1;
            
            %kernel_rank = kernel_rank/size(M,2);
            
            metrics = [metrics kernel_rank];%*100];
            
            %% Genralization Rank
        case 'GR'
            rng(1,'twister');
            ui_1 = round(10*rand)/10;
            ui = repmat(ui_1,1,numTimesteps)'+(1*rand(numTimesteps,1)-0.5)/10;
            ui(1) = ui_1;
            %inputSequence = ui;
            inputSequence =repmat(ui,1,N);
            
            %collect states
            G = config.assessFcn(genotype,inputSequence,config);
            
            %catch errors
            G(isnan(G)) = 0;
            G(isinf(G)) = 0;
            
            % get rank of matrix
            s = svd(G);
            
            %claculate effective rank
            tmp_rank_sum = 0;
            full_rank_sum = 0;
            e_rank = 1;
            for i = 1:length(s)
                full_rank_sum = full_rank_sum +s(i);
                while (tmp_rank_sum < full_rank_sum * 0.99)
                    tmp_rank_sum = tmp_rank_sum + s(e_rank);
                    e_rank= e_rank+1;
                end
            end
            gen_rank = e_rank-1;
            
            %gen_rank = gen_rank/size(M,2);
            %metrics = [metrics gen_rank*100];
            
            metrics = [metrics gen_rank];
                
            %% LE measure
        case 'LE'
            rng(1,'twister');
            meanLE = LEmetrics_DeepESN(genotype,config);
            metrics = [metrics meanLE];
            
            %% Entropy measure
        case 'Entropy'
            rng(1,'twister');
            inputSequence = ones(1000,1);
            
            X = config.assessFcn(genotype,inputSequence,config);
            C = X'*X;
            
            X_eig = eig(C);
            
            normX_eig = X_eig./sum(X_eig);
            
            H = -sum(normX_eig.*log2(normX_eig));
            
            entropy = real(H/log2(size(X,2)));
            
            entropy(isnan(entropy)) = 0;
            metrics = [metrics entropy*100];
            
        case 'MC'
            %Remove input sequence and reduce forget points
            config.nForgetPoints = 200;
            
            nInternalUnits = genotype.nTotalUnits;%sum([genotype.nInternalUnits]);
            
            nOutputUnits = nInternalUnits*2;
            nInputUnits = genotype.nInputUnits;
            
            %% Assign input data and collect target output
            dataLength = 6000;
            if strcmp(config.resType,'basicCA') || strcmp(config.resType,'2dCA') || strcmp(config.resType,'RBN')
                dataSequence = round(rand(1,dataLength+1++nOutputUnits));% Deep-ESN version: 1.6*rand(1,dataLength+1++nOutputUnits)-0.8;
            else
                dataSequence = rand(1,dataLength+1++nOutputUnits);% Deep-ESN version: 1.6*rand(1,dataLength+1++nOutputUnits)-0.8;
            end
            sequenceLength = 5000;
            
            memInputSequence = dataSequence(nOutputUnits+1:dataLength+nOutputUnits)';
            
            for i = 1:nOutputUnits
                memOutputSequence(:,i) = dataSequence(nOutputUnits+1-i:dataLength+nOutputUnits-i);
            end
            
            trainInputSequence = repmat(memInputSequence(1:sequenceLength,:),1,nInputUnits);%repmat(memInputSequence(1:sequenceLength/2,:),1,maxInputs);
            testInputSequence = repmat(memInputSequence(1+sequenceLength:end,:),1,nInputUnits);%repmat(memInputSequence,1,maxInputs);
            
            trainOutputSequence = memOutputSequence(1:sequenceLength,:);%repmat(memInputSequence,1,maxInputs);
            testOutputSequence = memOutputSequence(1+sequenceLength:end,:);%repmat(memInputSequence,1,maxInputs);
            
            states = config.assessFcn(genotype,trainInputSequence,config);
            
            %train
            outputWeights = trainOutputSequence(config.nForgetPoints+1:end,:)'*states*inv(states'*states + config.regParam*eye(size(states'*states)));
            Yt = round(states * outputWeights');
            
            %test
            testStates =  config.assessFcn(genotype,testInputSequence,config);
            
            Y = round(testStates * outputWeights');
            
            MC= 0; Cm = 0;
            for i = 1:nOutputUnits
                coVar = cov(testOutputSequence(config.nForgetPoints+1:end,i),Y(:,i)).^2;
                outVar = var(Y(:,i));
                targVar = var(testInputSequence(config.nForgetPoints+1:end,:));
                totVar = (outVar*targVar(1)');
                C = coVar(1,2)/totVar;
                MC = MC + C;
                R = corrcoef(testOutputSequence(config.nForgetPoints+1:end,i),Y(:,i));
                Cm = Cm + R(1,2).^2;
            end
            
            %remove errors
            if isnan(MC) || MC < 0
                MC = 0;
            end
            
            metrics = [metrics MC];
    end
end

rng(temp_seed,'twister');