function plotGraphWeights(all_databases,database_esnMinor,database_esnMajor)

esn = 1;
figure1 = figure;
figure2 = figure;

exit =1;

minX = 1; maxX = 1;
minY = 1; maxY = 1;
minZ = 0.5; maxZ = 0.5;

if ~esn
    metrics = all_databases{1,10};
else
    metrics = all_databases{10,10};    
    for i = 1:length(metrics)
        genotype(i).Wscaling = database_esnMinor(i).spectralRadius;
        genotype(i).inputScaling = database_esnMinor(i).inputScaling;
        genotype(i).leakRate = database_esnMinor(i).leakRate;
        genotype(i).w = database_esnMajor(i).connectWeights{1,1};
        genotype(i).w_in = database_esnMinor(i).inputWeights;
        genotype(i).nTotalUnits = database_esnMinor(i).nInternalUnits;
    end
end

subplot(2,3,1)
c = repmat([0.8 0.8 0.8],length(metrics),1);
scatter(metrics(:,1),metrics(:,3),10,c,'filled')

while(exit)
    
    subplot(2,3,1)
    %[x,y] = getpts;
   x = input('KR = ');
   y = input('GR = ');
   z = input('MC = ');
    
    c = repmat([0.8 0.8 0.8],length(metrics),1);
    scatter(metrics(:,1),metrics(:,3),10,c,'filled')
    
    desired_metric = [x,y,z];
    
    [err,order_m] = sort(sum((metrics-desired_metric).^2,2));
    inOrderM = metrics(order_m,:);
    best_indv = order_m(1);
    
    var_list = [];
    for i = 1:length(metrics)
        if  metrics(i,1) >= round(x)-minX && metrics(i,1) <= round(x)+maxX
            if  metrics(i,2) >= round(y)-minY && metrics(i,2) <= round(y)+maxY
                if  metrics(i,3) >= round(z)-minZ && metrics(i,3) <= round(z)+maxZ
                    var_list = [var_list i];
                end
            end
        end
    end
    
    %
    %var_list = 1:length(metrics);
    var_metrics =  metrics(var_list,:);
    figure(figure2)
    std_metrics_at_loc = std(var_metrics)
    
    % collect genotype data
    Wscaling = [genotype(var_list).Wscaling];
    inputScaling = [genotype(var_list).inputScaling];
    leakRate = [genotype(var_list).leakRate];
    totalWeights = genotype(1).nTotalUnits^2;
    for i = 1:length(var_list)
        Wcon(i) = mean(nonzeros(genotype(var_list(i)).w(:)));%length(nonzeros(handles.genotype(i).w))/totalWeights;
        Wdist(i) = mean(nonzeros(genotype(var_list(i)).w));
        Windist(i) = mean(nonzeros(genotype(var_list(i)).w_in));
        totalInputs(i) = length(nonzeros(genotype(var_list(i)).w_in));
    end
    
    figure(figure2)
    data_plot = {Wscaling,inputScaling,leakRate,Wcon,Wdist,Windist,totalInputs};
    for r = 1:7
        subplot(2,4,r)
        hist(data_plot{r})
        
    end
    
    %% back to normal plot
    figure(figure1)
    
    if ~esn
        adjMatrix  = database_genotype(best_indv).w;
    else
        adjMatrix  = database_esnMajor(best_indv).connectWeights{1,1};
    end
    
    G = digraph(adjMatrix);
    
    hold on
    scatter(metrics(best_indv,1),metrics(best_indv,3),10,[1 0 0],'filled')
    hold off
    
    subplot(2,3,2)
    p1 = plot(G,'NodeLabel',{});
    p1.EdgeCData = G.Edges.Weight;
    p1.NodeColor = 'black';
    p1.MarkerSize = 1;
    colormap(bluewhitered)
    
    subplot(2,3,3)
    p2 = plot(G,'NodeLabel',{},'Layout','force','WeightEffect','direct');
    p2.EdgeCData = G.Edges.Weight;
    p2.NodeColor = 'black';
    p2.MarkerSize = 1;
    colormap(bluewhitered)
    
    subplot(2,3,4)
    p3 = plot(G,'NodeLabel',{},'Layout','force','UseGravity',true);
    p3.EdgeCData = G.Edges.Weight;
    p3.NodeColor = 'black';
    p3.MarkerSize = 1;
    colormap(bluewhitered)
    
    subplot(2,3,5)
    p4 = plot(G,'NodeLabel',{},'Layout','subspace');
    p4.EdgeCData = G.Edges.Weight;
    p4.NodeColor = 'black';
    p4.MarkerSize = 1;
    colormap(bluewhitered)
    
    subplot(2,3,6)
    p5 = plot(G,'NodeLabel',{},'Layout','circle');
    p5.EdgeCData = G.Edges.Weight;
    p5.NodeColor = 'black';
    p5.MarkerSize = 1;
    colormap(bluewhitered)
    
    drawnow
    pause(0.1)
end
