function plotBZ(figure1,individual,best_indv,loser,config)
set(0,'currentFigure',figure1)

    set(0,'currentFigure',figure1)
    subplot(2,3,1)
    imagesc(reshape(individual(best_indv).input_loc(1:individual(best_indv).size.^2),individual(best_indv).size,individual(best_indv).size))
    title('Input Location (Best)')
    
    subplot(2,3,2)
    imagesc(reshape(individual(best_indv).input_loc((individual(best_indv).size.^2)+1:(individual(best_indv).size.^2)*2),individual(best_indv).size,individual(best_indv).size))
    title('Input Location (Best)')
    
    subplot(2,3,3)
    imagesc(reshape(individual(best_indv).input_loc(((individual(best_indv).size.^2)*2)+1:(individual(best_indv).size.^2)*3),individual(best_indv).size,individual(best_indv).size))
    title('Input Location (Best)')
    
    subplot(2,3,4)
    imagesc(reshape(individual(loser).input_loc(1:individual(loser).size.^2),individual(loser).size,individual(loser).size))
    title('Input Location (loser)')
    
    subplot(2,3,5)
    imagesc(reshape(individual(loser).input_loc((individual(loser).size.^2)+1:(individual(loser).size.^2)*2),individual(loser).size,individual(loser).size))
    title('Input Location (loser)')
    
    subplot(2,3,6)
    imagesc(reshape(individual(loser).input_loc(((individual(loser).size.^2)*2)+1:(individual(loser).size.^2)*3),individual(loser).size,individual(loser).size))
    title('Input Location (loser)')
    

drawnow
end