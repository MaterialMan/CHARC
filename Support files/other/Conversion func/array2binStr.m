function y = array2binStr(x,signed,word_length,frac_length)

y =  [];

for i = 1:size(x,1)
    t=[];
    for j = 1:size(x,2)
        t = [t mat2str(x(i,j))];
    end
    y(i) = typecast(uint16(bin2dec(t)),'int16');
end

