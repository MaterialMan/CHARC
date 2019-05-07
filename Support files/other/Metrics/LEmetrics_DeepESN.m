%% This function calculates the Largest Lyapunov Exponent of the provided reservoir.
% The calculation is done by applying a sinewave to two identical
% reservoirs with one experiencing a small perturbation. Therefore, the LE
% is representative of the difference in distance between resulting
% trajectories

function [meanLE] = LEmetrics_DeepESN(esnMajor,esnMinor,resType)

%% Assign input data and collect target output
freq = 1000;
scanFreq = 20000; %per channel
step = 1/scanFreq;
t = 0:step:1;

%amplitude
A=1; %when weights are abs, anything above one produces bad results (probably saturating)
%esn.nForgetPoints = 200;
% Define input sequence
%for i = 1:esn.nInputUnits
%n =esnMajor.nInputUnits;
inputSequence= 2*ones(1000,esnMajor.nInputUnits);%A*sin(2*pi*freq*t); %
%end
%trainInputSequence = trainInputSequence(1:500,:);

for i= 1:esnMajor.nInternalUnits
    states{i} = zeros(size(inputSequence,1),esnMinor(i).nInternalUnits);
    states2{i} = zeros(size(inputSequence,1),esnMinor(i).nInternalUnits);
    x{i} = zeros(size(inputSequence,1),esnMinor(i).nInternalUnits);
    x2{i} = zeros(size(inputSequence,1),esnMinor(i).nInternalUnits);
end
  
for i= 1:esnMajor.nInternalUnits
   yk_preNorm =[];
   
    for n = 2:length(inputSequence(:,1))        
        if n == size(inputSequence,1)/2
            pert = 10e-9;
        else
            pert = 0;
        end
        
        %collect states
        switch(resType)
            case 'RoR'
                for k= 1:esnMajor.nInternalUnits
                    x{i}(n,:) = x{i}(n,:) + (esnMajor.connectWeights{i,k}*states{k}(n-1,:)')';
                    x2{i}(n,:) = x2{i}(n,:) + (esnMajor.connectWeights{i,k}*states2{k}(n-1,:)')';
                end
                
                if i == 1
                    states{i}(n,:) = feval(char(esnMajor.reservoirActivationFunction),(((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([esnMinor(i).inputShift inputSequence(n,:)])'))+x{i}(n-1,:)');
                    states2{i}(n,:) = feval(char(esnMajor.reservoirActivationFunction),(((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([esnMinor(i).inputShift inputSequence(n,:)])')+pert)+x2{i}(n-1,:)');
                else
                    states{i}(n,:) = feval(char(esnMajor.reservoirActivationFunction),x{i}(n-1,:)');
                    states2{i}(n,:) = feval(char(esnMajor.reservoirActivationFunction),pert+x2{i}(n-1,:)');
                end
                
            case 'RoR_IA'
                for k= 1:esnMajor.nInternalUnits
                    x{i}(n,:) = x{i}(n,:) + (esnMajor.connectWeights{i,k}*states{k}(n-1,:)')';
                    x2{i}(n,:) = x2{i}(n,:) + (esnMajor.connectWeights{i,k}*states2{k}(n-1,:)')';
                end
                
                states{i}(n,:) = feval(char(esnMajor.reservoirActivationFunction),(((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([esnMinor(i).inputShift inputSequence(n,:)])'))+x{i}(n-1,:)');
                states2{i}(n,:) = feval(char(esnMajor.reservoirActivationFunction),(((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([esnMinor(i).inputShift inputSequence(n,:)])')+pert)+x2{i}(n-1,:)');
                
            case 'Ensemble'
                
                states{i}(n,:) = feval(esnMajor.reservoirActivationFunction,((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([esnMinor(i).inputShift inputSequence(n,:)])')+esnMajor.connectWeights{i,i}*states{i}(n-1,:)');
                states2{i}(n,:) = feval(esnMajor.reservoirActivationFunction,(((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([esnMinor(i).inputShift inputSequence(n,:)])')+pert)+esnMajor.connectWeights{i,i}*states2{i}(n-1,:)');

            case 'pipeline'                
                if i == 1
                    states{i}(n,:) = feval(esnMajor.reservoirActivationFunction,((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([esnMinor(i).inputShift inputSequence(n,:)])')+ esnMajor.connectWeights{i,i}*states{i}(n-1,:)');
                    states2{i}(n,:) = feval(esnMajor.reservoirActivationFunction,(((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([esnMinor(i).inputShift inputSequence(n,:)])')+pert)+ esnMajor.connectWeights{i,i}*states2{i}(n-1,:)');                    
                else
                    states{i}(n,:) = feval(esnMajor.reservoirActivationFunction,((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([esnMinor(i).inputShift states{i-1}(n,:)])')+ esnMajor.connectWeights{i,i}*states{i}(n-1,:)');
                    states2{i}(n,:) = feval(esnMajor.reservoirActivationFunction,(((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([esnMinor(i).inputShift states2{i-1}(n,:)])')+pert)+ esnMajor.connectWeights{i,i}*states2{i}(n-1,:)');
                end
                
            case 'pipeline_IA'
                if i == 1
                    states{i}(n,:) = feval(esnMajor.reservoirActivationFunction,((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([esnMinor(i).inputShift inputSequence(n,:)])')+ esnMajor.connectWeights{i,i}*states{i}(n-1,:)');
                    states2{i}(n,:) = feval(esnMajor.reservoirActivationFunction,(((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([esnMinor(i).inputShift inputSequence(n,:)])')+pert)+ esnMajor.connectWeights{i,i}*states2{i}(n-1,:)');
                else
                    states{i}(n,:) = feval(esnMajor.reservoirActivationFunction,((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([inputSequence(n,:) states{i-1}(n,:)])')+ esnMajor.connectWeights{i,i}*states{i}(n-1,:)');
                    states2{i}(n,:) = feval(esnMajor.reservoirActivationFunction,(((esnMinor(i).inputWeights*esnMinor(i).inputScaling)*([inputSequence(n,:) states2{i-1}(n,:)])')+pert)+ esnMajor.connectWeights{i,i}*states2{i}(n-1,:)');
                end
        end
                
        yk_preNorm(n,:) = states{i}(n,:)-states2{i}(n,:);
        yk(i,n) = norm(yk_preNorm(n,:));
        
        if n >= size(inputSequence,1)/2%esn.nForgetPoints*2
            states2{i}(n,:) = states2{i}(n,:) + (10e-9/yk(i,n))*(states2{i}(n,:)-states{i}(n,:));
        end
        
    end
    lambda =  log(yk(i,:)/10e-9); %*(1/i)
    
    %safety check
    if isnan(lambda(end))
        lambda_n(i) = 0;%lambda_n(node-1);
    else
        lambda_n(i) = lambda(end);
    end
end

%Final LE
%meanLE = mean(lambda_n);
meanLE = lambda_n;

