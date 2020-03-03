%% Convert discrete (binary) data back to continuous (double) data
function y = binaryVector2doubleOutput(x,q,nbits)

if nargin < 2
    nbits = 16; %bit precision
    q = quantizer('fixed', 'Ceiling', 'Saturate', [nbits nbits-1]);
end

% convert double array to string
s = num2str(x);

% remove white spaces
s(:,isspace(s(1,:))) =[];

% counter
counter=1;

% takes double convert to char binary
for i = 1:nbits:size(x,2)
    y(:,counter) = bin2num(q,s(:,i:nbits*counter));
    counter = counter+1;
end