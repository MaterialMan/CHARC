function [genotype,inactiveGenes] = createGenotypeHardware(popSize,numElectrodes,voltageRange,range)

genotype = zeros(popSize,numElectrodes/2,6);

for p= 1:popSize       
         %Assign random in-out ratios
         inOutperm =randperm(numElectrodes);
         
         genotype(p,:,1) = inOutperm(1:numElectrodes/2);
            
         if range ==1 %only one input
             genotype(p,randi([1 numElectrodes/2]),2)=1;
         else             
             for j = 1:randi([1 range]) %up to 'range' inputs
                 genotype(p,randi([1 numElectrodes/2]),2)= round(rand);
             end
             if sum(genotype(p,:,2)) == 0
                 genotype(p,randi([1 numElectrodes/2]),2)=1;
             end
         end
         
        for i = 1:numElectrodes/2
            
            genotype(p,i,3)= round(rand);%sum(rand >= cumsum([0.5, 0.5])); %50/50 ratio of controls to weights
            genotype(p,i,4)= (-voltageRange-voltageRange)*rand+voltageRange;%rand*voltageRange;%
            genotype(p,i,5)= (-voltageRange-voltageRange)*rand+voltageRange;%rand*voltageRange;%
        end
        
        genotype(p,1,6) = rand;
        inactiveGenes = inOutperm(33:end);
end