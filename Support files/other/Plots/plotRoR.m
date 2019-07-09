function plotRoR(figure1,population,best,loser,config)

set(0,'currentFigure',figure1)
for res_indx = 1:config.num_reservoirs
    
ax1 = subplot(3,config.num_reservoirs*2,res_indx);
imagesc(population(best).input_weights{res_indx})
colormap(ax1,bluewhitered)
title('Input weights (best)')

ax2 = subplot(3,config.num_reservoirs*2,config.num_reservoirs*2 + res_indx);
imagesc(population(best).W{res_indx,res_indx})
colormap(ax2,bluewhitered)
title('Hidden weights (best)')

ax3 = subplot(3,config.num_reservoirs*2,config.num_reservoirs*4 + res_indx);
imagesc(population(best).output_weights)
colormap(ax3,bluewhitered)
title('Output weights (best)')

% plot loser
ax1 = subplot(3,config.num_reservoirs*2,res_indx + config.num_reservoirs);
imagesc(population(loser).input_weights{res_indx})
colormap(ax1,bluewhitered)
title('Input weights (loser)')

ax2 = subplot(3,config.num_reservoirs*2,config.num_reservoirs*2+ config.num_reservoirs + res_indx);
imagesc(population(loser).W{res_indx,res_indx})
colormap(ax2,bluewhitered)
title('Hidden weights (loser)')

ax3 = subplot(3,config.num_reservoirs*2,config.num_reservoirs*4 + config.num_reservoirs + res_indx);
imagesc(population(loser).output_weights)
colormap(ax3,bluewhitered)
title('Output weights (loser)')

drawnow
end

