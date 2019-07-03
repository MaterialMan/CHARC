function plotRoR(figure1,population,best,loser)

set(0,'currentFigure',figure1)
ax1 = subplot(2,3,1);
imagesc(population(best).input_weights{1})
colormap(ax1,bluewhitered)
title('Input weights (best)')

ax2 = subplot(2,3,2);
imagesc(population(best).W{1,1})
colormap(ax2,bluewhitered)
title('Hidden weights (best)')

ax3 = subplot(2,3,3);
imagesc(population(best).output_weights)
colormap(ax3,bluewhitered)
title('Output weights (best)')

set(0,'currentFigure',figure1)
ax1 = subplot(2,3,4);
imagesc(population(loser).input_weights{1})
colormap(ax1,bluewhitered)
title('Input weights (loser)')

ax2 = subplot(2,3,5);
imagesc(population(loser).W{1,1})
colormap(ax2,bluewhitered)
title('Hidden weights (loser)')

ax3 = subplot(2,3,6);
imagesc(population(loser).output_weights)
colormap(ax3,bluewhitered)
title('Output weights (loser)')

drawnow
end

