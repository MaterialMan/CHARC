function nodeUpdated = assocRules(node,rulesMatrix)

% ASSOCRULES Set the array "rule" in the NODE structure-array according to the network's
% transition logic rules defined in RULESMATRIX.
%   
%   ASSOCRULES(NODE, RULESMATRIX) updates the fields "rule" in the NODE 
%   stucture-array according to the RULESMATRIX.
% 
%   Input:
%       node               - 1 x n structure-array containing node information
%       rulesMatrix        - 2^k x n matrix containing transition logic rules for each node
%
%   Output: 
%       nodeUpdated        - 1 x n sturcture-array with updated node information ("rule" field)
%


%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 13.11.2002 LastModified: 20.01.2003

if(nargin == 2)
   
    nodeUpdated = node;
    
    % set rule vector
    for i=1:length(node)
        nodeUpdated(i).rule = int8(rulesMatrix(:,i));
    end
    
else
     error('Wrong number of arguments. Type: help assocRules')
end

