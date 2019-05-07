function [train,xVal,test] = split_train_test3way(sample, trainPercentage, xvalSize, testSize)

% SPLIT_TRAIN_TEST splits the "sample" time series into a train and a 
% test subsequence such that the train subsequence has a length of 
% trainPercentage of the original sample length

% Created April 30, 2006, D. Popovici
% Copyright: Fraunhofer IAIS 2006 / Patent pending

nSamplePoints = size(sample, 1) ; 
nTrainPoints = floor(nSamplePoints * trainPercentage) ; 


if nargin < 3
    train = sample(1:nTrainPoints,:) ; 
    test  = sample(nTrainPoints+1:end,:) ;
    xVal = [];
else
    
    nValPoints = floor(nSamplePoints * xvalSize) ;
    nTestPoints = floor(nSamplePoints * testSize) ;
    
    train = sample(1:nTrainPoints,:) ;
    xVal  = sample(nTrainPoints+1:nTrainPoints+nValPoints,:) ;
    test  = sample(nTrainPoints+1+nValPoints:end,:) ;

end
  
