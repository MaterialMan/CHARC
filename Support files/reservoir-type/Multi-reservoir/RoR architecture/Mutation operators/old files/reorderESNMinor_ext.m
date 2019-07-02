function [esnMinor, esnMajor] = reorderESNMinor_ext(esnMinor,esnMajor)

%construct empty struct
tempESNMinor =struct;
%tempESNMinor= esnMinor(1);
%esnMinor(1) = removeMinorValues_ext(esnMinor(1));
cnt = 1;
for i = 1:size(esnMinor,2)
    if ~isempty(esnMinor(i).nInternalUnits) %for any non-empty minors
        if cnt ==1
            tempESNMinor = esnMinor(i);

        else
            tempESNMinor(cnt) = esnMinor(i);

        end
        %remove all variables so new order can be inserted
        esnMinor(i) = removeMinorValues_ext(esnMinor(i));
        cnt = cnt+1;
    end
end

%put new order in to esnMinor
esnMinor(1:size(tempESNMinor,2)) = tempESNMinor;

%cycle through and remove old connection weights
c= esnMajor.connectWeights(~cellfun('isempty',esnMajor.connectWeights));
esnMajor.connectWeights = reshape(c,size(tempESNMinor,2),size(tempESNMinor,2));

%update scaling?
u= esnMajor.interResScaling(~cellfun('isempty',esnMajor.interResScaling));
esnMajor.interResScaling = reshape(u,size(tempESNMinor,2),size(tempESNMinor,2));

%final check of major units
esnMajor.nInternalUnits = recountMajorInternalUnits(esnMinor);
