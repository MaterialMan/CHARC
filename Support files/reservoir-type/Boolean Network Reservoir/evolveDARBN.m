function [nodeUpdated, timeStateMatrix] = evolveDARBN(node, varargin)

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
%   CreationDate: 20.11.2002 LastModified: 30.11.2018 (Matt Dale)


%k = varargin{1};
input_loc = varargin{1};
input_sequence = varargin{2};
k = size(input_sequence,2);

nodeUpdated = resetNodeStats(node);

timeStateMatrix = zeros(length(nodeUpdated), k); %k+1
timeStateMatrix(1:length(nodeUpdated),1) = getStateVector(nodeUpdated)';

n = length(nodeUpdated);

% evolve network
for i= 2:k
    
    timeNow = i-1;
    %timeNow = i;
    nodeSelected = [];
    for j=1:n
        if(mod(timeNow,nodeUpdated(j).p) == nodeUpdated(j).q)
            nodeSelected = [nodeSelected j];
        end
    end
    
    nodeUpdated = setLUTLines(nodeUpdated);
    nodeUpdated = setNodeNextState(nodeUpdated,input_loc,input_sequence(:,i-1));
        
    for j=1:length(nodeSelected)
        
        nodeUpdated(nodeSelected(j)).state = nodeUpdated(nodeSelected(j)).nextState;
        nodeUpdated(nodeSelected(j)).nbUpdates = nodeUpdated(nodeSelected(j)).nbUpdates + 1;
    end
    
    timeStateMatrix(1:length(nodeUpdated),i) = getStateVector(nodeUpdated)';
    
end
