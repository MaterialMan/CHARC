function plotCA(config,states)

figure

for i = 1:size(states,1)-1
    imagesc(reshape(states(i,2:end),sqrt(config.maxMinorUnits),sqrt(config.maxMinorUnits)));
    title(strcat('Iteration: ',num2str(i)))
    pause(0.05)
    
end
    