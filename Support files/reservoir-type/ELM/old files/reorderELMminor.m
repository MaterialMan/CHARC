function [esnMinor, esnMajor] = reorderELMminor(esnMinor,esnMajor)

%construct empty struct
tempESNMinor =struct;

cnt = 1;
for i = 1:size(esnMinor,2)
    if ~isempty(esnMinor(i).nInternalUnits) %for any non-empty minors
        if cnt ==1
            tempESNMinor = esnMinor(i);

        else
            tempESNMinor(cnt) = esnMinor(i);

        end
        
        %remove all variables so new order can be inserted
        esnMinor(i).bias = [];
        esnMinor(i).nInternalUnits = [];
        cnt = cnt+1;
    end
end

%put new order in to esnMinor
esnMinor(1:size(tempESNMinor,2)) = tempESNMinor;

%cycle through and remove old connection weights
c= esnMajor.connectWeights(~cellfun('isempty',esnMajor.connectWeights));
esnMajor.connectWeights = reshape(c,size(tempESNMinor,2),size(tempESNMinor,2));

%final check of major units
esnMajor.nInternalUnits = recountMajorInternalUnits(esnMinor);
