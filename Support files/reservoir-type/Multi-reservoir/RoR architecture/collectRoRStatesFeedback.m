function[final_states,output_sequence,individual] = collectRoRStatesFeedback(individual,input_sequence,config)

%if single input entry, add previous state
if size(input_sequence,1) == 1
    input_sequence = [zeros(size(input_sequence)); input_sequence];
end

output_sequence = zeros(size(input_sequence));

for i= 1:config.num_reservoirs
    if size(input_sequence,1) == 2
        states{i} = individual.last_state{i};
    else
        states{i} = zeros(size(input_sequence,1),individual.nodes(i));
    end
    x{i} = zeros(size(input_sequence,1),individual.nodes(i));
end

final_states = zeros(size(input_sequence,1),individual.total_units);
 
% preassign activation function calls
if size(individual.activ_Fcn,2) > 1
    for i= 1:config.num_reservoirs
        for p = 1:length(config.activ_list)
            index{i,p} = findActiv({individual.activ_Fcn{i,:}},config.activ_list{p});
        end
    end
end

%equation: x(n) = f(Win*u(n) + S)
for n = 2:size(input_sequence,1)
    n_states = [];
    for i= 1:config.num_reservoirs
        
        for k= 1:config.num_reservoirs
            x{i}(n,:) = x{i}(n,:) + ((individual.W{i,k}*individual.W_scaling(i,k))*states{k}(n-1,:)')';
        end
        
        if size(individual.activ_Fcn,2) > 1
            for p = 1:length(config.activ_list)
                states{i}(n,index{i,p}) = config.activ_list{p}(((individual.input_weights{i}(index{i,p},:)*individual.input_scaling(i))*([individual.bias_node input_sequence(n,:)])')+ x{i}(n,index{i,p})' + individual.feedback_weights(index{i,p},:)*individual.feedback_scaling*output_sequence(n-1,:)');
            end
        else
            if n <= ceil(length(input_sequence)/2)
                %states{i}(n,:) = individual.activ_Fcn{1}(((individual.input_weights{i}*individual.input_scaling(i))*([individual.bias_node input_sequence(n,:)])')+ x{i}(n,:)');
                %states{i}(n,:) = individual.activ_Fcn{1}(((individual.input_weights{i}*individual.input_scaling(i))*([individual.bias_node ones(1,size(input_sequence(n,:),2))*0.2])')+ x{i}(n,:)' + individual.feedback_weights*individual.feedback_scaling*input_sequence(n-1,:)');    
                states{i}(n,:) = individual.activ_Fcn{1}(x{i}(n,:)' + individual.feedback_weights*individual.feedback_scaling*input_sequence(n-1,:)');    

            else
                if n == ceil(length(input_sequence)/2) +1                    
                    % concat all states for output weights
                    final_states = [];
                    for j= 1:config.num_reservoirs
                        final_states = [final_states states{j}(1:n-1,:)]; 
                    end
                    
                    final_states = final_states(config.wash_out+1:end,:);
                    individual.output_weights = (config.train_output_sequence(config.wash_out+1:n-1,:)'*final_states*inv(final_states'*final_states + 10e-7*eye(size(final_states'*final_states))))';
                    
                    % Calculate trained output Y
                    output_sequence(config.wash_out+1:n-1,:) = final_states*individual.output_weights;
                else
                          
                 states{i}(n,:) = individual.activ_Fcn{1}(x{i}(n,:)' + individual.feedback_weights*individual.feedback_scaling*output_sequence(n-1,:)');
                 output_sequence(n,:) = states{i}(n,:)*individual.output_weights;
                 
                % states{i}(n,:) = individual.activ_Fcn{1}(((individual.input_weights{i}*individual.input_scaling(i))*([individual.bias_node ones(1,size(input_sequence(n,:),2))*0.2])')+ x{i}(n,:)' + individual.feedback_weights*individual.feedback_scaling*output_sequence(n-1,:)');
                % states{i}(n,:) = individual.activ_Fcn{1}(x{i}(n,:)' + individual.feedback_weights*individual.feedback_scaling*output_sequence(n-1,:)');
                end
            end
        end
        
%         if config.leak_on
%             states{i}(n,:) = (1-individual.leak_rate(i))*states{i}(n-1,:)+ individual.leak_rate(i)*states{i}(n,:);
%         end
%         
%         % concat all states for output weights
         n_states = [n_states states{i}(n,:)];
    end
       
%     output_sequence(n,:) = n_states*individual.output_weights;
% 
     final_states(n,:)  = n_states;
end

%final_states = [zeros(1,size(final_states,2)); final_states]; % remove washout
final_states = final_states(config.wash_out+1:end,:); % remove washout