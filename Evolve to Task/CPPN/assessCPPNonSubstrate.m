function [substrate,config_sub,CPPN,config] =assessCPPNonSubstrate(substrate,config_sub,CPPN,config)

% get input and hidden node detials
input = substrate.input_weights{1};
%output weights always the same
output = substrate.output_weights;

%% define coordinates
%for n = 1:size(substrate.W,2)
    
    num_inputs = size(input,2);
    num_outputs = size(output,2);
    subrate_size = floor(sqrt(substrate.nodes));
    
    % define hidden nodes
    [X_grid,Y_grid] = ndgrid(linspace(-1,1,subrate_size));
    
    cnt = 1;
    for i = 1:length(X_grid)
        for j = 1:length(Y_grid)
            hidden_node(cnt).X = X_grid(i,j);
            hidden_node(cnt).Y = Y_grid(i,j);
            hidden_node(cnt).Z = 0;
            cnt = cnt+1;
        end
    end
    
    % define input nodes
    input_loc = linspace(-0.5,0.5,num_inputs);
    cnt = 1;
    for i = 1:length(input_loc)
        input_node(cnt).X = input_loc(i);
        input_node(cnt).Y = 0;
        input_node(cnt).Z = -1;
        cnt = cnt+1;
    end
    
    % define output nodes
    output_loc = linspace(-0.5,0.5,num_outputs);
    cnt = 1;
    for i = 1:length(output_loc)
        output_node(cnt).X = output_loc(i);
        output_node(cnt).Y = 0;
        output_node(cnt).Z = 1;
        cnt = cnt+1;
    end
    

% query input weights
cnt = 1; from =[]; to =[];
for i = 1:length(input_node)
    for j = 1:length(hidden_node)
        from(cnt,:) = [input_node(i).X input_node(i).Y input_node(i).Z];
        to(cnt,:) = [hidden_node(j).X hidden_node(j).Y hidden_node(j).Z];
        cnt = cnt +1;
    end
end

input_sequence = [zeros(1,6); from to];
[test_states,CPPN] = config.assessFcn(CPPN,input_sequence,config);
CPPN_input_weights = test_states*CPPN.output_weights(:,1);
substrate.input_weights{1} = reshape(CPPN_input_weights,size(input));

% query hidden weights
cnt = 1; from =[]; to =[]; d =[];
for i = 1:length(hidden_node)
    for j = 1:length(hidden_node)
        from(cnt,:) = [hidden_node(i).X hidden_node(i).Y hidden_node(i).Z];
        to(cnt,:) = [hidden_node(j).X hidden_node(j).Y hidden_node(j).Z];
        cd(cnt,:) = [i j];
        cnt = cnt +1;
    end
end

hidden_sequence = [zeros(1,6); from to];
[test_states,CPPN] = config.assessFcn(CPPN,hidden_sequence,config);
CPPN_hidden_weights = test_states*CPPN.output_weights(:,2);
%substrate.W{1} = reshape(CPPN_hidden_weights,size(substrate.W{1}));

for i = 1:length(cd)
    substrate.W{1}(cd(i,1),cd(i,2)) = CPPN_hidden_weights(i);
end

% query output weights
if config_sub.evolve_output_weights
    cnt = 1; from =[]; to =[];
    for i = 1:length(output_node)
        for j = 1:length(hidden_node)
            from(cnt,:) = [hidden_node(j).X hidden_node(j).Y hidden_node(j).Z];
            to(cnt,:) = [output_node(i).X output_node(i).Y output_node(i).Z];
            cnt = cnt +1;
        end
    end
    
    output_sequence = [ones(1,6); from to];
    [test_states,CPPN] = config.assessFcn(CPPN,output_sequence,config);
    substrate.output_weights = test_states*CPPN.output_weights(:,3);
end

%assess substrate on task
substrate = config_sub.testFcn(substrate,config_sub);

end
