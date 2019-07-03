function [substrate,config_sub,CPPN,config] =assessCPPNonSubstrate(substrate,config_sub,CPPN,config)

max_num = substrate.total_units + substrate.n_output_units + substrate.n_input_units;
min_num = 1;

switch(config_sub.res_type)
    
    case 'Graph'
        input_nodes{1,1} = substrate.w_in;
        hidden_nodes{1,1} = substrate.G.Edges.EndNodes+size(substrate.w_in,2);
        
        for i = 1:length(hidden_nodes{1,1})
            node(i).num = i;
            node(i).pos = hidden_nodes{1,1}(i,:);
        end

        for i = 1:length(hidden_nodes{1,1})
            xy1(i,:) = node(hidden_nodes{1,1}(i,1)).pos;
            xy2(i,:) = node(hidden_nodes{1,1}(i,2)).pos;
        end
        
        hidden_nodes{1,1} = [xy1 xy2];
        
    case 'ELM'
         input_nodes = [];
        
          for n = 1:size(substrate.W,1)
            for p = 1:size(substrate.W,2)
                hidden_nodes{n,p} = substrate.W{n,p}';
            end
          end        
         
    case 'RoR_IA_v2'
       
        for n = 1:size(substrate.W,1)
            input_nodes{n} = substrate.inputWeights{n};
            for p = 1:size(substrate.W,2)
                hidden_nodes{n,p} = substrate.W{n,p};
            end
        end
        
    otherwise
        
         for n = 1:size(substrate.W,1)
            input_nodes{n} = substrate.input_weights{n};
            for p = 1:size(substrate.W,2)
                hidden_nodes{n,p} = substrate.W{n,p};
            end
        end
end

%output weights always the same
output_nodes = substrate.output_weights;

%% query input weights
for n = 1:size(input_nodes,1) %loop over multiple networks/layers/reservoirs
    for p = 1:size(input_nodes,2)
        [input_sequence,input_X,input_Y] = getIndexes(input_nodes{n,p},substrate,'input',max_num,min_num);   
        % run CPPN
        [test_states,CPPN] = config.assessFcn(CPPN,input_sequence,config);
        CPPN_input_weights{n,p} = test_states*CPPN.output_weights(:,p);
    end
end

%% query hidden weights
for n = 1:size(hidden_nodes,1) %loop over multiple networks/layers/reservoirs
   for p = 1:size(hidden_nodes,2)
        if strcmp(config_sub.res_type,'Graph')
            hidden_sequence = [1 1 1 1; full(hidden_nodes{n,p})];
        else
            [hidden_sequence,hidden_X,hidden_Y]= getIndexes(full(hidden_nodes{n,p}),substrate,'hidden',max_num,min_num);
        end
        % run CPPN
        [test_states,CPPN] = config.assessFcn(CPPN,hidden_sequence,config);
        CPPN_hidden_weights{n,p} = test_states*CPPN.output_weights(:,size(input_nodes,2)+p);
   end
end

%% query output nodes
if config.evolve_output_weights
    [out_sequence] = getIndexes(output_nodes,substrate,'output',max_num,min_num);
    
    % run CPPN
    [test_states,CPPN] = config.assessFcn(CPPN,out_sequence,config);
    CPPN_output_weights = test_states*CPPN.output_weights(:,size(input_nodes,2)+size(hidden_nodes,2)+1);
    
    substrate.output_weights = CPPN_output_weights;%reshape(CPPN_output_weights,size(output_nodes));
    
end

%% reassign weights
switch(config_sub.res_type)
    
    case 'Graph'
        %reassign input
        substrate.w_in = CPPN_input_weights{1,1};
        %reassign hidden
        substrate.G.Edges.Weight = CPPN_hidden_weights{1,1};
        
       %idx2 = sub2ind(size(substrate.G.Edges.Weight), hiddenX, hiddenY);
        %substrate.G.Edges.Weight(idx2) = CPPN_hidden_weights{n,p};
                 
        A = table2array(substrate.G.Edges);
        substrate.w = zeros(size(substrate.G.Nodes,1));
        
        for j = 1:size(substrate.G.Edges,1)
            substrate.w(A(j,1),A(j,2)) = A(j,3);
        end
        
        
        
    case 'ELM'
        
         for n = 1:size(substrate.W,1)
            for p = 1:size(substrate.W,2) 
                substrate.W{n,p} = CPPN_hidden_weights{n,p}';
            end
         end
         
         
        
    case 'RoR_IA_v2'
   
        for n = 1:size(substrate.W,1)
            idx = sub2ind(size(substrate.inputWeights{n}), input_X, input_Y);
                 substrate.inputWeights{n}(idx) = CPPN_input_weights{n};
                 
            for p = 1:size(substrate.W,2)               
                 idx2 = sub2ind(size(substrate.W{n,p}), hidden_X, hidden_Y);
                 substrate.W{n,p}(idx2) = CPPN_hidden_weights{n,p};
                 
%                 for cnt = 1:length(inputX)
%                     substrate.esnMinor(n,p).inputWeights(inputX(cnt),inputY(cnt)) = CPPN_input_weights{n,p}(cnt);
%                 end
% 
%                 for cnt = 1:length(hiddenX)
%                     substrate.connectWeights{n,p}(hiddenX(cnt),hiddenY(cnt)) = CPPN_hidden_weights{n,p}(cnt);
%                 end
            end
        end
        
    otherwise
        
        for n = 1:size(substrate.W,1)
            idx = sub2ind(size(substrate.input_weights{n}), input_X, input_Y);
            substrate.input_weights{n}(idx) = CPPN_input_weights{n};
            
            for p = 1:size(substrate.W,2)
                idx2 = sub2ind(size(substrate.W{n,p}), hidden_X, hidden_Y);
                substrate.W{n,p}(idx2) = CPPN_hidden_weights{n,p};
                
            end
        end
        
end

%assess substrate on task
substrate = config_sub.testFcn(substrate,config_sub);

end

function [input_sequence, I , J] = getIndexes(sequence,substrate,type, max_num, min_num)

        if size(sequence,2) < 2
            I = ones(length(sequence),1)';
            J = (1:length(sequence));
        else
            [I,J] = ind2sub([size(sequence)],1:length(sequence(:)));
            
        end
                
        grid = [I;J]';
        
        for i = 1:length(grid)
            node(i).num = i;
            node(i).pos = grid(i,:);
        end

        for i = 1:length(I)
            xy1(i,:) = node(I(i)).pos;
            xy2(i,:) = node(J(i)).pos;
        end
        
        %inputSequence = [1 1; I' J'];
        input_sequence = [1 1 1 1; xy1 xy2];
        
        switch(type)
            case 'input'
                %blank - okay as is
               % inputSequence = inputSequence(:,1:3) -1;
            case 'hidden'
                input_sequence = input_sequence + substrate.n_input_units; %shift by num inputs
            case 'output'
                %inputSequence = [inputSequence(:,2) inputSequence(:,1)+length(inputSequence)]; %rearrange hidden nodes to outputs (index shifted by num hidden units)  
                input_sequence(:,1:3) = input_sequence(:,1:3) + substrate.n_input_units + length(input_sequence);
        end
        
          %normalise           
          input_sequence = [[input_sequence(:,1); min_num; max_num] [input_sequence(:,2); min_num; max_num] [input_sequence(:,3); min_num; max_num] [input_sequence(:,4); min_num; max_num]];
          input_sequence = mapminmax(input_sequence',-1,1);
          input_sequence = input_sequence(:,1:end-2)';

end