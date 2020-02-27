function [Exp_status]=Map_Plot(Exp_status)

%-- Plot obstacles
if (isfield(Exp_status,'Map')),
    V=Exp_status.Map.Obstacle;
    for h=1:length(V)
        set(Exp_status.Map.Obstacle(h).Handle_patch,'XData',V(h).Vertex(:,1),'YData',V(h).Vertex(:,2));
    end
end
%------

