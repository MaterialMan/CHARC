function plotBZ(figure1,population,best_indv,loser,config)
set(0,'currentFigure',figure1)

    set(0,'currentFigure',figure1)
    subplot(2,3,1)
    imagesc(reshape(population(best_indv).input_weights{1,1}(:,1),config.num_nodes,config.num_nodes))
    title('Input Location (Best)')
    
    subplot(2,3,2)
    imagesc(reshape(population(best_indv).input_weights{1,2}(:,1),config.num_nodes,config.num_nodes))
    title('Input Location (Best)')
    
    subplot(2,3,3)
    imagesc(reshape(population(best_indv).input_weights{1,3}(:,1),config.num_nodes,config.num_nodes))
    title('Input Location (Best)')
    
    subplot(2,3,4)
    imagesc(reshape(population(loser).input_weights{1,1}(:,1),config.num_nodes,config.num_nodes))
    title('Input Location (loser)')
    
    subplot(2,3,5)
    imagesc(reshape(population(loser).input_weights{1,2}(:,1),config.num_nodes,config.num_nodes))
    title('Input Location (loser)')
    
    subplot(2,3,6)
    imagesc(reshape(population(loser).input_weights{1,3}(:,1),config.num_nodes,config.num_nodes))
    title('Input Location (loser)')
    

drawnow
end