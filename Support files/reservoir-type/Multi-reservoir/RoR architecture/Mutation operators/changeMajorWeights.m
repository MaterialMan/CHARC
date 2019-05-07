function [esnMajor]= changeMajorWeights(esnMajor,esnMinorToChange,esnMinor)
% Note: new weights used to be scaled by inputScaling

%esnMajor.nInternalUnits = recountMajorInternalUnits(esnMinor);

esnMajor.InnerConnectivity = 1/esnMajor.nInternalUnits;
for i = 1:size(esnMinor,2)%esnMajor.nInternalUnits%
    if ~isempty(esnMinor(esnMinorToChange).nInternalUnits) && ~isempty(esnMinor(i).nInternalUnits)
        internalWeights = sprand(esnMinor(esnMinorToChange).nInternalUnits, esnMinor(i).nInternalUnits, esnMajor.InnerConnectivity);
        internalWeights(internalWeights ~= 0) = ...
            internalWeights(internalWeights ~= 0)  - 0.5;
        if i~= esnMinorToChange
            val = 2*rand-1;
            esnMajor.interResScaling{i,esnMinorToChange} = val;
            esnMajor.interResScaling{esnMinorToChange,i} = val;
            esnMajor.connectWeights{i,esnMinorToChange} = internalWeights'*esnMajor.interResScaling{i,esnMinorToChange};
            esnMajor.connectWeights{esnMinorToChange,i} = internalWeights*esnMajor.interResScaling{esnMinorToChange,i};
        else
            esnMajor.connectWeights{esnMinorToChange,esnMinorToChange} = esnMinor(esnMinorToChange).internalWeights;
            esnMajor.interResScaling{i,esnMinorToChange} = 1;
        end
    else
        esnMajor.connectWeights{i,esnMinorToChange} = [];        
        esnMajor.connectWeights{esnMinorToChange,i} = [];
        esnMajor.interResScaling{i,esnMinorToChange} = [];
        esnMajor.interResScaling{esnMinorToChange,i} = [];
    end
end

%esnMajor.nInternalUnits = recountMajorInternalUnits(esnMinor);