function [index] = findActiv(individualFcn,activ)

for i = 1:length(individualFcn)
    index(i) = isequal(activ, individualFcn{i});
end

index = find(index);