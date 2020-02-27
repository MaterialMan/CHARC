function [Y] = featureNormailse(X,Type)

%Number of observations
N=length(X(:,1));

%Number of variables
M=length(X(1,:));

% output array of normalised values
Y=zeros(N,M);

switch Type
    
    case'std'
        %Subtract mean of each Column from data
        Y=X-repmat(mean(X),N,1);
        
        %normalize each observation by the standard deviation of that variable
        Y=Y./repmat(std(X,0,1),N,1);
        
    case 'scaling' % scal each column/feature to be within [0 1]
        % determine the maximum value of each colunm of an array
        Max=max(X);
        % determine the minimum value of each colunm of an array
        Min=min(X);
        %array that contains the different between the maximum and minimum value for each column
        Difference=Max-Min;    
        %subtract the minimum value for each column
        Y=X-repmat(Min,N,1);
        %Column by the difference between the maximum and minimum value 
        Y=Y./repmat(Difference,N,1);
        
        Y = 2*Y-1; %shift to [-1 1] 
        
    case 'rescale' % all scaled together within [0 1]
        Y =(X-min(min(X)))./(max(max(X))-min(min(X)));
        Y = 2*Y-1; %shift to [-1 1] 
        %Y = X*1e21;%2*Y-1; %shift to [-1 1]
        
    otherwise
        Y = X;
end
end