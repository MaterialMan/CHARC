

f1 = figure
maxMC = max(pred_dataset.inputs(:,3))+5;
set(f1,'position',[0,492,1657,456])
task = 4;

in = pred_dataset.inputs;
out = pred_dataset.outputs;

out(out(:,task) > 1,task) = 1;

subplot(1,3,1)
scatter(in(:,1),in(:,2),20,out(:,task),'filled')
colorbar
xlabel('Kernel Rank')
ylabel('Generalisation Rank')
xlim([0 config.maxMinorUnits])
ylim([0 config.maxMinorUnits])


subplot(1,3,2)
scatter(in(:,1),in(:,3),20,out(:,task),'filled')
colorbar
xlabel('Kernel Rank')
ylabel('Memory Capacity')
xlim([0 config.maxMinorUnits])
ylim([0 maxMC])


subplot(1,3,3)
scatter(in(:,2),in(:,3),20,out(:,task),'filled')
colorbar
xlabel('Generalisation Rank')
ylabel('Memory Capacity')
xlim([0 config.maxMinorUnits])
ylim([0 maxMC])

colormap(cubehelix)


if config.evolvedOutputStates
    states= states(config.nForgetPoints+1:end,logical(genotype.state_loc));
else
    states= states(config.nForgetPoints+1:end,:);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f1 = figure
set(f1,'position',[0,492,1657,456])
substrate = 'BZ (40x40) Time Domain';
database = all_databases{1,1};

subplot(1,3,1)
scatter(database(:,1),database(:,2),20,1:length(database),'filled')
colormap('copper')
xlabel('KR')
ylabel('GR')
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,2)
scatter(database(:,1),database(:,3),20,1:length(database),'filled')
xlabel('KR')
ylabel('MC')
colormap('copper')
title(substrate)
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,3)
scatter(database(:,2),database(:,3),20,1:length(database),'filled')
xlabel('GR')
ylabel('MC')
colormap('copper')
set(gca,'FontSize',12,'FontName','Arial')

set(gcf,'renderer','OpenGL')
set(gcf,'PaperOrientation','landscape');

print(substrate,'-dpdf','-bestfit')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f1 = figure
set(f1,'position',[0,492,1657,456])
substrate = 'Lattice';

database =[];
for i = 1:10
    database = [database; all_databases_196{i,10}];
end

subplot(1,3,1)
scatter(database(:,1),database(:,2),20,1:length(database),'filled')
colormap('copper')
xlabel('KR')
ylabel('GR')
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,2)
scatter(database(:,1),database(:,3),20,1:length(database),'filled')
xlabel('KR')
ylabel('MC')
colormap('copper')
title(substrate)
set(gca,'FontSize',12,'FontName','Arial')

subplot(1,3,3)
scatter(database(:,2),database(:,3),20,1:length(database),'filled')
xlabel('GR')
ylabel('MC')
colormap('copper')
set(gca,'FontSize',12,'FontName','Arial')

set(gcf,'renderer','OpenGL')
set(gcf,'PaperOrientation','landscape');

print(substrate,'-dpdf','-bestfit')