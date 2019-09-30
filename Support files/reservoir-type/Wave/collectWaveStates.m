function[final_states,individual] = collectWaveStates(individual,input_sequence,config)

%if single input entry, add previous state
if size(input_sequence,1) == 1
    input_sequence = [zeros(size(input_sequence)); input_sequence];
end

for i= 1:config.num_reservoirs
        
    % initialise bucket
    node_grid_size(i) = sqrt(individual.nodes(i));
    
    if size(input_sequence,1) == 2
        states{i} = individual.last_state{i};
        H{i} = reshape(states{i}(end,:),node_grid_size(i),node_grid_size(i));
        oldH{i}= reshape(states{i}(end-1,:),node_grid_size(i),node_grid_size(i));
        %oldH{i}=zeros(node_grid_size(i));
        newH{i}=zeros(node_grid_size(i));
    else
        %states{i} = zeros(size(input_sequence,1),individual.nodes(i));
        H{i} = zeros(node_grid_size(i));
        oldH{i}=H{i};
        newH{i}=H{i};
    end

    % this is a square but it could be any shape
    x_size(i,:) = 2:node_grid_size(i)-1; 
    y_size(i,:) = x_size(i,:);
    
    %% preassign allocate input sequence and time multiplexing
    input{i} = [input_sequence repmat(individual.bias_node(i),size(input_sequence,1),1)]*(individual.input_weights{i}*individual.input_scaling(i))';
    
    % time multiplex -
    input_mul{i} = zeros(size(input_sequence,1)*individual.time_period(i),size(input{i},2));
    if individual.time_period > 1
        input_mul{i}(mod(1:size(input_mul{i},1),individual.time_period(i)) == 1,:) = input{i};
    else
        input_mul{i} = input{i};
    end    
    
    states{i} = zeros(size(input_mul{i},1),individual.nodes(i));
end


%% equation: x(n) = f(Win*u(n) + S)
for n = 2:size(input_mul{i})%size(input_sequence,1)
    
    for i= 1:config.num_reservoirs
        
%         for k= 1:config.num_reservoirs
%             x{i}(n,:) = x{i}(n,:) + ((individual.W{i,k}*individual.W_scaling(i,k))*states{k}(n-1,:)')';
%         end
        
        % Wave equation
        newH{i} = Wave_sim(sqrt(individual.nodes(i)),x_size,y_size,individual.time_step(i)...
            ,individual.wave_speed(i),individual.damping_constant(i),... % apply liquid parameters
            H{i},oldH{i},... % set current and previous states
            individual.boundary_conditions(i,1),individual.boundary_conditions(i,2),individual.boundary_conditions(i,3)); %set boundary conditions
         
        oldH{i}=H{i};
        
        %add input
        in = reshape(input_mul{i}(n,:),node_grid_size(i),node_grid_size(i));
        %newH{i} = newH{i} + reshape(input_mul{i}(n,:),node_grid_size(i),node_grid_size(i));
        
        newH{i}(logical(in)) = newH{i}(logical(in)) + nonzeros(in);
        oldH{i}(logical(in)) = newH{i}(logical(in)) + nonzeros(in);
        
        H{i}=newH{i};
             
        %states{i}(n,:) = reshape(newH{i},1,individual.nodes(i));
        
        states{i}(n,:) = newH{i}(:);
        states{i}(n-1,:) = oldH{i}(:);
    end
end

%need to check! deplex to get states
if individual.time_period(i) > 1
    states{i} = states{i}(mod(1:size(states{i},1),individual.time_period(i)) == 1,:);
end

% get leak states
if config.leak_on
    states = getLeakStates(states,individual,input_sequence,config);
end

% concat all states for output weights
final_states = [];
for i= 1:config.num_reservoirs
%     if sum(sum(isnan(states{i}))) > 1 || sum(sum(isinf(states{i}))) > 1
%         states{i} = zeros(size(input_sequence,1),individual.nodes(i));
%     end
    
    final_states = [final_states states{i}];
    
    %assign last state variable
    individual.last_state{i} = states{i}(end-1:end,:);
end

% concat input states
if config.add_input_states == 1
    final_states = [final_states input_sequence];
end

if size(input_sequence,1) == 2
    final_states = final_states(end,:); % remove washout
else
    final_states = final_states(config.wash_out+1:end,:); % remove washout
end