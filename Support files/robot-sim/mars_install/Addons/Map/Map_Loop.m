function [Exp_status]=Map_Loop(Exp_status)
% Compute Obstacle_distance and Robot_distance

Pose=Exp_status.Pose;
n_robot=Exp_status.Robots;
n_object=length(Exp_status.Map.Obstacle);

%-- Compute Obstacle_distance
if (~isfield(Exp_status.Map,'Obstacle_distance')) || (~isfield(Exp_status.Map.Obstacle_distance,'Enable')) || (Exp_status.Map.Obstacle_distance.Enable==true)
    D_obstacle=[];
    for w=1:n_robot
        for k=1:n_object
            [distance,px,py]=p_poly_dist(Pose(1,w),Pose(2,w),Exp_status.Map.Obstacle(k).Vertex(:,1),Exp_status.Map.Obstacle(k).Vertex(:,2));
            D_obstacle(w,k).Min_dist=distance;
            D_obstacle(w,k).P_min=[px ; py];
        end
    end
    Exp_status.Map.Obstacle_distance=D_obstacle;
end
%------

%-- Compute Robot_distance
if (~isfield(Exp_status.Map,'Robot_distance')) || (~isfield(Exp_status.Map.Robot_distance,'Enable')) || (Exp_status.Map.Robot_distance.Enable==true)
    D_robot=zeros(n_robot,n_robot);
    for w=1:n_robot-1
        for e=w+1:n_robot
            D_robot(w,e)=norm(Pose(1:2,w)-Pose(1:2,e));
            D_robot(e,w)=D_robot(w,e);
        end
    end
    Exp_status.Map.Robot_distance=D_robot;
end
%------

end


