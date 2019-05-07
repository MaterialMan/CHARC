
%% This is rough playaround - not sure it shows much at the moment...
% Adjacency plot and strength need adjusting.

figure1 = figure;

for n = 8:9
    
D = database_esnMajor(n).connectWeights{1,1};
G = graph(D,'upper');

% adjacency on graph
B = adjacency(G);
nn = numnodes(G);
[s,t] = findedge(G);
A = sparse(s,t,G.Edges.Weight,nn,nn);
A = A + A.' - diag(diag(A));


% complete guess, just playing around...
D = D +zeros(100,100);
N=zeros(100,100);
for i = 1:100
    for j = 1:100
        [~,N(i,:)] = knnsearch(D(i,j),D(i,:)','K',10);
        aN(i) = mean(N(i,:));
    end
end

set(0,'currentFigure',figure1)
% plot adjacency matrix
subplot(1,3,1)
imagesc(A)
title('Adjacency')
colormap(gca,bluewhitered)

%plot original weights
subplot(1,3,2)
imagesc(D)
title('Original')
colormap(gca,bluewhitered)

%plot strength of connectivity??
subplot(1,3,3)
imagesc(A.*(aN'*aN))
title('Strength')
colormap(gca,bluewhitered)
pause(2)
end


