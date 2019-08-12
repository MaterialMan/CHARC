function G = torusGraph(Nodes,self_loop,config)
%%  N > 8 tends to visualise better

s = [];
t=[];
N_rings = config.torus_rings;

%rings
for i = 1:N_rings
    s(i,:) = (i-1)*Nodes+1:i*Nodes;
    t(i,:) = [(i-1)*Nodes+2:i*Nodes (i-1)*Nodes+1];   
end

%connecting rings
if N_rings > 1
    for i = N_rings+1:N_rings*2-1
        s(i,:) = s(i-(N_rings-1),:);
        t(i,:) =  s(i-N_rings,:); 
    end
    
    %last ring
    s(i+1,:) = s(1,:);
    t(i+1,:) = s(i,:);
end

% looks odd if N <= N_rings
if strcmp('Moores',config.rule_type)
    for j = 1:N_rings
        %top right
        s(j+N_rings*2,:) = s(N_rings+j,:);
        t(j+N_rings*2,1:end-1) =  t(N_rings+j,1:end-1)+1;
        t(j+N_rings*2,end) =  t(j+N_rings*2,1)-1;
        
        %tbottom right
        s(j+N_rings*3,:) = s(N_rings+j,:);
        t(j+N_rings*3,2:end) =  t(N_rings+j,2:end)-1;
        t(j+N_rings*3,1) =  t(j+N_rings*3,end)+1;
        
    end
end

%add self connections
if self_loop
    for j = 1:N_rings
        s = [s; (j-1)*Nodes+1:j*Nodes];
        t = [t; (j-1)*Nodes+1:j*Nodes];
    end
end

G = graph(s(:),t(:));

%% plot torus
% figure
% h = plot(G,'Layout','subspace3')

%label nodes
% for i = 1:size(G.Nodes,1)
%     labelnode(h,i,{num2str(i)})
% end