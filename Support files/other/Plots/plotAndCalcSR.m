
function database_esnMinor = plotAndCalcSR(figureHandle,database_esnMinor,database_esnMajor,search_archive)

%% calculate spectral radius
opts.disp = 0;
for i = 1:length(database_esnMinor)    
    database_esnMinor(i).actualSR = max(abs(eigs(database_esnMajor(i).connectWeights{1,1},1, 'lm', opts)));
end

parameter = [database_esnMinor.actualSR].*[database_esnMinor.spectralRadius];

figure(figureHandle)
subplot(1,3,1)
scatter(search_archive(:,1),search_archive(:,2),20,parameter,'filled')
map = cubehelix(length(search_archive));
colormap(map)
xlabel('KR')
ylabel('GR')
colorbar

subplot(1,3,2)
scatter(search_archive(:,1),search_archive(:,3),20,parameter,'filled')
map = cubehelix(length(search_archive));
colormap(map)
xlabel('KR')
ylabel('MC')
colorbar

subplot(1,3,3)
scatter(search_archive(:,2),search_archive(:,3),20,parameter,'filled')
map = cubehelix(length(search_archive));
colormap(map)
xlabel('GR')
ylabel('MC')
colorbar

set(gca,'FontSize',14,'FontName','Arial')
set(gcf,'renderer','OpenGL')

