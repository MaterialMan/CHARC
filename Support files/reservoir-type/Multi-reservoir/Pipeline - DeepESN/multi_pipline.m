% Make sure files are in the path
addpath(genpath('\RoR-master\'))

% Example tests
dataSet = 'NARMA10'
maxMinorUnits=50;
maxMajorUnits=2;
resType = 'pipeline'
DeepESN_microGA_pipeline

dataSet = 'NARMA10'
maxMinorUnits=200;
maxMajorUnits=2;
resType = 'pipeline'
DeepESN_microGA_pipeline