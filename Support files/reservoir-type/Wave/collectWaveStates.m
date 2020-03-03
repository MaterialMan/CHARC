function[final_states,individual] = collectWaveStates(individual,input_sequence,config,target_output)

%if single input entry, add previous state
if size(input_sequence,1) == 1
    input_sequence = [zeros(size(input_sequence)); input_sequence];
end

max_input_length = 0;

for i= 1:config.num_reservoirs
        
    % initialise bucket
    node_grid_size(i) = sqrt(individual.nodes(i));
    
    if size(input_sequence,1) == 2
        states{i} = individual.last_state{i};
        H{i} = reshape(states{i}(end,:),node_grid_size(i),node_grid_size(i));
        oldH{i}= reshape(states{i}(end,:),node_grid_size(i),node_grid_size(i));
        %oldH{i}=zeros(node_grid_size(i));
        %newH{i}=zeros(node_grid_size(i));
    else
        %states{i} = zeros(size(input_sequence,1),individual.nodes(i));
        H{i} = zeros(node_grid_size(i));
        oldH{i}=H{i};
        newH{i}=H{i};
    end

    % this is a square but it could be any shape
    x_size{i} = 2:node_grid_size(i)-1; 
    y_size{i} = x_size{i};
    
    %% preassign allocate input sequence and time multiplexing
    input{i} = [input_sequence repmat(individual.bias_node,size(input_sequence,1),1)]*(individual.input_weights{i}*individual.input_scaling(i))';
    
    % time multiplex -
    input_mul{i} = zeros(size(input_sequence,1)*individual.time_period(i),size(input{i},2));
    if individual.time_period(i) > 1
        input_mul{i}(mod(1:size(input_mul{i},1),individual.time_period(i)) == 1,:) = input{i};
    else
        input_mul{i} = input{i};
    end    
    
    % change input widths
    for n = 1:size(input_mul{i},1)
        m = reshape(input_mul{i}(n,:),node_grid_size(i),node_grid_size(i));
        f_pos = find(m);
        input_matrix_2d = m;
        for p = 1:length(f_pos)
            t = zeros(size(m));
            t(f_pos(p)) = m(f_pos(p));
            [t] = adjustInputShape(t,individual.input_widths{i}(f_pos(p)));
            input_matrix_2d = input_matrix_2d + t;
        end
        input_mul{i}(n,:) = input_matrix_2d(:);
    end

    x{i} = zeros(size(input_mul{i},1),individual.nodes(i));
    states{i} = zeros(size(input_mul{i},1),individual.nodes(i));

    if size(input_mul{i},1) > max_input_length
        max_input_length = size(input_mul{i},1);
    end
end

%% equation: x(n) = f(Win*u(n) + S)
for n = 2:max_input_length
    
    for i= 1:config.num_reservoirs
        
        for k= 1:config.num_reservoirs
            if mod(n,individual.time_period(i)) == 0
                %step = n/individual.time_period(i);
                x{i}(n,:) = x{i}(n,:) + ((individual.W{i,k}*individual.W_scaling(i,k))*states{k}(n-1,:)')';
            else
                x{i}(n,:) = zeros(1,individual.nodes(i));
            end
        end
        
        % Wave equation
        newH{i} = Wave_sim(sqrt(individual.nodes(i)),x_size{i},y_size{i},individual.time_step(i)...
            ,individual.wave_speed(i),individual.damping_constant(i),... % apply liquid parameters
            H{i},oldH{i},... % set current and previous states
            individual.boundary_conditions(i,1),individual.boundary_conditions(i,2),individual.boundary_conditions(i,3)); %set boundary conditions
         
        % store H
        oldH{i}=H{i};
          
        %add input
        in = reshape(input_mul{i}(n,:),node_grid_size(i),node_grid_size(i)) + reshape(x{i}(n-1,:),node_grid_size(i),node_grid_size(i));
  
        %update 
%         H{i}(logical(in)) = newH{i}(logical(in)) + nonzeros(in);
%         %oldH{i}(logical(in)) = oldH{i}(logical(in)) + nonzeros(in);
%         states{i}(n,:) = newH{i}(:);
        
        newH{i}(logical(in)) = newH{i}(logical(in)) + nonzeros(in);%
        %oldH{i}(logical(in)) = newH{i}(logical(in)) + nonzeros(in);%
        H{i}=newH{i};  %           
        states{i}(n,:) = H{i}(:);
        %states{i}(n-1,:) = oldH{i}(:); %
  
    end
end

%need to check! deplex to get states
for i= 1:config.num_reservoirs
    if individual.time_period(i) > 1
        states{i} = states{i}(mod(1:size(states{i},1),individual.time_period(i)) == 1,:);
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

% get rid off bad sims
final_states(final_states > 100 | final_states < -100) = 0;

% concat input states
if config.add_input_states == 1
    final_states = [final_states input_sequence];
end

if size(input_sequence,1) == 2
    final_states = final_states(end,:); % remove washout
else
    final_states = final_states(config.wash_out+1:end,:); % remove washout
end

%set(0,'currentFigure',config.figure_array(1))
% subplot(1,2,2)
% plot(input_sequence)
% subplot(1,2,1)
% plot(final_states)
% drawnow
% set(0,'currentFigure',config.figure_array(2))