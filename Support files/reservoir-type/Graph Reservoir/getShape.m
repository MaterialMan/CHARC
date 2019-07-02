%% called from getDataSetInfo
% Create graph structure G to use

function config = getShape(config)

switch(config.graph_type)

    case 'Bucky'
        config.G = graph(bucky);
        config.plot_3d = 1;      % plot graph in 3D.
        
    case 'L'
        A = delsq(numgrid('L',config.NGrid +2));
        config.G = graph(A,'omitselfloops');
        config.plot_3d = 0;    % plot graph in 3D.
        
    case 'Hypercube'
        A = hypercube(config.num_nodes);
        config.G = graph(A);
        config.plot_3d = 1;    % plot graph in 3D.
        
    case 'Torus'
        config.G = torusGraph(config.num_nodes,config.self_loop,config.num_reservoirs,config);
        config.plot_3d = 1;    % plot graph in 3D.
    
    case 'Barbell'
        load barbellgraph.mat
        config.G = graph(A,'omitselfloops');
        config.plot_3d = 0;    % plot graph in 3D.
        
    case 'basicLattice'||'partialLattice'||'fullLattice'||'basicCube'||'partialCube'||'fullCube'|| 'ensembleLattice'|| 'ensembleCube'||'ensembleShape'
        
        config.G = createLattice(config.num_nodes,config.latticeType,config.self_loop,config.num_reservoirs);
        config.plot_3d = 0;    % plot graph in 3D.
        
    case 'Ring'
        config.G = torusGraph(config.num_nodes,config.self_loop,1,config);
        config.plot_3d = 0;    % plot graph in 3D.
        
    otherwise
        error('Requires a substrate shape.')
end

 config.rule_type = config.lattice_type;       % used with Torus, 5 neighbours (Von Neumann) or 8 neighbours (Moore's)
 config.num_nodes =  size(config.G.Nodes,1);      