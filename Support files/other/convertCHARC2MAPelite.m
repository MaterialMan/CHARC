
function config = convertCHARC2MAPelite(config,database_genotype,all_databases,error, metrics, task)

%% Task parameters
config.discrete = 0;                                                        % binary input for discrete systems
config.nbits = 16;                                                          % if using binary/discrete systems
config.preprocess = 1;                                                      % basic preprocessing, e.g. scaling and mean variance
config.dataSet = task;                                                  % Task to evolve for

% get dataset
[config] = selectDataset(config);

% get any additional params stored in getDataSetInfo.m
[config] = getDataSetInfo(config);

config.metrics = metrics;

for i = 1:length(database_genotype)
    config.database_genotype{i} = database_genotype(i);  
    config.database_genotype{i}.metrics = all_databases(i,1:length(metrics));
    config.database_genotype{i}.valError = error(i);
end