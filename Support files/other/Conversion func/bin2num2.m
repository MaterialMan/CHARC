function num = bin2num(bin,precision,endian)
%bin2num - Convert from binary float in string to number
% Converts from binary32 or binary64 IEEE 754 standards to number.
% Pass 'single' for 32 or 'double' for 64 precision,
% and 'Big' to Big-endian or 'Little' to Little-endian convention.
%
% Syntax:  num = bin2num(s)
%          num = bin2num(s,precision,endian)
%
% Inputs:
%        bin - binary float string
%  precision - 'single' (default) or 'double' precision
%     endian - endianness convention 'Big' (default) or 'Little'
%
% Outputs:
%        num - matlab number
%
%
% See also:  num2bin, bin2dec, base2dec.
% Author: Marco Borges, Ph.D. Student, Computer/Biomedical Engineer
% UFMG, PPGEE, Neurodinamica Lab, Brazil
% email address: marcoafborges@gmail.com
% Website: http://www.cpdee.ufmg.br/
% April 2015; Version: v1; Last revision: 2015-04-28
% Changelog:
%------------------------------- BEGIN CODE -------------------------------
if nargin < 2
    endian = 'Big';
    precision = 'single';
elseif nargin < 3
    endian = 'Big';
end
r = rem(length(bin),4);
if r > 0
    bin = [48*ones(1,4-r),bin];
end
n = length(bin)/4;
switch precision
    case 'single'
        if strcmp(endian,'Little')
            warning('TODO');
        end
        b = hex2dec(dec2hex(bin2dec(reshape(bin,4,n)'))');
        sign = bitget(b,32);
        exponent = bitget(b,24:31)*2.^(0:7).';
        fraction = bitget(b,1:23)*2.^(-23:-1).';
        num = (-1)^sign*(1+fraction)*2^(exponent-127);
    case 'double'
        if strcmp(endian,'Little')
            warning('TODO');
        end
        num = hex2num(dec2hex(bin2dec(reshape(bin,4,n)'))');
end
end
%-------------------------------- END CODE --------------------------------