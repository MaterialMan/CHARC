%% assessGOL.m
% function to collect Game of Life reservoir states. 

% This is called by the @config.assessFcn pointer.

function[final_states,individual,extra_states] = assessGOL(individual,input_sequence,config,target_output)

%if single input entry, add previous state
if size(input_sequence,1) == 1
    input_sequence = [zeros(size(input_sequence)); input_sequence];
end

% pre-allocate state matrices
for i= 1:config.num_reservoirs
    
    node_grid_size(i) = config.num_nodes(i);
    
    %% preassign allocate input sequence and time multiplexing
    input{i} = [input_sequence repmat(individual.bias_node(i),size(input_sequence,1),1)]*(individual.input_weights{i}*individual.input_scaling(i))';
    
    % time multiplex -
    input_mul{i} = zeros(size(input_sequence,1)*individual.time_period(i),size(input{i},2));
    if individual.time_period > 1
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
    
    if size(input_sequence,1) == 2
        states{i} = individual.last_state{i};
    else
        %width =2;
        %states{i} = zeros(size(input_mul{i},1),(sqrt(individual.nodes(i))/width).^2);
    
        extra_states = zeros(size(input_mul{i},1),individual.nodes(i));    
        % without averaging
        %states{i} = zeros(size(input_mul{i},1),individual.nodes(i));    
    end
    
    % pre-assign anything that can be calculated before running the reservoir
    prev_mat{i} = zeros(node_grid_size(i),node_grid_size(i));
    prev_mat{i}= Bnd(prev_mat{i},individual.boundary_condition(i));
    [d1,d2]=size(prev_mat{i});
    nxt_mat{i}=prev_mat{i};
end

% Calculate reservoir states - general state equation for multi-reservoir system: x(n) = f(Win*u(n) + S)
for n = 2:size(input_mul{i},1)
    
    for i= 1:config.num_reservoirs % cycle through sub-reservoirs
        
        % *for later use with more reservoirs
        %         for k= 1:config.num_reservoirs % collect previous states of all sub-reservoirs and multiply them by the connecting matrices `W`
        %             x{i}(n,:) = x{i}(n,:) + ((individual.W{i,k}*individual.W_scaling(i,k))*states{k}(n-1,:)')';
        %         end
        
        % Calaculate current state when combined with input signal.
        % This line will depend on the reservoir, below is just an example:
        % ... states{i}(n,:) = individual.activ_Fcn{1}(((individual.input_weights{i}*individual.input_scaling(i))*([individual.bias_node input_sequence(n,:)])')+ x{i}(n,:)');
        
%         m = reshape(input_mul{i}(n,:),node_grid_size(i),node_grid_size(i));
%         f_pos = find(m);
%         input_matrix_2d = m;
%         for p = 1:length(f_pos)
%             t = zeros(size(m));
%             t(f_pos(p)) = m(f_pos(p));
%             [t] = adjustInputShape(t,individual.input_widths{i}(f_pos(p)));
%             input_matrix_2d = input_matrix_2d + t;
%         end
        %input_mul{i}(n,:) = input_matrix_2d(:);

        % binarised input
        I = (reshape(input_mul{i}(n,:),node_grid_size(i),node_grid_size(i)) > 0 );
        %I = input_matrix_2d;
        
        % for each cell in the CA
        for j=2:d1-1
            for k=2:d2-1
                % apply Game of life rule
                prev_mat{i}(j,k)=GOL(prev_mat{i},nxt_mat{i},j,k,individual) + I(j-1,k-1) > 0;
            end
        end
        % next state becomes current state
        nxt_mat{i}=prev_mat{i};        

        t_state = prev_mat{i}(2:end-1,2:end-1);
        extra_states(n,:) = t_state(:);
        
        % insert reduction strategy
        % convolve filter
        if individual.stride(i) ~= 1
            t_state = conv2(padarray(t_state, [individual.pad_size(i) individual.pad_size(i)]), individual.kernel{i}, 'valid');
        end
        t_state = t_state(1:individual.stride(i):end, 1:individual.stride(i):end);
        t_state(t_state ~= 0) = 2*t_state(t_state ~= 0)-1;
        
        % sum blocks
        %t_state = sepblockfun(t_state,[width  width],@sum)/width.^2;
    
        states{i}(n,:) = double(t_state(:));  
    end
    
end

%need to check! deplex to get states
for i= 1:config.num_reservoirs
    if individual.time_period(i) > 1
        states{i} = states{i}(mod(1:size(states{i},1),individual.time_period(i)) == 1,:);
    end
end


% Add leak states, if used
if config.leak_on
    states = getLeakStates(states,individual,input_sequence,config);
end

% Concat all states for output weights
final_states = [];
for i= 1:config.num_reservoirs
    final_states = [final_states states{i}];
    
    %assign last state variable
    individual.last_state{i} = states{i}(end,:);
end

% Concat input states
if config.add_input_states == 1
    final_states = [final_states input_sequence];
end

% Remove washout and output final states
final_states = final_states(config.wash_out+1:end,:);


%==========================================
%   Game of Life Rules
%==========================================
function s=GOL(A,B,i,j,individual)
% game of life rule
sm=0;
% count number of alive neighbors
sm=sm+ B(i-1,j-1)+B(i-1,j)+B(i-1,j+1);
sm=sm+ B(i,j-1)+           B(i,j+1);
sm=sm+ B(i+1,j-1)+B(i+1,j)+B(i+1,j+1);

% compute the new state of the current cell
s=B(i,j);
if B(i,j)==1 %
    if (sm>individual.loneliness_threshold)&&(sm<(individual.loneliness_threshold + individual.overcrowding_threshold)) % survival
        s=1;
    else % lonliness and overcrowding
        s=0 ;
    end
else
    if sm==individual.birth_threshold % birth
        s=1;
    end
end

%==========================================
%   Boundary Type
%==========================================
function bA= Bnd(A,k)
% add new four vectors based on boundary type
[d1, d2]=size(A);
d1=d1+2; d2=d2+2;
X=ones(d1,d2);
X=imbinarize(X);
X(2:d1-1,2:d2-1)=A;
%imshow(X);
%whos A X
if k==0 % Reflection
    X(  1  , 2:d2-1)=A(end , :);
    X(  d1 , 2:d2-1)=A( 1  , :);
    X( 2:d1-1 , 1  )=A(: , end);
    X( 2:d1-1 , d2 )=A(: ,  1 );
    
    X(1,1)    =A(end,end);
    X(1,end)  =A(end,1);
    X(end,1)  =A(1,end);
    X(end,end)=A(1,1);
elseif k==1 % Double
    X(  1  , 2:d2-1)=A( 1  , :);
    X(  d1 , 2:d2-1)=A(end , :);
    X( 2:d1-1 , 1  )=A(: ,  1 );
    X( 2:d1-1 , d2 )=A(: , end);
    
    X(1,1)    =A(end,1);
    X(1,end)  =A(end,end);
    X(end,1)  =A(1,1);
    X(end,end)=A(1,end);
else % k==2 % zeros
    X(  1  ,:)=0;
    X( end ,:)=0;
    X(: ,  1  )=0;
    X(: , end )=0;
end
bA=X;
