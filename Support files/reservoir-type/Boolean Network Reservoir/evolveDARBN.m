function [individual, timeStateMatrix] = evolveDARBN(individual, varargin)

%  EVOLVEDARBN Develop network gradually K discrete time-steps according to DARBN (Deterministic
%  Asynchronous Random Boolean Network) update scheme
%
%   EVOLVEDARBN(NODE) advances all nodes in NODE one time-step in DARBN update mode.
%
%   EVOLVEDARBN(NODE, K) advances all nodes in NODE K time-steps in DARBN update mode.
%
%   EVOLVEDARBN(NODE, K, TK) advances all nodes in NODE K time-steps in DARBN update mode
%   and saves all TK steps all node-states and the timeStateMatrix to the disk.
%
%
%   Input:
%       node               - 1 x n structure-array containing node information
%       k                  - (Optional) Number of time-steps
%       tk                 - (Optional) Period for saving node-states/timeStateMatrix to disk.
%
%   Output:
%       nodeUpdated        - 1 x n sturcture-array with updated node information
%                            ("lineNumber", "state", "nextState")
%       timeStateMatrix    - n x k+1 matrix containing calculated time-state evolution



%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 20.11.2002 LastModified: 08.08.2019 (Matt Dale)


input_sequence = varargin{1};
k = size(input_sequence,1);

for i= 1:length(individual.RBN_node)
    
    nodeUpdated = resetNodeStats(individual.RBN_node{i});
    
    timeStateMatrix{i} = zeros(k,length(nodeUpdated));
    timeStateMatrix{i}(1,1:length(nodeUpdated)) = getStateVector(nodeUpdated);
    
    N = length(nodeUpdated);
    
    input = input_sequence*(individual.input_weights{i}*individual.input_scaling(i))';
    
    % time multiplex -
    input_mul = zeros(size(input_sequence,1)*individual.time_period(i),size(input,2));
    if individual.time_period > 1
        input_mul(mod(1:length(input_mul),individual.time_period(i)) == 1,:) = input;
    else
        input_mul = input;
    end
    
    % evolve network
    cnt = 1;
    for n= 1:size(input_mul,1)
        % add input to states
        if mod(n,individual.time_period(i)) == 1
            timeStateMatrix{i}(cnt,:) = getStateVector(nodeUpdated);
            cnt = cnt +1;
            state = int8(floor(heaviside(double([nodeUpdated.state]) + input_mul(n,:))));
            
            for j=1:length(nodeUpdated)
                nodeUpdated(j).state = state(j);
            end
        end
        
        nodeSelected = [];
        for j=1:N
            if(mod(n,nodeUpdated(j).p) == nodeUpdated(j).q)
                nodeSelected = [nodeSelected j];
            end
        end
        
        nodeUpdated = setLUTLines(nodeUpdated);
        nodeUpdated = setNodeNextState(nodeUpdated);
        
        for j=1:length(nodeSelected)
            nodeUpdated(nodeSelected(j)).state = nodeUpdated(nodeSelected(j)).nextState;
            nodeUpdated(nodeSelected(j)).nbUpdates = nodeUpdated(nodeSelected(j)).nbUpdates + 1;
        end       
    end
end