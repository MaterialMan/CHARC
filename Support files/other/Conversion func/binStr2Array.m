function y = binStr2Array(x)

y=zeros(size(x));
for i = 1:size(x,1)
    for j = 1:size(x,2)
        y(i,j) = str2double(x(i,j));
    end
end

y(:,isnan(y(1,:))) = [];