%% Objective function
function y = fitnessNSGAII(genotype,config)

%Assess each task
y = zeros(1,config.num_objectives);
for j = 1:config.num_objectives
    config.trainInputSequence = config.data{1,j}.trainInputSequence;
    config.trainOutputSequence = config.data{1,j}.trainOutputSequence;
    
    config.valInputSequence = config.data{1,j}.valInputSequence;
    config.valOutputSequence = config.data{1,j}.valOutputSequence;
    
    config.testInputSequence = config.data{1,j}.testInputSequence;
    config.testOutputSequence = config.data{1,j}.testOutputSequence;
    
    config.nForgetPoints =  config.data{1,j}.nForgetPoints;
    config.errType = config.data{1,j}.errType;
    
    config.task_num_inputs = size(config.trainInputSequence,2);
    config.task_num_outputs = size(config.trainOutputSequence,2);
    
    genotype = testReservoir(genotype,config);
    y(j) = sum(genotype.valError);%sum(genotype.trainError + genotype.valError);
end

end