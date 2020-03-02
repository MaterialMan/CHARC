%% Types of reservoirs available
% If creating a new reservoir, add a case statement here to point to
% necessary functions

function config = selectReservoirType(config)

% if more than one type of reservoir set to heterotic
if iscell(config.res_type) 
    res_type = 'Heterotic';
else
    res_type = config.res_type;
end

%% Get pointers for each reservoir type
switch(res_type)
    
    case 'ELM'
        config.createFcn = @createELM;
        config.assessFcn = @collectELMStates;
        config.mutFcn = @mutateRoR;
        config.recFcn = @recombRoR;
        
    case 'RoR'
        config.createFcn = @createRoR;
        config.assessFcn = @collectRoRStates;
        config.mutFcn = @mutateRoR;
        config.recFcn = @recombRoR;
        
    case 'Pipeline'
        config.createFcn = @createPipeline;
        config.assessFcn = @collectPipelineStates;
        config.mutFcn = @mutateRoR;
        config.recFcn = @recombRoR;
        
    case 'Ensemble'
        config.createFcn = @createEnsemble;
        config.assessFcn = @collectEnsembleStates;
        config.mutFcn = @mutateRoR;
        config.recFcn = @recombRoR;
        config.hierarchy = 1;
        
    case 'Graph'
        config.createFcn = @createGraphReservoir;
        config.assessFcn = @assessGraphReservoir;
        config.mutFcn = @mutateSW;
        config.recFcn = @recombSW;
        
    case 'BZ'
        config.createFcn = @createBZReservoir;
        config.assessFcn = @assessBZReservoir;
        config.mutFcn = @mutateBZ;
        config.recFcn = @recombBZ;
        
    case 'RBN'
        config.createFcn = @createRBNreservoir;
        config.assessFcn = @assessRBNreservoir;
        config.mutFcn = @mutateRBN;
        config.recFcn = @recombRBN;
        
    case 'elementary_CA'
        config.createFcn = @createRBNreservoir;
        config.assessFcn = @assessRBNreservoir;
        config.mutFcn = @mutateRBN;
        config.recFcn = @recombRBN;
        
    case '2D_CA'
        config.createFcn = @createRBNreservoir;
        config.assessFcn = @assessRBNreservoir;
        config.mutFcn = @mutateRBN;
        config.recFcn = @recombRBN;
        
    case 'DNA'
        config.createFcn = @createDNAreservoir;
        config.assessFcn = @assessDNAreservoir;
        config.mutFcn = @mutateDNA;
        config.recFcn = @recombDNA;
        
    case 'DL'
        config.createFcn = @createDLReservoir;
        config.assessFcn = @collectDLStates;
        config.mutFcn = @mutateDL;
        config.recFcn = @recombDL;
        
    case 'instrRes'
        config.createFcn = @createInstruReservoir;
        config.assessFcn = @assessInstru;
        config.mutFcn = @mutateInstru;
        config.recFcn = @recombInstru;
        
    case 'CNT'
        config.createFcn = @createCNT;
        config.assessFcn = @collectCNTStates;
        config.mutFcn = @mutateCNT;
        config.recFcn = @recombCNT;
        
    case 'Wave'
        config.createFcn = @createWave;
        config.assessFcn = @collectWaveStates;
        config.mutFcn = @mutateWave;
        config.recFcn = @recombWave;
        
    case 'MM'
        config.createFcn = @createMM;
        config.assessFcn = @collectMMStates;
        config.mutFcn = @mutateMM;
        config.recFcn = @recombMM;
        
    case 'GOL'
        config.createFcn = @createGOL;
        config.assessFcn = @assessGOL;
        config.mutFcn = @mutateGOL;
        config.recFcn = @recombGOL;
        
    case 'Ising'
        config.createFcn = @createIsing;
        config.assessFcn = @assessIsing;
        config.mutFcn = @mutateIsing;
        config.recFcn = @recombIsing;
        
    case 'SW'
        config.createFcn = @createSWReservoir;
        config.assessFcn = @collectRoRStates;
        config.mutFcn = @mutateSW;
        config.recFcn = @recombSW;
        
    case 'Heterotic'
        config.createFcn = @createHeterotic;
        config.assessFcn = @assessHeterotic;
        config.mutFcn = @mutateHeterotic;
        config.recFcn = @recombHeterotic;
end

%% set reservoir test function
switch(res_type)
    case 'CNT'
        config.testFcn = @testHardwareReservoir;
    otherwise
        config.testFcn = @testReservoir; % default for all
end