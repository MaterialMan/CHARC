function config = convertMAPtoDatabase(config)

cnt = 1;
for i = 1:length(config.database_genotype)
    if ~isempty(config.database_genotype{i})
    temp_database(cnt) = config.database_genotype{i};
    cnt = cnt +1;
    end
end
    
config.database_genotype = temp_database;