function states = getLeakStates(states,individual,input_sequence,config)

for i= 1:config.num_reservoirs
    leak_states = zeros(size(states{i}));
    for n = 2:size(input_sequence,1)
        leak_states(n,:) = (1-individual.leak_rate(i))*leak_states(n-1,:)+ individual.leak_rate(i)*states{i}(n,:);
    end
    states{i} = leak_states;
end