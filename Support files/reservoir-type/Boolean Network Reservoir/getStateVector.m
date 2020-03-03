function stateVector = getStateVector(node)

% GETSTATEVECTOR Return the states of the nodes in NODE as row vector.
%   
%   GETSTATEVECTOR(NODE) returns the states of all nodes in NODE as one row vector.
% 
%   Input:
%       node               - 1 x n structure-array containing node information
%
%   Output: 
%       stateVector        - 1 x n array with node states
%                            

%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 15.11.2002 LastModified: 08.08.2019 (matt dale)

stateVector = zeros(1,length(node));
for i=1:length(node)
   stateVector(i) = node(i).state;    
end
