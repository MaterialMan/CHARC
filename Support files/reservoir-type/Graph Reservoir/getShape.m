%% called from getDataSetInfo
% Create graph structure G to use

function config = getShape(config)

temp_num_nodes = 0;

for graph_indx = 1:length(config.num_nodes)
    
    if iscell(config.num_nodes)
        num_nodes= config.num_nodes{graph_indx};
    else
        num_nodes = config.num_nodes;
    end
    
    switch(config.graph_type)
        
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
            G = torusGraph(num_nodes,config.self_loop,config.num_reservoirs,config);
            config.plot_3d = 1;    % plot graph in 3D.
            
        case 'Barbell'
            load barbellgraph.mat
            G = graph(A,'omitselfloops');
            config.plot_3d = 0;    % plot graph in 3D.
            
        case {'basicLattice','partialLattice','fullLattice','basicCube','partialCube','fullCube','ensembleLattice', 'ensembleCube','ensembleShape'}
            G = createLattice(num_nodes,config.graph_type,config.self_loop,config.num_reservoirs);
            config.plot_3d = 0;    % plot graph in 3D.
            
        case 'Ring'
            G = torusGraph(num_nodes,config.self_loop,1,config);
            config.plot_3d = 0;    % plot graph in 3D.
            
        otherwise
            error('Requires a substrate shape.')
    end
    
    
    if iscell(config.num_nodes)
        config.G{graph_indx} = G;
        temp_num_nodes = size(config.G{graph_indx}.Nodes,1);
    else
        config.G = G;
        temp_num_nodes =  size(config.G.Nodes,1);
    end
       
end

config.rule_type = config.graph_type;       % used with Torus, 5 neighbours (Von Neumann) or 8 neighbours (Moore's)
config.num_nodes = temp_num_nodes;