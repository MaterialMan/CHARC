function [outside,idx]=Check_bounds(EXP)
% Check if robots are outside the safety bounds
% outside = 0, ok.      outside = 1, at least 1 robot is outside the bounds
% idx   contains the indexes of robots outside bounds

switch EXP.Workspace_type
    case 0  % open space
        outside=false; idx=0;
    case 1  % unbounded region
        outside=false; idx=0;
        % TO BE DONE...
        
    case 2  % bounded polygon
        inside=inpolygon(EXP.Pose(1,:),EXP.Pose(2,:),EXP.Workspace(:,1),EXP.Workspace(:,2));
        idx=find(inside==0);
        outside=sum(idx)>0;
end
end