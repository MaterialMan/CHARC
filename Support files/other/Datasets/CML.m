function [x] = CML(individual, input_sequence, config)

switch(config.type)
    
    case 'CML' % coupled map lattice
        x = [1 individual.x0 1];
        for n = 1:config.time_steps
            x(n+1,2:end-1) = (1 - individual.W').*f(x(n,2:end-1)) + (individual.W'/2).*(f(x(n,3:end)) + f(x(n,1:end-2)));% + individual.Win'*input_sequence(n,:);
        end
        
    case 'GCM' % globally coupled map
        x = individual.x0;
        for n = 1:config.time_steps
           x(n+1,:) = (1 - individual.W').*f(x(n,:)) + (individual.W'/individual.lattice_size)*sum(f(x(n,:)));
        end       
end


imagesc(x')
drawnow

    % logistic map function
    function x = f(x)
        x = 1-individual.r*x.^2;
    end
end