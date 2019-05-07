%% called from getDataSetInfo
% Create graph structure G to use

function config = getShape(config)

switch(config.substrate)

    case 'Bucky'
        config.G = graph(bucky);
        config.N = size(config.G.Nodes,1);
        config.plot3d = 1;      % plot graph in 3D.
        
    case 'L'
        A = delsq(numgrid('L',config.NGrid +2));
        config.G = graph(A,'omitselfloops');
        config.N = size(config.G.Nodes,1);
        config.plot3d = 0;    % plot graph in 3D.
        
    case 'Hypercube'
        A = hypercube(config.NGrid);
        config.G = graph(A);
        config.N = size(config.G.Nodes,1);
        config.plot3d = 1;    % plot graph in 3D.
        
    case 'Torus'
        config.G = torusGraph(config.NGrid,config.self_loop,config.N_rings,config);
        config.N = size(config.G.Nodes,1);
        config.plot3d = 1;    % plot graph in 3D.
    
    case 'Barbell'
        load barbellgraph.mat
        config.G = graph(A,'omitselfloops');
        config.N = size(config.G.Nodes,1);
        config.plot3d = 0;    % plot graph in 3D.
        
    case 'Lattice'
        config.G = createLattice(config.NGrid,config.latticeType,config.self_loop,config.num_ensemble);
        config.N = size(config.G.Nodes,1);
        config.plot3d = 0;    % plot graph in 3D.
        
    case 'Cube'
        config.G = createLattice(config.NGrid,config.latticeType,config.self_loop,config.num_ensemble);
        config.N = size(config.G.Nodes,1);
        config.plot3d = 0;    % plot graph in 3D.
        
    case 'Ring'
        config.G = torusGraph(config.NGrid,config.self_loop,1,config);
        config.N = size(config.G.Nodes,1);
        config.plot3d = 0;    % plot graph in 3D.
        
    otherwise
        error('Requires a substrate shape.')
end
