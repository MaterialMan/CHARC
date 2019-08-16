function [nodeUpdated, timeStateMatrix] = evolveARBN(node, varargin)

% EVOLVEARBN Develop network gradually K discrete time-steps according to ARBN (Asynchronous
% Random Boolean Network) update scheme.
%
%   EVOLVEARBN(NODE) advances all nodes in NODE one time-step in ARBN update mode.
%   
%   EVOLVEARBN(NODE, K) advances all nodes in NODE K time-steps in ARBN update mode.
%
%   EVOLVEARBN(NODE, K, TK) advances all nodes in NODE K time-steps in ARBN update mode
%   and saves all TK steps all node-states and the timeStateMatrix to the disk.
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
%   CreationDate: 20.11.2002 LastModified: 30.11.2018 (Matt Dale)

input_sequence = varargin{1};
k = size(input_sequence,1);

nodeUpdated = resetNodeStats(node);
timeStateMatrix = zeros(length(nodeUpdated), k);
timeStateMatrix(1:length(nodeUpdated),1) = getStateVector(nodeUpdated)';

n = length(nodeUpdated);

% evolve network
for i=1:k
    
    nodeSelected = randi([1 n],1,1);        %pick node at random    
    
    nodeUpdated = setLUTLines(nodeUpdated);
    nodeUpdated = setNodeNextState(nodeUpdated);
    
    nodeUpdated(nodeSelected).state = nodeUpdated(nodeSelected).nextState;
    nodeUpdated(nodeSelected).nbUpdates = nodeUpdated(nodeSelected).nbUpdates + 1;
    
    timeStateMatrix(1:length(nodeUpdated),i) = getStateVector(nodeUpdated)';
        
end
