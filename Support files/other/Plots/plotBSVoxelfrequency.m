%% plots the number of reservoirs occupying a single voxel
% *use measureSpace function beforehand
function plotBSVoxelfrequency(size,space_cnt)

% figure
[X,Y,Z] = meshgrid(1:size+1);
d = space_cnt(:)> 1;
[~,d]=sort(space_cnt(:),'ascend');

X = X(:); Y=Y(:); Z=Z(:);
% scatter3(X(d),Y(d),Z(d),15,space_cnt(d),'filled');
% colormap(bluewhitered)

figure
subplot(1,3,1)
scatter(X(d),Y(d),15,space_cnt(d),'filled')
xlabel('KR')
ylabel('GR')

subplot(1,3,2)
scatter(X(d),Z(d),15,space_cnt(d),'filled')
xlabel('KR')
ylabel('MC')

subplot(1,3,3)
scatter(Y(d),Z(d),15,space_cnt(d),'filled')
xlabel('GR')
ylabel('MC')
colorbar

colormap(bluewhitered)