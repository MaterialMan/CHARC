%% Types of reservoirs available
% If creating a new reservoir, add a case statement here to point to
% necessary functions

function config = selectReservoirType(config)

switch(config.res_type)
    
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
        config.mutFcn = @mutateRoR;
        config.recFcn = @recombRoR;
         
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
end

if strcmp(config.res_type,'CNT')
    config.testFcn = @testHardwareReservoir;
else
    config.testFcn = @testReservoir; % default for all
end