function filter_states = iirFilterStates(prev_states,filter_states,individual,config)

%filter_states = zeros(size(states));
%prev_states = states;

%for n = 1:size(states,1)-1
    
    for i = 1:size(prev_states,2) %cycle through neurons
        
        % equation: x_i(n+1) = (1/a_i,0) ((sum j=0 -> K) b_i,j *
        % u_i(n-j) - (sum j=0 -> K) a_i,j * u_i(n-j))
        filter_states(i) = (individual.iir_weights{1}(i,:)*prev_states(config.iir_filter_order:-1:1,i) - individual.iir_weights{2}(i,1:end-1)*filter_states(config.iir_filter_order-1:-1:1,i))./individual.iir_weights{2}(i,1);
        
    end
%end
