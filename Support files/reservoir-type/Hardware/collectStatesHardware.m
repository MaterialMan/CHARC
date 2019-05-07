
function [states,inputLoc,queue] = collectStatesHardware(evalType,switch_session, read_session, genotype, ...
    inputSequence,nForgetPoints,maxInputs,queueType,...
    weightedInputSequence,inputLoc,queue,leakOn)

temp_config = zeros(64,1);
for i = 1:32
    if genotype(i,2) == 1
        temp_config(genotype(i,1),1) = 1;
    end
end

if strcmp(evalType, 'train') && ~isempty(switch_session)
    setUp64Switch_RevoMatMk2(switch_session, temp_config);
    release(switch_session);
end

%% Create output queue for DAQ OUT
if strcmp(evalType, 'train')
    inputLoc =[];queue =[];
end

[outputData,inputLoc,queue] = createOuputQueue(inputSequence,weightedInputSequence,maxInputs,queueType,genotype,inputLoc,queue);

%% start session for DAQ
if strcmp(evalType, 'train')    
     
    %Ground and collect states
    totEval = 3;%10
    for testRep = 1:totEval
        read_session.queueOutputData([zeros(25,maxInputs);outputData; zeros(10,maxInputs)]);
        testStates(testRep,:,:) = read_session.startForeground;%startBackground;%
    end
    %remove excess data points
    state_comp = testStates(:,26+nForgetPoints:end-10,:); %was 150
    
    %avg state readings
    states = reshape(median(state_comp),size(state_comp,2),size(state_comp,3));
    %states = reshape(state_comp,size(state_comp,2),size(state_comp,3));
    
%     %temp plot
%     subplot(1,2,1)
%     plot(states)
%     drawnow
    
    %calculate state variance
    C = combnk(1:totEval,2);
    stateVar = 0;
    for j = 1:totEval
        stateVar = stateVar + compute_NRMSE(reshape(state_comp(C(j,1),:,:),size(state_comp,2),size(state_comp,3)),reshape(state_comp(C(j,2),:,:),size(state_comp,2),size(state_comp,3)));
    end
    

    for i = 1:length(temp_config)
        if temp_config(i) == 1
            states(:,i) = zeros;
        end
        % remove channels with large variance
        if stateVar(i) > 0.5%totEval%05%05
            states(:,i) = zeros;
        end
        
        % remove channels with below threshold - i.e. high impedance
        if median(states(:,i)) < -4.8 %05%05
            states(:,i) = zeros;
        end
    end
    
%     %temp plot
    %subplot(1,2,2)
    %plot(states)
%     imagesc(states)
%     colormap('gray')
%     drawnow
    
else
     read_session.queueOutputData([zeros(25,maxInputs);outputData; zeros(10,maxInputs)]);
     testStates = read_session.startForeground;%startBackground;%
     %remove excess data points
     states = testStates(26+nForgetPoints:end-10,:);
end

%add inputsequence to states
states = [states inputSequence(nForgetPoints+1:end,:)];

%apply leak rate
if leakOn
    leakStates = zeros(size(states));
    for p = 2:size(states,1)
        leakStates(p,:) = (1-genotype(1,6))*leakStates(p-1,:)+genotype(1,6)*states(p,:);
    end
    states = leakStates;
end

release(read_session);