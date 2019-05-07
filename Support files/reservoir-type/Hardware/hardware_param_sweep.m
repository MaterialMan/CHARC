%% Baseline experiments - set parameters
clear
config.material = 'B2S164';

config.split2run = 0;
config.popSize =100; 
config.deme = round(config.popSize*0.4); %sub-species increase diversity
config.numMutate = 0.1;    
config.recRate = 0.5;
config.numTests = 1;
config.numEpoch = 200;
config.saveGen = 200;
config.metrics_used = [1 1 0]; %KR GR
config.paramIndx=1;
config.leakOn = 1;

%Archive settings
config.k_neighbours = 15;
config.p_min = 2;
config.p_min_check = 50;

config.genPrint = 50;
config.startTime = datestr(now, 'HH:MM:SS');

%hardware variables
config.num_electrodes =64;
config.voltage_range =7;
config.input_range = 16;
[read_session,switch_session] = createDaqSessions(0:config.num_electrodes-1,0:(config.num_electrodes/2)-1);
config.reg_param = 10e-5;

config.popList = 10:10:100;%[5 10 20 40 80 160];
config.demeList = 0.1:0.1:1;%[1 0.5 0.25 0.125];
config.recList = 0:0.2:1;
config.mutList = 0:0.2:1;%(0.1:0.075:0.8).^2;%[0.005 0.01 0.025 0.05 0.075 0.1 0.2 0.3 0.4 0.5];

figure1 = figure;
figure2 = figure;

if config.split2run == 1
    %% pop & deme analysis
    config.demeVSpop = zeros(length(config.popList),length(config.demeList));
%     cd ../..
%     datadir='paramSweep\popAndDeme';
%     cd(datadir);
    config.paramIndx=1;
    for popIndx = 1:length(config.popList)
        for demeIndx = 1:length(config.demeList)

            config.popSize =config.popList(popIndx); %large pop better
            config.numMutate = 0.1;
            config.deme = round(config.popList(popIndx)*config.demeList(demeIndx)); %sub-species increase diversity
            config.recRate = 0.5;
            
            hardware_param_search
            config.paramIndx = config.paramIndx+1;
            
            figure(figure2)
            config.demeVSpop(popIndx,demeIndx) = total_space_covered(config.paramIndx-1);
            imagesc(config.demeVSpop)
            contourf(config.demeVSpop)
            xticks([1:length(config.demeList)])
            yticks([1:length(config.popList)])
            xticklabels(config.demeList)
            yticklabels(config.popList)
            colormap('hot')
            colorbar
            ylabel('Pop size')
            xlabel('Deme size')
            drawnow
        end
    end
    
    %% deme vs pop
    test = 1;
    figure
    subplot(2,1,1)
    demeVSpop = reshape(stats_novelty_KQ(:,test),length(config.demeList),length(config.popList));
    imagesc(demeVSpop')
    contourf(demeVSpop')
    xticks([1:length(config.demeList)])
    yticks([1:length(config.popList)])
    xticklabels(config.demeList)
    yticklabels(config.popList)
    colormap('hot')
    colorbar
    ylabel('Pop size')
    xlabel('Deme size')
    
    subplot(2,1,2)
    demeVSpop = reshape(stats_novelty_MC(:,test),length(config.demeList),length(config.popList));
    imagesc(demeVSpop')
    contourf(demeVSpop')
    xticks([1:length(config.demeList)])
    yticks([1:length(config.popList)])
    xticklabels(config.demeList)
    yticklabels(config.popList)
    colormap('hot')
    colorbar
    ylabel('Pop size')
    xlabel('Deme size')
    
else
    %% rec & mut analysis
    config.mutVSrec = zeros(length(config.mutList),length(config.recList));
%     cd ../..
%     datadir='paramSweep\recAndMutRate';
%     cd(datadir);
    config.paramIndx=1;
    for mutIndx = 1:length(config.mutList)
        for recIndx = 1:length(config.recList)
            
            config.numMutate = config.mutList(mutIndx);
            config.recRate = config.recList(recIndx);
            
            hardware_param_search
            config.paramIndx =config.paramIndx+1;
            
            figure(figure2)
            config.mutVSrec(mutIndx,recIndx) = total_space_covered(config.paramIndx-1);
            imagesc(config.mutVSrec)
            %contourf(config.mutVSrec)
            xticks([1:length(config.recList)])
            yticks([1:length(config.mutList)])
            xticklabels(config.recList)
            yticklabels(round(config.mutList,2))
            colormap('hot')
            colorbar
            xlabel('rec rate')
            ylabel('mut rate')
            drawnow
        end
    end
    
    %%
    test = 3;
    figure
    subplot(2,1,1)
    mutVSrec = reshape(stats_novelty_KQ(:,test),length(config.recList),length(config.mutList));
    imagesc(mutVSrec')
    contourf(mutVSrec')
    xticks([1:length(config.recList)])
    yticks([1:length(config.mutList)])
    xticklabels(config.recList)
    yticklabels(round(config.mutList,2))
    colormap('hot')
    colorbar
    title('KQ')
    xlabel('rec Rate')
    ylabel('mut Rate')
    
    subplot(2,1,2)
    mutVSrec = reshape(stats_novelty_MC(:,test),length(config.recList),length(config.mutList));
    imagesc(mutVSrec')
    contourf(mutVSrec')
    xticks([1:length(config.recList)])
    yticks([1:length(config.mutList)])
    xticklabels(config.recList)
    yticklabels(round(config.mutList,2))
    colormap('hot')
    colorbar
    title('MC')
    xlabel('rec Rate')
    ylabel('mut Rate')
end





