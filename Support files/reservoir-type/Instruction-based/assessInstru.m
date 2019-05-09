
function states = assessInstru(genotype,inputSequence,config)

% instantiate variables
for i= 1:genotype.nInternalUnits
    states{i} = zeros(size(inputSequence,1),genotype.nTotalUnits);
    x{i} = zeros(size(inputSequence,1),genotype.nTotalUnits);
end

% compute pipleine instruction set or time-varying
if genotype.multiResInstru
    
    for n = 2:length(inputSequence(:,1))
        
        %equation: x(n) = f(Win*u(n) + S)
        for i= 1:genotype.nInternalUnits % this counter cycles through heirarchical reservoirs, is one when using single reservoir
            
            current_res = config.database_genotype(genotype.instrSeq(i));            
            
            % pipeline
            if i == 1
                states{i}(n,:) = feval(current_res.reservoirActivationFunction,((current_res.esnMinor.inputWeights*current_res.esnMinor(i).inputScaling)*([current_res.esnMinor(i).inputShift inputSequence(n,:)])')+ current_res.connectWeights{1,1}*states{i}(n-1,:)');
            else
                states{i}(n,:) = feval(current_res.reservoirActivationFunction,((genotype.res(i).inputWeights*current_res.esnMinor(1).inputScaling)*([inputSequence(n,:) states{i-1}(n,:)])')+ current_res.connectWeights{1,1}*states{i}(n-1,:)');
            end
            
        end
    end
    
else
    % set counters
    instruDurationCnt = 1;
    instrNum = 1;
    
    %equation: x(n) = f(Win*u(n) + S)
    for i= 1:genotype.nInternalUnits % this counter cycles through heirarchical reservoirs, is one when using single reservoir
        
        for n = 2:length(inputSequence(:,1))
            
            % defines rotation between instructions after some duration given
            % by a gene
            if instruDurationCnt < genotype.configDuration(instrNum)
                % select instruction to use
                current_res = config.database_genotype(genotype.instrSeq(instrNum));
                % add to the durration it has been running
                instruDurationCnt = instruDurationCnt+1;
            else
                
                %normalise previous states
                if n-instruDurationCnt == 1
                    %states{i}(2:n-1,:) = normalize(states{i}(2:n-1,:),2);
                    %states{i}(2:n,:) = rescale(states{i}(2:n,:));
                else
                    %states{i}(n-instruDurationCnt:n-1,:) = normalize(states{i}(n-instruDurationCnt:n-1,:),2);
                    %states{i}(n-instruDurationCnt:n,:) = rescale(states{i}(n-instruDurationCnt:n,:));
                end
                % reset the duration counter
                instruDurationCnt = 1;
                
                if instrNum == length(genotype.instrSeq)
                    % cycle to first instruction
                    instrNum = 1;
                else
                    % move to next instruction
                    instrNum = instrNum+1;
                end
            end
            
            % collect all connecting reservoir states -- not used if using
            % single reservoir
            for k= 1:current_res.nInternalUnits
                x{i}(n,:) = x{i}(n,:) + (current_res.connectWeights{i,k}*states{k}(n-1,:)')';
            end
            
            % get states of all nodes at time n
            states{i}(n,:) = feval(current_res.reservoirActivationFunction,((current_res.esnMinor(i).inputWeights*current_res.esnMinor(i).inputScaling)*([current_res.esnMinor(i).inputShift inputSequence(n,:)])')+x{i}(n,:)');
            
        end
    end
    
    % last rescale
    %states{i}(n-instruDurationCnt:n,:) = rescale(states{i}(n-instruDurationCnt:n,:));
    %states{i}(n-instruDurationCnt:n-1,:) = normalize(states{i}(n-instruDurationCnt:n-1,:));
    
end


% concat all states together
statesExt =[];
for i= 1:genotype.nInternalUnits
    statesExt = [statesExt states{i}];
end
states = statesExt;

% plot(states)
% drawnow

% add leak states
if config.leakOn
    states = getLeakStates(states,genotype,config);
end

% assign reduced output states
if config.evolvedOutputStates
    states= states(config.nForgetPoints+1:end,logical(genotype.state_loc));
else
    states= states(config.nForgetPoints+1:end,:);
end

% add input to state matrix
if config.AddInputStates
    states = [ones(size(inputSequence(config.nForgetPoints+1:end,1))) inputSequence(config.nForgetPoints+1:end,:) states];
else
    states = [ones(size(inputSequence(config.nForgetPoints+1:end,1))) states];
end
