config.discrete = 0;               % select '1' for binary input for discrete systems
config.nbits = 16;                 % only applied if config.discrete = 1; if wanting to convert data for binary/discrete systems
config.preprocess = 1;             % basic preprocessing, e.g. scaling and mean variance
config.dataset = 'test_plot';          % Task to evolve for

% get any additional params. This might include:
% details on reservoir structure, extra task variables, etc. 
config = getAdditionalParameters(config);

% get dataset information
config = selectDataset(config);
config.figure_array(2) = figure;
v = VideoWriter('Ising_10x10','MPEG-4');
open(v);

if exist('database') ~= 1
    database = population;
end

config.run_sim = 1;
config.film = 1;
step  = 1;
F = [];
for i = 1:step:length(database)-step
    t_F = plotReservoirDetails(database,i,1,1,config);
    F = [F t_F];
end

writeVideo(v,F);
close(v)
