%% Types of reservoirs available
function config = selectReservoirType(config)

switch(config.res_type)
    
    case 'ELM'
        config.createFcn = @createELM;
        config.assessFcn = @collectELMStates;
        config.mutFcn = @mutateRoR;
        config.recFcn = @recombRoR;
        config.hierarchy = 1;
        
    case 'RoR' 
        config.createFcn = @createRoR;
        config.assessFcn = @collectRoRStates;
        config.mutFcn = @mutateRoR;
        config.recFcn = @recombRoR;
        config.hierarchy = 1;
           
    case 'RoR_IA_v2'
        config.createFcn = @createRoR_v2;
        config.assessFcn = @collectDeepStates_IA_v2;
        config.mutFcn = @mutateRoR_v2;
        config.recFcn = @recombRoR_v2;
        config.hierarchy = 1;
        
    case 'RoR_IA_delay' % not working yet
        config.createFcn = @createDelayRoR;
        config.assessFcn = @collectDeepDelayStates_IA;
        config.mutFcn = @mutateRoRdelay;
        config.recFcn = @recombRoR;
        config.hierarchy = 1;
        
    case 'Pipeline'
        config.createFcn = @createPipeline;
        config.assessFcn = @collectPipelineStates;
        config.mutFcn = @mutateRoR;
        config.recFcn = @recombRoR;
        config.hierarchy = 1;
        
         
    case 'Ensemble'
        config.createFcn = @createEnsemble;
        config.assessFcn = @collectEnsembleStates;
        config.mutFcn = @mutateRoR;
        config.recFcn = @recombRoR;
        config.hierarchy = 1;
         
    case 'Graph'
        config.createFcn = @createGraphReservoir;
        config.assessFcn = @assessGraphReservoir;
        config.mutFcn = @mutateGraph;
        config.recFcn = @recombGraph;
         config.hierarchy = 0;
         
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
        
    case 'basicCA'
        config.createFcn = @createRBNreservoir;
        config.assessFcn = @assessRBNreservoir;
        config.mutFcn = @mutateRBN;
        config.recFcn = @recombRBN;
        
    case '2dCA'
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
        
end

config.testFcn = @testReservoir; % default for all