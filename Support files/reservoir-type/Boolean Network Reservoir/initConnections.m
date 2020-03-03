function connection = initConnections(varargin)

% INITCONNECTIONS Generate N x N adjacent matrix with K incoming connections per node.
%
%   INITCONNECTIONS(N, K) generates N x N adjacent matrix (defined as in graph theory)
%   with K incoming connections per node selected at random (uniformly distributed).
%   
%   INITCONNECTIONS(N, KMIN, KMAX) generates N x N adjacent matrix (defined as in 
%   graph theory) with at average k=(KMIN + KMAX)/2 incoming connections per node 
%   selected at random (uniformly distributed). Each Node has at least KMIN and at 
%   most KMAX incoming connections per node (k ~ U[KMIN, KMAX]).
%
%   INITCONNECTIONS(CONNECTIONMATRIX) generates N x N adjacent matrix using
%   CONNECTIONMATRIX to set the incoming connections.
%
%   Input:
%       n                  - (Optional) Number of nodes
%       k                  - (Optional) Number of connections per node
%       kMin               - (Optional) Minimal number of connections per node
%       kMax               - (Optional) Maximal number of connections per node
%       connectionMatrix   - (Optional) n x n adjacent matrix
%
%   Output: 
%       connection         - n x n adjacent matrix with at average k incoming 
%                            connections per node
%


%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 4.11.2002 LastModified: 20.01.2003

% one argument: connectionMatrix
if(nargin == 1)
    connection = varargin{1};
    
% two arguments: N and K 
elseif(nargin == 2)
    
    n = varargin{1};
    k = varargin{2};
    
    if(k>n)
        error('K should be equal to or less than N')
    end
    
    connection = zeros(n,n);
    for i=1:n
        success = 0; 
        while success < k
            a=randi([1 n],1,1);
            connection([a],i) = connection([a],i) + 1;
            success = success + 1;
            %             if(connection([a],i) == 0)
            %                 connection([a],i ) = 1;    code that would be necessary for limiting connections between two
            %                 success = success +1;      nodes to one
            %           end
            
        end
    end       
    
% three arguments: N, kMin and kMax
elseif(nargin == 3)
    
    n = varargin{1};
    kMin = varargin{2};
    kMax = varargin{3};
    
    if(kMax>n)
        error('kMax should be equal to or less than N')
    end
    
    connection = zeros(n,n);
    for i=1:n
        k = randint(1,1,[kMin,kMax]);
        success = 0;
        while success < k
            a=randint(1,1,[1,n]);
            connection([a],i) = connection([a],i) + 1;
            success = success + 1;
        end
    end
    
% wrong number of arguments
else
    error('Wrong number of arguments. Type: help initConnections')
end






