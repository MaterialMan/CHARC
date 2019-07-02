function plotReservoirDetails(figure1,population,store_error,test,best_indv,gen,loser,config)

% plot reservoir details
switch(config.res_type)
    case 'Graph'
        plotGridNeuron(figure1,population,store_error,test,best_indv(gen),loser,config)
        
    case '2dCA'
        plotGridNeuron(figure1,population,store_error,test,best_indv(gen),loser,config)
        
    case 'basicCA'
%         figure(figure1)
%         imagesc(loserStates');

    case 'BZ'
        plotBZ(config.BZ_figure1,population,best_indv(gen),loser,config)
        
    case 'RoR'
        plotRoR(figure1,population,best_indv(gen),loser);
end

% plot task specific details
switch(config.dataset)
    
    case 'autoencoder'
        plotAEWeights(figure3,figure4,config.testInputSequence,population(best_indv(gen)),config)
               
    case 'poleBalance'
        config.run_sim = 1;
        config.testFcn(population(best_indv(gen)),config);
        config.run_sim = 0;
        
    case 'robot'
        config.run_sim = 1;
        config.testFcn(population(best_indv(gen)),config);
        config.run_sim = 0;
end

end
