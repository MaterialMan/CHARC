function nodeUpdated = setLUTLines(node)

% SETLUTLINES Updates the "lineNumber" field of the NODE structure-array. 
% Make sure that assocNeighbours has been called on NODE before using this function.  
%   
%   SETLUTLINES(NODE) For each node in NODE the states of the incoming nodes are 
%   evaluated and transformed from binary to decimal representation (linenumber of the rulesmatrix).
%   This enables direct access into the rulesmatrix. The linenumber is stored in the "lineNumber" 
%   field of the NODE structure-array.
%   
%   Input:
%       node               -  1 x n structure-array containing node information
%      
%   Output: 
%       nodeUpdated        -  1 x n structure-array containing updated node information                       

%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 13.11.2002 LastModified: 20.01.2003

nodeUpdated = node;

for i=1:length(node)
    
    statevector = zeros(1,length(node(i).input));      
    
    for k=1:length(node(i).input)
        statevector(k) = node(node(i).input(k)).state;
    end  

    
    y = statevector(1);
    for k = 2:length(statevector)
        y = y.*2+statevector(k);
    end
    nodeUpdated(i).lineNumber = y+1;
end
