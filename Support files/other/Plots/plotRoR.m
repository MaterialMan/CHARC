function plotRoR(figure1,best,loser,config)

set(0,'currentFigure',figure1)
for res_indx = 1:config.num_reservoirs
    
ax1 = subplot(3,config.num_reservoirs*2,res_indx);
imagesc(best.input_weights{res_indx})
colormap(ax1,bluewhitered)
title('Input weights (best)')

ax2 = subplot(3,config.num_reservoirs*2,config.num_reservoirs*2 + res_indx);
imagesc(best.W{res_indx,res_indx})
colormap(ax2,bluewhitered)
title('Hidden weights (best)')

ax3 = subplot(3,config.num_reservoirs*2,config.num_reservoirs*4 + res_indx);
imagesc(best.output_weights)
colormap(ax3,bluewhitered)
title('Output weights (best)')

% plot loser
ax1 = subplot(3,config.num_reservoirs*2,res_indx + config.num_reservoirs);
imagesc(loser.input_weights{res_indx})
colormap(ax1,bluewhitered)
title('Input weights (loser)')

ax2 = subplot(3,config.num_reservoirs*2,config.num_reservoirs*2+ config.num_reservoirs + res_indx);
imagesc(loser.W{res_indx,res_indx})
colormap(ax2,bluewhitered)
title('Hidden weights (loser)')

ax3 = subplot(3,config.num_reservoirs*2,config.num_reservoirs*4 + config.num_reservoirs + res_indx);
imagesc(loser.output_weights)
colormap(ax3,bluewhitered)
title('Output weights (loser)')

drawnow
end

