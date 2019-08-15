function nodeUpdated = setNodeNextState(node)

% SETNODENEXTSTATE Look up next state for each node and update "nextState" field of the NODE
% structure-array. Make sure that assocRules() has been called on NODE before using this function.  
%
%   SETNODENEXTSTATE(NODE) returns the updated node structure-array containing 
%   next-state information for each node.
%   Next state information is stored in the "nextState" field of the NODE structure-array.
%
%   Input:
%       node               -  1 x n structure-array containing node information
%       genotype           -  1 x 1 structure-array containing genotype information
%       inputSequence      -  1 x n array containing input sequence
%
%   Output: 
%       nodeUpdated        -  1 x n structure-array containing updated node information         
%
%

%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 13.11.2002 LastModified: 30.11.2018 (Matt Dale)

nodeUpdated = node;

for i=1:length(node)    
   nodeUpdated(i).nextState = nodeUpdated(i).rule(nodeUpdated(i).lineNumber);
end  
