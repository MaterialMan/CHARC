%% Convert continuous input data to discrete data
function [y, q] = double2binaryInputVector(x,nbits)

if nargin < 2
    nbits = 16; %bit precision
end

q = quantizer('fixed', 'Ceiling', 'Saturate', [nbits nbits-1]);

% counter
counter=1;

% takes double, convert to char binary vector
for i = 1:nbits:size(x,2)*nbits
    B(:,i:nbits*counter) = num2bin(q,x(:,counter));
    counter = counter+1;
end

% binary char to double array
y = binStr2Array(B);
