function G = torusGraph(N,self_loop,N_rings,config)
%%  N > 8 tends to visualise better

if nargin < 2
    N_rings = N;
    self_loop = 0;
else
    if nargin < 3
        N_rings = N;
    end
end

s = [];
t=[];

%rings
for i = 1:N_rings
    s(i,:) = (i-1)*N+1:i*N;
    t(i,:) = [(i-1)*N+2:i*N (i-1)*N+1];   
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
if strcmp('Moores',config.ruleType)
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
        s = [s; (j-1)*N+1:j*N];
        t = [t; (j-1)*N+1:j*N];
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