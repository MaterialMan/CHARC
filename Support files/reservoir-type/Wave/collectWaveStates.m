function[final_states,individual] = collectWaveStates(individual,input_sequence,config)

%if single input entry, add previous state
if size(input_sequence,1) == 1
    input_sequence = [zeros(size(input_sequence)); input_sequence];
end

for i= 1:config.num_reservoirs
    if size(input_sequence,1) == 2
        states{i} = individual.last_state{i};
    else
        states{i} = zeros(size(input_sequence,1),individual.nodes(i));
    end
%     x{i} = zeros(size(input_sequence,1),individual.nodes(i));
%     
    % initialise bucket
    node_grid_size(i) = sqrt(individual.nodes(i));
    H{i} = zeros(node_grid_size(i));
    oldH{i}=H{i};
    newH{i}=H{i};
    
    if config.run_sim
        h{i}=surf(newH{i});
    end
    
    % this is a square but it could be any shape
    x_size(i,:) = 2:node_grid_size(i)-1; 
    y_size(i,:) = x_size(i,:);
    
    %% preassign allocate input sequence and time multiplexing
    input{i} = [input_sequence repmat(individual.bias_node(i),size(input_sequence,1),1)]*(individual.input_weights{i}*individual.input_scaling(i))';
    
    % time multiplex -
    input_mul{i} = zeros(size(input_sequence,1)*individual.time_period(i),size(input{i},2));
    if individual.time_period > 1
        input_mul{i}(mod(1:length(input_mul{i}),individual.time_period(i)) == 1,:) = input{i};
    else
        input_mul{i} = input{i};
    end    
end


%% equation: x(n) = f(Win*u(n) + S)
for n = 2:size(input_sequence,1)
    
    for i= 1:config.num_reservoirs
        
%         for k= 1:config.num_reservoirs
%             x{i}(n,:) = x{i}(n,:) + ((individual.W{i,k}*individual.W_scaling(i,k))*states{k}(n-1,:)')';
%         end
        
        % Wave equation
        newH{i} = Wave_sim(sqrt(individual.nodes(i)),x_size(i,:),y_size(i,:),individual.time_step(i)...
            ,individual.wave_speed(i),individual.damping_constant(i),... % apply liquid parameters
            H{i},oldH{i},... % set current and previous states
            individual.boundary_conditions(i,1),individual.boundary_conditions(i,2),individual.boundary_conditions(i,3)); %set boundary conditions
     
        if config.run_sim
            set(h{i},'zdata',newH{i},'facealpha',0.65);
            set(gca, 'xDir', 'reverse',...
                'camerapositionmode','manual','cameraposition',[0.5 0.5 2]);
            axis([1 node_grid_size(i) 1 node_grid_size(i) -2 2]);
            drawnow
            %pause(config.sim_speed);
        end
    
        oldH{i}=H{i};
        
        %add input
        newH{i} = newH{i} + reshape(input_mul{i}(n,:),node_grid_size(i),node_grid_size(i));
        
        H{i}=newH{i};
                
        states{i}(n,:) = newH{i}(:);
        
    end
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
    individual.last_state{i} = states{i}(end,:);
end

% concat input states
if config.add_input_states == 1
    final_states = [final_states input_sequence];
end

final_states = final_states(config.wash_out+1:end,:); % remove washout