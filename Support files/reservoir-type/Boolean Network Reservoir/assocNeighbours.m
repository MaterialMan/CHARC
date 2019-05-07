function  nodeUpdated = assocNeighbours(node, connectionMatrix)

% ASSOCNEIGHBOURS Set the array "input" in the NODE structure-array according to the
% network structure defined in CONNECTIONMATRIX.
%   
%   ASSOCNEIGHBOURS(NODE, CONNECTIONMATRIX) updates the fields "input" in the NODE 
%   stucture-array according to the CONNECTIONMATRIX.
% 
%   Input:
%       node               -  1 x n structure-array containing node information
%       connectionMatrix   -  n x n adjacent matrix (defined as in graph theory)
%
%   Output: 
%       nodeUpdated        - 1 x n sturcture-array with updated node information ("input" fields)
%


%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 8.11.2002 LastModified: 20.01.2003


if(nargin == 2)
    
    if(length(node) ~= length(connectionMatrix))
        error('ConnectionMatrix does not correspond to NodeMatrix. Wrong dimension.')
    end
        
    nodeUpdated = node; 
        
    for i=1:length(node)
        
        nodeUpdated(i).input = [];
        indices = find(connectionMatrix(:,i));
        
        % get number of incoming connections from a particular node (multiplicity)
        for k=1:length(indices)
            multiplicity(k) = connectionMatrix(indices(k),i);    
        end
        
        % set input vector
        for m=1:length(indices)
            nodeUpdated(i).input = [nodeUpdated(i).input repmat(indices(m),1,multiplicity(m))];        
        end       
        
    end
    
else
    error('Wrong number of arguments. Type: help assocNeighbours')
end
