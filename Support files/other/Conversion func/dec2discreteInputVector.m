%% convert a decimal into a disctrete binary vector
% x = value
% s = signed property
% w = n-bit word length
% f = fraction length

function y = dec2discreteInputVector(x,s,w,f)

if nargin < 2
       data = fi(x); %returns a signed fixed-point object with value v, 16-bit word length, and best-precision fraction length when v is a double.
else
    data = fi(x,s,w,f); % returns a fixed-point object with value v, Signed property value s, word length w, and fraction length f. Fraction length can be greater than word length or negative
end
binary_form = bin(data);

%convert to input array
y = binStr2Array(binary_form);

%remove leftover NaNs
y(:,isnan(y(1,:))) = [];
