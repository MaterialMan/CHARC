
function plotInputConnectivity(figureHandle,database_esnMinor,search_archive)

%% W connectivity
totalInputWeights = database_esnMinor(1).nInternalUnits*2;
for i = 1:length(database_esnMinor)
    database_esnMinor(i).input_connectivity_actual = length(nonzeros(database_esnMinor(i).inputWeights))/totalInputWeights;
end

figure(figureHandle)
subplot(1,3,1)
scatter(search_archive(:,1),search_archive(:,2),20,[database_esnMinor.input_connectivity_actual],'filled')
map = cubehelix(length(search_archive));
colormap(map)
xlabel('KR')
ylabel('GR')
colorbar

subplot(1,3,2)
scatter(search_archive(:,1),search_archive(:,3),20,[database_esnMinor.input_connectivity_actual],'filled')
map = cubehelix(length(search_archive));
colormap(map)
xlabel('KR')
ylabel('MC')
colorbar

subplot(1,3,3)
scatter(search_archive(:,2),search_archive(:,3),20,[database_esnMinor.input_connectivity_actual],'filled')
map = cubehelix(length(search_archive));
colormap(map)
xlabel('GR')
ylabel('MC')
colorbar

set(gca,'FontSize',14,'FontName','Arial')
set(gcf,'renderer','OpenGL')

