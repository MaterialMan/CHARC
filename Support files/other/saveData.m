function saveData(database_history,database,quality,test,config,network_size)

config.figure_array =[];

if test == 9
    save(strcat('substrate_',num2str(network_size),'_run',num2str(test),'_networkSize_',config.res_type,'_undirected',num2str(config.undirected)),...
        'database_history','database','config','quality','-v7.3');
else
    save(strcat('substrate_',num2str(network_size),'_run',num2str(test),'_networkSize_',config.res_type,'_undirected',num2str(config.undirected)),...
        'database_history','config','quality','-v7.3');
end

end