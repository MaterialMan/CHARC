function rule = initRules(varargin)

% INITRULES Generate a 2^k x n or 2^kMax x n matrix containing logic transition 
% rules for each node.
%   
%   INITRULES(N,K) generates a 2^K x N matrix defining logic transition rules 
%   for each of the N nodes. A node with K incoming connections has 2^K possible 
%   input vectors. Corresponding output (0 or 1) for each input vector is assigned 
%   at random.
%
%   INITRULES(RULESMATRIX) assigns given RULESMATRIX to rule.
%
%   INITRULES(N, KMIN, KMAX, CONNECTIONMATRIX) generates a 2^KMAX x N matrix defining 
%   logic transition rules for each of the N nodes. KMIN and KMAX define the minimum/
%   maximum incoming connections per node. The actual number of incoming connections 
%   is determined by inspection of CONNECTIONMATRIX.
%
%
%   Inputs:
%       n                  - (Optional) Number of nodes
%       k                  - (Optional) Number of connections per node
%       kMin               - (Optional) Minimal number of connections per node
%       kMax               - (Optional) Maximal number of connections per node
%       rulesMatrix        - (Optional) 2^k x n matrix containing logic transition rules for each node
%       connectionMatrix   - (Optional) n x n adjacent matrix (defined as in graph theory)
%
%   Output: 
%       rule                - 2^k x n (2^kMax x n) matrix containing transition logic rules for each node
%


%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 6.11.2002 LastModified: 20.01.2003

% one argument: rulesMatrix
if(nargin == 1)
    
    rule = int8(varargin{1});
    
% two arguments: n,k
elseif(nargin == 2)
    
    n = varargin{1};
    k = varargin{2};
    rule = int8(randi([0,1],2^k,n));    
    
% four arguments: n,kMin,kMax,connectionMatrix
elseif(nargin == 4)
    
    n = varargin{1};
    kMin = varargin{2};
    kMax = varargin{3};
    connectionMatrix = varargin{4};
    
    rule = int8(zeros(2^kMax,n));
    for i=1:n
        s = sum(connectionMatrix(:,i));        
        rule(:,i)= [randi([0,1],1,2^s) zeros(1,2^kMax-2^s)]';       
    end
    
else
    error('Wrong number of arguments. Type: help initRules')
end
