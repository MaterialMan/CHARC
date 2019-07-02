function esnMajor = adaptMajorWeights(esnMajor,esnMinorToChange,esnMinor,N,add)

if add
    for i = 1:esnMajor.nInternalUnits
        addWeights = sprand(esnMinor(i).nInternalUnits,1,esnMajor.InnerConnectivity);%zeros(esn.nInternalUnits,1)+
        addWeights(addWeights ~= 0) = ...
            addWeights(addWeights ~= 0)  - 0.5;
        
        %weights = esnMajor.connectWeights{esnMinorToChange,i};
        weights = esnMajor.connectWeights{i,esnMinorToChange};
%         scale = esnMajor.interResScaling{i,esnMinorToChange};
        
        if i~= esnMinorToChange
            if ~isempty(weights)
                weights = [weights(:,1:N) addWeights weights(:,N+1:end)];
%                 scale = [scale(:,1:N) addWeights scale(:,N+1:end)];
                esnMajor.connectWeights{esnMinorToChange,i} = weights'*esnMajor.interResScaling{esnMinorToChange,i};
                esnMajor.connectWeights{i,esnMinorToChange} = weights*esnMajor.interResScaling{i,esnMinorToChange};
            end
        end
    end
else
    for i = 1:esnMajor.nInternalUnits
        weights = esnMajor.connectWeights{i,esnMinorToChange};
        %weights = esnMajor.connectWeights{esnMinorToChange,i};
%         scale = esnMajor.interResScaling{i,esnMinorToChange};
        if i~= esnMinorToChange
            if ~isempty(weights)
                weights(:,N)=[];
%                 scale(:,N)=[];
%                 esnMajor.interResScaling{esnMinorToChange,i} =scale;
%                 esnMajor.interResScaling{i,esnMinorToChange}=scale;
                esnMajor.connectWeights{esnMinorToChange,i} = weights'*esnMajor.interResScaling{esnMinorToChange,i};
                esnMajor.connectWeights{i,esnMinorToChange} = weights*esnMajor.interResScaling{i,esnMinorToChange};
            end
        end
        
    end
end