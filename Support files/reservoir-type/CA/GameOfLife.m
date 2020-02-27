function GameOfLife
% This is a simple simulation of Conway Game of life GoL
% it is good for understanding Cellular Automata (CA) concept
% GoL Rules:
%   1. Survival: an alive cell live if it has 2 or 3 alive neighbors
%   2. Birth: a dead cell will be alive if it has 3 alive neighbors
%   3. Deaths: 
%        Lonless: alive cell dies if it has 0 or 1 alive neighbors    
%        Overcrowding: alive cell dies if it has 4 or more alive neighbors    
% Any questions related to CA are welcome
% By: Ibraheem Al-Dhamari
clc;
close all;

figure1 = figure;

set(0,'currentFigure',figure1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% size= 500x500 
% different random initial values
%A= rand(500,500);
%A= ones(500,500);
% periodic configuration
%A= zeros(500,500);
% A(100,200)=1;
% A(100,201)=1;
% A(100,202)=1;
% initial from image
img_size= 100;

A= zeros(img_size,img_size);
% convert to binary--> % states={0,1}
A=imbinarize(A);


%% visualize the initial states 
% disp('the binary image')
% imshow(A);
% %pause

config.discrete = 0;               % select '1' for binary input for discrete systems
config.nbits = 16;                 % only applied if config.discrete = 1; if wanting to convert data for binary/discrete systems
config.preprocess = 1;             % basic preprocessing, e.g. scaling and mean variance
config.dataset = 'narma_10_DLexample';          % Task to evolve for

config.evolve_feedback_weights = 0;
% get dataset information
config = selectDataset(config);

% boundary type: 0= reflection 
%                1= doublication
%                2= null, zeros
% this step enlarge A with 4 virtual vectors
A=Bnd(A,0); 
[d1,d2]=size(A);
disp('the extended binary image')
whos A
%imshow(A);
%pause
B=A;
t=0;
stp=false; % to stop when if no new configrations
%B is the CA in time t
%A is the CA in time t+1
%t is the number of generations 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Play ^_^
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

input_sequence = config.test_input_sequence;
config.num_nodes = size(A,1)-2;

% individual.bias_node
individual.bias_node = 1;
individual.n_input_units = size(input_sequence,2);

input_weights = sprand(config.num_nodes.^2,  individual.n_input_units+1, 0.01);
input_weights(input_weights ~= 0) = ...
    2*input_weights(input_weights ~= 0)  - 1;
individual.input_weights = input_weights;

individual.input_widths = randi([1 4],length(input_weights),1); %size of the inputs; pin-point or broad

individual.input_scaling = rand;

% modify input signal
input = [input_sequence repmat(individual.bias_node,size(input_sequence,1),1)]*(individual.input_weights*individual.input_scaling)';

% time multiplex -
% input_mul = zeros(size(input_sequence,1)*individual.time_period,size(input{i},2),size(input{i},3));
% if individual.time_period > 1
%     input_mul(mod(1:size(input_mul{i},1),individual.time_period) == 1,:,:) = input{i};
% else
input_mul = input;
%end

% change input widths
for n = 1:size(input_mul,1)
    m = reshape(input_mul(n,:),config.num_nodes,config.num_nodes);
    f_pos = find(m);
    input_matrix_2d = m;
    for p = 1:length(f_pos)
        t = zeros(size(m));
        t(f_pos(p)) = m(f_pos(p));
        [t] = adjustInputShape(t,individual.input_widths(f_pos(p)));
        input_matrix_2d = input_matrix_2d + t;
    end
    input_mul(n,:) = input_matrix_2d(:);
end

%%
colormap('bone')
t = 1;
while ~stp && (t<size(config.test_input_sequence,1)) % repeat for 10 generations
    
    I = reshape(input_mul(t,:),img_size,img_size);
    % for each cell in the CA 
    for i=2:d1-1
        for j=2:d2-1           
            % apply Game of life rule   
            A(i,j)=GOL(A,B,i,j)    +   I(i-1,j-1) > 0 ;%logical(floor(heaviside(I(i-1,j-1))))    ;
        end
    end 
    % visualize what happened
    %imshow(A);    
    imagesc(A); 
    drawnow;
%    pause
    % save B 
    if A==B
       stp=true; % no more new states
    end
    B=A;  
    t=t+1 ; 
end  

%==========================================
%   Game of Life Rules 
%==========================================
function s=GOL (A,B,i,j)
% game of life rule
sm=0;
% count number of alive neighbors
sm=sm+ B(i-1,j-1)+B(i-1,j)+B(i-1,j+1);
sm=sm+ B(i,j-1)+           B(i,j+1);
sm=sm+ B(i+1,j-1)+B(i+1,j)+B(i+1,j+1);

% compute the new state of the current cell
s=B(i,j);
if B(i,j)==1
    if (sm>1)&&(sm<4)
        s=1;
    else
        s=0 ;   
    end
else
    if sm==3
       s=1;
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
X=im2bw(X);
X(2:d1-1,2:d2-1)=A;
imshow(X);
whos A X
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
