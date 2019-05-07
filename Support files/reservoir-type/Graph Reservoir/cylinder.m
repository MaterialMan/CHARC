s = [];
t=[];
N = 8;
N_rings =N;

%rings
for i = 1:N_rings
    s(i,:) = (i-1)*N+1:i*N;
    t(i,:) = [(i-1)*N+2:i*N (i-1)*N+1];   
end

%connecting rings
for i = N_rings+1:N_rings*2-1
    s(i,:) = s(i-(N_rings-1),:);
    t(i,:) =  s(i-N_rings,:);   
end
%last ring
s(i+1,:) = s(1,:);
t(i+1,:) = s(i,:);

G = graph(s(:),t(:));
plot(G,'Layout','subspace3')

%plot(G)