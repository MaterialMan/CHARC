%% called from getDataSetInfo
% Create graph structure G to use

function [config,new_num_nodes] = getShape(config)


for graph_indx = 1:length(config.num_nodes)
    
    num_nodes= config.num_nodes(graph_indx);
    graph_type = config.graph_type{graph_indx};
       
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
            config.rule_type = 'Moores';
            config.torus_rings = config.num_nodes;
            G = torusGraph(num_nodes,config.self_loop(graph_indx),config);
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
            config.torus_rings = 1;
            G = torusGraph(num_nodes,config.self_loop(graph_indx),config);
            config.plot_3d = 0;    % plot graph in 3D.                 
  
        otherwise
            error('Requires a substrate shape. Check graph type.')
    end
    
    config.G{graph_indx} = G;
    new_num_nodes(graph_indx) = size(config.G{graph_indx}.Nodes,1);
end
