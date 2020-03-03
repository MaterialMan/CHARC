%% Mutation operator used for different reservoir systems
% Details:
% - number of weights mutated is based on mut_rate; 
function offspring = mutateRoR(offspring,config)

% params - input scaling and leak rate
input_scaling = offspring.input_scaling(:);
pos = randperm(length(input_scaling),sum(rand(length(input_scaling),1) < config.mut_rate));
input_scaling(pos) = mutateWeight(input_scaling(pos),config);
offspring.input_scaling = reshape(input_scaling,size(offspring.input_scaling));

leak_rate = offspring.leak_rate(:);
pos = randperm(length(leak_rate),sum(rand(length(leak_rate),1) < config.mut_rate));
leak_rate(pos) = mutateWeight(leak_rate(pos),config);
offspring.input_scaling = reshape(leak_rate,size(offspring.leak_rate));

% W scaling
W_scaling = offspring.W_scaling(:);
pos = randperm(length(W_scaling),sum(rand(length(W_scaling),1) < config.mut_rate));
W_scaling(pos) = mutateWeight(W_scaling(pos),config);
offspring.W_scaling = reshape(W_scaling,size(offspring.W_scaling));

% cycle through all sub-reservoirs
for i = 1:config.num_reservoirs
    
    % input weights
    input_weights = offspring.input_weights{i}(:);
    pos = randperm(length(input_weights),sum(rand(length(input_weights),1) < config.mut_rate));
    input_weights(pos) = mutateWeight(input_weights(pos),config); 
    offspring.input_weights{i} = reshape(input_weights,size(offspring.input_weights{i}));
        
    % hidden weights
    for j = 1:config.num_reservoirs
        % only mutate one half of matrix if undirected weights in use
        if (config.undirected_ensemble && i ~= j) || (config.undirected && i == j)
            W= triu(offspring.W{i,j});
            f = find(W);
             pos = randperm(length(f),sum(rand(length(f),1) < config.mut_rate));
            W(f(pos)) = mutateWeight(W(f(pos)),config);
            W = triu(W)+triu(W,1)'; % copy top-half to lower-half
            offspring.W{i,j} = W;
        else
            W = offspring.W{i,j}(:);
            % select weights to change
            pos = randperm(length(W),sum(rand(length(W),1) < config.mut_rate));
            W(pos) = mutateWeight(W(pos),config);
            offspring.W{i,j} = reshape(W,size(offspring.W{i,j}));
            
            %                 if rand < 0.5 % knock out a node and its connections
            %                     pos2 = randi([1 length(offspring.W{i,j})],ceil(config.mut_rate*length(offspring.W{i,j})),1);
            %                     offspring.W{i,j}(pos2,:) = 0;
            %                     offspring.W{i,j}(:,pos2) = 0;
            %                 end
        end
               
        offspring.connectivity(i,j) = nnz(offspring.W{i,j})/offspring.total_units.^2;
    end
    
    % mutate activ fcns
    if config.multi_activ
        activFcn = offspring.activ_Fcn(i,:);
        pos =  randperm(length(activFcn),sum(rand(length(activFcn),1) < config.mut_rate));
        activFcn(pos) = {config.activ_list{randi([1 length(config.activ_list)],length(pos),1)}};
        offspring.activ_Fcn(i,:) = reshape(activFcn,size(offspring.activ_Fcn(i,:)));
    else
        activFcn = offspring.activ_Fcn;
        pos =  randperm(length(activFcn),sum(rand(length(activFcn),1) < config.mut_rate));
        activFcn(pos) = {config.activ_list{randi([1 length(config.activ_list)],length(pos),1)}};
        offspring.activ_Fcn = reshape(activFcn,size(offspring.activ_Fcn));
    end
    
    if config.iir_filter_on
        iir_feedfoward = offspring.iir_weights{i,1}(:,1);
        pos = randperm(length(iir_feedfoward),sum(rand(length(iir_feedfoward),1) < config.mut_rate));
        w_0 = mutateWeight(iir_feedfoward(pos),config);        
        alpha = sin(w_0).*sinh((log(2)./2) * (3*rand) * (w_0./(sin(w_0))));
        offspring.iir_weights{i,1}(pos,:) = alpha .* [1 0 -1]; 
                
        %offspring.iir_weights{i,1} = reshape(iir_feedfoward,size(offspring.iir_weights{i,1}));
        
        %iir_feedback = offspring.iir_weights{i,2}(:,1);
        %pos =  randperm(length(iir_feedback),ceil(config.mut_rate*length(iir_feedback)));
        %iir_feedback(pos) = mutateWeight(iir_feedback(pos),config);
        
        offspring.iir_weights{i,2}(pos,:) = [1+alpha -2*cos(w_0) 1-alpha];%reshape(iir_feedback,size(offspring.iir_weights{i,2}));        
        
    end
end

% mutate output weights
if config.evolve_output_weights
    output_weights = offspring.output_weights(:);
    pos = randperm(length(output_weights),sum(rand(length(output_weights),1) < config.mut_rate));   
    output_weights(pos) = mutateWeight(output_weights(pos),config);
    offspring.output_weights = reshape(output_weights,size(offspring.output_weights));
end

% mutate feedback weights
if config.evolve_feedback_weights
    % feedback scaling
    feedback_scaling = offspring.feedback_scaling(:);
    pos =  randperm(length(feedback_scaling),sum(rand(length(feedback_scaling),1) < config.mut_rate));
    feedback_scaling(pos) = mutateWeight(feedback_scaling(pos),config);
    offspring.feedback_scaling = reshape(feedback_scaling,size(offspring.feedback_scaling));
    
    feedback_weights = offspring.feedback_weights(:);
    pos = randperm(length(feedback_weights),sum(rand(length(feedback_weights),1) < config.mut_rate));
       
    feedback_weights(pos) = mutateWeight(feedback_weights(pos),config);
    offspring.feedback_weights = reshape(feedback_weights,size(offspring.feedback_weights));
end
end

function value = mutateWeight(value,config)

switch(config.mutate_type)
    case 'gaussian'
        value = value-randn(size(value))*0.15;
        
    case 'uniform'
        value = 2*rand(size(value))-1;
end
end