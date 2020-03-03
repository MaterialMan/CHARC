function plotRandvsNS(holdOnPlot,resize)

  if holdOnPlot
        figure1 = figure;
  end
    
for p = 1:length(resize)
    
    if resize(p) == 25
        %% plot 25
        database1 = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\25 nodes\noveltySearch3D_size25_run10_gens2000.mat', 'all_databases');
        database1_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\25 nodes\noveltySearch3D_size25_run10_gens2000.mat', 'total_space_covered');
        database2= load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_25.mat', 'all_databases');
        database2_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_25.mat', 'total_space_covered');
        database1_name = '25 node(NS)';
        database2_name = '25 node(Rand)';
        
        if holdOnPlot
            plotDatabases(figure1,database1_ts.total_space_covered,database2_ts.total_space_covered,database1_name,database2_name)
        else
            plotDatabases(figure,database1_ts.total_space_covered,database2_ts.total_space_covered,database1_name,database2_name)
        end
         print('25node_coverage','-dpdf','-bestfit')
        
        plotDB1 =[]; plotDB2 =[];
        for i = 1:length(database1.all_databases)
            plotDB1 = [plotDB1;database1.all_databases{i,10}];
            plotDB2 = [plotDB2;database2.all_databases{i,10}];
        end
        plotDatabaseComparison(figure,plotDB1,plotDB2,database1_name,database2_name)
        print('25node_BS','-dpdf','-bestfit')
        
    end
    %% plot 50
    if resize(p) == 50
        database1 = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\50 nodes\noveltySearch3D_size50_run10_gens2000.mat', 'all_databases');
        database1_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\50 nodes\noveltySearch3D_size50_run10_gens2000.mat', 'total_space_covered');
        database2= load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_50.mat', 'all_databases');
        database2_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_50.mat', 'total_space_covered');
        database1_name = '50 node(NS)';
        database2_name = '50 node(Rand)';
        
        if holdOnPlot
            plotDatabases(figure1,database1_ts.total_space_covered,database2_ts.total_space_covered,database1_name,database2_name)
        else
            plotDatabases(figure,database1_ts.total_space_covered,database2_ts.total_space_covered,database1_name,database2_name)
        end
        print('50node_coverage','-dpdf','-bestfit')
        
        plotDB1 =[]; plotDB2 =[];
        for i = 1:length(database1.all_databases)
            plotDB1 = [plotDB1;database1.all_databases{i,10}];
            plotDB2 = [plotDB2;database2.all_databases{i,10}];
        end
        plotDatabaseComparison(figure,plotDB1,plotDB2,database1_name,database2_name)
        print('50node_BS','-dpdf','-bestfit')
    end
    %% plot 100
    if resize(p) == 100
        database1 = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\100 nodes\noveltySearch3D_size100_run10_gens2000.mat', 'all_databases');
        database1_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\100 nodes\noveltySearch3D_size100_run10_gens2000.mat', 'total_space_covered');
        database2= load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_100.mat', 'all_databases');
        database2_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_100.mat', 'total_space_covered');
        database1_name = '100 node(NS)';
        database2_name = '100 node(Rand)';
        
        if holdOnPlot
            plotDatabases(figure1,database1_ts.total_space_covered,database2_ts.total_space_covered,database1_name,database2_name)
        else
            plotDatabases(figure,database1_ts.total_space_covered,database2_ts.total_space_covered,database1_name,database2_name)
        end
        print('100node_coverage','-dpdf','-bestfit')
        
        plotDB1 =[]; plotDB2 =[];
        for i = 1:length(database1.all_databases)
            plotDB1 = [plotDB1;database1.all_databases{i,10}];
            plotDB2 = [plotDB2;database2.all_databases{i,10}];
        end
        plotDatabaseComparison(figure,plotDB1,plotDB2,database1_name,database2_name)
        print('100node_BS','-dpdf','-bestfit')
    end
    
    %% plot 200
    if resize(p) == 200
        database1 = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\200 nodes\noveltySearch3D_size200_run10_gens2000.mat', 'all_databases');
        database1_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\200 nodes\noveltySearch3D_size200_run10_gens2000.mat', 'total_space_covered');
        database2= load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_200.mat', 'all_databases');
        database2_ts = load('Z:\Working_code_repo\SQuARC\Squarc Framework\Journal Results\ESNs\Random Search\randSearch_3DGPU_Nres_200.mat', 'total_space_covered');
        database1_name = '200 node(NS)';
        database2_name = '200 node(Rand)';
        
        if holdOnPlot
            plotDatabases(figure1,database1_ts.total_space_covered,database2_ts.total_space_covered,database1_name,database2_name)
        else
            plotDatabases(figure,database1_ts.total_space_covered,database2_ts.total_space_covered,database1_name,database2_name)
        end
        print('200node_coverage','-dpdf','-bestfit')
        
        plotDB1 =[]; plotDB2 =[];
        for i = 1:length(database1.all_databases)
            plotDB1 = [plotDB1;database1.all_databases{i,10}];
            plotDB2 = [plotDB2;database2.all_databases{i,10}];
        end
        plotDatabaseComparison(figure,plotDB1,plotDB2,database1_name,database2_name)
        print('200node_BS','-dpdf','-bestfit')
    end
    

end
