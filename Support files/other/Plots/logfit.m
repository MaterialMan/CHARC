%% function [slope, intercept,MSE, R2, S] = logfit(x,y,varargin)
% This function plots the data with a power law, logarithmic, exponential
% or linear fit.
%
%   logfit(X,Y,graphType),  where X is a vector and Y is a vector or a
%               matrix will plot the data with the axis scaling determined
%               by graphType as follows: graphType-> xscale, yscale
%                  loglog-> log, log
%                    logx -> log, linear
%                    logy -> linear, log
%                  linear -> linear, linear
%               A line is then fit to the scaled data in a least squares
%               sense.
%               See the 'notes' section below for help choosing a method.
% 
%   logfit(X,Y), will search through all the possible axis scalings and
%               finish with the one that incurs the least error (with error
%               measured as least squares on the linear-linear data.)
% 
%   [slope, intercept, MSE, R2, S] = logfit(X,Y,graphType), returns the following:
%                slope: The slope of the line in the log-scale units.
%            intercept: The intercept of the line in the log-scale units.
%                  MSE: The mean square error between the 'y' data and the
%                       approximation in linear units.
%                   R2: The coefficient of determination
%                    S: This is returned by 'polyfit' and it allows you to
%                       be much fancier with your error estimates in the
%                       following way: (see polyfit for more information)
%                    >> S contains fields R, df, and normr, for the
%                    >> triangular factor from a QR decomposition of the
%                    >> Vandermonde matrix of x, the degrees of freedom,
%                    >> and the norm of the residuals, respectively. If the
%                    >> data y are random, an estimate of the covariance
%                    >> matrix of p is (Rinv*Rinv')*normr^2/df, where Rinv
%                    >> is the inverse of R. If the errors in the data y
%                    >> are independent normal with constant variance,
%                    >> polyval produces error bounds that contain at least
%                    >> 50% of the predictions.
% 
%   [graphType, slope, intercept, MSE, R2, S] = logfit(X,Y), if you choose
%                       not to pass a 'graphType' variable, then it will go
%                       ahead and select the one with the least square
%                       error. The firt parameter returned will be the
%                       graphType, with the following parameters in the
%                       usual order.
%               
%   logfit(X,Y,'PropertyName',PropertyValue), or
%   logfit(X,Y,graphType,'PropertyName',PropertyValue)
% 
%               see parameter options below
%__________________________________________________________________________ 
% USER PARAMETERS:
% 
% For skipping part of the data set:
%       'skip': skip 'n' rows from the beginning of the data set when
%               calculating the linear fit. Must be integer. Pass a negative
%               number to skip rows from the end instead of from the
%               beginning. All points will be plotted. 'num2skip'
%  'skipBegin': skip 'n' rows from the beginning when calculating the
%               linear fit similar to skip n. 'beginSkip'
%    'skipEnd': skip 'n' rows from the end, similar to skip -n 'endSkip'
% 
%__________________________________________________________________________ 
% For plotting in different styles
%   'fontsize': The fontsize of the axis, for axis tick labels and legend.
%               'font','fsize'
% 'markersize': The size of the marker for the points, 
% 'markertype': The type of marker for the points, such as 'o--' or '.r'
%               'markerstyle','markertype','marker'
% 
%  'linewidth': The width of the dashed line for the approximation
% 
%       'ftir': The approximation is plotted for a range around the
%               endpoints of the data set. By default it is 1/20 of the
%               range of the points. You may change this default by using
%               this parameter.
%               'fraction_to_increase_range','fractiontoincreaserange'
%__________________________________________________________________________ 
% Note the following sytax may also be used to specify 'graphtype'
%         'loglog','log','powerlaw'
%         'logx','logarithmic'
%         'logy','exponential','exp'
%         'linear','lin'
%__________________________________________________________________________ 
% Notes:
% The notes here will explain what the output means in terms of fitting
% functions depending on which method you use,
% 
% A power law relationship
% [slope, intercept] = logfit(x,y,'loglog');
%            yApprox = (10^intercept)*x.^(slope);
% 
% An exponential relationship
% [slope, intercept] = logfit(x,y,'logy');
%            yApprox = (10^intercept)*(10^slope).^x;
% 
% A logarithmic relationship
% [slope, intercept] = logfit(x,y,'logx');
%            yApprox = (intercept)+(slope)*log10(x);
% 
% A linear relationship
% [slope, intercept] = logfit(x,y,'linear');
%            yApprox = (intercept)+(slope)*x;
% 
%__________________________________________________________________________ 
% Examples:
% A power law, power 'a'
% a=2;
% x=(1:20)+rand(1,20); y=x.^a;
% power = logfit(x,y);
% % 
% A exponential relationship 
% a=3; x=(1:30)+10*rand(1,30); y=a.^x+100*rand(1,30);
% [graphType a] = logfit(x,y)
% base = 10^(a)
% 
% Thanks to Aptima inc. for  for giving me a reason to write this function.
% Thanks to Avi and Eli for help with designing and testing logfit.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jonathan Lansey updated 2013,                                           %
%                   questions/comments welcome to Lansey at gmail.com     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [slope, intercept,MSE, R2, S, extra] = logfit(x,y,varargin)
% The 'extra' is here in case 'graphtype' is not passed and needs to be
% returned.
extra=[];
%% Check user inputed graphType, and standardize its value
k=1;
if isempty(varargin)
    [slope, intercept,MSE, R2, S, extra] = findBestFit(x,y);
    return;
    
else % interpret all these possible user parameters here, so we can be more specific later.
    switch lower(varargin{1}); % make all lowercase in case someone put in something different.
        case {'logy','exponential','exp'}
            graphType = 'logy';
        case {'logx','logarithmic'}
            graphType = 'logx';
        case {'loglog','log','powerlaw'}
            graphType = 'loglog';
        case {'linear','lin'}
            graphType = 'linear';
        otherwise            
            [slope, intercept, MSE, R2, S, extra] = findBestFit(x,y,varargin{:});
            return;
    end
    k=k+1; % will usually look at varargin{2} later because of this
    
    markerColor = varargin{2};
    markerType = varargin{3};
end
%% Set dynamic marker type defaults
% for example, 'o' or '.' as well as size
yIsMatrixFlag = size(y,1)>1 && size(y,2)>1; % There is more than one data point per x value
markerSize=5;
%markerType = '.';

%markerColor = [0 0 0];

if ~yIsMatrixFlag % check how many points there are
    if length(y)<80 % relatively few points
        %markerType = 'o';
        markerSize=5;
    %   the following will overwrite markersize
        if length(y)<30 % this number '30' is completely arbitrary
            markerSize=5; % this '12' is also rather arbitrary
        end
%   else % there are many points, keep above defaults
%         lineWidth=1;
%         markerSize=5;
    end
end
% markerLineWidth is always 2.
%% Set static some defaults
% before interpreting user parameters.
fSize=15;
num2skip=0; skipBegin = 0; skipEnd=0;
ftir=20; %  = fraction_To_Increase_Range, for increasing where the green line is plotted
lineColor = markerColor;%[.3 .7 .3]; % color of the line
lineWidth= 1;  % width of the approximate line
lineStyle = '--';
%% Interpret extra user parameters
while k <= length(varargin) && ischar(varargin{k})
    switch (lower(varargin{k}))
%       skipping points from beginning or end        
        case {'skip','num2skip'}
            num2skip = varargin{k+1};
            k = k + 1;
        case {'skipbegin','beginskip'}
            skipBegin = varargin{k+1};
            k = k + 1;
        case {'skipend','endskip'}
            skipEnd = varargin{k+1};
            k = k + 1;
%       Adjust font size
        case {'fontsize','font','fsize'}
            fSize = varargin{k+1};
            k = k+1;
%       Approx, line plotting
        case {'ftir','fraction_to_increase_range','fractiontoincreaserange'}
            ftir = varargin{k+1};
            k = k+1;
            
%       Plotting style parameters        
        case {'color'}
            markerColor = varargin{k+1};
            lineColor = varargin{k+1};
            k = k + 1;
        case {'markersize'}
            markerSize = varargin{k+1}; %forceMarkerSizeFlag=1;
            k = k + 1;
        case {'markercolor'}
            markerColor = varargin{k+1};
            k = k + 1;
        case {'markertype','markerstyle','marker'}
            markerType = varargin{k+1}; %forceMarkerTypeFlag=1;
            k = k+1;
        case {'linecolor'}
            lineColor = varargin{k+1};
            k = k+1;
        case {'linestyle'}
            lineStyle = varargin{k+1};
            k = k+1;
        case 'linewidth'
            lineWidth = varargin{k+1};
            k = k+1;
        otherwise
            warning(['user entered parameter ''' varargin{k} ''' not recognized']);
    end
    k = k + 1;
end
%% Checks for user mistakes in input
% data size and skip related errors/warnings
    % Check they skipped an integer number of rows.
    if round(skipBegin)~=skipBegin || round(skipEnd)~=skipEnd || round(num2skip)~=num2skip 
        error('you can only skip an integer number of data rows');
    end
    if (skipEnd~=0 || skipBegin~=0) && num2skip~=0
        warning('you have entered ambigious parameter settings, ''skipBegin'' and ''skipEnd'' will take priority');
        num2skip=0;
    end
    if num2skip>0
        skipBegin=num2skip;
    elseif num2skip<0
        skipEnd=-num2skip;
    % else
    %     num2skip==0; % so do nothing
    end
    % Check that the user has not skipped all of his/her data
    if length(x)<1+skipEnd+skipBegin
        error('you don''t have enough points to compute a linear fit');
    end
    if length(x)<3+skipEnd+skipBegin
        warning('your data are meaningless, please go collect more points');
    end
    
% Data formatting errors and warnings    
    % Check that 'x' is a vector
    if size(x,1)>1 && size(x,2)>1 % something is wrong
        error('Your x values must be a vector, it cannot be a matrix');
    end
    if yIsMatrixFlag % There is more than one data point per x value
        if size(y,1)~=length(x)
            error('the length of ''x'' must equal the number of rows in y');
        end
    else % y and x must be vectors by now
        if length(x)~=length(y)
            error('the length of ''x'' must equal the length of y');
        end
    end
    
    if ~isnumeric(markerSize)
        error('marker size must be numeric');
    end
% Helpful warning
    if markerSize<=1
        warning(['Your grandma will probably not be able to read your plot, '...
                 'the markersize is just too small!']);
    end
%% Prepare y data by making it a properly oriented vector
% skip rows as requested and create standard vectors (sometimes from matrices)
x=x(:);
x2fit=x(skipBegin+1:end-skipEnd);
if yIsMatrixFlag % There is more than one data point per x value
% note the '+1' so it can be used as an index value
% This is the ones that will be used for fitting, rather than for plotting.
    y2fit = y(skipBegin+1:end-skipEnd,:);
    
    [x2fit,y2fit]= linearify(x2fit,y2fit);
    [x,y]        = linearify(x,y);
else % no need to linearify further
    y=y(:);
    y2fit=y(skipBegin+1:end-skipEnd);
%     Note that 'x' is already forced to be a standard vector above
end
%% Check here for data that is zero or negative on a log scaled axis.
% This is a problem because log(z<=0) is not a real number
% This cell will remove it with a warning and helpful suggestion.
% 
% This warning can suggest you choose a different plot, or perhaps add 1 if
% your data are large enough.
% 
% Note that this is done in order, so if by removing the 'y==0' values, you
% also delete the 'x==0' values, then the 'x' warning won't show up. I
% don't think this is of any concern though.
% 
switch graphType
    case {'logy','loglog'}
        yMask=(y<=0);
        if sum(yMask)>0
            yNegMask=(y<0);
            if sum(yNegMask)>0 % there are proper negative values
                warning(['values with y<=0 were removed.'...
                         'Are you sure that ''logy'' is smart to take? '...
                         'some ''y'' values were negative in your data.']);
            
            else % just some zero values
                if sum(y<10)/length(y) < (1/2) % if less than half your data is below than 10.
                    warning(['values with y==0 were removed. '...
                             'you may wish to add +1 to your data to make these points visible.']);
                else % The numbers are pretty small, you don't want to add one.
                    warning(['values with y==0 were removed. '...
                             'Nothing you can really do about it sorry.']);
                end
                
            end
            
            y=y(~yMask); y2Mask=(y2fit<=0); y2fit=y2fit(~y2Mask);
            x=x(~yMask);                    x2fit=x2fit(~y2Mask);
%             warning('values with y<=0 were removed. It may make suggest you add 1 to your data.')
        end
end
switch graphType
    case {'logx','loglog'}
        xMask=(x<=0);
        if sum(xMask)>0
            
            xNegMask=(x<0);
            if sum(xNegMask)>0 % there are proper negative values
                warning(['values with x<=0 were removed.'...
                         'Are you sure that ''logx'' is smart to take? '...
                         'some ''x'' values were negative in your data.']);
            
            else % just some zero values
                if sum(x<10)/length(x) < (1/2) % if less than half your data is below than 10.
                    warning(['values with x==0 were removed. '...
                             'you may wish to add +1 to your data to make these points visible.']);
                else % The numbers are pretty small, you don't want to add one.
                    warning(['values with x==0 were removed. '...
                             'Nothing you can really do about it sorry.']);
                end
                
            end
            
            x=x(~xMask); x2Mask=(x2fit<=0); x2fit=x2fit(~x2Mask);
            y=y(~xMask);                    y2fit=y2fit(~x2Mask);
        end
end
%% remove NaN values since we don't need to plot those.
nansI = isnan(x+y);
if sum(nansI>0)
    warning([num2str(sum(nansI)) ' NaNs were removed from the data set']);
    x = x(~nansI);
    y = y(~nansI);
end
nansI = isnan(x2fit+y2fit);
if sum(nansI>0)
    warning([num2str(sum(nansI)) ' NaNs were removed from the data set']);
    x2fit = x2fit(~nansI);
    y2fit = y2fit(~nansI);
end
%% FUNCTION GUTS BELOW
%% set and scale the data values for linear fitting
switch graphType
    case 'logy'
        logY=log10(y2fit);
        logX=x2fit;
    case 'logx'
        logX=log10(x2fit);
        logY=y2fit;
    case 'loglog'
        logX=log10(x2fit); logY=log10(y2fit);
    case 'linear'
        logX=x2fit; logY=y2fit;
end
%% Set the range that the approximate line will be displayed for
if isempty(x2fit) || isempty(y2fit)
    warning(['cannot fit any of your points on this ' graphType ' scale']);
    slope=NaN; intercept=NaN; MSE = NaN; R2= NaN;
    S=inf; % so that this is not used.
    return;
end
range=[min(x2fit) max(x2fit)];
% make this compatible with skipping some points.... don't know how yet....
switch graphType
    case {'logx','loglog'}
        logRange=log10(range);
        totRange=diff(logRange)+10*eps; % in case its all zeros...
        logRange = [logRange(1)-totRange/ftir, logRange(2)+totRange/ftir];
        ex = linspace(logRange(1),logRange(2),100); % note this is in log10 space
    otherwise % logy, linear
        totRange=diff(range);
        range= [range(1)-totRange/ftir, range(2)+totRange/ftir];        
        ex=linspace(range(1),range(2),100);
end
%% Do the linear fitting and evaluating
[p, S] = polyfit(logX,logY,1);
yy = polyval(p,ex);
estY=polyval(p,logX); % the estimate of the 'y' value for each point.
%% rescale the approximation results for plotting
switch lower(graphType)
    case 'logy'
        yy=10.^yy;
        estY=10.^estY; logY=10.^logY;% need to do this for error estimation
    case 'logx'
        ex=10.^ex;
    case 'loglog'
        yy=10.^yy;
        ex=10.^ex;
        estY=10.^estY; logY=10.^logY;% need to do this for error estimation
    case 'linear'
%         'do nothing';
    otherwise
%         'There is no otherwise at this point';
end
%% Calculate MSE and R2
% Note that this is done after the data re-scaling is finished.
MSE = mean((logY-estY).^2); % mean squared error.
%     COVyhaty    = cov(estY,y); % = cov(estimated values, experimental values)
%     R2        = (COVyhaty(2).^2) ./(var(estY).*var(y));
%     
tmp = corrcoef(estY,y2fit).^2;
R2 = tmp(2);
    
%% Ready the axis for plotting
% create or grab an axis before setting the scales
a=gca;
set(a,'fontsize',fSize);
holdState=ishold;
%% Plot the data
% This one is just to get the legend right
plot(x,y,markerType,'markersize',markerSize,'linewidth',2,'color',markerColor);
%% Plot the approximate line
hold('on'); % in case hold off was on before
plot(ex,yy,lineStyle,'linewidth',lineWidth,'color',lineColor);
%% Plot the points
% This time again just so it appears on top of the other line.
h = plot(x,y,markerType,'markersize',markerSize,'linewidth',2,'color',markerColor);
%set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); 
%% Set the axis and to scale correctly
switch graphType
    case 'logy'
        set(a,'yscale','log');
     case 'logx'
        set(a,'xscale','log');
    case 'loglog'
        set(a,'xscale','log','yscale','log');
    case 'linear'
        set(a,'xscale','linear','yscale','linear');
end
%% Finish up some graph niceties
% fix the graph limits.
% no idea why this is always needed
axis('tight');
%legend('data',[graphType ' fit'],'location','best'); legend('boxoff');
% reset hold state
if ~holdState
    hold('off');
end
%% set output data
% before returning
slope=p(1);
intercept = p(2);
end % function logfit over
%% linearify
% This function will take a vector x, and matrix y and arrange them so that
% y is a vector where each number in the i'th row of y has the value of the
% i'th number in 'x'
% This only works when the number of rows in y equals the number of
% elements in x. The new 'x' vector will be have length(y(:)) elements
function [x,y] = linearify(x,y)
x=x(:); % just in case its not already a vector pointing this way.
x=repmat(x,size(y,2),1);
y=y(:);
% if length(y)~=length(x)
%     warning(['Look what you doin son, the length of ''x'' must equal the '...
%            'number of rows in y to make this function useful'           ]);
% end    
end
%% this checks to see which type of plot has the smallest error
% Then it will return and plot the results from the one with the least
% error. Note that 'graphType' is returned first, making all the following
% outputs shifted.
function [graphType, slope, intercept, MSE, R2, S] = findBestFit(x,y,varargin)
% List of graph types to check
testList={'loglog','logx','logy','linear'};
MSE=zeros(4,1);
warning('off'); hold('off'); % just so you don't have it repeating the warnings a million times
for ii=1:4
    [a,b,MSE(ii),R2(ii)]=logfit(x,y,testList{ii},varargin{:});
end
warning('on')
%% check for winning graphtype
% the one with the minimum error wins.
% graphType=testList(MSE==min(MSE));
graphType=testList(R2==max(R2));
switch length(graphType)
    case 1
%         no warning, nothing
    case 2
        warning([graphType{1} ' and ' graphType{2} ' had equal error, so ' graphType{1} ' was chosen)']);
    case 3
        warning([graphType{1} ', ' graphType{2} ' and ' graphType{3} ' had equal errors, so ' graphType{1} ' was chosen)']);
    otherwise
%         wow this will probably never happen
        warning(['all graph types had equal error, ' graphType{1} ' was chosen']);
end
graphType=graphType{1};
%% run it a last time to get results
[slope, intercept, MSE, R2, S]=logfit(x,y,graphType,varargin{:});
end
