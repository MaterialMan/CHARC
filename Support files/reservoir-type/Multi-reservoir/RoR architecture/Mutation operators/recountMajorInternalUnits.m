function count = recountMajorInternalUnits(esnMinor)

%recount esnMajor internal units
count = 0;
for p = 1:size(esnMinor,2)
    if esnMinor(p).nInternalUnits > 0
        count = count+1;
    end
end
