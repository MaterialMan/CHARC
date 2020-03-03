function [Exp_status]=Map_Plot_Initialize(Exp_status)

%-- Plot obstacles
if (isfield(Exp_status,'Map')),
    V=Exp_status.Map.Obstacle;
    for h=1:length(V)
        Exp_status.Map.Obstacle(h).Handle_patch=patch(V(h).Vertex(:,1),V(h).Vertex(:,2),[.8 .8 .8]);
    end
end
%------

end

