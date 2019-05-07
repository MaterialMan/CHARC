function [nodeUpdated, timeStateMatrix] = evolveCRBN(node, varargin)

% EVOLVECRBN Develop network gradually K discrete time-steps according to CRBN (Classical
% Random Boolean Network) update scheme.
%
%   EVOLVECRBN(NODE) advances all nodes in NODE one time-step in CRBN update mode.
%   
%   EVOLVECRBN(NODE, K) advances all nodes in NODE K time-steps in CRBN update mode.
% 
%   EVOLVECRBN(NODE, K, TK) advances all nodes in NODE K time-steps in CRBN update mode
%   and saves all TK steps all node-states and the timeStateMatrix to the disk.
%
%
%   Input:
%       node               - 1 x n structure-array containing node information
%       k                  - (Optional) Number of time-steps
%       tk                 - (Optional) Period for saving node-states/timeStateMatrix to disk.
%
%
%   Output: 
%       nodeUpdated        - 1 x n sturcture-array with updated node information
%                            ("lineNumber", "state", "nextState")                           
%       timeStateMatrix    - n x k+1 matrix containing calculated time-state evolution                                        



%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 15.11.2002 LastModified: 30.11.2018 (Matt Dale)


k = varargin{1};
inputSequence = varargin{2};
genotype = varargin{3};

nodeUpdated = resetNodeStats(node);

timeStateMatrix = zeros(length(nodeUpdated), k+1);
timeStateMatrix(:,1) = getStateVector(nodeUpdated)';

% evolve network
for i=2:k
    %tic
    nodeUpdated = setLUTLines(nodeUpdated);
    nodeUpdated = setNodeNextState(nodeUpdated,genotype,inputSequence(i-1,:));
    
    for j=1:length(nodeUpdated)
        nodeUpdated(j).state = nodeUpdated(j).nextState;
        nodeUpdated(j).nbUpdates = nodeUpdated(j).nbUpdates + 1;
    end
    
    timeStateMatrix(:,i) = getStateVector(nodeUpdated)';
   %toc
end
