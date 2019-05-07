function nodeUpdated = setLUTLines(node, varargin)

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


if(nargin == 1)
nodeUpdated = node;


% The old and slow version 
% ------------------------
% for i=1:length(node)
%      binaryString = '';
%      for k=1:length(node(i).input)
%          binaryString = strcat(binaryString,num2str(node(node(i).input(k)).state));
%      end
%      binaryString;
%      nodeUpdated(i).lineNumber = bin2dec(binaryString) + 1;
% end


% The new version (10x faster than the old!)
%------------------------------------------
for i=1:length(node)
    statevector = zeros(1,length(node(i).input));
    for k=1:length(node(i).input)
        statevector(k) = node(node(i).input(k)).state;
    end  
    nodeUpdated(i).lineNumber = polyval(statevector,2)+1;   
end

else
     error('Wrong number of arguments. Type: help setLUTLines')    
end