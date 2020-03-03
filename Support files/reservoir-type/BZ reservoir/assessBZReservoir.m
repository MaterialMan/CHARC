%% assessBZReservoir.m
% BZ function to collect reservoir states. 
%
% This is called by the @config.assessFcn pointer.

function[final_states,individual] = assessBZReservoir(individual,input_sequence,config,target_output)

%if single input entry, add previous state
if size(input_sequence,1) == 1
    input_sequence = [zeros(size(input_sequence)); input_sequence];
end

% pre-allocate state matrices
for i= 1:config.num_reservoirs
    if size(input_sequence,1) == 2
        states{i} = individual.last_state{i};
    else
        states{i} = zeros(size(input_sequence,1),individual.nodes(i));
    end
    
    xres(i,:) = config.num_nodes(i);
    yres(i,:) = xres(i,:);
    
    
    %% preassign allocate input sequence and time multiplexing
    for r = 1:3
        input{i,r} = [input_sequence repmat(individual.bias_node(i),size(input_sequence,1),1)]*(individual.input_weights{i,r}*individual.input_scaling(i,r))';
        
        % time multiplex -
        input_mul{i,r} = zeros(size(input_sequence,1)*individual.time_period(i),size(input{i,r},2),size(input{i,r},3));
        if individual.time_period > 1
            input_mul{i,r}(mod(1:size(input_mul{i,r},1),individual.time_period(i)) == 1,:,:) = input{i,r};
        else
            input_mul{i,r} = input{i,r};
        end  
    end
    
    % change input widths
    for n = 1:size(input_mul{i,r},1)
        for r = 1:3
            m = reshape(input_mul{i,r}(n,:),config.num_nodes(i),config.num_nodes(i));
            f_pos = find(m);
            input_matrix_2d = m;
            for p = 1:length(f_pos)
                t = zeros(size(m));
                t(f_pos(p)) = m(f_pos(p));
                [t] = adjustInputShape(t,individual.input_widths{i,r}(f_pos(p)));
                input_matrix_2d = input_matrix_2d + t;
            end
            input_mul{i,r}(n,:) = input_matrix_2d(:);
        end
    end
        
    states{i} = zeros(size(input_mul{i},1),individual.nodes(i)*3);
end

% pre-assign anything that can be calculated before running the reservoir
img=zeros(xres,yres,3);
mm = mod((1:xres+2)+xres,xres)+1;
nn = mod((1:yres+2)+yres,yres)+1;
[mm,nn]=meshgrid(mm,nn);
idx=sub2ind([yres xres],nn(:),mm(:)); %find equivalent single index
idx=reshape(idx,[yres xres]+2); % returns an yres by xres matrix whose
%elements are taken columnwise from idx

p = 1;
q = 2;

a = individual.a;
b = individual.b;
c = individual.c;

step = 1; % update step

%% Calculate reservoir states - general state equation for multi-reservoir system: x(n) = f(Win*u(n) + S)
for n = 2:size(input_mul{1},1)
    
    for i= 1:config.num_reservoirs % cycle through sub-reservoirs
        
        %         for k= 1:config.num_reservoirs % collect previous states of all sub-reservoirs and multiply them by the connecting matrices `W`
        %             x{i}(n,:) = x{i}(n,:) + ((individual.W{i,k}*individual.W_scaling(i,k))*states{k}(n-1,:)')';
        %         end
        
        %initialise empty matrix
        c_a = zeros(xres,yres);
        c_b = zeros(xres,yres);
        c_c = zeros(xres,yres);
        
        for m=1:step:xres
            
            for nn=1:step:yres
                
                idx_temp = idx(m:m+2,:);
                idx_temp= idx_temp(:,nn:nn+2);
                idx_temp=idx_temp(:);
                
                % shift?
                if p==2
                    idx_temp=idx_temp+(xres+0)*(yres+0);
                end
                
                c_a(m,nn) =c_a(m,nn) + sum(a(idx_temp));
                c_b(m,nn) =c_b(m,nn) + sum(b(idx_temp));
                c_c(m,nn) =c_c(m,nn) + sum(c(idx_temp));
            end
        end
        
        %correction of pixel drift
        c_a = circshift(c_a,[2 2]);
        c_b = circshift(c_b,[2 2]);
        c_c = circshift(c_c,[2 2]);
        
        c_a =c_a/9.0;
        c_b =c_b/9.0;
        c_c =c_c/9.0;
        
        % apply inputs
        c_a = c_a + reshape(input_mul{i,1}(n,:),size(c_a,1),size(c_a,2));
        c_b = c_b + reshape(input_mul{i,2}(n,:),size(c_b,1),size(c_b,2));
        c_c = c_c + reshape(input_mul{i,3}(n,:),size(c_c,1),size(c_c,2));
        
        a(:,:,q) = double(uint8(255*(c_a + c_a .* (c_b - c_c))))/255;
        b(:,:,q) = double(uint8(255*(c_b + c_b .* (c_c - c_a))))/255;
        c(:,:,q) = double(uint8(255*(c_c + c_c .* (c_a - c_b))))/255;
        
        img(:,:,1)=c(:,:,q);
        img(:,:,2)=b(:,:,q);
        img(:,:,3)=a(:,:,q);
        
        if p == 1
            p = 2; q = 1;
        else
            p = 1; q = 2;
        end
        
        if config.fft
            S = fft2(img);
            S_shift = abs(fftshift(S));
            
            dim1 = S_shift(:,:,1);
            dim2 = S_shift(:,:,2);
            dim3 = S_shift(:,:,3);
            states{i}(n,:) = [dim1(:); dim2(:); dim3(:)]';
            
        else
            dim1 = img(:,:,1);
            dim2 = img(:,:,2);
            dim3 = img(:,:,3);
            states{i}(n,:) = [dim1(:); dim2(:); dim3(:)]';
        end
        
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
if size(input_sequence,1) == 2
    final_states = final_states(end,:); % remove washout
else
    final_states = final_states(config.wash_out+1:end,:); % remove washout
end