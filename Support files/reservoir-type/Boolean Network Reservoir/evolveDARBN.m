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


k = varargin{1};
inputSequence = varargin{2};
genotype = varargin{3};

nodeUpdated = resetNodeStats(node);

timeStateMatrix = zeros(length(nodeUpdated), k+1);
timeStateMatrix(1:length(nodeUpdated),1) = getStateVector(nodeUpdated)';

n = length(nodeUpdated);

% evolve network
for i=2:k+1
    
    timeNow = i-1;
    nodeSelected = [];
    for j=1:n
        if(mod(timeNow,nodeUpdated(j).p) == nodeUpdated(j).q)
            nodeSelected = [nodeSelected j];
        end
    end
    
    for j=1:length(nodeSelected)
        nodeUpdated = setLUTLines(nodeUpdated);
        nodeUpdated = setNodeNextState(nodeUpdated,genotype,inputSequence(i-1,:));
        
        nodeUpdated(nodeSelected(j)).state = nodeUpdated(nodeSelected(j)).nextState;
        nodeUpdated(nodeSelected(j)).nbUpdates = nodeUpdated(nodeSelected(j)).nbUpdates + 1;
    end
    
    timeStateMatrix(1:length(nodeUpdated),i) = getStateVector(nodeUpdated)';
    
end
