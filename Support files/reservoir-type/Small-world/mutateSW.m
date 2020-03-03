%% Mutation operator used for SW reservoir systems
% Details:
% - number of weights mutated is based on mut_rate;
function offspring = mutateSW(offspring,config)

% params - input scaling and leak rate
input_scaling = offspring.input_scaling(:);
pos = randperm(length(input_scaling),sum(rand(length(input_scaling),1) < config.mut_rate));
input_scaling(pos) = 2*rand(length(pos),1)-1;
offspring.input_scaling = reshape(input_scaling,size(offspring.input_scaling));

leak_rate = offspring.leak_rate(:);
pos = randperm(length(leak_rate),sum(rand(length(leak_rate),1) < config.mut_rate));
leak_rate(pos) = rand(length(pos),1);
offspring.input_scaling = reshape(leak_rate,size(offspring.leak_rate));

% W scaling
W_scaling = offspring.W_scaling(:);
pos = randperm(length(W_scaling),sum(rand(length(W_scaling),1) < config.mut_rate));
W_scaling(pos) = 2*rand(length(pos),1);
offspring.W_scaling = reshape(W_scaling,size(offspring.W_scaling));

% cycle through all sub-reservoirs
for i = 1:config.num_reservoirs
    
    % input weights
    input_weights = offspring.input_weights{i}(:);
    pos =  randperm(length(input_weights),ceil(config.mut_rate*length(input_weights)));
    for n = 1:length(pos)
        input_weights(pos(n)) = mutateWeight(input_weights(pos(n)),config);
    end
    offspring.input_weights{i} = reshape(input_weights,size(offspring.input_weights{i}));
    
    % hidden weights
    for j = 1:config.num_reservoirs
        
        switch(config.SW_type)
            
            case 'topology'
                
                W = offspring.W{i,j};
                %change base graph
                f = find(adjacency(config.G{i,j}));
                pos = randperm(length(f),ceil(config.mut_rate*length(f)));
                
                % select weights to change
                for n = 1:length(pos)
                    W(f(pos(n))) = mutateWeight(W(f(pos(n))),config);
                end
                offspring.W{i,j} = W;
                
            case 'topology_plus_weights'% must maintain proportion of connections
                W = offspring.W{i,j};  % current graph
                base_W_0 = adjacency(config.G{i,j});
                pos_chng = find(~base_W_0); % non-base weights
                
                w1 = find(W(pos_chng)); %all non-zero non-base weights
                w = w1; %set default non-zero non-base weights
                
                for p = 1:ceil(config.mut_rate*length(w1)) % num to mutate
                    
                    pos(p) = randperm(length(w),1);
                    while(sum(pos(p) == pos(1:p-1)) > 0)
                        pos(p) = randperm(length(w),1);
                    end
                    
                    if round(rand) && config.P_rc < 1
                        % remove random non-zero non-base weight
                        W(pos_chng(w(pos(p)))) = 0;
                        
                        pos2(p) = w(pos(p));
                        while(sum(pos2(p) == w) > 0 || sum(pos2(p) == pos2(1:p-1)) > 0)
                            pos2(p) = randi([1 length(pos_chng)]);
                        end
                        
                        W(pos_chng(pos2(p))) = mutateWeight(W(pos_chng(pos2(p))),config);
                        
                        %check still okay
                        if nnz(offspring.W{i,j}) ~= nnz(W)
                            error('SW not working');
                        end
                    else
                        % change non-zero non-base weight to another value
                        W(pos_chng(w(pos(p)))) = mutateWeight(W(pos_chng(w(pos(p)))),config);
                    end
                    
                end
                
                %check still okay
                if nnz(offspring.W{i,j}) ~= nnz(W)
                    error('SW not working');
                end
                
                offspring.W{i,j} = W;
                
                %change base graph
                f = find(base_W_0);
                pos = randperm(length(f),ceil(config.mut_rate*length(f)));
                
                % select weights to change
                for n = 1:length(pos)
                    W(f(pos(n))) = mutateWeight(W(f(pos(n))),config);
                end
                offspring.W{i,j} = W;
                
            case 'watts_strogartz'
                
                W = offspring.W{i,j};
                f = find(W);
                pos = randperm(length(f),ceil(config.mut_rate*length(f)));
                
                for n = 1:length(pos)
                    % switch
                    if rand < config.P_rc% rewiring probability
                        % find row and col
                        [row,col] = ind2sub(size(W),f(pos(n)));
                        
                        tmp_val1 = W(row,col);
                        tmp_val2 = W(col,row);
                        
                        W(row,col) = 0;
                        W(col,row) = 0;
                        
                        list = 1:length(W);
                        list(list == row) = [];
                        list(list == col) = [];
                        
                        indx = randi([1 length(list)]);
                        
                        W(row,list(indx)) = tmp_val1;
                        W(list(indx),col) = tmp_val2;
                    else
                        W(f(pos(n))) = mutateWeight(W(f(pos(n))),config);
                    end
                end
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
    
end

% mutate output weights
if config.evolve_output_weights
    output_weights = offspring.output_weights(:);
    pos =  randperm(length(output_weights),ceil(config.mut_rate*length(output_weights)));
    
    for n = 1:length(pos)
        output_weights(pos(n)) = mutateWeight(output_weights(pos(n)),config);
    end
    offspring.output_weights = reshape(output_weights,size(offspring.output_weights));
end

% mutate feedback weights
if config.evolve_feedback_weights
    % feedback scaling
    feedback_scaling = offspring.feedback_scaling(:);
    pos =  randperm(length(feedback_scaling),sum(rand(length(feedback_scaling),1) < config.mut_rate));
    feedback_scaling(pos) = 2*rand(length(pos),1);
    offspring.feedback_scaling = reshape(feedback_scaling,size(offspring.feedback_scaling));
    
    feedback_weights = offspring.feedback_weights(:);
    pos =  randperm(length(feedback_weights),ceil(config.mut_rate*length(feedback_weights)));
    
    for n = 1:length(pos)
        feedback_weights(pos(n)) = mutateWeight(feedback_weights(pos(n)),config);
    end
    offspring.feedback_weights = reshape(feedback_weights,size(offspring.feedback_weights));
end
end

function value = mutateWeight(value,config)

switch(config.mutate_type)
    case 'gaussian'
        value = value-randn*0.15;
        
    case 'uniform'
        if rand > 0.5 % 50% chance to zero weight
            value = 0;
        else
            value = 2*rand-1;
        end
end
end