function [maxKR,maxGR,maxMC] = plotBS(figureHandle,database,dotSize,maxKR,maxGR,maxMC,directedPlots,genotype,param)

if nargin <= 7
    
    set(figureHandle,'position',[0,492,1657,456])
    if directedPlots % plot ring vs lattice vs esn
        set(0,'currentFigure',figureHandle)
        
        for i = 1:length(database)
            tempGR = max([max(database{i}(:,2)) max(database{i}(:,2))]);
            tempKR = max([max(database{i}(:,1)) max(database{i}(:,1))]);
            tempMC = max([max(database{i}(:,3)) max(database{i}(:,3))]);
            
            if tempGR > maxGR
                maxGR =tempGR;
            end
            if tempKR > maxKR
                maxKR =tempKR;
            end
            if tempMC > maxMC
                maxMC =tempMC;
            end
        end
        
        for i = 3:-1:1
            switch(i)
                case 1
                    c =[0 0 0];
                case 2
                    c=[0.4 0.4 0.4];
                case 3
                    c=[0.8 0.8 0.8];
            end
            
            subplot(1,3,1)%+(i-1)*3)
            hold on
            scatter(database{i}(:,1),database{i}(:,2),dotSize,c,'filled')
            xlabel('KR','FontSize',12,'FontName','Arial')
            ylabel('GR','FontSize',12,'FontName','Arial')
            xlim([0 maxKR])
            ylim([0 maxGR])
            
            subplot(1,3,2)%+(i-1)*3)
            hold on
            scatter(database{i}(:,1),database{i}(:,3),dotSize,c,'filled')
            xlabel('KR','FontSize',12,'FontName','Arial')
            ylabel('MC','FontSize',12,'FontName','Arial')
            xlim([0 maxKR])
            ylim([0 maxMC])
            
            subplot(1,3,3)%+(i-1)*3)
            hold on
            scatter(database{i}(:,2),database{i}(:,3),dotSize,c,'filled')
            xlabel('GR','FontSize',12,'FontName','Arial')
            ylabel('MC','FontSize',12,'FontName','Arial')
            xlim([0 maxGR])
            ylim([0 maxMC])
        end
        hold off
        
        
        % set(gcf,'PaperOrientation','landscape');
        set(gcf,'renderer','OpenGL')
        drawnow
        
    else % plot directed vs undirected
        
        set(0,'currentFigure',figureHandle)
        
        for i = 1:length(database)
            tempGR = max([max(database{i}(:,2)) max(database{i}(:,2))]);
            tempKR = max([max(database{i}(:,1)) max(database{i}(:,1))]);
            tempMC = max([max(database{i}(:,3)) max(database{i}(:,3))]);
            
            if tempGR > maxGR
                maxGR =tempGR;
            end
            if tempKR > maxKR
                maxKR =tempKR;
            end
            if tempMC > maxMC
                maxMC =tempMC;
            end
        end
        
        
        hold on
        for i = 2:-1:1
            
            switch(i)
                case 1
                    c =[0 0 0];
                case 2
                    c= [0.6 0.6 0.6];
            end
            
            subplot(1,3,1)%+(i-1)*3)
            hold on
            scatter(database{i}(:,1),database{i}(:,2),dotSize,c,'filled')
            xlabel('KR','FontSize',12,'FontName','Arial')
            ylabel('GR','FontSize',12,'FontName','Arial')
            xlim([0 maxKR])
            ylim([0 maxGR])
            
            subplot(1,3,2)%+(i-1)*3)
            hold on
            scatter(database{i}(:,1),database{i}(:,3),dotSize,c,'filled')
            xlabel('KR','FontSize',12,'FontName','Arial')
            ylabel('MC','FontSize',12,'FontName','Arial')
            xlim([0 maxKR])
            ylim([0 maxMC])
            
            subplot(1,3,3)%+(i-1)*3)
            hold on
            scatter(database{i}(:,2),database{i}(:,3),dotSize,c,'filled')
            xlabel('GR','FontSize',12,'FontName','Arial')
            ylabel('MC','FontSize',12,'FontName','Arial')
            xlim([0 maxGR])
            ylim([0 maxMC])
        end
        hold off
        
        %set(gca,'FontSize',12,'FontName','Arial')
        %set(gcf,'PaperOrientation','landscape');
        set(gcf,'renderer','OpenGL')
        drawnow
        
    end
    
else
    
    

    for i = 1:length(database)
            tempGR = max([max(database{i}(:,2)) max(database{i}(:,2))]);
            tempKR = max([max(database{i}(:,1)) max(database{i}(:,1))]);
            tempMC = max([max(database{i}(:,3)) max(database{i}(:,3))]);
            
            if tempGR > maxGR
                maxGR =tempGR;
            end
            if tempKR > maxKR
                maxKR =tempKR;
            end
            if tempMC > maxMC
                maxMC =tempMC;
            end
    end
        
    %% plot params vs metrics
    for i = 1:length(genotype)
        switch(param)
            case 'Wscaling'
                parm{i} = [genotype{i}.Wscaling];
                
            case 'inputScaling'
                parm{i} = [genotype{i}.inputScaling];
                
            case 'leakRate'
                parm{i} = [genotype{i}.leakRate];
                
            case 'numInputs'
                parm{i} = [genotype{i}.totalInputs];
                
            case 'Wconnectivity'
                totalWeights = genotype{i}(1).nTotalUnits^2;
                for j = 1:length(genotype{i})
                    genotype{i}(j).Wconnectivity = length(nonzeros(abs(genotype{i}(j).w) > 0.25))/totalWeights;
                end
                parm{i} = [genotype{i}.Wconnectivity];
                
            case 'Wdist'
                for j = 1:length(genotype{i})
                    wdist(j) = mean(nonzeros(genotype{i}(j).w));
                end
                parm{i} = [wdist];
                
            case 'WinDist'
                for j = 1:length(genotype{i})
                    wdinist(j) = mean(nonzeros(genotype{i}(j).w_in));
                end
                parm{i} = [windist];
        end
        
        
        subplot(1,length(genotype),i)
        scatter(database{i}(:,1),database{i}(:,3),dotSize,parm{i},'filled')
        xlabel('KR','FontSize',12,'FontName','Arial')
        ylabel('MC','FontSize',12,'FontName','Arial')
        xlim([0 maxKR])
        ylim([0 maxMC])
        colormap(cubehelix)
        %if i == length(genotype)
        colorbar
        OuterPosition = get(gca,'OuterPosition');
        set(gca,'OuterPosition',OuterPosition + [0 0.1 0 0.1])
        %end
    end
    set(figureHandle,'position',[271,460,1067,344])
    
    
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'renderer','OpenGL')
end