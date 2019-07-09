%% called from getDataSetInfo
% Create graph structure G to use

function config = getShape(config)

temp_num_nodes = [];

for graph_indx = 1:length(config.num_nodes)
    
    %if config.num_reservoirs > 1
        num_nodes= config.num_nodes(graph_indx);
        graph_type = config.graph_type{graph_indx};
%     else
%         num_nodes = config.num_nodes;
%         if iscell(config.graph_type)
%             graph_type = config.graph_type{1};
%         else
%             graph_type = config.graph_type;
%         end
%     end
    
    switch(graph_type)
        
        case 'Bucky'
            G = graph(bucky);
            config.plot_3d = 1;      % plot graph in 3D.
            
        case 'L'
            A = delsq(numgrid('L',num_nodes +2));
            G = graph(A,'omitselfloops');
            config.plot_3d = 0;    % plot graph in 3D.
            
        case 'Hypercube'
            A = hypercube(num_nodes);
            G = graph(A);
            config.plot_3d = 1;    % plot graph in 3D.
            
        case 'Torus'
            config.rule_type = 1;
            G = torusGraph(num_nodes,config.self_loop(graph_indx),config.num_reservoirs,config);
            config.plot_3d = 1;    % plot graph in 3D.
            
        case 'Barbell'
            load barbellgraph.mat
            G = graph(A,'omitselfloops');
            config.plot_3d = 0;    % plot graph in 3D.
            
        case {'basicLattice','partialLattice','fullLattice','basicCube','partialCube','fullCube','ensembleLattice', 'ensembleCube','ensembleShape'}
            G = createLattice(num_nodes,graph_type,config.self_loop(graph_indx),config.num_reservoirs);
            config.plot_3d = 0;    % plot graph in 3D.
            
        case 'Ring'
            config.rule_type = 0;
            G = torusGraph(num_nodes,config.self_loop(graph_indx),1,config);
            config.plot_3d = 0;    % plot graph in 3D.
            
        otherwise
            error('Requires a substrate shape. Check graph type.')
    end
    
    
%     if config.num_reservoirs > 1
        config.G{graph_indx} = G;
        temp_num_nodes(graph_indx) = size(config.G{graph_indx}.Nodes,1);
%     else
%         config.G = G;
%         temp_num_nodes =  size(config.G.Nodes,1);
%     end
       
end

config.rule_type = config.graph_type;       % used with Torus, 5 neighbours (Von Neumann) or 8 neighbours (Moore's)
config.num_nodes = temp_num_nodes;