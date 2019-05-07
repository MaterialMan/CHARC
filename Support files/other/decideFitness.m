%% Decide which fitness criteria will be used
function [totalError] = decideFitness(trainError, valError,type)

switch(type)
    case 'train'
        totalError = sum(trainError);
    case 'val'
        totalError = sum(valError);
    case'both'
        totalError = sum(trainError)+sum(valError);
    case 'ranked'
        
end
