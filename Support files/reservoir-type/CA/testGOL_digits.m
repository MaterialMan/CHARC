%clearvars -except population

function testGOL_digits(population)

individual = population(1);

load('handDigits.mat');

node_grid_size = 20;



individual.birth_threshold = 3; % a dead cell will be alive if it has n alive neighbors, Conways: 3
individual.loneliness_threshold = 1; %alive cell dies if it has n alive neighbors, Conways: 1
individual.overcrowding_threshold = 3; %alive cell dies if it has n or more alive neighbors, Conways: 4
      
for digit = 1:100:length(X)
    
    I = zeros(20);
    %I((X(randi([1 length(X)]),:) > 0.5)) = 1;
    I((X(digit,:) > 0.5)) = 1;
    subplot(1,2,1)
    imagesc(I)

    prev_mat = zeros(node_grid_size,node_grid_size);
nxt_mat=prev_mat;
[d1,d2]=size(prev_mat);
prev_mat= Bnd(prev_mat,individual.boundary_condition);

for n = 2:12
    
    % binarised input
    if n == 10
        t_I = (reshape(I,node_grid_size,node_grid_size) > 0);
    else
        t_I = zeros(20);
    end
    
    % for each cell in the CA
    for j=2:d1-1
        for k=2:d2-1
            % apply Game of life rule
            prev_mat(j,k)=GOL(prev_mat,nxt_mat,j,k,individual) + t_I(j-1,k-1) > 0;
        end
    end
    % next state becomes current state
    nxt_mat=prev_mat;
    
    states(n,:) = prev_mat(:);
    
    subplot(1,2,2)
    imagesc(prev_mat)
    drawnow
end
end
end

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

end