function nodeUpdated = resetNodeStats(node)

% RESETNODESTATS Reset all variables of the node structure which are involved in statistical evaluation to zero.
%   
%   RESETNODESTATS(NODE) resets all variables of the NODE structure which are involved in statistical evaluation to zero.
%
%   Input:
%       node               -  1 x n structure-array containing node information
%
%   Output: 
%       nodeUpdated        -  1 x n structure-array containing updated node information ("nbUpdates"-field)


%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 27.11.2002 LastModified: 20.01.2003

nodeUpdated = node;
for i=1:length(node)
    nodeUpdated(i).nbUpdates = 0;
end
    